return {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
       -- vim.cmd.colorscheme "catppuccin"
require("catppuccin").setup({
  -- 关键设置
  transparent_background = true,
})
    end,
}

