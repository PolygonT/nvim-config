vim.g.mapleader = " "

vim.keymap.set("n", "<leader>w", "<C-w>") 

vim.keymap.set("n", "H", "^") 
vim.keymap.set("v", "H", "^") 
vim.keymap.set("n", "L", "$") 
vim.keymap.set("v", "L", "$") 

vim.keymap.set("n", "<C-d>", "<C-d>zz") 
vim.keymap.set("n", "<C-u>", "<C-u>zz") 

vim.keymap.set("v", "<leader>y", [["+y]]) 
vim.keymap.set("n", "<leader>y", [["+y]]) 
vim.keymap.set("x", "<leader>p", [["_dP]]) 
vim.keymap.set("v", "<leader>p", [["_dP]]) 

vim.keymap.set("i", "<C-c>", "<Esc>") 

-- terminal relate
-- escape terminal mode
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>") 

