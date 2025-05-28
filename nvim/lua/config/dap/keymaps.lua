local M = {}

local whichkey = require("which-key")
-- local legendary = require "legendary"

-- local function keymap(lhs, rhs, desc)
--   vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
-- end

function M.setup()
	whichkey.add({
		{ "<leader>d", group = "DAP", nowait = false, remap = false },
		{
			"<leader>dC",
			"<cmd>lua require'dap'.set_breakpoint(vim.fn.input '[Condition] > ')<cr>",
			desc = "Conditional Breakpoint",
			nowait = false,
			remap = false,
		},
		{
			"<leader>dE",
			"<cmd>lua require'dapui'.eval(vim.fn.input '[Expression] > ')<cr>",
			desc = "Evaluate Input",
			nowait = false,
			remap = false,
		},
		{
			"<leader>dR",
			"<cmd>lua require'dap'.run_to_cursor()<cr>",
			desc = "Run to Cursor",
			nowait = false,
			remap = false,
		},
		{
			"<leader>dS",
			"<cmd>lua require'dap.ui.widgets'.scopes()<cr>",
			desc = "Scopes",
			nowait = false,
			remap = false,
		},
		{ "<leader>dU", "<cmd>lua require'dapui'.toggle()<cr>", desc = "Toggle UI", nowait = false, remap = false },
		{ "<leader>db", "<cmd>lua require'dap'.step_back()<cr>", desc = "Step Back", nowait = false, remap = false },
		{ "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", desc = "Continue", nowait = false, remap = false },
		{ "<F5>", "<cmd>lua require'dap'.continue()<cr>", desc = "Continue", nowait = false, remap = false },
		{ "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>", desc = "Disconnect", nowait = false, remap = false },
		{ "<leader>de", "<cmd>lua require'dapui'.eval()<cr>", desc = "Evaluate", nowait = false, remap = false },
		{ "<leader>dg", "<cmd>lua require'dap'.session()<cr>", desc = "Get Session", nowait = false, remap = false },
		{
			"<leader>dh",
			"<cmd>lua require'dap.ui.widgets'.hover()<cr>",
			desc = "Hover Variables",
			nowait = false,
			remap = false,
		},
		{ "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", desc = "Step Into", nowait = false, remap = false },
		{ "<F11>", "<cmd>lua require'dap'.step_into()<cr>", desc = "Step Into", nowait = false, remap = false },
		{ "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", desc = "Step Over", nowait = false, remap = false },
		{ "<F10>", "<cmd>lua require'dap'.step_over()<cr>", desc = "Step Over", nowait = false, remap = false },
		{ "<leader>dp", "<cmd>lua require'dap'.pause.toggle()<cr>", desc = "Pause", nowait = false, remap = false },
		{ "<leader>dq", "<cmd>lua require'dap'.close()<cr>", desc = "Quit", nowait = false, remap = false },
		{
			"<leader>dr",
			"<cmd>lua require'dap'.repl.toggle()<cr>",
			desc = "Toggle Repl",
			nowait = false,
			remap = false,
		},
		{
			"<leader>dt",
			"<cmd>lua require'dap'.toggle_breakpoint()<cr>",
			desc = "Toggle Breakpoint",
			nowait = false,
			remap = false,
		},
		{ "<leader>du", "<cmd>lua require'dap'.step_out()<cr>", desc = "Step Out", nowait = false, remap = false },
		{ "<leader>dx", "<cmd>lua require'dap'.terminate()<cr>", desc = "Terminate", nowait = false, remap = false },
	})
	--- require("legendary.integrations.which-key").bind_whichkey(keymap, opts, false)
	whichkey.add({
		{ "<leader>d", group = "Debug", mode = "v", nowait = false, remap = false },
		{
			"<leader>de",
			"<cmd>lua require'dapui'.eval()<cr>",
			desc = "Evaluate",
			mode = "v",
			nowait = false,
			remap = false,
		},
	})
	--- require("legendary.integrations.which-key").bind_whichkey(keymap_v, opts, false)
end

return M
