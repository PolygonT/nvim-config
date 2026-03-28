if vim.fn.has('unix') then
    require("config.lazy")
    require("remap")
    require("lsp")
    require("globals")
else
    require("remap")
    require("globals")
    require("config.lazy")
    require("lsp")
end

vim.opt.nu = true
vim.opt.wrap = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.relativenumber = true
vim.opt.scrolloff = 8
-- thick cursor when enter insert mode
vim.opt.guicursor = ""
-- no highlight search
vim.opt.hlsearch = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- ==========folding==============
vim.o.foldmethod = "expr"
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.o.foldmethod = "indent"
vim.o.foldlevel = 99
vim.keymap.set("n", "zm", function()
    if vim.o.foldlevel == 0 then
        vim.o.foldlevel = 99
    else
        vim.o.foldlevel = 0
    end
end)
--
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = { "cpp", "c", "h", "hpp" },
--     callback = function()
--         vim.opt_local.foldmethod = "indent"
--     end
-- })
-- ===============================
--
-- auto read
vim.o.autoread = true
vim.o.updatetime = 200

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})


if vim.fn.has('unix') then
    vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
else
    vim.opt.undodir = "C:/Users/wenhaoxiong/Documents" .. "/.vim/undodir"
    vim.g.undotree_DiffCommand = "FC"
    vim.opt.smartindent = false
end
-- vim.opt.smartindent = false

vim.opt.signcolumn = "yes"

vim.opt.termguicolors = true

-- highlight yank
local augroup = vim.api.nvim_create_augroup
local yank_group = augroup('HighlightYank', {})
local autocmd = vim.api.nvim_create_autocmd


autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 200,
        })
    end,
})

