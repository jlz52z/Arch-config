return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>p", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>P", builtin.live_grep, { desc = "Search with live grep" })
            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {                                            -- 插入模式下的快捷键
                            ["<C-j>"] = require("telescope.actions").move_selection_next, -- 下移
                            ["<C-k>"] = require("telescope.actions").move_selection_previous, -- 上移
                        },
                        n = {                                            -- 普通模式下的快捷键
                            ["j"] = require("telescope.actions").move_selection_next, -- 下移
                            ["k"] = require("telescope.actions").move_selection_previous, -- 上移
                        },
                    },
                },
            })
        end,
    },
}
