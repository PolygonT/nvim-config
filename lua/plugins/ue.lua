local M = {}
if vim.fn.has('unix') then

else
    M = {
        {
            'ue.nvim',
            dev = true,
            -- branch = "win",
            config = function()
                require('ue').setup({
                    versions = {
                        {
                            version = "5.4",
                            path = "C:/Program Files/Epic Games/UE_5.4/"
                        },
                        {
                            version = "5.6",
                            path = "F:/EpicGames/UE_5.6/"
                        },
                    }
                })
            end
        },

    }
end

return M
