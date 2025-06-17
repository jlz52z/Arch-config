local M = {}

local function configure()
	-- -- 设置断点图标和颜色
	-- vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#FF0000" })
	-- vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#FF9900" })
	-- vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#00FF00" })
	-- vim.api.nvim_set_hl(0, "DapStopped", { fg = "#00FFFF" })
	local dap_breakpoint = {
		breakpoint = {
			text = "",
			-- texthl = "LspDiagnosticsSignError",
			texthl = "DiagnosticSignError",
			-- linehl = "",
			-- numhl = "",
			linehl = "DebugLineHighlight", -- 行高亮（可选）
			numhl = "DebugNumberHighlight", -- 行号高亮（可选）
		},
		rejected = {
			text = "󰚦",
			texthl = "DiagnosticSignHint",
			linehl = "",
			numhl = "",
		},
		stopped = {
			text = "",
			texthl = "DiagnosticSignInfo",
			linehl = "DiagnosticUnderlineInfo",
			numhl = "DiagnosticSignInfo",
		},
		dap_breakpointcondition = {
			text = "󰃤",
			texthl = "DiagnosticSignWarn",
			linehl = "",
			numhl = "debugBreakpoint",
		},
        dap_logPoint ={ text = "󰌑", texthl = "DapLogPoint", linehl = "", numhl = "" },
	}
	-- 该函数已经被废弃
	vim.fn.sign_define("DapBreakpoint", dap_breakpoint.breakpoint)
	vim.fn.sign_define("DapStopped", dap_breakpoint.stopped)
	vim.fn.sign_define("DapBreakpointRejected", dap_breakpoint.rejected)
	vim.fn.sign_define("DapBreakpointCondition", dap_breakpoint.dap_breakpointcondition)
	vim.fn.sign_define("DapLogPoint", dap_breakpoint.breakpoint)
	-- vim.diagnostic.config({
	--   signs = {
	--     DapBreakpoint = dap_breakpoint.breakpoint,
	--     DapStopped = dap_breakpoint.stopped,
	--     DapBreakpointRejected = dap_breakpoint.rejected
	--   }
	-- })
end

local function configure_exts()
	require("nvim-dap-virtual-text").setup({
		enabled = true, -- 启用虚拟文本
		enabled_commands = true, -- 创建命令DapVirtualTextEnable等
		highlight_changed_variables = true, -- 高亮变化的变量
		highlight_new_as_changed = false, -- 将新变量视为已更改变量
		show_stop_reason = true, -- 显示停止原因
		commented = false, -- 在注释中显示虚拟文本
		only_first_definition = false, -- 不仅在第一次定义时显示虚拟文本
		all_references = true, -- 在所有引用处显示虚拟文本
	})

	local dap, dapui = require("dap"), require("dapui")
	dapui.setup({
		expand_lines = true,
		icons = { expanded = "", collapsed = "", circular = "" },
		mappings = {
			-- Use a table to apply multiple mappings
			expand = { "<CR>", "<2-LeftMouse>" },
			open = "o",
			remove = "d",
			edit = "e",
			repl = "r",
			toggle = "t",
		},
		layouts = {
			{
				elements = {
					{ id = "scopes", size = 0.33 },
					{ id = "breakpoints", size = 0.17 },
					{ id = "stacks", size = 0.25 },
					{ id = "watches", size = 0.25 },
				},
				size = 0.33,
				position = "right",
			},
			{
				elements = {
					{ id = "repl", size = 0.45 },
					{ id = "console", size = 0.55 },
				},
				size = 0.27,
				position = "bottom",
			},
		},
		floating = {
			max_height = 0.9,
			max_width = 0.5, -- Floats will be treated as percentage of your screen.
			border = vim.g.border_chars, -- Border style. Can be 'single', 'double' or 'rounded'
			mappings = {
				close = { "q", "<Esc>" },
			},
		},
	}) -- use default
	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open({})
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close({})
	end
	dap.listeners.before.event_exited["dapui_config"] = function()
		dapui.close({})
	end
end

local function configure_debuggers() end

function M.setup()
	configure() -- Configuration
	configure_exts() -- Extensions
	configure_debuggers() -- Debugger
	require("config.dap.keymaps").setup() -- Keymaps
	require("config.dap.cpp").setup()
	-- require("dap.ext.vscode").load_launchjs(nil, { codelldb = { "c", "cpp", "rust" } })
end

configure_debuggers()

return M
