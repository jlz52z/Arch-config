return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        -- require('lualine').setup()
        require("lualine").setup({
            options = {
                theme = "auto",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                globalstatus = true,
                -- padding = { top = 0, bottom = 1 }, -- 底部增加 1 行间距
            },
            sections = {
                lualine_c = {
                    {
                        "filename",
                        path = 1,              -- 0 = 仅文件名, 1 = 相对路径, 2 = 绝对路径
                        fmt = function(path)
                            return vim.fn.fnamemodify(path, ":~:.") -- 显示从家目录开始的路径
                        end,
                    },
                },
            },
        })
    end,
}
