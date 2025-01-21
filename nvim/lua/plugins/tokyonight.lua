return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
        -- 设置主题为moon
        vim.g.tokyonight_style = "night"
    end,
}
