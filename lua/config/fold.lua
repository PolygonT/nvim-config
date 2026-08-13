-- Per-filetype folding strategies.
--
-- The fold options ('foldmethod', 'foldexpr', 'foldlevel', 'foldtext') are
-- *window*-local, not buffer-local. That is why everything here goes through
-- `vim.wo[win][0]`: the second index `0` means "this buffer, in this window",
-- and Nvim restores it whenever the buffer is shown in that window again.
-- Using `vim.opt_local` / `vim.wo` instead would leak the setting onto the
-- next file you open in the same window.
--
-- Usage -- put one line in `after/ftplugin/<ft>.lua`:
--     require("config.fold").use("indent")
--     require("config.fold").use("treesitter", { level = 1 })
--
-- Filetypes without an `after/ftplugin` file fall back to the default:
-- treesitter if a parser is available, plain `indent` otherwise.
--
-- When an LSP client reports `textDocument/foldingRange`, a "treesitter"
-- buffer is upgraded to LSP folding automatically (it knows about imports and
-- comment regions, which treesitter's folds.scm does not). Pass
-- `{ lsp = false }` to pin a filetype to treesitter.
--
-- NOTE: `after/ftplugin` and not `ftplugin`: several runtime ftplugins
-- (gdscript, markdown, rust, ...) set 'foldexpr' themselves, and
-- `$VIMRUNTIME/ftplugin` is sourced *after* `~/.config/nvim/ftplugin`.

local M = {}

---@alias FoldStrategy "treesitter"|"lsp"|"indent"|"marker"|"manual"

-- Fold LSP-reported import blocks when a file is opened.
M.close_imports_on_open = true

---@param buf integer
---@return integer? winid the window currently displaying `buf`, if any
local function win_of(buf)
    if buf == vim.api.nvim_get_current_buf() then
        return vim.api.nvim_get_current_win()
    end
    local win = vim.fn.bufwinid(buf)
    return win ~= -1 and win or nil
end

---@param buf integer
---@return boolean
function M.has_parser(buf)
    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
    return lang ~= nil and vim.treesitter.language.add(lang) == true
end

---@param buf integer
---@return boolean whether an attached client can serve `textDocument/foldingRange`
local function has_lsp_folding(buf)
    if not vim.lsp.foldexpr then
        return false
    end
    local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/foldingRange" })
    return next(clients) ~= nil
end

---Close the LSP-reported import block, if this buffer uses LSP folding.
---@param buf integer
local function close_imports(buf)
    if not (M.close_imports_on_open and vim.lsp.foldclose) then
        return
    end
    if vim.b[buf].fold_strategy ~= "lsp" then
        return
    end
    local win = vim.fn.bufwinid(buf)
    if win == -1 then
        return
    end
    -- `vim.lsp.foldclose()` is a silent no-op until the LSP fold provider
    -- exists for the buffer, and the only thing that creates one is an
    -- evaluation of `vim.lsp.foldexpr()` -- which merely *schedules* the setup.
    -- So the warm-up has to happen here, with 'foldexpr' already pointing at
    -- LSP, and the foldclose one tick later.
    vim.api.nvim_win_call(win, function()
        vim.fn.foldlevel(1)
    end)
    vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
            pcall(vim.lsp.foldclose, "imports", win)
        end
    end)
end

---Apply a folding strategy to a buffer.
---@param strategy FoldStrategy
---@param opts? { buf?: integer, level?: integer, close_level?: integer, lsp?: boolean }
---  level       -- 'foldlevel' to start at (default: the global 99, all open)
---  close_level -- 'foldlevel' that `zm` collapses to (default 0, everything
---                 folded). Java wants 1: level 1 is the class body, so 0
---                 would fold the whole class instead of just its methods.
function M.use(strategy, opts)
    opts = opts or {}
    local buf = opts.buf or vim.api.nvim_get_current_buf()
    local win = win_of(buf)
    if not win then
        return
    end

    local wo = vim.wo[win][0]

    -- nvim-jdtls (and anything else that attaches from `ftplugin/<ft>.lua`)
    -- reuses an already running client for the *second* file of that filetype,
    -- so LspAttach has already fired by the time `after/ftplugin` gets here.
    -- Without this check we would downgrade that buffer back to treesitter and
    -- nothing would ever upgrade it again -- the first file folds its imports,
    -- every file after it does not.
    if strategy == "treesitter" and opts.lsp ~= false and has_lsp_folding(buf) then
        strategy = "lsp"
    end

    if strategy == "treesitter" then
        wo.foldmethod = "expr"
        wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        wo.foldtext = "foldtext()"
    elseif strategy == "lsp" then
        wo.foldmethod = "expr"
        wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
        -- shows the server-provided `collapsedText`, highlighted via treesitter
        wo.foldtext = "v:lua.vim.lsp.foldtext()"
    elseif strategy == "indent" then
        wo.foldmethod = "indent"
        wo.foldtext = "foldtext()"
    elseif strategy == "marker" then
        wo.foldmethod = "marker"
        wo.foldtext = "foldtext()"
    else
        wo.foldmethod = "manual"
        wo.foldtext = "foldtext()"
    end

    -- always set it: without an explicit value the buffer would inherit
    -- whatever the window happens to be at, e.g. a level some other file left
    -- behind after `zm`. Falling back to the global keeps "opens expanded".
    wo.foldlevel = opts.level or vim.go.foldlevel
    -- only overwrite when given, so the LspAttach upgrade below (which calls
    -- use("lsp") with no opts) keeps the value the ftplugin picked
    if opts.close_level then
        vim.b[buf].fold_close_level = opts.close_level
    end

    vim.b[buf].fold_strategy = strategy
    -- an explicit `use()` call is not "auto", so the default autocmd below and
    -- `M.refresh()` leave it alone
    vim.b[buf].fold_auto = nil
    vim.b[buf].fold_no_lsp = opts.lsp == false or nil

    if strategy == "lsp" then
        -- the LspNotify handler below only fires for a `didOpen` that arrives
        -- *after* this; when the client was already attached, this is the only
        -- chance to fold the imports
        close_imports(buf)
    end
end

---Pick the default strategy for a buffer: treesitter when we have a parser.
---@param buf integer
local function apply_default(buf)
    M.use(M.has_parser(buf) and "treesitter" or "indent", { buf = buf })
    vim.b[buf].fold_auto = true
end

---Re-evaluate the default strategy. Called by the nvim-treesitter FileType
---handler once a parser finishes installing asynchronously, so the very first
---time you open a new filetype you don't get stuck on the `indent` fallback.
---@param buf integer
function M.refresh(buf)
    if vim.b[buf] and vim.b[buf].fold_auto then
        apply_default(buf)
    end
end

---The `zm` toggle: collapse to this filetype's `close_level`, or open
---everything back up.
function M.toggle()
    local buf = vim.api.nvim_get_current_buf()
    local closed = vim.b[buf].fold_close_level or 0
    if vim.wo.foldlevel == closed then
        vim.wo[0][0].foldlevel = 99
    else
        vim.wo[0][0].foldlevel = closed
        -- setting 'foldlevel' reopens every fold at or below it, which for
        -- Java (close_level = 1) includes the import block
        close_imports(buf)
    end
end

local group = vim.api.nvim_create_augroup("user_folding", { clear = true })

-- Default for every filetype that has no `after/ftplugin` override.
-- The `fold_auto` guard makes this independent of whether this autocmd runs
-- before or after the ftplugin files.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(ev)
        if vim.b[ev.buf].fold_strategy and not vim.b[ev.buf].fold_auto then
            return
        end
        apply_default(ev.buf)
    end,
})

-- Upgrade treesitter folding to LSP folding where the server supports it.
vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(ev)
        if vim.b[ev.buf].fold_no_lsp then
            return
        end
        -- don't override an explicit indent/marker/manual choice
        local current = vim.b[ev.buf].fold_strategy
        if current ~= "treesitter" and current ~= nil then
            return
        end
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client or not client:supports_method("textDocument/foldingRange") then
            return
        end
        M.use("lsp", { buf = ev.buf })
    end,
})

-- Fold the import block on open. `vim.lsp.foldclose()` is new in nvim 0.13.
if vim.lsp.foldclose then
    vim.api.nvim_create_autocmd("LspNotify", {
        group = group,
        callback = function(ev)
            if not M.close_imports_on_open or ev.data.method ~= "textDocument/didOpen" then
                return
            end
            -- `didOpen` is sent just *before* LspAttach, so the buffer is
            -- usually still on treesitter here and `close_imports()` bails --
            -- this only matters for a `didOpen` on an already-LSP-folded
            -- buffer, e.g. after a server restart.
            close_imports(ev.buf)
        end,
    })
end

return M
