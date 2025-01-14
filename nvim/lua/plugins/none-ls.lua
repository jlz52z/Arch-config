return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
        sources = {
            -- lua 格式化
            null_ls.builtins.formatting.stylua,
            -- 单词拼写检查
            null_ls.builtins.completion.spell,
            -- c++ 格式化
            null_ls.builtins.formatting.clang_format,
        },
    })

    vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})
  end
}
