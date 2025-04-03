return {
	"sindrets/diffview.nvim",
	config = function()
		require("diffview").setup({
			use_icons = false, -- 禁用图标以纯色条显示
			enhanced_diff_hl = true, -- 启用更精细的差异高亮
		})
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		local diffview = require("diffview")

		-- 自定义动作：仓库提交 → Diffview 文件列表
		local function open_commit_file_list(prompt_bufnr)
			local entry = action_state.get_selected_entry()
			actions.close(prompt_bufnr)
			vim.cmd("DiffviewOpen " .. entry.value)
		end

		-- 自定义动作：文件提交 → 分屏对比
		local function open_file_diff(prompt_bufnr)
			local entry = action_state.get_selected_entry()
			actions.close(prompt_bufnr)
			local commit_hash = entry.value
			local file_path = vim.fn.expand("%:p")
			vim.cmd("DiffviewOpen " .. commit_hash .. " -- " .. file_path)
		end

		-- 绑定快捷键
		vim.keymap.set("n", "<leader>gc", function()
			builtin.git_commits({
				attach_mappings = function(_, map)
					map("i", "<CR>", open_commit_file_list)
					map("n", "<CR>", open_commit_file_list)
					return true
				end,
			})
		end, { desc = "查看提交的文件改动列表" })

		vim.keymap.set("n", "<leader>gb", function()
			builtin.git_bcommits({
				attach_mappings = function(_, map)
					map("i", "<CR>", open_file_diff)
					map("n", "<CR>", open_file_diff)
					return true
				end,
			})
		end, { desc = "分屏对比文件历史版本" })
		vim.keymap.set("n", "<leader>gh", ":DiffviewOpen<CR>", { desc = "Open diffview" })
		vim.keymap.set("n", "<leader>gj", ":DiffviewFileHistory %<CR>", { desc = "Open current file history" })
		vim.keymap.set("n", "<leader>gk", ":DiffviewOpen HEAD %<CR>", { desc = "Check diff between HEAD and current buffer" })
		vim.keymap.set("n", "<leader>gl", ":DiffviewClose<CR>", { desc = "Close diffview" })
		-- 设置 Diffview 的修改部分颜色为黄色
		-- vim.api.nvim_set_hl(0, "DiffviewDiffChange", { bg ="#47482b"})
		-- DiffviewDiffChange被链接到了DiffChange，故只修改DiffChange，由于Tokyo主题会覆盖颜色设置，故在options.lua中进行设置
		-- vim.api.nvim_set_hl(0, "DiffChange", { bg ="#47482b"})

		-- 将空行的填充符号从‘-’改为‘/’
		vim.opt.fillchars:append("diff:╱")
	end,
}
