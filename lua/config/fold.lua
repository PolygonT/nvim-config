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
---
--- `vim.lsp.foldclose()` is not usable here: when the fold provider is not up
--- to date yet it defers the real `:foldclose` into an async LSP callback
--- (runtime/lua/vim/lsp/_folding_range.lua), where an E490 escapes any pcall we
--- could put around the call. Requesting the ranges ourselves keeps the
--- `:foldclose` inside our own error handling, and lets us wait until the fold
--- actually exists in the window before closing it.
---@param buf integer
---@param force? boolean re-fold even if the imports were folded once already
local function close_imports(buf, force)
    if not M.close_imports_on_open then
        return
    end
    if vim.b[buf].fold_strategy ~= "lsp" then
        return
    end
    if force then
        vim.b[buf].fold_imports_done = nil
    elseif vim.b[buf].fold_imports_done or vim.b[buf].fold_imports_pending then
        return
    end
    if vim.fn.bufwinid(buf) == -1 then
        return
    end

    -- bumped by every new run and by `toggle()` when it opens everything back
    -- up, so a slow retry loop from an earlier run cannot re-close the imports
    -- after the user has unfolded them
    local gen = (vim.b[buf].fold_imports_gen or 0) + 1
    vim.b[buf].fold_imports_gen = gen

    ---Close `rows` once the LSP fold data has landed in the window. Evaluating
    ---'foldexpr' is also what creates the provider, so this doubles as the
    ---warm-up: retry until a fold shows up, then give up.
    local function apply(rows, attempt)
        if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].fold_imports_gen ~= gen then
            -- superseded: whoever bumped the generation owns `pending` now
            return
        end
        local win = vim.fn.bufwinid(buf)
        if win == -1 then
            vim.b[buf].fold_imports_pending = nil
            return
        end
        local ready = false
        vim.api.nvim_win_call(win, function()
            for _, lnum in ipairs(rows) do
                if vim.fn.foldlevel(lnum) > 0 then
                    ready = true
                    if vim.fn.foldclosed(lnum) == -1 then
                        pcall(vim.cmd, lnum .. "foldclose")
                    end
                end
            end
        end)
        if ready then
            vim.b[buf].fold_imports_pending = nil
            vim.b[buf].fold_imports_done = true
        elseif attempt < 40 then
            vim.defer_fn(function()
                apply(rows, attempt + 1)
            end, 50)
        else
            vim.b[buf].fold_imports_pending = nil
        end
    end

    vim.b[buf].fold_imports_pending = true
    local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
    vim.lsp.buf_request_all(buf, "textDocument/foldingRange", params, function(results)
        local rows = {}
        for _, res in pairs(results) do
            for _, range in ipairs(res.result or {}) do
                -- zero-length ranges are not folds; nvim ignores them too
                if range.kind == "imports" and range.startLine < range.endLine then
                    rows[#rows + 1] = range.startLine + 1
                end
            end
        end
        if #rows == 0 or not vim.api.nvim_buf_is_valid(buf) then
            vim.b[buf].fold_imports_pending = nil
            return
        end
        -- innermost first, so a closed outer fold never hides an inner one
        table.sort(rows, function(a, b)
            return a > b
        end)
        apply(rows, 1)
    end)
end

---Assign a window option only when the value actually changes.
---
--- Re-assigning 'foldexpr' fires OptionSet even when the new value is
--- identical, and nvim's LSP fold provider tears itself down on that event
--- (`OptionSet foldexpr` -> `_capability.enable('folding_range', false)` in
--- runtime/lua/vim/lsp/_folding_range.lua). Every LSP fold in the buffer
--- disappears then -- `vim.lsp.foldexpr()` returns "0" for every line -- so a
--- second `use("lsp")` on the same buffer would undo the first one. That
--- happens on every Java file after the first: `after/ftplugin` upgrades to
--- LSP folding *and* LspAttach fires for the reused jdtls client.
---@param wo table the `vim.wo[win][0]` handle
---@param name string
---@param value string|integer
---@return boolean changed
local function set(wo, name, value)
    if wo[name] == value then
        return false
    end
    wo[name] = value
    return true
end

---Write the fold options for `strategy` into one window.
---
--- These options are *window*-local with per-buffer memory, so they only stick
--- for the (window, buffer) pair that is current when they are written. A
--- buffer that got its filetype somewhere else -- harpoon's `bufload()`, a
--- telescope/fzf preview -- keeps `b:fold_strategy`, but the window you later
--- look at it in falls back to the defaults ('foldmethod' "manual",
--- 'foldexpr' "0"), i.e. no folds at all. The `BufWinEnter` autocmd below
--- re-runs this for every window the buffer shows up in.
---@param win integer
---@param strategy FoldStrategy
---@param level integer
---@return boolean changed whether this window was still on other options
local function apply_options(win, strategy, level)
    local wo = vim.wo[win][0]
    local changed = false
    ---@param name string
    ---@param value string|integer
    local function put(name, value)
        changed = set(wo, name, value) or changed
    end

    if strategy == "treesitter" then
        put("foldmethod", "expr")
        put("foldexpr", "v:lua.vim.treesitter.foldexpr()")
        put("foldtext", "foldtext()")
    elseif strategy == "lsp" then
        put("foldmethod", "expr")
        put("foldexpr", "v:lua.vim.lsp.foldexpr()")
        -- shows the server-provided `collapsedText`, highlighted via treesitter
        put("foldtext", "v:lua.vim.lsp.foldtext()")
    elseif strategy == "indent" then
        put("foldmethod", "indent")
        put("foldtext", "foldtext()")
    elseif strategy == "marker" then
        put("foldmethod", "marker")
        put("foldtext", "foldtext()")
    else
        put("foldmethod", "manual")
        put("foldtext", "foldtext()")
    end

    -- always set it: without an explicit value the buffer would inherit
    -- whatever the window happens to be at, e.g. a level some other file left
    -- behind after `zm`. Falling back to the global keeps "opens expanded".
    -- via `set()`, because re-assigning it would reopen folds the window
    -- already has closed, e.g. the import block we just folded.
    put("foldlevel", level)

    return changed
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

    -- nvim-jdtls (and anything else that attaches from `ftplugin/<ft>.lua`)
    -- reuses an already running client for the *second* file of that filetype,
    -- so LspAttach has already fired by the time `after/ftplugin` gets here.
    -- Without this check we would downgrade that buffer back to treesitter and
    -- nothing would ever upgrade it again -- the first file folds its imports,
    -- every file after it does not.
    if strategy == "treesitter" and opts.lsp ~= false and has_lsp_folding(buf) then
        strategy = "lsp"
    end

    -- remembered so `BufWinEnter` can re-apply the same options to whatever
    -- window this buffer shows up in next
    local level = opts.level or vim.b[buf].fold_level or vim.go.foldlevel
    vim.b[buf].fold_level = level
    apply_options(win, strategy, level)

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
        -- cancel an import fold that is still waiting for its fold data
        vim.b[buf].fold_imports_gen = (vim.b[buf].fold_imports_gen or 0) + 1
    else
        vim.wo[0][0].foldlevel = closed
        -- setting 'foldlevel' reopens every fold at or below it, which for
        -- Java (close_level = 1) includes the import block
        close_imports(buf, true)
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

-- Re-apply the buffer's strategy every time it is displayed in a window.
--
-- `M.use()` only reaches the window that showed the buffer when its filetype
-- was set, and that is not always the window you end up reading it in.
-- Harpoon is the case that bit us: it does `vim.fn.bufload(bufnr)` before
-- `nvim_set_current_buf()`, so `FileType` fires while the buffer is only
-- current inside Nvim's temporary autocommand window -- `M.use()` writes the
-- fold options into that window and they die with it. Same story for a
-- telescope/fzf preview window or a background `:badd`. `b:fold_strategy`
-- survives, `FileType` never fires again, and the real window is left on
-- 'foldmethod' "manual" / 'foldexpr' "0": no folds at all, and `za` on the
-- import block answers E490.
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(ev)
        local strategy = vim.b[ev.buf].fold_strategy
        if not strategy then
            return
        end
        local win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_get_buf(win) ~= ev.buf then
            return
        end
        if not apply_options(win, strategy, vim.b[ev.buf].fold_level or vim.go.foldlevel) then
            return
        end
        -- this window was on the defaults, so nothing is folded in it yet --
        -- whatever an earlier window did to the import block does not count
        vim.b[ev.buf].fold_imports_done = nil
        close_imports(ev.buf)
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

-- Fold the import block on open. `vim.lsp.foldexpr()` is new in nvim 0.11.
if vim.lsp.foldexpr then
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
            close_imports(ev.buf, true)
        end,
    })
end

return M
