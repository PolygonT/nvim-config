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
            vim.keymap.set('n', '<leader>pf', fzf.files, {})
            vim.keymap.set('n', '<leader>pg', fzf.live_grep, {})


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
                        ["<C-d>"]  = "preview-down",
                        ["<C-u>"]    = "preview-up",
                    },
                    fzf = {
                        -- fzf '--bind=' options
                        -- true,        -- uncomment to inherit all the below in your custom config
                        ["ctrl-z"]      = "abort",
                        ["ctrl-u"]      = "unix-line-discard",
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
                    },
                },
                -- SPECIFIC COMMAND/PICKER OPTIONS, SEE BELOW
                -- files = { ... },
            }
        end
    }
}

