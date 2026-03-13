return {
    {
        'xiyaowong/transparent.nvim',
        config = function ()
            local transparent = require('transparent')
            transparent.clear_prefix('NeoTree')
            transparent.clear_prefix('lualine')
            transparent.clear_prefix('BufferLine')
            local orig_util = vim.lsp.util.open_floating_preview

            vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = "rounded"
                return orig_util(contents, syntax, opts, ...)
            end

            require("transparent").setup({
                -- table: default groups
                groups = {
                    'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
                    'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
                    'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
                    'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
                    'EndOfBuffer',
                },
                -- table: additional groups that should be cleared
                extra_groups = {
                    'NormalFloat',
                    "FloatBorder",
                    'NvimTreeNormal',
                    'NvimTreeNormalNC',
                    'NvimTreeNormalFloat',
                    'NvimTreeEndOfBuffer',
                },
                -- table: groups you don't want to clear
                exclude_groups = {
                },
                -- function: code to be executed after highlight groups are cleared
                -- Also the user event "TransparentClear" will be triggered
                on_clear = function() end,
            })

            -- Optional, you don't have to run setup.
        end
    }
}

