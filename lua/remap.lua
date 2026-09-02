vim.g.mapleader = " "

vim.keymap.set("n", "<leader>w", "<C-w>")

vim.keymap.set("n", "H", "^")
vim.keymap.set("v", "H", "^")
vim.keymap.set("n", "L", "$")
vim.keymap.set("v", "L", "$")

-- vim.keymap.set("n", "<C-d>", "<C-d>zz") 
-- vim.keymap.set("n", "<C-u>", "<C-u>zz") 

vim.keymap.set("v", "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>y", [["+y]])
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("v", "<leader>p", [["_dP]])

vim.keymap.set("i", "<C-c>", "<Esc>")

-- terminal relate
-- escape terminal mode
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>")

-- quickfix / location list remap
-- uses the location list when the current window has one, else the quickfix list
local function list_jump(cmd)
    return function()
        pcall(vim.cmd, (#vim.fn.getloclist(0) > 0 and "l" or "c") .. cmd)
    end
end

vim.keymap.set("n", "<C-j>", list_jump("next"), { desc = "Next quickfix/location item" })
vim.keymap.set("n", "<C-k>", list_jump("prev"), { desc = "Prev quickfix/location item" })

-- open file in browser
vim.keymap.set("n", "<leader>os", function()
    vim.ui.open(vim.api.nvim_buf_get_name(0))
end, { desc = "Open file with default app" })

