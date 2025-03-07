-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
require("config.lazy")
require("config.keymappings")
require("config.options")
-- set custom theme
-- require("config.custom_theme.wallbash")
