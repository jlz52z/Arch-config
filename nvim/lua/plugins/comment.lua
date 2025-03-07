return {
	"numToStr/Comment.nvim",
	opts = {
		-- add any options here
	},
	config = function()
		require("Comment").setup({
			extra = {
				---Add comment on the line above
				above = "gcO",
				---Add comment on the line below
				below = "gco",
				---Add comment at the end of line
				eol = "gca",
			},
		})
	end,
}
