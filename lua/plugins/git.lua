return {
    {
        'tpope/vim-fugitive',
    },
    {

	    'lewis6991/gitsigns.nvim',
        config = function ()
            local gitsigns = require('gitsigns')
            gitsigns.setup()

            vim.keymap.set('n', 'gn', gitsigns.next_hunk, {})
            vim.keymap.set('n', 'gp', gitsigns.prev_hunk, {})
            vim.keymap.set('n', 'go', gitsigns.preview_hunk_inline, {})
            vim.keymap.set('n', 'gz', gitsigns.reset_hunk, {})

        end
    }
}
