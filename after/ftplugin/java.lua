-- Treesitter folds until jdtls attaches, then LSP folding takes over (it knows
-- about imports, so the import block is auto-collapsed).
--
-- close_level = 1 because in Java everything lives inside a class: level 1 is
-- the class body and level 2 is the methods. With the default 0, `zm` would
-- fold the whole class away; 1 folds just the methods.
require("config.fold").use("treesitter", { close_level = 1 })
