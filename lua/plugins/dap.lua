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

            -- dap.adapters.cppdbg = {
            --     id = 'cppdbg',
            --     type = 'executable',
            --     command = 'C:\\Users\\wenhaoxiong\\.vscode\\extensions\\ms-vscode.cpptools-1.26.3-win32-x64\\debugAdapters\\bin\\OpenDebugAD7.exe',
            --     options = {
            --         detached = false
            --     }
            -- }
            --
            -- dap.configurations.cpp = {
            --     {
            --         name = "Launch file",
            --         type = "cppdbg",
            --         request = "launch",
            --         program = function()
            --             return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '\\', 'file')
            --         end,
            --         cwd = '${workspaceFolder}',
            --         stopAtEntry = true,
            --         runInTerminal = true,
            --         setupCommands = {  
            --             { 
            --                 text = '-enable-pretty-printing',
            --                 description =  'enable pretty printing',
            --                 ignoreFailures = false 
            --             },
            --         },
            --     },
            -- }
            dap.adapters.lldb = {
                type = 'executable',
                command = 'C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\Llvm\\x64\\bin\\lldb-dap.exe', -- adjust as needed, must be absolute path
                name = 'lldb'
            }
            dap.configurations.cpp = {
                {
                    name = 'Launch',
                    type = 'lldb',
                    request = 'launch',
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},

                    -- 💀
                    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
                    --
                    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
                    --
                    -- Otherwise you might get the following error:
                    --
                    --    Error on launch: Failed to attach to the target process
                    --
                    -- But you should be aware of the implications:
                    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
                    -- runInTerminal = false,
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
