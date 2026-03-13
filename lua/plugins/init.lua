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
	{
        'neovim/nvim-lspconfig',
        -- wired glsl error
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.name == "glsl_analyzer" then
                        client.cancel_request = function() end
                    end
                end,
            })
        end,
    },
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
            vim.g.everforest_background = "hard"
            vim.g.everforest_transparent_background = 1
            -- vim.cmd [[ set background=dark ]]
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

    {
        'MeanderingProgrammer/render-markdown.nvim',
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },

    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            bigfile = { enabled = true },
            dashboard = { enabled = false },
            explorer = { enabled = false },
            indent = { enabled = true },
            input = { enabled = false },
            picker = { enabled = true },
            notifier = { enabled = true },
            quickfile = { enabled = false },
            scope = { enabled = false },
            scroll = { enabled = true },
            statuscolumn = { enabled = true },
            words = { enabled = false },
        },
    },

    -- {
    --     'kevinhwang91/nvim-ufo', dependencies = 'kevinhwang91/promise-async',
    --     config = function ()
    --         vim.o.foldcolumn = '1' -- '0' is not bad
    --         vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    --         vim.o.foldlevelstart = 99
    --         vim.o.foldenable = true
    --
    --         -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
    --         vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    --         vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
    --
    --
    --         -- Option 2: nvim lsp as LSP client
    --         -- Tell the server the capability of foldingRange,
    --         -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
    --         local capabilities = vim.lsp.protocol.make_client_capabilities()
    --         capabilities.textDocument.foldingRange = {
    --             dynamicRegistration = false,
    --             lineFoldingOnly = true
    --         }
    --         local language_servers = vim.lsp.get_clients() -- or list servers manually like {'gopls', 'clangd'}
    --         for _, ls in ipairs(language_servers) do
    --             require('lspconfig')[ls].setup({
    --                 capabilities = capabilities
    --                 -- you can add other fields for setting up lsp server in this table
    --             })
    --         end
    --         require('ufo').setup()
    --         --
    --
    --         -- Option 3: treesitter as a main provider instead
    --         -- (Note: the `nvim-treesitter` plugin is *not* needed.)
    --         -- ufo uses the same query files for folding (queries/<lang>/folds.scm)
    --         -- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
    --         require('ufo').setup({
    --             provider_selector = function(bufnr, filetype, buftype)
    --                 return {'treesitter', 'indent'}
    --             end
    --         })
    --         --
    --
    --     end
    -- },

    -- unreal egine support
    -- use {
    --     'zadirion/Unreal.nvim',
    --     requires =
    --     {
    --         {"tpope/vim-dispatch"}
    --     }
    -- }
    --
    -- '/home/wenhaoxiong/workspace/neovim/ue.nvim',
    -- {
    --     'ue.nvim',
    --     dev = true
    -- }
}
