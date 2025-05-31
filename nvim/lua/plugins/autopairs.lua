return {
    "windwp/nvim-autopairs",
    -- event = "InsertEnter",
    config = function()
        local npairs = require("nvim-autopairs")
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local handlers = require("nvim-autopairs.completion.handlers")
        local cmp = require("cmp")
        cmp.event:on(
            "confirm_done",
            cmp_autopairs.on_confirm_done({
                filetypes = {
                    -- "*" is a alias to all filetypes
                    ["*"] = {
                        ["("] = {
                            kind = {
                                cmp.lsp.CompletionItemKind.Function,
                                cmp.lsp.CompletionItemKind.Method,
                            },
                            handler = handlers["*"],
                        },
                    },
                    -- Disable for tex
                    tex = false,
                },
            })
        )
        npairs.setup({
            fast_wrap = {},
            map_bs = true,
            check_ts = true,
            ts_config = {
                lua = { "string" }, -- it will not add a pair on that treesitter node
                javascript = { "template_string" },
            },
        })
    end,
}
