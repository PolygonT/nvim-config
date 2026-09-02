return {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function ()
        local ls = require('luasnip')

        -- blink.cmp is configured with `snippets.preset = "luasnip"`, so the
        -- completion menu is fed by LuaSnip: friendly-snippets has to be loaded
        -- through LuaSnip instead of by blink itself
        require("luasnip.loaders.from_vscode").lazy_load()

        -- our own snippets: one file per language in lua/snippets/<ft>.lua,
        -- loaded when a buffer of that filetype first shows up. See
        -- lua/config/snippets.lua for the declaration format
        require("config.snippets").setup()

        -- jump between the placeholders of an expanded snippet, plain
        -- <Tab>/<S-Tab> everywhere else
        local function jump_or(direction, fallback)
            return function ()
                if ls.locally_jumpable(direction) then
                    ls.jump(direction)
                else
                    vim.api.nvim_feedkeys(vim.keycode(fallback), "n", false)
                end
            end
        end

        vim.keymap.set({ "i", "s" }, "<Tab>", jump_or(1, "<Tab>"), { silent = true })
        vim.keymap.set({ "i", "s" }, "<S-Tab>", jump_or(-1, "<S-Tab>"), { silent = true })
    end
}
