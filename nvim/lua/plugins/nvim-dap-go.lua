return {
	"leoluz/nvim-dap-go",
	dependencies = { "mfussenegger/nvim-dap" },
	event = "VeryLazy",
	config = function()
		require("dap-go").setup() -- 默认即可
	end,
}
