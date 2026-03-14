return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true },
        dashboard = { enabled = false },
        explorer = { enabled = false },
        indent = { enabled = true },
        input = { enabled = false },
        picker = { enabled = false },
        notifier = { 
            enabled = true,
            timeout = 15000, -- default timeout in ms
            width = { min = 40, max = 0.4 },
            height = { min = 1, max = 0.6 },
            -- editor margin to keep free. tabline and statusline are taken into account automatically
            margin = { top = 0, right = 1, bottom = 0 },
            padding = true, -- add 1 cell of left/right padding to the notification window
            gap = 0, -- gap between notifications
            sort = { "level", "added" }, -- sort by level and time
            -- minimum log level to display. TRACE is the lowest
            -- all notifications are stored in history
            level = vim.log.levels.TRACE,
            icons = {
                error = " ",
                warn = " ",
                info = " ",
                debug = " ",
                trace = " ",
            },
            keep = function(notif)
                return vim.fn.getcmdpos() > 0
            end,
            ---@type snacks.notifier.style
            style = "compact",
            top_down = true, -- place notifications from top to bottom
            date_format = "%R", -- time format for notifications
            -- format for footer when more lines are available
            -- `%d` is replaced with the number of lines.
            -- only works for styles with a border
            ---@type string|boolean
            more_format = " ↓ %d lines ",
            refresh = 50, -- refresh at most every 50ms
        },
        quickfile = { enabled = false },
        scope = { enabled = false },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = false },
    },
}
