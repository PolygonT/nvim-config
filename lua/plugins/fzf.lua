return {
    {
        "ibhagwan/fzf-lua",
        -- optional for icon support
        dependencies = { "nvim-tree/nvim-web-devicons" },
        -- or if using mini.icons/mini.nvim
        -- dependencies = { "echasnovski/mini.icons" },
        opts = {},
        config = function()
            local fzf = require('fzf-lua')
            -- local actions = require('fzf-lua.actions')

            vim.keymap.set('n', '<leader>pf', fzf.files, {})
            -- vim.keymap.set('n', '<leader>pg', fzf.live_grep, {})
            vim.keymap.set('n', '<leader>psf', fzf.git_files, {})
            -- vim.keymap.set('n', '<leader>pc', fzf.current_buffer_fuzzy_find, {})
            vim.keymap.set('n', '<leader>pg', fzf.live_grep, {})
            vim.keymap.set('n', '<leader>pb', fzf.buffers, {})
            vim.keymap.set('n', '<leader>ph', fzf.helptags, {})
            vim.keymap.set('n', '<leader>pic', fzf.git_commits, {})
            vim.keymap.set('n', '<leader>pih', fzf.git_bcommits, {})
            vim.keymap.set('n', '<leader>pid', fzf.git_status, {})
            vim.keymap.set('n', '<leader>pib', fzf.git_branches, {})
            vim.keymap.set('n', '<leader>pis', fzf.git_stash, {})

            local diff_view = function(selected, opts)
                if not selected[1] then return end

                local commit_hash
                if type(opts.fn_match_commit_hash) == "function" then
                    commit_hash = opts.fn_match_commit_hash(selected[1], opts)
                else
                    commit_hash = selected[1]:match("[^ ]+")
                end

                vim.cmd("DiffviewOpen " .. commit_hash .. "^!")

            end

            fzf.setup{
                -- MISC GLOBAL SETUP OPTIONS, SEE BELOW
                -- fzf_bin = ...,
                -- each of these options can also be passed as function that return options table
                -- e.g. winopts = function() return { ... } end
                keymap = {
                    -- Below are the default binds, setting any value in these tables will override
                    -- the defaults, to inherit from the defaults change [1] from `false` to `true`
                    builtin = {
                        -- neovim `:tmap` mappings for the fzf win
                        -- true,        -- uncomment to inherit all the below in your custom config
                        ["<M-Esc>"]     = "hide",     -- hide fzf-lua, `:FzfLua resume` to continue
                        ["<F1>"]        = "toggle-help",
                        ["<F2>"]        = "toggle-fullscreen",
                        -- Only valid with the 'builtin' previewer
                        ["<F3>"]        = "toggle-preview-wrap",
                        ["<F4>"]        = "toggle-preview",
                        -- Rotate preview clockwise/counter-clockwise
                        ["<F5>"]        = "toggle-preview-ccw",
                        ["<F6>"]        = "toggle-preview-cw",
                        -- `ts-ctx` binds require `nvim-treesitter-context`
                        ["<F7>"]        = "toggle-preview-ts-ctx",
                        ["<F8>"]        = "preview-ts-ctx-dec",
                        ["<F9>"]        = "preview-ts-ctx-inc",
                        ["<S-Left>"]    = "preview-reset",
                        ["<S-down>"]    = "preview-page-down",
                        ["<S-up>"]      = "preview-page-up",
                        -- <C-d> <ctrl-d>每个地方不同，混用会导致问题
                        ["<C-d>"]  = "preview-down",
                        ["<C-u>"]    = "preview-up",
                        -- ["<M-down>"]  = "preview-down",
                        -- ["<M-up>"]    = "preview-up",
                    },
                    fzf = {
                        -- fzf '--bind=' options
                        -- true,        -- uncomment to inherit all the below in your custom config
                        ["ctrl-z"]      = "abort",
                        -- ["ctrl-u"]      = "unix-line-discard",
                        ["ctrl-f"]      = "half-page-down",
                        ["ctrl-b"]      = "half-page-up",
                        ["ctrl-a"]      = "beginning-of-line",
                        ["ctrl-e"]      = "end-of-line",
                        ["alt-a"]       = "toggle-all",
                        ["alt-g"]       = "first",
                        ["alt-G"]       = "last",
                        -- Only valid with fzf previewers (bat/cat/git/etc)
                        ["f3"]          = "toggle-preview-wrap",
                        ["f4"]          = "toggle-preview",
                        ["shift-down"]  = "preview-page-down",
                        ["shift-up"]    = "preview-page-up",
                        ["ctrl-d"]  = "preview-down",
                        ["ctrl-u"]    = "preview-up",
                    },
                },
                -- SPECIFIC COMMAND/PICKER OPTIONS, SEE BELOW
                -- files = { ... },
                git = {
                    commits = {
                        cmd = [[git log --graph --color --pretty=format:"%C(yellow)%h%Creset ]]
                            .. [[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset"]],
                        actions = {
                            ["ctrl-e"] = {
                                fn = diff_view,
                                desc = "diff-view"
                            },
                            ["ctrl-d"] = false,
                        },
                        fn_match_commit_hash = function(line, _)
                            return line:match("[a-z0-9]+")
                        end,
                        -- preview = [[ echo {} | grep -oE "[a-f0-9]{7,}" | head -1 | xargs git show --color ]],
                        preview = [[ hash=$(echo {} | grep -oE "[a-f0-9]{7,}" | head -1); ]]
                            .. [[ if [ -z "$hash" ]; then ]]
                            .. [[ echo "Not a commit line"; ]]
                            .. [[ else ]]
                            .. [[ git show --color "$hash"; ]]
                            .. [[ fi ]]
                    },
                    bcommits = {
                        actions = {
                            ["ctrl-e"] = {
                                fn = diff_view,
                                desc = "diff-view"
                            },
                        }

                    },
                    branches = {
                        preview = [[git log --graph --pretty=format:"%C(yellow)%h %C(green)%ad %C(reset)%s %C(blue)%an%C(reset)" --date=format:"(%Y-%m-%d %H:%M)" --abbrev-commit --color {1}]]
                    },

                }
            }
        end
    }
}

