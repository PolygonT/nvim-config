if vim.fn.has('unix') then
    -- linux config
    -- Set up lspconfig.
    -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities();
    local snippet_capabilities = vim.lsp.protocol.make_client_capabilities()
    snippet_capabilities.textDocument.completion.completionItem.snippetSupport = true

    -- Setup language servers.
    -- local lspconfig = require('lspconfig')

    -- jdtls
    -- lspconfig.jdtls.setup{
    --     capabilities = capabilities, 
    -- }
    --

    -- rust_analyzer
    -- lspconfig.rust_analyzer.setup {
    --     capabilities = capabilities, 
    --     on_attach = function()
    --         vim.keymap.set('n', '<leader>cmr', "<cmd>!cargo run<CR>")
    --         vim.keymap.set('n', '<leader>cmt', "<cmd>!cargo test<CR>")
    --     end,
    --
    --     -- Server-specific settings. See `:help lspconfig-setup`
    --     settings = {
    --         ['rust-analyzer'] = {},
    --     },
    -- }

    -- html
    -- lspconfig.html.setup{
    --     capabilities = snippet_capabilities,
    -- }

    -- lua
    -- lspconfig.lua_ls.setup{}

    -- lspconfig.jdtls.setup{
    -- }

    -- php
    -- lspconfig.phan.setup{}

    -- clangd
    local clangd_on_attach = vim.lsp.config.clangd.on_attach
    vim.lsp.config("clangd", {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            clangd_on_attach(client, bufnr)
            vim.keymap.set('n', '<leader>s', "<cmd>LspClangdSwitchSourceHeader<CR>")

            -- if unreal project
            local is_unreal_project = string.len(vim.fn.glob('*.uproject')) ~= 0
            if is_unreal_project then
                vim.keymap.set('n', '<leader>pf', function()
                    require('telescope.builtin').find_files({
                        cwd = "Source"
                    })
                end, {})

                vim.keymap.set('n', '<leader>pss', function()
                    require('telescope.builtin').find_files({
                        cwd = "/home/wenhaoxiong/software/unreal/UnrealEngine-5.4.4-release/Engine/Source/Runtime"
                    })
                end, {})

                vim.keymap.set('n', '<leader>pg', function ()
                    require('telescope.builtin').live_grep({
                        cwd = "Source"
                    })
                end, {})

                vim.keymap.set('n', '<leader>psg', function ()
                    require('telescope.builtin').live_grep({
                        cwd = "/home/wenhaoxiong/software/unreal/UnrealEngine-5.4.4-release/Engine/Source/Runtime"
                    })
                end, {})
            end
        end,
        cmd = { "clangd-19"}
        -- cmd = { "/home/wenhaoxiong/develop/language_server/clangd_19.1.2/bin/clangd" }
        -- cmd = { "/home/wenhaoxiong/develop/language_server/ccls/Release/ccls" }
    })

    vim.lsp.enable('clangd')

    vim.lsp.config("gdscript", {
        cmd = { "/home/wenhaoxiong/software/godot-wsl-lsp-1.4.0/bin/godot-wsl-lsp", "--useMirroredNetworking", "--experimentalFastPathConversion"}
    })
    vim.lsp.enable('gdscript')

    -- vim.lsp.config('glsl_analyzer', {
    --     capabilities = capabilities,
    --     cmd = { "glsl_analyzer" }
    -- })
    -- vim.lsp.enable('glsl_analyzer')
    -- vim.lsp.enable('glslls')



    -- Global mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions

    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = false,
        float = true,
    })

    vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float)
    vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev)
    vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist)

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
            -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
            -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
            -- vim.keymap.set('n', '<space>wl', function()
            --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            -- end, opts)
            -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
            -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            -- vim.keymap.set('n', '<space>f', function()
            --   vim.lsp.buf.format { async = true }
            -- end, opts)

        end,
    })
else
    -- windows config
    -- Set up lspconfig.
    -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities();
    local snippet_capabilities = vim.lsp.protocol.make_client_capabilities()
    snippet_capabilities.textDocument.completion.completionItem.snippetSupport = true

    -- Setup language servers.
    local lspconfig = require('lspconfig')

    -- jdtls
    -- lspconfig.jdtls.setup{
    --     capabilities = capabilities, 
    -- }
    --

    -- rust_analyzer
    lspconfig.rust_analyzer.setup {
        capabilities = capabilities, 
        on_attach = function()
            vim.keymap.set('n', '<leader>cmr', "<cmd>!cargo run<CR>")
            vim.keymap.set('n', '<leader>cmt', "<cmd>!cargo test<CR>")
        end,

        -- Server-specific settings. See `:help lspconfig-setup`
        settings = {
            ['rust-analyzer'] = {},
        },
    }

    -- html
    lspconfig.html.setup{
        capabilities = snippet_capabilities,
    }

    -- lua
    lspconfig.lua_ls.setup{}

    -- lspconfig.jdtls.setup{
    -- }

    -- php
    lspconfig.phan.setup{}

    -- clangd
    local clangd_on_attach = vim.lsp.config.clangd.on_attach
    vim.lsp.config("clangd", {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            clangd_on_attach(client, bufnr)
            vim.keymap.set('n', '<leader>s', "<cmd>LspClangdSwitchSourceHeader<CR>")

            -- if unreal project
            local is_unreal_project = string.len(vim.fn.glob('*.uproject')) ~= 0
            if is_unreal_project then
                vim.keymap.set('n', '<leader>pf', function()
                    require('fzf-lua').files({
                        cwd = "Source",
                        -- path_display = { "tail" }
                    })
                end, {})
                vim.keymap.set('n', '<leader>pss', function()
                    require('fzf-lua').files({
                        cwd = "F:/EpicGames/UE_5.6",
                        -- path_display = { "tail" }
                    })
                end, {})
                vim.keymap.set('n', '<leader>pg', function ()
                    require('fzf-lua').live_grep({
                        cwd = "Source"
                    })
                end, {})
            end
        end,
        cmd = { "D:/software/clangd_19.1.2/bin/clangd" }
    })

    vim.lsp.enable('clangd')

    -- lspconfig.clangd.setup{
    --     capabilities = capabilities,
    --     -- cmd = { "D:/software/clangd_19.1.2/bin/clangd" }
    -- }


    -- Global mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions

    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = false,
        float = true,
    })

    vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float)
    vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev)
    vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist)

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }

            local fzf = require('fzf-lua')
            vim.keymap.set('n', 'gD', fzf.lsp_declarations, opts)
            vim.keymap.set('n', 'gd', fzf.lsp_definitions, opts)
            vim.keymap.set('n', 'gr', fzf.lsp_references, opts)
            vim.keymap.set('n', 'gi', fzf.lsp_implementations, opts)
            vim.keymap.set('n', 'gt', fzf.lsp_typedefs, opts)

            -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            -- vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
            vim.keymap.set({ 'n', 'v' }, 'gf', vim.lsp.buf.format, opts)
            -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
            -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
            -- vim.keymap.set('n', '<space>wl', function()
            --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            -- end, opts)
            -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
            -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            -- vim.keymap.set('n', '<space>f', function()
            --   vim.lsp.buf.format { async = true }
            -- end, opts)

        end,
    })

end
