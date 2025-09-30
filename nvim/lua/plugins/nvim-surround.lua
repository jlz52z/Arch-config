return {
	"kylechui/nvim-surround",
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	event = "VeryLazy",
	config = function()
		require("nvim-surround").setup({
			-- Configuration here, or leave empty to use defaults
			move_cursor = false, --  可以改为 "end" 或 "begin"
			keymaps = {
				visual = "gs",
				visual_line = "gS",
			},
		})
	end,
}
