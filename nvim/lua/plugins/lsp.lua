return {
	{
		"williamboman/mason.nvim",
		event = "VeryLazy",
		config = function()
			require("mason").setup({
				ensure_installed = { "goimports", "delve" },
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig", -- 也依赖于 lspconfig 本身
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "gopls", "lua_ls", "ts_ls", "clangd", "pyright" },
				automatic_installation = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim", -- 显式依赖
			"williamboman/mason-lspconfig.nvim", -- 显式依赖
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")

			-- Define a shared on_attach function for all LSPs
			local on_attach = function(client, bufnr)
				-- keybind options
				-- go相关的lsp快捷键在go.lua中定义
				local keymap = vim.keymap -- for conciseness
				local opts = { noremap = true, silent = true, buffer = bufnr }

				-- set keybinds
				keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", opts) -- 跳转到定义
				keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>", opts) -- 显示定义和引用
				keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- 显示文档
				keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- 智能重命名
				keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- 显示代码操作
				keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- 显示当前行诊断信息
				keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- 跳转到上一个诊断
				keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- 跳转到下一个诊断
				keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", opts) -- 打开符号大纲
				keymap.set("n", "<leader>gi", "<cmd>Lspsaga incoming_calls<CR>", opts) -- 逆向追溯：谁调用了当前符号
				keymap.set("n", "<leader>go", "<cmd>Lspsaga outgoing_calls<CR>", opts) -- 正向追踪：当前符号调用了谁
				keymap.set("n", "<leader>gD", "<cmd>Lspsaga peek_definition<CR>", opts) -- 在浮动窗口中查看函数具体实现代码
				---- Inlay Hints are provided by Language Servers and should be enabled there
				opts.desc = "Enable Inlay hints"
				keymap.set("n", "<leader>i", function()
					local status = vim.lsp.inlay_hint.is_enabled() and "OFF" or "ON"
					vim.api.nvim_notify("Toggling inlay hints " .. status, vim.log.levels.INFO, {})
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				end, opts)
				keymap.set("n", "<leader>gR", "<cmd>Lspsaga peek_type_definition<CR>", opts) -- 在浮动窗口中查看类型系统的类型定义
			end
			-- Change the Diagnostic symbols in the sign column (gutter)
			-- (not in youtube nvim video)
			local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end
			-- Setup LSP servers with capabilities and on_attach
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" }, -- 让 lua_ls 知道 vim 这个全局变量
						},
					},
				},
			})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})
			-- configure cpp clangd
			lspconfig.clangd.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})
			-- configure python pyright
			lspconfig.pyright.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					pyright = {
						autoImportCompletion = true,
						python = {
							analysis = {
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
							},
						},
					},
				},
			})
		end,
	},
	{
		"glepnir/lspsaga.nvim",
		event = "BufRead",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			--      require("lspsaga").setup({
			--        ui = {
			--          border = "rounded", -- 边框样式
			--          win_width = 25,     -- 设置窗口宽度
			--          win_height = 15,    -- 可选：设置窗口高度
			--        },
			--        outline = {
			--          win_width = 15,     -- 符号大纲窗口宽度
			--        },
			--        hover = {
			--          max_width = 15,     -- 悬浮文档窗口的最大宽度
			--        },
			--        code_action = {
			--          num_shortcut = true,
			--          show_server_name = false,
			--          extend_gitsigns = true,
			--          max_width = 40,     -- 代码操作窗口的最大宽度
			--        },
			--      })
			require("lspsaga").setup({
				rename = {
					keys = {
						quit = "<ESC>",
					},
				},
				code_action = {
					keys = {
						quit = "<ESC>",
					},
				},
			})
			-- 在 lspsaga 配置中添加：
			-- require("lspsaga").setup({
			--     finder = {
			--         keys = {
			--             toggle_or_open = "o", -- 原跳转键
			--             vsplit = "v",
			--             split = "s",
			--             tabe = "t",
			--             quit = "q",
			--             -- quit = "<ESC>" -- 将ESC键设置为退出finder窗口
			--             -- 覆盖 Enter 行为
			--             shuttle = "<cr>", -- 新增此行
			--         },
			--     },
			-- })
		end,
	},
}
