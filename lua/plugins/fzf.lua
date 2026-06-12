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
            fzf.register_ui_select()

            local function get_visual_selection()
                local saved_reg = vim.fn.getreg('"')
                vim.cmd('noautocmd normal! "vy')
                local sel = vim.fn.getreg('v')
                vim.fn.setreg('"', saved_reg)
                return (sel:gsub('\n', ' '):gsub('^%s+', ''):gsub('%s+$', ''))
            end

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

            vim.keymap.set('v', '<leader>pf', function() fzf.files({ query = get_visual_selection() }) end, {})
            vim.keymap.set('v', '<leader>pg', fzf.grep_visual, {})

            local diff_view = function(selected, opts)
                if not selected[1] then return end

                local function hash_of(entry)
                    if type(opts.fn_match_commit_hash) == "function" then
                        return opts.fn_match_commit_hash(entry, opts)
                    end
                    return entry:match("[^ ]+")
                end

                -- collect the commit hash of every marked entry
                local hashes = {}
                for _, entry in ipairs(selected) do
                    local h = hash_of(entry)
                    if h and #h > 0 then hashes[#hashes + 1] = h end
                end
                if #hashes == 0 then return end

                -- single commit -> just that commit's own diff
                if #hashes == 1 then
                    vim.cmd("DiffviewOpen " .. hashes[1] .. "^!")
                    return
                end

                -- range select -> cumulative diff of the whole span:
                -- oldest commit's parent .. newest commit. Order by commit time
                -- so it works regardless of the order entries were marked in.
                local ct = {}
                for _, h in ipairs(hashes) do
                    ct[h] = tonumber(vim.fn.system({ "git", "show", "-s", "--format=%ct", h })) or 0
                end
                table.sort(hashes, function(a, b) return ct[a] < ct[b] end)
                vim.cmd(("DiffviewOpen %s^..%s"):format(hashes[1], hashes[#hashes]))
            end

            local preview_cmd

            if vim.loop.os_uname().sysname ~= "Windows_NT" then
                preview_cmd = [[ hash=$(echo {} | grep -oE "[a-f0-9]{7,}" | head -1); ]]
                .. [[ if [ -z "$hash" ]; then ]]
                .. [[ echo "Not a commit line"; ]]
                .. [[ else ]]
                .. [[ git show --color "$hash"; ]]
                .. [[ fi ]]
            else
                preview_cmd = [[ powershell -Command "$line = '{}'; if ($line -match '[a-f0-9]{7,}') { git show --color $matches[0] } else { echo 'Not a commit line' }" ]]
            end

            -- Custom *builtin* previewer for git commits: runs `git show | delta`
            -- in a terminal preview buffer, keeping delta's colors. <C-t> toggles
            -- the preview between the full diff and the changed-file list.
            local builtin_prev = require("fzf-lua.previewer.builtin")
            local GitCommitPreviewer = builtin_prev.buffer_or_file:extend()

            -- toggled from the picker (see on_create below): true = list of
            -- changed files (`git show --stat`, default), false = full diff.
            local commits_show_stat = true

            function GitCommitPreviewer:parse_entry(entry_str)
                local hash = entry_str:match("[a-f0-9]+")
                if not hash then
                    return { content = { "Not a commit line" } }
                end
                -- delta emits ansi even when piped, but can't auto-detect width
                -- without a tty, so pass the preview window width explicitly.
                local width = 80
                local win = self.win and self.win.preview_winid
                if win and vim.api.nvim_win_is_valid(win) then
                    width = vim.api.nvim_win_get_width(win)
                end
                -- --stat-width/--stat-name-width keep git from eliding folder
                -- names with `.../` so full paths show in the file-list view.
                local sh_cmd = ("git show --color=always %s %s | delta --%s --navigate --paging=never --width=%d")
                    :format(
                        commits_show_stat and "--stat --stat-width=200 --stat-name-width=200" or "",
                        hash, vim.o.bg, width)
                -- post-process the diffstat: tint the filename (part before ` | `,
                -- \e[38;2;R;G;Bm truecolor #7fbbb3 teal) and drop the +/- histogram
                -- after the change count.
                if commits_show_stat then
                    sh_cmd = sh_cmd ..
                        [[ | perl -pe 's/^( +)([^|]+\S)( +\| )/$1\e[38;2;127;187;179m$2\e[0m$3/; s/(\| +\d+) .*$/$1/']]
                end
                -- non-pty `cmd` is run via vim.system -> must be a LIST, so wrap the
                -- pipe in `sh -c`. Streamed through nvim_open_term (ansi colors, no
                -- terminal job / no "[Process exited]" banner).
                return { cmd = { "sh", "-c", sh_cmd } }
            end

            function GitCommitPreviewer:gen_winopts()
                return vim.tbl_extend("keep", { wrap = false, number = false }, self.winopts)
            end

            -- Toggle the preview between full diff and file-list, driven from the
            -- fzf prompt (no focus switch). Flips the flag then re-renders the
            -- current entry via the live previewer on the FzfWin singleton.
            local function toggle_filelist()
                commits_show_stat = not commits_show_stat
                local win = require("fzf-lua.win").__SELF()
                if win and win._previewer then
                    win._previewer:display_last_entry()
                end
            end

            function GitCommitPreviewer:preview_buf_post(entry, min_winopts)
                GitCommitPreviewer.super.preview_buf_post(self, entry, min_winopts)
                -- terminal bufs leave the cursor at the bottom; start at the top
                local pwin = self.win and self.win.preview_winid
                if pwin and vim.api.nvim_win_is_valid(pwin) then
                    pcall(vim.api.nvim_win_set_cursor, pwin, { 1, 0 })
                end
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
                        ["<C-d>"]  = "preview-half-page-down",
                        ["<C-u>"]    = "preview-half-page-up",
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
                            .. [[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(dim white)<%an>%Creset"]],
                        -- enable multi-select (default is --no-multi): mark a range
                        -- of commits with Tab/S-Tab, then ctrl-e diffs the span.
                        fzf_opts = { ["--multi"] = true, ["--no-multi"] = false },
                        actions = {
                            ["ctrl-e"] = {
                                fn = diff_view,
                                desc = "diff-view (range)"
                            },
                            ["ctrl-d"] = false,
                        },
                        fn_match_commit_hash = function(line, _)
                            return line:match("[a-z0-9]+")
                        end,
                        -- builtin previewer (real buffer) rendering delta output.
                        previewer = { _ctor = function() return GitCommitPreviewer end },
                        winopts = {
                            -- <C-t> in the picker toggles the preview between the
                            -- full diff and the changed-file list (git show --stat).
                            on_create = function(e)
                                -- fires once per picker open -> default to the
                                -- file-list view each time, regardless of last toggle.
                                commits_show_stat = true
                                vim.keymap.set("t", "<C-t>", toggle_filelist,
                                    { buffer = e.bufnr, nowait = true })
                            end,
                        },
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
                        preview = [[git log --graph --pretty=format:"%C(yellow)%h %C(green)%ad %C(reset)%s %C(dim white)%an%C(reset)" --date=format:"(%Y-%m-%d %H:%M)" --abbrev-commit --color {1}]]
                    },
                    files = {
                        actions = {
                            ['ctrl-g'] = function(_, opts)
                                require('fzf-lua').files({ query = opts.last_query, cwd = opts.cwd })
                            end,
                        },
                    },

                },
                files = {
                    actions = {
                        ['ctrl-g'] = function(_, opts)
                            require('fzf-lua').git_files({ query = opts.last_query, cwd = opts.cwd })
                        end,
                    },
                },
                lsp = {
                    code_actions = {
                        -- need install git-delta first ```sudo apt install git-delta`
                        previewer = "codeaction_native",
                        preview_pager = "delta --side-by-side --width=$FZF_PREVIEW_COLUMNS --hunk-header-style=omit --file-style=omit",
                    }
                },
            }
        end
    }
}

