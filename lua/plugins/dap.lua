local M = {}
if vim.fn.has('unix') then
    -- linux config
    M = {
        {
            'mfussenegger/nvim-dap',
            dependencies = {
                {'rcarriga/nvim-dap-ui'},
                {'theHamsta/nvim-dap-virtual-text'},
                {'nvim-neotest/nvim-nio'}
            },
            config = function ()
                -- nvim dap
                local dap = require('dap')
                local dapui = require('dapui')
                dapui.setup()
                require('nvim-dap-virtual-text').setup()

                dap.adapters.cppdbg = {
                    id = 'cppdbg',
                    type = 'executable',
                    command = '/home/wenhaoxiong/software/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
                }

                dap.configurations.cpp = {
                    {
                        name = "cpptool server",
                        type = "cppdbg",
                        request = "launch",
                        cwd = '${workspaceFolder}',
                        program = function()
                            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                        end,
                        stopAtEntry = true,
                        setupCommands = {  
                            { 
                                text = '-enable-pretty-printing',
                                description =  'enable pretty printing',
                                ignoreFailures = false 
                            },
                        },
                    }
                }

                -- dap keymaps

                vim.keymap.set('n', '<leader>do', dapui.toggle)
                vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)
                vim.keymap.set('n', '<leader>dr', dap.continue)
                vim.keymap.set('n', '<leader>dc', dap.run_to_cursor)
                vim.keymap.set('n', '<leader>d?', function ()
                    dapui.eval(nil, { enter = true })
                end)
            end
        },
    }
else
    -- windows config
    M = {
        {
            'mfussenegger/nvim-dap',
            dependencies = {
                {'rcarriga/nvim-dap-ui'},
                {'theHamsta/nvim-dap-virtual-text'},
                {'nvim-neotest/nvim-nio'}
            },
            config = function ()
                -- nvim dap
                local dap = require('dap')
                local dapui = require('dapui')
                dapui.setup()
                require('nvim-dap-virtual-text').setup()

                dap.adapters.cppdbg = {
                    id = 'cppdbg',
                    type = 'executable',
                    command = 'C:\\Users\\wenhaoxiong\\.vscode\\extensions\\ms-vscode.cpptools-1.26.3-win32-x64\\debugAdapters\\bin\\OpenDebugAD7.exe',
                    options = {
                        detached = false
                    }
                }

                dap.configurations.cpp = {
                    {
                        name = "Launch file",
                        type = "cppdbg",
                        request = "launch",
                        program = function()
                            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '\\', 'file')
                        end,
                        cwd = '${workspaceFolder}',
                        stopAtEntry = true,
                        runInTerminal = true,
                        setupCommands = {  
                            { 
                                text = '-enable-pretty-printing',
                                description =  'enable pretty printing',
                                ignoreFailures = false 
                            },
                        },
                    },
                }

                -- dap keymaps

                vim.keymap.set('n', '<leader>do', dapui.toggle)
                vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)
                vim.keymap.set('n', '<leader>dr', dap.continue)
                vim.keymap.set('n', '<leader>dc', dap.run_to_cursor)
                vim.keymap.set('n', '<leader>d?', function ()
                    dapui.eval(nil, { enter = true })
                end)
            end
        },

    }
end

return M;
