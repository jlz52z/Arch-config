return {
    {
        "williamboman/mason.nvim",
        event = "VeryLazy",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "ts_ls", "clangd", "pyright" },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")

            -- Define a shared on_attach function for all LSPs
            local on_attach = function(client, bufnr)
                -- keybind options
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
            require("lspsaga").setup({})
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
