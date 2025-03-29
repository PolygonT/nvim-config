return {
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
                command = '/home/wenhaoxiong/software/debug-adapters/cpptool/extension/debugAdapters/bin/OpenDebugAD7',
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
