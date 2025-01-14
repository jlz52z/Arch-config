-- Define function for keymap
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
-- https://www.reddit.com/r/vim/comments//2k4cbr/problem_with_gj_and_gk/
-- Remap 'j' and 'k' to handle display (wrapped) lines properly.
-- If no count is provided, use 'gj' or 'gk' to move by display lines.
-- If a count is provided, use the regular 'j' or 'k' to move by actual lines.
vim.keymap.set("n", "j", "v:count ? 'j' : 'gj'", { noremap = true, silent = true, expr = true })
vim.keymap.set("n", "k", "v:count ? 'k' : 'gk'", { noremap = true, silent = true, expr = true })

-- 在视觉模式下移动选中代码块
vim.keymap.set('v', '<S-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('v', '<S-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })



-- Keymap
local keymaps = {
  -- Normal Mode
  normal_mode = {
    -- Window operations
    ["<leader>vs"] = ":vsplit<CR>",     -- Split the window vertically
    ["<leader>hs"] = ":split<CR>",      -- Split the window horizontally
--    ["<C-h>"] = "<C-w>h",              -- Move focus to the window on the left
--    ["<C-l>"] = "<C-w>l",              -- Move focus to the window on the right
--    ["<C-j>"] = "<C-w>j",              -- Move focus to the window below
--    ["<C-k>"] = "<C-w>k",              -- Move focus to the window above
    ["<leader>q"] = "<C-w>c",          -- Close the current window
    ["<leader>o"] = "<C-w>o",          -- Close all other windows
    ["<leader>+"] = "<C-w>+",          -- Increase window height
    ["<leader>-"] = "<C-w>-",          -- Decrease window height
    ["<leader>>"] = "<C-w>>",          -- Increase window width
    ["<leader><"] = "<C-w><",          -- Decrease window width

    -- Clear search highlight after pressing <Esc>
    ["<Esc>"] = ":nohlsearch<CR><Esc>",

    -- Press P to paste 
    ["P"] = ":pu<CR>",

    ["<Leader>["] = "<C-o>",
    ["<Leader>]"] = "<C-i>",
    ["d"] = '"ad',
  },

  -- Insert Mode
  insert_mode = {
  },

  -- Visual Mode
  visual_mode = {
    ["<"] = "<gv", -- Keep selection after indenting left
    [">"] = ">gv", -- Keep selection after indenting right
  },

  -- Command Mode
  command_mode = {
    -- Prevent accidental use of capital Q to quit
    ["Q"] = "<Nop>",
  },
}

-- Apply key mappings
for mode, mappings in pairs(keymaps) do
  for lhs, rhs in pairs(mappings) do
    map(mode:sub(1, 1), lhs, rhs) -- `mode:sub(1, 1)` gets the first letter of the mode
  end
end

