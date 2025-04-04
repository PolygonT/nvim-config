return {
    {
        'xiyaowong/transparent.nvim',
        config = function ()
            local transparent = require('transparent')
            transparent.clear_prefix('NeoTree')
            transparent.clear_prefix('lualine')
            transparent.clear_prefix('BufferLine')

            -- Optional, you don't have to run setup.
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
                    'NvimTreeNormal',
                    'NvimTreeNormalNC',
                    'NvimTreeNormalFloat',
                    'NvimTreeEndOfBuffer',
                },
                -- table: groups you don't want to clear
                exclude_groups = {
                    'NormalFloat',
                },
                -- function: code to be executed after highlight groups are cleared
                -- Also the user event "TransparentClear" will be triggered
                on_clear = function() end,
            })
        end
    }
}

