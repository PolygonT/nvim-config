-- Snippets, one file per language.
--
-- Usage -- put one file in `lua/snippets/<ft>.lua` returning a list of
-- declarations, one table per snippet:
--
--     return {
--         { trig = "main", dscr = "entry point", body = "int main() {\n\t$0\n}" },
--         { trig = ".foreach", priority = 2000,
--           body = "for (${1:const auto&} ${2:item} : $EXPR) {\n\t$0\n}" },
--     }
--
-- The file is named after the filetype and loaded the first time a buffer of
-- that filetype shows up, the same rule `after/ftplugin/<ft>.lua` follows.
-- Adding a language is adding one file; nothing here changes.
--
-- `body` is LSP snippet text -- `$1`, `${2:default}`, `${1|a,b|}`, `$0` -- the
-- syntax friendly-snippets and every language server speak, so bodies can be
-- pasted in from anywhere.
--
-- A trigger that starts with a dot is a *postfix* snippet: it is only offered
-- after `<expression>.`, and `$EXPR` in the body is that expression
-- (`items.foreach` -> a loop over `items`).
--
-- Two escape hatches, neither needed so far:
--     nodes = function (n) return { n.t("std::size("), n.expr(), n.t(")") } end
-- replaces `body` when LSP snippet text cannot say it -- `n` is LuaSnip's node
-- constructors plus `n.expr()`, the expression before the dot. And
--     preview = " (const auto& item : %s) {"
-- pins the menu preview that is otherwise derived from the snippet itself.
--
-- NOTE: no `require` at the top of this file. blink.cmp's snippets provider
-- calls `transform_items` below every time a completion menu opens, so this
-- module has to stay cheap to load and free of side effects; LuaSnip is
-- required inside the functions that need it, all of which run at FileType
-- time.

local M = {}

-- how much of `en->items[k].foreach` counts as the expression: LuaSnip's
-- default pattern plus `[]`, `->` and `::`, but no parens, so that
-- `foo(items.foreach` picks up `items` rather than `foo(items`
M.match_pattern = [[[%w_%.%->%[%]:]+$]]

--- The expression a postfix snippet would work on, nil when the cursor isn't
--- sitting behind `<expression>.<word>`.
--- @param line_to_cursor? string defaults to the current line up to the cursor
function M.expression(line_to_cursor)
    if not line_to_cursor then
        local col = vim.api.nvim_win_get_cursor(0)[2]
        line_to_cursor = vim.api.nvim_get_current_line():sub(1, col)
    end
    return line_to_cursor:match("([%w_%.%->%[%]:]+)%.[%w_]*$")
end

--- LuaSnip `show_condition`: only offer the postfix snippets after a dot, so
--- they don't take over the menu when `for` is typed on its own. blink hands
--- the condition the line up to *one char before* the cursor, which would hide
--- them for as long as the dot is the last thing typed, hence reading the line
--- from the buffer instead.
function M.after_dot() return M.expression() ~= nil end

-- ---------------------------------------------------------------------------
-- Building snippets
-- ---------------------------------------------------------------------------

-- the expression in front of the trigger (`items` in `items.foreach`) is
-- handed to us in env.POSTFIX_MATCH -- with a trailing dot when the snippet was
-- picked from the completion menu, since only the typed part (`for`,
-- `foreach`, ...) counts as the trigger then
local function match(parent)
    return (parent.snippet.env.POSTFIX_MATCH:gsub("%.$", ""))
end

local n -- LuaSnip node constructors, built on first use

local function helpers()
    if n then return n end
    local ls = require("luasnip")
    n = {
        s = ls.snippet, sn = ls.snippet_node, t = ls.text_node,
        i = ls.insert_node, c = ls.choice_node, f = ls.function_node,
        d = ls.dynamic_node, rep = require("luasnip.extras").rep,
    }

    --- Node: the expression the postfix snippet was triggered on, verbatim.
    function n.expr()
        return n.f(function (_, parent) return match(parent) end, {})
    end

    -- `$EXPR`, in the shape the parser wants a variable: the pair
    -- { dynamicNode-fn, is_interactive }. Never interactive, so a nested
    -- `${2:std::size($EXPR)}` collapses into one editable insertNode
    -- pre-filled with `std::size(arr)` instead of a nested snippet.
    n.EXPR = {
        function (_, parent) return n.sn(nil, { n.t(match(parent)) }) end,
        function () return false end,
    }
    return n
end

--- Turn a declaration's `body`/`nodes` into a LuaSnip node list.
local function nodes_of(decl)
    local h = helpers()
    if decl.nodes then return decl.nodes(h) end

    local nodes = require("luasnip").parser.parse_snippet(
        nil, decl.body, { variables = { EXPR = h.EXPR } })

    -- The parser hands every `$VAR` a jump index of its own, numbered after the
    -- highest one in the body. The expression is not something you tab into --
    -- without this swap `.foreach` would grow a fourth stop between `item` and
    -- `$0`. A nested `$EXPR` (inside `${2:...}`) is already flattened to text
    -- by then, so only the top level needs it.
    for idx, node in ipairs(nodes) do
        if node.fn == h.EXPR[1] then nodes[idx] = h.expr() end
    end
    return nodes
end

-- a byte that cannot occur in a snippet body, so the expression can be found
-- again after the snippet has been rendered
local MARKER = "\1"

--- What the menu shows for a postfix snippet, derived from the snippet itself
--- so there is no second copy of the body to keep in sync.
---
--- `copy():fake_expand()` + `get_static_text()` is how LuaSnip renders a
--- snippet's own docstring: insertNode defaults render as their default text,
--- `$1` mirrors render mirrored, and the dynamicNode is actually evaluated --
--- with MARKER standing in for the expression, which `transform_items` swaps
--- for the real one. On a copy, because `fake_expand` writes into the snippet.
---@return string the first line of the expansion, MARKER standing in for the
---  expression -- and standing in more than once if the body says `$EXPR` twice
local function derive_preview(snippet, trig)
    local copy = snippet:copy()
    copy:fake_expand({
        -- like LuaSnip's own `Environ.fake()`, but with our marker for the
        -- match: every other variable keeps its `$NAME` stand-in
        env = setmetatable({ POSTFIX_MATCH = MARKER }, {
            __index = function (_, name) return "$" .. name end,
        }),
    })
    local line = copy:get_static_text()[1] or ""

    -- blink draws the preview right after the trigger the user has typed, and
    -- `.foreach` is typed where the `for` would go -- so a leading keyword the
    -- trigger already spells out is dropped: `for (const auto& ...` previews as
    -- ` (const auto& ...`. Only a whole leading word counts, otherwise a future
    -- `.pct` -> `print(...)` would have its `p` eaten.
    local head = line:match("^[%w_]+") or ""
    local word = trig:gsub("^%p+", "")
    if head ~= "" and word:sub(1, #head) == head then
        return line:sub(#head + 1)
    end
    return " " .. line
end

--- One declaration -> one LuaSnip snippet, plus its preview when postfix.
local function build(decl)
    -- everything except our own keys is LuaSnip's snippet context, so `dscr`,
    -- `priority`, `wordTrig`, `regTrig`, ... are passed straight through
    local context = {}
    for key, value in pairs(decl) do
        if key ~= "body" and key ~= "nodes" and key ~= "preview" then
            context[key] = value
        end
    end

    local nodes = nodes_of(decl)
    if decl.trig:sub(1, 1) ~= "." then
        return require("luasnip").snippet(context, nodes), nil
    end
    -- a hand-written `preview` is spelled with `%s`, like the docs say; inside
    -- it is the same marker the derived ones use
    local pinned = decl.preview and decl.preview:gsub("%%s", MARKER)

    -- what makes a postfix snippet behave, stated once here instead of in
    -- every declaration
    context.match_pattern = context.match_pattern or M.match_pattern
    context.show_condition = context.show_condition or M.after_dot
    local snippet = require("luasnip.extras.postfix").postfix(context, nodes)
    return snippet, pinned or derive_preview(snippet, decl.trig)
end

-- previews[ft][trig]: what the snippet expands to, MARKER standing in for the
-- expression. Filled in by define(), read by transform_items() when a menu
-- opens. Keyed by filetype because two languages may well want the same
-- trigger.
M.previews = {}

--- Register one language's declarations.
---@param ft string filetype, or "all" for every filetype
---@param decls table[] what `lua/snippets/<ft>.lua` returns
function M.define(ft, decls)
    local snippets, previews = {}, {}
    for _, decl in ipairs(decls) do
        local snippet, preview = build(decl)
        snippets[#snippets + 1] = snippet
        previews[decl.trig] = preview
    end
    M.previews[ft] = previews
    -- `key` makes this idempotent, which is what `M.reload` below rides on:
    -- re-registering a language replaces its snippets instead of adding a
    -- second copy. LuaSnip only *marks* the old batch invalidated and blink's
    -- snippet source does not filter those out, so sweep them here or the menu
    -- shows every trigger twice.
    local ls = require("luasnip")
    ls.add_snippets(ft, snippets, { key = "user_snippets_" .. ft })
    ls.clean_invalidated({ inv_limit = 0 })
end

local loaded = {}

--- Load `lua/snippets/<ft>.lua`, once per filetype per session.
---@param ft string
function M.load(ft)
    if ft == "" or loaded[ft] then return end
    loaded[ft] = true
    -- a missing file is the normal case for most filetypes, but a *broken* one
    -- must still raise, so look before requiring instead of `pcall(require)`
    if #vim.api.nvim_get_runtime_file("lua/snippets/" .. ft .. ".lua", false) == 0 then
        return
    end
    M.define(ft, require("snippets." .. ft))
end

--- Re-read a language file without restarting nvim, for while you are writing
--- snippets: `:lua require("config.snippets").reload("cpp")`. (Editing the file
--- is not enough on its own -- nothing watches it.)
---@param ft string
function M.reload(ft)
    loaded[ft] = nil
    package.loaded["snippets." .. ft] = nil
    M.load(ft)
end

--- Called from LuaSnip's `config()`.
function M.setup()
    -- `all` is LuaSnip's own name for "every filetype". Plain snippets only:
    -- previews are keyed by filetype, so a postfix snippet here would show up
    -- without its menu preview.
    M.load("all")

    -- a language file costs nothing until a buffer of that filetype shows up
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_snippets", { clear = true }),
        callback = function (ev) M.load(ev.match) end,
    })
    -- buffers that already exist -- the file nvim was started on, a restored
    -- session: their FileType fired before this ran and never fires again
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then M.load(vim.bo[buf].filetype) end
    end
end

--- blink.cmp `transform_items` for the snippets source: rank the postfix
--- snippets first and show what they expand to.
--- @param ctx blink.cmp.Context
--- @param items blink.cmp.CompletionItem[]
function M.transform_items(ctx, items)
    local previews = M.previews[vim.bo[ctx.bufnr].filetype]
    if not previews then return items end -- no snippets of ours in this language

    local expression = M.expression(ctx.line:sub(1, ctx.cursor[2]))

    for _, item in ipairs(items) do
        local preview = previews[item.label]
        if preview and expression then
            -- postfix snippets outrank the plain ones, which otherwise win on
            -- the exact prefix match; ties among them fall back to the LuaSnip
            -- priority carried in sortText
            item.score_offset = (item.score_offset or 0) + 10

            preview = preview:gsub(MARKER, (expression:gsub("%%", "%%%%")))
            item.labelDetails = { description = preview }

            -- ghost text draws `insertText` with the already typed part chopped
            -- off, so putting the trigger in front leaves the expansion on
            -- screen. Marking it a snippet is what keeps that expansion out of
            -- the buffer: while an item is selected blink types it in
            -- (`selection.auto_insert`), but for snippets it only types the part
            -- before the first bracket or space -- here the trigger, so
            -- selecting completes `entities.for` into `entities.foreach` the
            -- way any other snippet item would, and nothing else moves. That is
            -- also how the LSP's own `for (${1:init}; ...)` behaves.
            --
            -- It has to be the trigger rather than what has been typed so far:
            -- blink runs this once per completion session (the luasnip source
            -- reports its list complete, so further keystrokes reuse it), and a
            -- prefix captured here would be stale by the next character -- then
            -- written over the line, deleting what was typed since.
            item.insertText = item.label .. preview
            item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet
        end
    end

    return items
end

return M
