local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<C-a>", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-h>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "zp", function() harpoon:list():select(1) end)
vim.keymap.set("n", "zs", function() harpoon:list():select(2) end)
vim.keymap.set("n", "zt", function() harpoon:list():select(3) end)
vim.keymap.set("n", "zf", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "gon", function() harpoon:list():prev() end)
vim.keymap.set("n", "gop", function() harpoon:list():next() end)
