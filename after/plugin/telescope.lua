local actions = require "telescope.actions"

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
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}
