-- See `:help vim.lsp.start` for an overview of the supported `config` options.
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local home_dir = os.getenv("HOME")
local workspace_dir = home_dir .. '/software/jdtls/workspace/' .. project_name

-- local home = os.getenv('HOME')

local config = {
    name = "jdtls",


    -- `cmd` defines the executable to launch eclipse.jdt.ls.
    -- `jdtls` must be available in $PATH and you must have Python3.9 for this to work.
    --
    -- As alternative you could also avoid the `jdtls` wrapper and launch
    -- eclipse.jdt.ls via the `java` executable
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {

        home_dir .. '/develop/java/jdk-21.0.10.jdk/Contents/Home/bin/java', -- or '/path/to/java17_or_newer/bin/java'
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-javaagent:'.. home_dir .. '/.m2/repository/org/projectlombok/lombok/1.18.28/lombok-1.18.28.jar',

        -- 💀
        '-jar', home_dir .. '/develop/language_server/jdtls/plugins/org.eclipse.equinox.launcher_1.7.100.v20251111-0406.jar',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
        -- Must point to the                                                     Change this to
        -- eclipse.jdt.ls installation                                           the actual version


        -- 💀
        '-configuration', home_dir .. '/develop/language_server/jdtls/config_linux/',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
        -- Must point to the                      Change to one of `linux`, `win` or `mac`
        -- eclipse.jdt.ls installation            Depending on your system.


        -- 💀
        -- See `data directory configuration` section in the README
        '-data', workspace_dir
    },


    -- `root_dir` must point to the root of your project.
    -- See `:help vim.fs.root`
    root_dir = vim.fs.root(0, {'gradlew', '.git', 'mvnw', 'pom.xml'}),


    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = {
        java = {
            configuration = {
                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                -- And search for `interface RuntimeOption`
                -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
                runtimes = {
                    {
                        name = "JavaSE-1.8",
                        path = home_dir .. "/develop/java/jdk-1.8/Contents/Home/",
                    },
                    {
                        name = "JavaSE-17",
                        path = home_dir .. "/develop/java/jdk-17.0.12.jdk/Contents/Home/",
                    },
                    {
                        name = "JavaSE-21",
                        path = home_dir .. "/develop/java/jdk-21.0.10.jdk/Contents/Home/",
                    },
                }
            }
        }
    },


    -- This sets the `initializationOptions` sent to the language server
    -- If you plan on using additional eclipse.jdt.ls plugins like java-debug
    -- you'll need to set the `bundles`
    --
    -- See https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on any eclipse.jdt.ls plugins you can remove this
    init_options = {
        bundles = {}
    },

    on_attach = function()
        vim.keymap.set('n', '<leader>pa', function()
            require('jdtls').extract_variable()
        end)
    end
}

require('jdtls').start_or_attach(config)












-- -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
-- local jdtls = require('jdtls')
--
-- local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
--
-- local workspace_dir = '/home/wenhaoxiong/software/jdtls/workspace/' .. project_name
--
-- local home = os.getenv('HOME')
--
-- local jar_patterns = {
--   '/software/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar',
--   '/software/vscode-java-test/server/*.jar',
--   '/software/vscode-java-test/java-extension/com.microsoft.java.test.plugin/target/*.jar',
--   '/software/vscode-java-test/java-extension/com.microsoft.java.test.runner/target/*.jar',
--   -- '/software/vscode-java-test/java-extension/com.microsoft.java.test.runner/lib/*.jar',
--   -- '/dev/testforstephen/vscode-pde/server/*.jar'
-- }
-- -- npm install broke for me: https://github.com/npm/cli/issues/2508
-- -- So gather the required jars manually; this is based on the gulpfile.js in the vscode-java-test repo
-- local plugin_path = '/software/vscode-java-test/java-extension/com.microsoft.java.test.plugin.site/target/repository/plugins/'
-- local bundle_list = vim.tbl_map(
--   function(x) return require('jdtls.path').join(plugin_path, x) end,
--   {
--       'org.eclipse.jdt.junit4.runtime_*.jar',
--       'org.eclipse.jdt.junit5.runtime_*.jar',
--       'org.junit.jupiter.api*.jar',
--       'org.junit.jupiter.engine*.jar',
--       'org.junit.jupiter.migrationsupport*.jar',
--       'org.junit.jupiter.params*.jar',
--       'org.junit.vintage.engine*.jar',
--       'org.opentest4j*.jar',
--       'org.junit.platform.commons*.jar',
--       'org.junit.platform.engine*.jar',
--       'org.junit.platform.launcher*.jar',
--       'org.junit.platform.runner*.jar',
--       'org.junit.platform.suite.api*.jar',
--       'org.apiguardian*.jar'
--   }
-- )
-- -- vim.list_extend(jar_patterns, bundle_list)
-- -- print(vim.inspect(jar_patterns))
-- local bundles = {}
-- for _, jar_pattern in ipairs(jar_patterns) do
--   for _, bundle in ipairs(vim.split(vim.fn.glob(home .. jar_pattern), '\n')) do
--       if not vim.endswith(bundle, 'com.microsoft.java.test.runner-jar-with-dependencies.jar')
--           and not vim.endswith(bundle, 'com.microsoft.java.test.runner.jar') then
--           table.insert(bundles, bundle)
--       end
--   end
-- end
-- local extendedClientCapabilities = jdtls.extendedClientCapabilities;
-- extendedClientCapabilities.resolveAdditionalTextEditsSupport = true;
--
-- local config = {
--   -- The command that starts the language server
--   -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
--   cmd = {
--
--     -- 💀
--     'java', -- or '/path/to/java17_or_newer/bin/java'
--             -- depends on if `java` is in your $PATH env variable and if it points to the right version.
--
--     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
--     '-Dosgi.bundles.defaultStartLevel=4',
--     '-Declipse.product=org.eclipse.jdt.ls.core.product',
--     '-Dlog.protocol=true',
--     '-Dlog.level=ALL',
--     '-Xmx1g',
--     '--add-modules=ALL-SYSTEM',
--     '--add-opens', 'java.base/java.util=ALL-UNNAMED',
--     '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
--     '-javaagent:/home/wenhaoxiong/software/jdtls/lombok-1.18.30.jar',
--
--     -- 💀
--     '-jar', '/home/wenhaoxiong/software/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar',
--          -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
--          -- Must point to the                                                     Change this to
--          -- eclipse.jdt.ls installation                                           the actual version
--
--
--     -- 💀
--     '-configuration', '/home/wenhaoxiong/software/jdtls/config_linux',
--                     -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
--                     -- Must point to the                      Change to one of `linux`, `win` or `mac`
--                     -- eclipse.jdt.ls installation            Depending on your system.
--
--
--     -- 💀
--     -- See `data directory configuration` section in the README
--     '-data', workspace_dir
--   },
--
--   -- 💀
--   -- This is the default if not provided, you can remove it. Or adjust as needed.
--   -- One dedicated LSP server & client will be started per unique root_dir
--   --
--   -- vim.fs.root requires Neovim 0.10.
--   -- If you're using an earlier version, use: require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
--   root_dir = vim.fs.root(0, {".git", "mvnw", "gradlew"}),
--
--   -- Here you can configure eclipse.jdt.ls specific settings
--   -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
--   -- for a list of options
--   settings = {
--     java = {
--     }
--   },
--
--   -- Language server `initializationOptions`
--   -- You need to extend the `bundles` with paths to jar files
--   -- if you want to use additional eclipse.jdt.ls plugins.
--   --
--   -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
--   --
--   -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
--   init_options = {
--       bundles = bundles,
--       extendedClientCapabilities = extendedClientCapabilities,
--   },
-- }
--
-- -- vim.keymap.set("n", "<F5>", function() 
-- --     require('jdtls.dap').setup_dap_main_class_configs()
-- -- end)
--
-- -- This starts a new client & server,
-- -- or attaches to an existing client & server depending on the `root_dir`.
-- require('jdtls').start_or_attach(config)
--
--
-- local dap = require('dap');
-- dap.listeners.before.attache.dapui_config = function ()
--     require('jdtls.dap').setup_dap_main_class_configs()
-- end
--
-- vim.keymap.set("n", "<leader>dt", function() 
--     require'jdtls'.test_nearest_method()
-- end)
--
--

