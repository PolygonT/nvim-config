vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

	--    Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }

	-- Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	-- Plug 'junegunn/fzf.vim'

	-- use 'morhetz/gruvbox'

	-- Use release branch (recommended)
	-- Plug 'neoclide/coc.nvim', {'branch': 'release'}
	-- Plug 'honza/vim-snippets'
	use 'vim-airline/vim-airline'

	-- Plug '~/share-dir/wenhaoxiong/test-plugin'
	--
	-- lsp
	--
	--  Uncomment these if you want to manage LSP servers from neovim
	-- Plug 'williamboman/mason.nvim'
	-- Plug 'williamboman/mason-lspconfig.nvim'

	-- LSP Support
	use 'neovim/nvim-lspconfig'
	-- Autocompletion
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'L3MON4D3/LuaSnip'
	use 'saadparwaiz1/cmp_luasnip'

	-- git Support
	use 'tpope/vim-fugitive'

	-- undo tree
	use 'mbbill/undotree'

	-- auto pairs
	use 'windwp/nvim-autopairs'

	-- comments
	use 'numToStr/Comment.nvim'

    -- neo tree
    use {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        requires = { 
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        }
    }

    -- colorschme
    use {
        'sainnhe/everforest',
        config = function()
            vim.cmd('set background=dark')
            vim.cmd('colorscheme everforest')
        end
    }

    -- telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    -- treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

    use({
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
    })

end)

