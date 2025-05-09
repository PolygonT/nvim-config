return {

    -- telescope fzf native
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
    },

    -- code action picker
    {
        'nvim-telescope/telescope-ui-select.nvim'
    },

    -- telescope
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        dependencies = { {'nvim-lua/plenary.nvim'} },
        config = function ()
            local actions = require "telescope.actions"

            -- telescope remap
            local builtin = require('telescope.builtin')

            vim.keymap.set('n', '<leader>psf', builtin.git_files, {})
            vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
            vim.keymap.set('n', '<leader>pc', builtin.current_buffer_fuzzy_find, {})
            vim.keymap.set('n', '<leader>pg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>pb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>ph', builtin.help_tags, {})
            vim.keymap.set('n', '<leader>pic', builtin.git_commits, {})
            vim.keymap.set('n', '<leader>pih', builtin.git_bcommits, {})
            vim.keymap.set('n', '<leader>pid', builtin.git_status, {})
            vim.keymap.set('n', '<leader>pib', builtin.git_branches, {})
            vim.keymap.set('n', '<leader>pis', builtin.git_stash, {})

            require('telescope').setup{
                defaults = {
                    sorting_strategy = "ascending",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top"
                        }
                    },
                    -- Default configuration for telescope goes here:
                    -- config_key = value,
                    mappings = {
                        i = {
                            -- map actions.which_key to <C-h> (default: <C-/>)
                            -- actions.which_key shows the mappings for your picker,
                            -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                            ["<C-h>"] = "which_key"
                        }
                    }
                },
                pickers = {
                    git_branches = {
                        mappings = {
                            i = {
                                ["<c-m>"] = actions.git_delete_branch,
                                ["<c-d>"] = actions.preview_scrolling_down,
                                ["<cr>"] = actions.git_switch_branch,
                            }
                            ,    }
                        }
                        -- Default configuration for builtin pickers goes here:
                        -- picker_name = {
                            --   picker_config_key = value,
                            --   ...
                            -- }
                            -- Now the picker_config_key will be applied every time you call this
                            -- builtin picker
                        },
                        extensions = {
                            fzf = {}
                            -- Your extension configuration goes here:
                            -- extension_name = {
                                --   extension_config_key = value,
                                -- }
                                -- please take a look at the readme of the extension you want to configure
                            }
                        }

                        require('telescope').load_extension('fzf')
                        require('telescope').load_extension('ui-select')
                    end
                },
            }
