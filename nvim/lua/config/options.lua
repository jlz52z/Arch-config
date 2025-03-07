-- 基础设置
local set = vim.opt

-- 设置剪贴板为系统剪贴板
set.clipboard = "unnamedplus"

-- 按键超时时间设置
set.timeoutlen = 300        -- 映射序列的超时时间（300 毫秒）
set.ttimeoutlen = 10        -- 终端模式下按键超时（10 毫秒）

-- 行号和光标设置
set.number = true           -- 显示行号
set.relativenumber = true   -- 显示相对行号
set.cursorline = true       -- 高亮当前行

-- 缩进设置
set.tabstop = 4             -- Tab 显示为 4 个空格
set.shiftwidth = 4          -- 缩进时使用 4 个空格
set.expandtab = true        -- 将 Tab 转为空格
set.smartindent = true      -- 启用智能缩进

-- 搜索设置
set.ignorecase = true       -- 搜索时忽略大小写
set.smartcase = true        -- 当搜索包含大写字符时，自动启用大小写敏感
set.hlsearch = true         -- 高亮搜索结果
set.incsearch = true        -- 增量搜索

-- 窗口分割行为
set.splitbelow = true       -- 新窗口从下方打开
set.splitright = true       -- 新窗口从右侧打开

-- 性能优化
set.lazyredraw = true       -- 禁用实时重绘，提高性能
set.updatetime = 300        -- 插入模式光标保持时间（默认是 4000 毫秒）

-- 其他 UI 设置
set.termguicolors = true    -- 启用 24 位 RGB 色彩支持
set.scrolloff = 8           -- 光标移动时，保持顶部和底部的间距
set.sidescrolloff = 8       -- 左右滚动时保持间距


-- 自动为 Python 环境安装 pynvim
local function ensure_pynvim_installed()
    local python3 = vim.g.python3_host_prog or "python3"
    -- 检查 pip 是否可用
    local check_pip_handle = io.popen(python3 .. " -m pip --version 2>/dev/null")
    local pip_version = check_pip_handle:read("*a")
    check_pip_handle:close()

    if pip_version == "" then
        print("Error: pip is not installed. Please install pip for " .. python3)
        return
    end

    -- 检查 pynvim 是否已经安装
    local check_pynvim_handle = io.popen(python3 .. " -m pip show pynvim 2>/dev/null")
    local pynvim_info = check_pynvim_handle:read("*a")
    check_pynvim_handle:close()

    if pynvim_info == "" then
        vim.cmd("! " .. python3 .. " -m pip install pynvim")
        print("Installed pynvim for Python 3 provider.")
    end
end

ensure_pynvim_installed()


-- 开启持久化撤销
vim.opt.undofile = true  -- 等同于 set undofile

-- 指定撤销文件存储目录
vim.opt.undodir = os.getenv("HOME") .. "/config/nvim/undodir"

-- 始终显示 signcolumn，防止文本移动
vim.opt.signcolumn = "yes"

-- 开启 Folding
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
-- 默认不要折叠
-- https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
vim.wo.foldlevel = 99

-- 开启自动保存
vim.api.nvim_create_autocmd({"InsertLeave", "TextChanged"}, {
  pattern = "*",
  command = "silent! write",
})
