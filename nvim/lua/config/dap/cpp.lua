local M = {}

function M.setup()
    -- local dap_install = require "dap-install"
    -- dap_install.config("codelldb", {})

    local dap = require("dap")
    local install_root_dir = vim.fn.stdpath("data") .. "/mason"
    local extension_path = install_root_dir .. "/packages/codelldb/extension/"
    local codelldb_path = extension_path .. "adapter/codelldb"

    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = codelldb_path,
            args = { "--port", "${port}" },

            -- On windows you may have to uncomment this:
            -- detached = false,
        },
    }
    -- 配置cppdbg适配器
    dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = vim.fn.expand("~/.local/share/nvim/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7"),
        options = {
            detached = false,
        },
    }
    dap.configurations.cpp = {
        {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
                -- 智能查找可执行文件
                local default_path
                local build_dirs = { "build", "bin", "out", "cmake-build-debug" }

                for _, dir in ipairs(build_dirs) do
                    local path = vim.fn.getcwd() .. "/" .. dir
                    if vim.fn.isdirectory(path) == 1 then
                        default_path = path
                        break
                    end
                end

                default_path = default_path or vim.fn.getcwd()
                return vim.fn.input("Path to executable: ", default_path .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = function()
                local args_str = vim.fn.input("Arguments: ")
                local args = {}
                for arg in string.gmatch(args_str, "%S+") do
                    table.insert(args, arg)
                end
                return args
            end,
            env = function()
                local env_str = vim.fn.input("Environment variables (KEY1=VALUE1,KEY2=VALUE2): ")
                if env_str == "" then
                    return nil
                end

                local env = {}
                for pair in string.gmatch(env_str, "[^,]+") do
                    local key, value = string.match(pair, "([^=]+)=(.*)")
                    if key and value then
                        env[key] = value
                    end
                end
                return env
            end,
            showDisassembly = "auto",
            sourceMaps = true,
            console = "integratedTerminal",
        },
        {
            name = "Attach to process",
            type = "codelldb",
            request = "attach",
            pid = function()
                local output = vim.fn.system("ps -e -o pid,comm | grep -v grep | sort -n")
                local lines = vim.split(output, "\n")
                local processes = {}
                for _, line in ipairs(lines) do
                    local pid, name = string.match(line, "%s*(%d+)%s+(.+)")
                    if pid and name then
                        table.insert(processes, { pid = pid, name = name })
                    end
                end

                local choices = {}
                for i, proc in ipairs(processes) do
                    table.insert(choices, string.format("[%d] %s (%s)", i, proc.name, proc.pid))
                end

                local choice = vim.fn.inputlist({ "Select process to attach:", unpack(choices) })
                if choice > 0 and choice <= #processes then
                    return tonumber(processes[choice].pid)
                end
                return nil
            end,
            cwd = "${workspaceFolder}",
            showDisassembly = "auto",
            sourceMaps = true,
        },
    }

    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp
end

return M
