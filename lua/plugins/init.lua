return {
    --use 'vim-airline/vim-airline'
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
        config = function ()
            require('lualine').setup()
        end
    },

    'nvim-lua/plenary.nvim',

	-- Plug '~/share-dir/wenhaoxiong/test-plugin'
	--
	-- lsp
	--
	--  Uncomment these if you want to manage LSP servers from neovim
	-- Plug 'williamboman/mason.nvim'
	-- Plug 'williamboman/mason-lspconfig.nvim'

	-- LSP Support
	'neovim/nvim-lspconfig',
	-- Autocompletion
	-- use 'hrsh7th/nvim-cmp'
	-- use 'hrsh7th/cmp-nvim-lsp'
	-- use 'hrsh7th/cmp-buffer'
 --    use 'hrsh7th/cmp-path'
 --    use 'hrsh7th/cmp-cmdline'
	-- use 'L3MON4D3/LuaSnip'
	-- use 'saadparwaiz1/cmp_luasnip'
	--
 --    use 'hrsh7th/cmp-vsnip'
 --    use 'hrsh7th/vim-vsnip'

    -- cmp icon
    -- use 'onsails/lspkind.nvim'


	-- undo tree
    {
        'mbbill/undotree',
        config = function ()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle) 
        end
    },

	-- auto pairs
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },

	-- comments
    -- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
    {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        }
    },


    -- colorschme
    {
        'sainnhe/everforest',
        config = function()
            vim.cmd [[ set background=dark ]]
            vim.cmd [[ colorscheme everforest" ]]
        end
    },

    -- markdown preview
    -- install without yarn or npm
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        config = function() vim.fn["mkdp#util#install"]() end,
    },

    -- img clip
    'HakonHarnes/img-clip.nvim',

    -- translate
	'uga-rosa/translate.nvim',

    -- jdtls
    'mfussenegger/nvim-jdtls',

    -- unreal egine support
    -- {
    --     'zadirion/Unreal.nvim',
    --     dependencies =
    --     {
    --         {"tpope/vim-dispatch"}
    --     }
    -- },

    {
        'ue.nvim',
        dev = true,
        -- branch = "win",
        config = function()
            require('ue').setup({
                versions = {
                    {
                        version = "5.4",
                        path = "C:/Program Files/Epic Games/UE_5.4/"
                    },
                    {
                        version = "5.6",
                        path = "F:/EpicGames/UE_5.6/"
                    },
                }
            })
        end
    },

    --
    -- '/home/wenhaoxiong/workspace/neovim/ue.nvim',
    -- {
    --     'ue.nvim',
    --     dev = true
    -- }
}
