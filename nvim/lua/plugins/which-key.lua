return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 您的配置可以在这里添加
    -- 如果留空，将使用默认设置
    -- 参考下面的配置部分
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ plugins = { spelling = true }, show_keys = true })
      end,
      desc = "Show WhichKey Help",
    },
  },
}
