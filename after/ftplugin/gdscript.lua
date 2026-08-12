-- Must live in `after/ftplugin`: $VIMRUNTIME/ftplugin/gdscript.vim sets its
-- own 'foldexpr' and is sourced after ~/.config/nvim/ftplugin.
-- Swap to `use("indent")` for Python-style indent folds.
require("config.fold").use("treesitter")
