-- Treesitter folds until the language server attaches, then LSP folding takes
-- over (it knows about imports, so the import block is auto-collapsed).
-- Pass { lsp = false } to stay on treesitter.
require("config.fold").use("treesitter")
