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

-- quickfix list remap
vim.keymap.set("n", "<C-j>", "<cmd>cnext<cr>") 
vim.keymap.set("n", "<C-k>", "<cmd>cprev<cr>") 

-- telescope remap
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', builtin.git_files, {})
vim.keymap.set('n', '<leader>psf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pc', builtin.current_buffer_fuzzy_find, {})
vim.keymap.set('n', '<leader>pg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>pb', builtin.buffers, {})
vim.keymap.set('n', '<leader>ph', builtin.help_tags, {})
vim.keymap.set('n', '<leader>pic', builtin.git_commits, {})
vim.keymap.set('n', '<leader>pih', builtin.git_bcommits, {})
vim.keymap.set('n', '<leader>pid', builtin.git_status, {})
vim.keymap.set('n', '<leader>pib', builtin.git_branches, {})
vim.keymap.set('n', '<leader>pis', builtin.git_stash, {})
