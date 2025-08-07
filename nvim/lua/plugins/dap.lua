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
		local keymap = vim.keymap -- for conciseness
		local opts = { noremap = true, silent = true, desc = "" }

		-- set keybinds
		opts.desc = "切换调试时的虚拟文本显示"
		keymap.set("n", "<leader>dv", "<cmd>DapVirtualTextToggle<CR>", opts) -- 跳转到定义
	end,
	disable = false,
}
