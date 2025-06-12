return {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function ()
        local ls = require('luasnip')
        local s = ls.snippet
        local t = ls.text_node
        local i = ls.insert_node

        -- vim.keymap.set({ "i", "s" }, "A-k", function ()
        --     if ls.expand_or_jumpable() then
        --         ls.expand_or_jump()
        --     end
        -- end, { silent = true })
        --
        -- vim.keymap.set({ "i", "s" }, "A-j", function ()
        --     if ls.jumpable(-1) then
        --         ls.jump(-1)
        --     end
        -- end, { silent = true })
    end
}
