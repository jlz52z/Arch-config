return {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
        -- vim.cmd.colorscheme "catppuccin"
        require("catppuccin").setup({
            -- 关键设置
            transparent_background = true,
            no_italic = false,
            no_bold = false,

            -- 通用分组（覆盖非 Treesitter 场景）
            styles = {
                comments = { "italic" },
                conditionals = {}, -- VS Code 里关键字整体非斜体
                functions = { "italic" },
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = { "italic" },
                operators = {},
            },

            -- 细分到 Treesitter/LSP 与 Markdown 场景
            custom_highlights = function(_)
                return {
                    -- Treesitter 语义
                    ["@function"] = { italic = true },
                    ["@function.method"] = { italic = true },
                    ["@constructor"] = { italic = true },
                    ["@type"] = { italic = true },
                    ["@type.builtin"] = { italic = true },
                    ["@parameter"] = { italic = true },

                    -- Markdown 强调
                    ["@markup.italic"] = { italic = true },
                    ["@markup.strong"] = { bold = true },

                    -- 兼容旧语法组（无 TS 时）
                    Function = { italic = true },
                    Type = { italic = true },
                }
            end,
        })
    end,
}
