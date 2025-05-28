return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "theHamsta/nvim-dap-virtual-text",
        "rcarriga/nvim-dap-ui",
        "nvim-telescope/telescope-dap.nvim",
        "jay-babu/mason-nvim-dap.nvim",
        "nvim-neotest/nvim-nio",
    },
    opt = true,
    -- 延迟加载，兼容packer.nvim配置
    -- module = { "dap" },
    -- requires = {
    --     {
    --         "theHamsta/nvim-dap-virtual-text",
    --         module = { "nvim-dap-virtual-text" },
    --     },
    --     {
    --         "rcarriga/nvim-dap-ui",
    --         module = { "dapui" },
    --     },
    --     "nvim-telescope/telescope-dap.nvim",
    --     {
    --         "jbyuki/one-small-step-for-vimkind",
    --         module = "osv",
    --     },
    -- },
    config = function()
        require("mason-nvim-dap").setup({
            ensure_installed = { "codelldb", "delve" },
            automatic_installation = true,
        })
        -- config/dap/init.lua 中的 M.setup() 函数
        require("config.dap").setup()
    end,
    disable = false,
}
