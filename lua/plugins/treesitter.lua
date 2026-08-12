-- nvim-treesitter `main` branch (the 2025 rewrite).
-- The old `require("nvim-treesitter.configs").setup{}` API no longer exists:
--   * highlight  -> vim.treesitter.start()
--   * indent     -> vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
--   * textobjects-> keymaps are set by hand, the plugin no longer owns them
-- Requires nvim 0.12+, `tree-sitter` CLI >= 0.26.1, curl and tar.

-- Parsers we never want to auto-install (was `ignore_install`)
local ignore_install = { javascript = true }

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = "main",
        lazy = false, -- the rewrite does not support lazy-loading
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")

            ts.setup({
                -- parsers + queries now live here, *not* under the plugin dir
                install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
            })

            -- cached so we don't hit the filesystem / rebuild the parser table
            -- on every single FileType event
            local installed = {}
            for _, lang in ipairs(require("nvim-treesitter.config").get_installed("parsers")) do
                installed[lang] = true
            end

            local available -- lazily filled on the first cache miss
            local function is_available(lang)
                if not available then
                    available = {}
                    for _, l in ipairs(ts.get_available()) do
                        available[l] = true
                    end
                end
                return available[lang]
            end

            -- replaces the old `highlight = { enable = true }` / `indent = { enable = true }`
            local function ts_start(buf, lang)
                if not vim.api.nvim_buf_is_valid(buf) then
                    return
                end
                pcall(vim.treesitter.start, buf, lang)
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end

            -- replaces the old `auto_install = true`
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("nvim_treesitter_start", { clear = true }),
                callback = function(ev)
                    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
                    if not lang or ignore_install[lang] then
                        return
                    end

                    if installed[lang] then
                        ts_start(ev.buf, lang)
                    elseif is_available(lang) then
                        ts.install(lang):await(function(err)
                            if err then
                                return
                            end
                            installed[lang] = true
                            vim.schedule(function()
                                ts_start(ev.buf, lang)
                            end)
                        end)
                    end
                end,
            })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        lazy = false,
        -- init = function()
        --     -- Uncomment to stop built-in ftplugins (python, lua, rust, ...) from
        --     -- shadowing the ]m / [m / ]] / [[ maps below with their own versions.
        --     vim.g.no_plugin_maps = true
        -- end,
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,

                    -- You can choose the select mode (default is charwise 'v')
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * method: eg 'v' or 'o'
                    -- and should return the mode ('v', 'V', or '<c-v>') or a table
                    -- mapping query_strings to modes.
                    selection_modes = {
                        ['@parameter.outer'] = 'v',  -- charwise
                        ['@function.outer'] = 'V',   -- linewise
                        ['@class.outer'] = '<c-v>',  -- blockwise
                    },

                    -- If you set this to `true` (default is `false`) then any textobject is
                    -- extended to include preceding or succeeding whitespace. Succeeding
                    -- whitespace has priority in order to act similarly to eg the built-in
                    -- `ap`.
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * selection_mode: eg 'v'
                    -- and should return true of false
                    include_surrounding_whitespace = true,
                },

                move = {
                    set_jumps = true, -- whether to set jumps in the jumplist
                },
            })

            local select = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")
            local swap = require("nvim-treesitter-textobjects.swap")
            local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

            -- ============= select =============
            -- You can use the capture groups defined in textobjects.scm
            local selects = {
                ["af"] = { "@function.outer", "textobjects", "Select outer part of a function" },
                ["if"] = { "@function.inner", "textobjects", "Select inner part of a function" },
                ["ac"] = { "@class.outer", "textobjects", "Select outer part of a class region" },
                ["ic"] = { "@class.inner", "textobjects", "Select inner part of a class region" },
                ["il"] = { "@loop.inner", "textobjects", "Select inner part of a loop" },
                ["al"] = { "@loop.outer", "textobjects", "Select outer part of a loop" },
                -- You can also use captures from other query groups like `locals.scm`
                -- NOTE: `@scope` was renamed to `@local.scope` in the rewrite
                ["as"] = { "@local.scope", "locals", "Select language scope" },
            }
            for lhs, spec in pairs(selects) do
                vim.keymap.set({ "x", "o" }, lhs, function()
                    select.select_textobject(spec[1], spec[2])
                end, { desc = spec[3] })
            end

            -- ============= swap =============
            vim.keymap.set("n", "<leader>l", function()
                swap.swap_next("@parameter.inner")
            end, { desc = "Swap with next parameter" })
            vim.keymap.set("n", "<leader>h", function()
                swap.swap_previous("@parameter.inner")
            end, { desc = "Swap with previous parameter" })

            -- ============= move =============
            -- These are repeatable with ; and , out of the box.
            local moves = {
                goto_next_start = {
                    ["]m"] = { "@function.outer", "textobjects", "Next function start" },
                    ["]a"] = { "@parameter.inner", "textobjects", "Next parameter start" },
                    ["]]"] = { "@class.outer", "textobjects", "Next class start" },
                    ["]l"] = { "@loop.outer", "textobjects", "Next loop start" },
                    -- You can pass a query group to use a query from
                    -- `queries/<lang>/<query_group>.scm` in your runtime path.
                    ["]s"] = { "@local.scope", "locals", "Next scope" },
                    ["]z"] = { "@fold", "folds", "Next fold" },
                },
                goto_next_end = {
                    ["]M"] = { "@function.outer", "textobjects", "Next function end" },
                    ["]["] = { "@class.outer", "textobjects", "Next class end" },
                },
                goto_previous_start = {
                    ["[m"] = { "@function.outer", "textobjects", "Previous function start" },
                    ["[a"] = { "@parameter.inner", "textobjects", "Previous parameter start" },
                    ["[["] = { "@class.outer", "textobjects", "Previous class start" },
                    ["[l"] = { "@loop.outer", "textobjects", "Previous loop start" },
                },
                goto_previous_end = {
                    ["[M"] = { "@function.outer", "textobjects", "Previous function end" },
                    ["[]"] = { "@class.outer", "textobjects", "Previous class end" },
                },
                -- Go to either the start or the end, whichever is closer.
                -- Use if you want more granular movements.
                goto_next = {
                    ["]d"] = { "@conditional.outer", "textobjects", "Next conditional" },
                },
                goto_previous = {
                    ["[d"] = { "@conditional.outer", "textobjects", "Previous conditional" },
                },
            }
            for fn_name, maps in pairs(moves) do
                local fn = move[fn_name]
                for lhs, spec in pairs(maps) do
                    vim.keymap.set({ "n", "x", "o" }, lhs, function()
                        fn(spec[1], spec[2])
                    end, { desc = spec[3] })
                end
            end

            -- =============make ]c ]x zj zk repeat move================
            -- `make_repeatable_move_pair` is gone in the rewrite; build the pair
            -- ourselves out of the single-function `make_repeatable_move`.
            local function make_repeatable_move_pair(next_fn, prev_fn)
                local repeatable = ts_repeat_move.make_repeatable_move(function(opts)
                    if opts.forward then
                        next_fn()
                    else
                        prev_fn()
                    end
                end)
                return function() repeatable({ forward = true }) end,
                    function() repeatable({ forward = false }) end
            end

            local diffview_actions = require("diffview.actions")
            local function next_diff()
                vim.cmd.normal({ "]c", bang = true })
            end

            local function prev_diff()
                vim.cmd.normal({ "[c", bang = true })
            end

            local function next_fold()
                vim.cmd.normal({ "zj", bang = true })
            end

            local function prev_fold()
                vim.cmd.normal({ "zk", bang = true })
            end

            local next_diff_repeat, prev_diff_repeat =
                make_repeatable_move_pair(next_diff, prev_diff)

            local next_conflict_marker_repeat, prev_conflict_marker_repeat =
                make_repeatable_move_pair(
                    diffview_actions.next_conflict,
                    diffview_actions.prev_conflict
                )

            local next_fold_repeat, prev_fold_repeat =
                make_repeatable_move_pair(next_fold, prev_fold)

            vim.keymap.set("n", "]c", next_diff_repeat)
            vim.keymap.set("n", "[c", prev_diff_repeat)
            -- vim.keymap.set("n", "]x", next_conflict_marker_repeat)
            -- vim.keymap.set("n", "[x", prev_conflict_marker_repeat)
            require("diffview").setup({
                keymaps = {
                    view = {
                        ["]x"] = function()
                            next_conflict_marker_repeat()
                        end,
                        ["[x"] = function()
                            prev_conflict_marker_repeat()
                        end,
                    },
                },
            })
            vim.keymap.set("n", "zj", next_fold_repeat)
            vim.keymap.set("n", "zk", prev_fold_repeat)

            -- ===================================================

            -- Repeat movement with ; and ,
            -- ensure ; goes forward and , goes backward regardless of the last direction
            vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
            vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

            -- vim way: ; goes to the direction you were moving.
            -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
            -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

            -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
            -- NOTE: these are `_expr` functions now and must be mapped with { expr = true }
            vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
            vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
            vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
            vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "VeryLazy",
        opts = {
            max_lines = 0,
        },
    }
}
