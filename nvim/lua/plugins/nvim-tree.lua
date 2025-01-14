return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    keys = {
        { "<leader>e", ":NvimTreeToggle<CR>", desc = "toggle file tree" },
    },
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        -- optionally enable 24-bit colour
        vim.opt.termguicolors = true
        require("nvim-tree").setup({
            update_focused_file = {
                enable = true, -- 启用高亮当前文件
                update_cwd = true, -- 更新当前工作目录
            },
            view = {
                width = 30,
                side = "left",
            },
            renderer = {
                highlight_opened_files = "all", -- 高亮打开的文件
            },
            filters = {
                dotfiles = false, -- 显示隐藏文件
                custom = { "^.git$" },
            },
        })
    end,
}
