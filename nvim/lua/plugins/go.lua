-- lua/plugins/go.lua
return {
    "ray-x/go.nvim",
    dependencies = {
        "ray-x/guihua.lua",                              -- 可选, 用于浮动终端 UI (如调试、测试输出)
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",               -- Go parser 需要安装
        "mfussenegger/nvim-dap",                         -- 调试支持
    },
    event = { "CmdlineEnter" },                          -- 允许随时使用 :Go 命令
    ft = { "go", "gomod", "gowork" },                    -- 只在 Go 相关文件加载
    -- build = ':GoInstallBinaries', -- 首次安装或更新时自动安装/更新 Go 工具 (gopls, dlv, gofmt, goimports 等)
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    config = function()
        local go = require("go")

        go.setup({
            -- ========== General ==========
            go = "go",   -- Go 可执行文件路径 (通常不需要改)
            go_fmt = "goimports", -- 默认格式化工具 ('gofmt', 'goimports', 'gofumpt')
            -- go_fmt = 'gofumpt', -- 如果你喜欢 gofumpt 风格
            -- max_line_len = 120,                                 -- 格式化时的行长限制
            tag_support = true,                        -- 启用 struct tag 功能 (:GoAddTags, :GoRmTags)
            tag_options = { "json", "yaml", "xml", "db" }, -- 自动添加/移除的常见 tag
            test_runner = "dlv",                       -- 使用 delve 进行测试，方便调试 ('go', 'richgo', 'dlv')
            luasnip = true,
            fillstruct_mode = "prompt",                -- 填充结构体时提示 ('prompt', 'recursive')
            -- icons = {breakpoint = '🔴', currentpos = '➡️'}, -- 自定义图标 (需要 Nerd Font)
            verbose = false,                           -- 设置为 true 查看详细日志
            log_path = vim.fn.stdpath("log") .. "/go.nvim.log", -- 日志文件路径

            -- ========== LSP (核心: go.nvim 管理 gopls) ==========
            lsp_cfg = true, -- <<< 让 go.nvim 负责配置 gopls (非常重要!)
            lsp_on_attach = function(client, bufnr)
                -- keybind options
                -- go相关的lsp快捷键在go.lua中定义
                local keymap = vim.keymap -- for conciseness
                local opts = { noremap = true, silent = true, buffer = bufnr }

                -- set keybinds
                keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", opts)  -- 跳转到定义
                keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>", opts)           -- 显示定义和引用
                keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)         -- 显示文档
                keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)   -- 智能重命名
                keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- 显示代码操作
                keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- 显示当前行诊断信息
                keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- 跳转到上一个诊断
                keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- 跳转到下一个诊断
                keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", opts)   -- 打开符号大纲
                keymap.set("n", "<leader>gi", "<cmd>Lspsaga incoming_calls<CR>", opts) -- 逆向追溯：谁调用了当前符号
                keymap.set("n", "<leader>go", "<cmd>Lspsaga outgoing_calls<CR>", opts) -- 正向追踪：当前符号调用了谁
                keymap.set("n", "<leader>gD", "<cmd>Lspsaga peek_definition<CR>", opts) -- 在浮动窗口中查看函数具体实现代码
                keymap.set("n", "<leader>gR", "<cmd>Lspsaga peek_type_definition<CR>", opts) -- 在浮动窗口中查看类型系统的类型定义
                ---- Inlay Hints are provided by Language Servers and should be enabled there
                opts.desc = "Enable Inlay hints"
                keymap.set("n", "<leader>i", function()
                    local status = vim.lsp.inlay_hint.is_enabled() and "OFF" or "ON"
                    vim.api.nvim_notify("Toggling inlay hints " .. status, vim.log.levels.INFO, {})
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                end, opts)
            end,
            lsp_keymaps = true, -- 使用 go.nvim 推荐的 Go 相关 LSP 快捷键
            lsp_codelens = true, -- 启用 CodeLens (如测试运行按钮)
            -- lsp_diag_hdlr = true,                                                            -- 使用 go.nvim 的诊断处理
            -- lsp_diag_virtual_text = true,                                                    -- 在行尾显示诊断信息
            -- lsp_diag_signs = true,                                                           -- 在符号列显示诊断图标
            -- lsp_diag_underline = true,                                                       -- 用下划线标记诊断区域
            diagnostic = { -- set diagnostic to false to disable vim.diagnostic.config setup,
                -- true: default nvim setup
                hdlr = false, -- hook lsp diag handler and send diag to quickfix
                underline = true,
                virtual_text = { spacing = 2, prefix = "" }, -- virtual text setup
                signs = { "", "", "", "" }, -- set to true to use default signs, an array of 4 to specify custom signs
                update_in_insert = true,
            },
            lsp_semantic_tokens = true, -- 启用语义高亮 (需要主题支持)
            lsp_inlay_hints = { -- 内联提示 (需要 gopls >= v0.9.0 & Nvim >= 0.10 效果最佳)
                enable = true,
                -- 下面的选项需要更新的 gopls 和 Nvim nightly 可能才支持得好
                parameter_hints = { enable = true },
                type_hints = { enable = true },
                variable_types = { enable = true },
                range_variable_types = { enable = true },
                constant_values = { enable = true },
                function_return_types = { enable = true },
                composite_literal_fields = { enable = true },
                composite_literal_types = { enable = true },
                show_implicit_equals_in_range = true,
            },

            -- ========== Formatting ==========
            format_on_save = true, -- 保存时自动格式化
            format_tool = nil, -- 设为 nil 会使用 go_fmt 设置的值 ('goimports')

            -- ========== Debugging (nvim-dap integration) ==========
            dap_debug = false,                     -- 启用调试功能
            dap_debug_keymap = false,              -- 添加调试快捷键 (如 <leader>dd 启动)
            dap_debug_gui = false,                 -- 使用 guihua.lua 作为调试 UI
            dap_debug_term_mode = "integrated",    -- 或 'float', 'integrated', 'external'
            dap_delve_backend = "native",          -- 'native', 'legacy', 'core' (native 推荐)
            dap_delve_build_flags = '-gcflags="all=-N -l"', -- 禁用优化，方便调试

            -- ========== Testing ==========
            test_keymap = true, -- 添加测试快捷键 (如 <leader>gt 运行测试)
            test_timeout = "30s", -- 测试超时时间

            -- ========== Go Commands Keymaps (可自定义) ==========
            -- (go.nvim 默认会添加一些, 这里可以覆盖或补充)
            -- vim.keymap.set('n', '<leader>gg', '<Cmd>GoRun<CR>', {desc = "Go Run File"})

            -- ========== Tools Installation ==========
            -- tools = { ... } -- 可以自定义工具安装路径或行为

            -- ========== Treesitter Integration ==========
            highlight_fields = true, -- 高亮结构体字段
            highlight_functions = true, -- 高亮函数定义
            highlight_methods = true, -- 高亮方法定义
            highlight_operators = true, -- 高亮操作符
            highlight_structs = true, -- 高亮结构体类型
            highlight_type_spec = true, -- 高亮类型定义
        })

        -- ============================================================
        -- == 定义 Go 文件类型的缓冲区局部 (Buffer-Local) 快捷键 ==
        -- ============================================================
        -- 创建一个自动命令组，确保只应用一次并且可以被清除
        local go_keymaps_group = vim.api.nvim_create_augroup("GoKeymaps", { clear = true })
        -- 定义自动命令：当文件类型是 go, gomod, 或 gowork 时执行
        vim.api.nvim_create_autocmd("FileType", {
            group = go_keymaps_group,
            pattern = { "go", "gomod", "gowork" }, -- 触发的文件类型
            callback = function(args)
                -- args.buf 是触发事件的缓冲区编号
                local map = vim.keymap.set
                -- 定义快捷键选项，关键是设置 buffer = args.buf 使其局部化
                local opts = { noremap = true, silent = true, buffer = args.buf, desc = "" }
                -- print("Setting up Go-specific keymaps for buffer: " .. args.buf)
                -- === 测试相关 ===
                -- 运行光标下的测试函数。
                opts.desc = "[G]o [T]est [F]unction (运行当前测试函数)"
                map("n", "<leader>gtf", "<Cmd>GoTestFunc<CR>", opts)
                -- 运行当前文件中的所有测试。
                opts.desc = "[G]o [T]est [F]ile (运行当前文件测试)"
                map("n", "<leader>gtF", "<Cmd>GoTestFile<CR>", opts)
                -- 在运行带覆盖率的测试后，切换编辑器中测试覆盖率的高亮显示。
                opts.desc = "[G]o [C]overage Toggle (切换测试覆盖率高亮)"
                map("n", "<leader>gc", "<Cmd>GoCoverageToggle<CR>", opts)
                -- 在浮动窗口中显示最新的测试结果摘要。
                opts.desc = "[G]o Test Summar[y] (显示测试摘要)"
                map("n", "<leader>gty", "<Cmd>GoTestSum<CR>", opts)
                -- === 构建/运行 ===
                -- 编译并运行当前的 Go 文件（如果包含 main 函数）。
                opts.desc = "[G]o [R]u[n] File (运行当前文件)"
                map("n", "<leader>grn", "<Cmd>wall | GoRun<CR>", opts)
                -- 停止运行当前的 Go 文件。
                opts.desc = "[G]o [S]top Process (停止 Go 进程)"
                map("n", "<leader>gs", "<Cmd>GoStop<CR>", opts)
                -- 编译当前包（相当于 'go build'），检查错误。
                opts.desc = "[G]o [B]uild (构建包)"
                map("n", "<leader>gb", "<Cmd>GoBuild<CR>", opts)
                -- === Go Modules / Imports ===
                -- 整理 go.mod 文件（添加缺失的依赖项/移除未使用的依赖项）。模块维护必备。
                opts.desc = "[G]o [M]od Tidy (整理 Go Modules)"
                map("n", "<leader>gm", "<Cmd>GoModTidy<CR>", opts)
                -- 使用 goimports 格式化当前缓冲区（同时组织导入）。用于手动格式化。
                opts.desc = "[G]o [I]mports (运行 goimports)"
                map("n", "<leader>gI", "<Cmd>GoImports<CR>", opts)
                -- 解释为什么需要某个包或模块（会提示输入）。用于依赖分析。
                opts.desc = "[G]o Mod [W]hy (解释依赖原因)"
                map("n", "<leader>gw", "<Cmd>GoModWhy<CR>", opts)
                -- === 代码生成 / Struct 操作 ===
                -- 自动填充光标下结构体字面量中的字段（如果需要会提示）。加速初始化。
                opts.desc = "[G]o [F]ill Struct (填充结构体)"
                map("n", "<leader>ggf", "<Cmd>GoFillStruct<CR>", opts)
                -- 为光标下结构体定义的字段添加结构体标签（例如 json, yaml）（会提示标签类型）。
                opts.desc = "[G]o [A]dd Tags (添加结构体标签)"
                map("n", "<leader>gta", "<Cmd>GoAddTags<CR>", opts)
                -- 从光标下结构体定义的字段中移除结构体标签（会提示标签类型）。
                opts.desc = "[G]o [R]emove Tags (移除结构体标签)"
                map("n", "<leader>gtr", "<Cmd>GoRmTags<CR>", opts)
                -- 为类型生成实现接口的方法桩（会提示类型和接口）。加速接口实现。
                opts.desc = "[G]o [Impl]ement Interface (实现接口)"
                map("n", "<leader>gimpl", "<Cmd>GoImpl<CR>", opts)
                -- 在当前目录运行 'go generate'，处理 '//go:generate' 指令。
                opts.desc = "[G]o [Gen]erate (运行 go generate)"
                map("n", "<leader>ggen", "<Cmd>GoGenerate<CR>", opts)
                opts.desc = "[G]p [G]enerate [R]eturn (自动为函数生成返回值和错误处理)"
                map("n", "<leader>ggr", "<Cmd>GoGenReturn<CR>", opts)

                -- 这个不起作用，先注释
                -- opts.desc = "[G]o from [J]SON (从剪贴板生成结构体)"
                -- vim.keymap.set("n", "<leader>gj", ':"+GoJson2Struct<CR>', opts)
                opts.desc = "[G]o from [J]SON (从选中内容生成结构体)"
                vim.keymap.set("v", "<leader>gj", ":GoJson2Struct<CR>", opts)

                -- 自定义结构体名称会出错，暂时使用默认名称
                -- -- 1. Normal Mode: 从剪贴板 (+) 生成
                -- opts.desc = "[G]o from [J]SON (Clipboard)"
                -- map("n", "<leader>gj", function()
                -- 	-- 弹出一个输入框让用户输入结构体名称
                -- 	vim.ui.input({ prompt = "Struct Name: " }, function(name)
                -- 		if not name or name == "" then
                -- 			name = "T" -- 如果用户不输入，则使用默认名称 T
                -- 		end
                -- 		-- 执行命令，从剪贴板寄存器 '+' 获取 JSON
                -- 		vim.cmd(':"+GoJson2Struct ' .. name)
                -- 	end)
                -- end, opts)
                --
                -- -- 2. Visual Mode: 从选中的文本生成
                -- opts.desc = "[G]o from [J]SON (Visual Selection)"
                -- map("v", "<leader>gj", function()
                -- 	-- 弹出一个输入框让用户输入结构体名称
                -- 	vim.ui.input({ prompt = "Struct Name: " }, function(name)
                -- 		if not name or name == "" then
                -- 			name = "T"
                -- 		end
                -- 		-- Neovim 会自动处理范围，我们只需要构建并执行命令
                -- 		-- 使用 vim.fn.escape 来确保名称中的特殊字符被正确处理
                -- 		local command = "GoJson2Struct " .. vim.fn.escape(name, " ")
                -- 		vim.api.nvim_command(command)
                -- 	end)
                -- end, opts)

                -- === 代码导航 / 查看 ===
                -- 在 Go 源文件 (.go) 和其对应的测试文件 (_test.go) 之间快速切换。
                opts.desc = "[G]o [Alt]ernate File (切换源/测试文件)"
                map("n", "<leader>ga", "<Cmd>GoAlt<CR>", opts)
                -- 使用 'godoc' 在 Web 浏览器中打开光标下符号的文档。
                opts.desc = "[G]o [Doc] (查看 Go 文档)"
                map("n", "<leader>gdoc", "<Cmd>GoDoc<CR>", opts)
                opts.desc = "[G]o [P]kg [O]utline (显示当前 Go 包的 Outline)"
                map("n", "<leader>gpo", "<Cmd>GoPkgOutline<CR>", opts)
                -- === Linting / Vetting ===
                -- 对当前包/缓冲区运行 golint 以检查代码风格问题（注意：golint 常被 golangci-lint 替代）。
                opts.desc = "[G]o [L]int (运行 golint)"
                map("n", "<leader>gl", "<Cmd>GoLint<CR>", opts)
                -- 对当前包运行 go vet 以查找可疑构造和潜在错误。
                opts.desc = "[G]o [V]et (运行 go vet)"
                map("n", "<leader>gv", "<Cmd>GoVet<CR>", opts)
                -- === 调试相关 (补充 go.nvim 默认键) ===
                -- 启动调试。如果存在多个调试配置，会提示选择一个。在暂停时也用于继续执行。
                opts.desc = "[G]o [D]ebug [S]elect Configuration / Continue (选择配置/继续调试)"
                map("n", "<leader>gds", "<Cmd>GoDebug<CR>", opts)
                -- 将调试器附加到已在运行的 Go 进程（会提示输入进程 ID）。
                opts.desc = "[G]o [D]ebug Attach (附加到进程调试)"
                map("n", "<leader>gda", "<Cmd>GoDebugAttach<CR>", opts)
            end,
        })
    end,
}
