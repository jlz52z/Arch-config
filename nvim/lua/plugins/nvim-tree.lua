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
				-- update_cwd = false, -- 更新当前工作目录
				update_root = false,
			},
			git = {
				enable = false, -- 临时禁用git忽略规则
			},
			view = {
				width = 30,
				side = "left",
			},
			renderer = {
				highlight_opened_files = "all", -- 高亮打开的文件
				indent_markers = {
					enable = true,
					icons = {
						corner = "└ ", -- 修改拐角符号
						edge = "│ ", -- 修改边缘线符号
						none = "  ", -- 空白层级的占位符
					},
				},
			},
			filters = {
				dotfiles = false, -- 显示隐藏文件
				custom = { "^.git$" },
			},
		})

		-- 在启动时自动打开 nvim-tree
		-- 1) 直接 `nvim`（无参数）时打开目录树
		-- 2) `nvim .` 或 `nvim <某个目录>` 时切到该目录并打开目录树
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function(data)
				local api = require("nvim-tree.api")

				-- 是否打开的是目录
				local is_directory = (vim.fn.isdirectory(data.file) == 1)
				-- 是否是空缓冲（无文件名、正常缓冲）
				local is_just_nvim = (data.file == "" and vim.bo[data.buf].buftype == "")

				if not is_directory and not is_just_nvim then
					return
				end

				-- 如果是以目录启动，先切换到该目录
				if is_directory then
					vim.cmd.cd(data.file)
				end

				-- 打开目录树
				api.tree.open()
			end,
		})
	end,
}
