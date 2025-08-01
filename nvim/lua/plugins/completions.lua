return {
    {
        "hrsh7th/cmp-nvim-lsp",
    },
    -- {
    --         "zbirenbaum/copilot-cmp",
    --         config = function()
    --             require("copilot_cmp").setup()
    --         end,
    -- },
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets" },
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
        config = function()
            vim.keymap.set({ "i", "s" }, "<C-l>", function()
                local ls = require("luasnip")
                if ls.jumpable(1) then
                    ls.jump(1)
                end
            end, { silent = true })

            vim.keymap.set({ "i", "s" }, "<C-h>", function()
                local ls = require("luasnip")
                if ls.jumpable(-1) then
                    ls.jump(-1)
                end
            end, { silent = true })
            require("luasnip.loaders.from_lua").load({ paths = "~/config/nvim/lua/config/snippets" })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            -- "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-cmdline",
        },
        config = function()
            local has_cmp, cmp = pcall(require, "cmp")

            if has_cmp then
                local rhs = function(rhs_str)
                    return vim.api.nvim_replace_termcodes(rhs_str, true, true, true)
                end
                local has_luasnip, luasnip = pcall(require, "luasnip")
                local lsp_kinds = {
                    Text = "",
                    Method = "󰆧",
                    Function = "󰊕",
                    Constructor = "",
                    Field = "󰇽",
                    Variable = "󰂡",
                    Class = "󰠱",
                    Interface = "",
                    Module = "",
                    Property = "󰜢",
                    Unit = "",
                    Value = "󰎠",
                    Enum = "",
                    Keyword = "󰌋",
                    Snippet = "",
                    Color = "󰏘",
                    File = "󰈙",
                    Reference = "",
                    Folder = "󰉋",
                    EnumMember = "",
                    Constant = "󰏿",
                    Struct = "",
                    Event = "",
                    Operator = "󰆕",
                    TypeParameter = "󰅲",
                }
                -- Returns the current column number.
                local column = function()
                    local _line, col = unpack(vim.api.nvim_win_get_cursor(0))
                    return col
                end

                -- Based on (private) function in LuaSnip/lua/luasnip/init.lua.
                local in_snippet = function()
                    local session = require("luasnip.session")
                    local node = session.current_nodes[vim.api.nvim_get_current_buf()]
                    if not node then
                        return false
                    end
                    local snippet = node.parent.snippet
                    local snip_begin_pos, snip_end_pos = snippet.mark:pos_begin_end()
                    local pos = vim.api.nvim_win_get_cursor(0)
                    if pos[1] - 1 >= snip_begin_pos[1] and pos[1] - 1 <= snip_end_pos[1] then
                        return true
                    end
                end

                -- Returns true if the cursor is in leftmost column or at a whitespace
                -- character.
                local in_whitespace = function()
                    local col = column()
                    return col == 0 or vim.api.nvim_get_current_line():sub(col, col):match("%s")
                end

                local in_leading_indent = function()
                    local col = column()
                    local line = vim.api.nvim_get_current_line()
                    local prefix = line:sub(1, col)
                    return prefix:find("^%s*$")
                end

                local shift_width = function()
                    if vim.o.softtabstop <= 0 then
                        return vim.fn.shiftwidth()
                    else
                        return vim.o.softtabstop
                    end
                end

                -- Complement to `smart_tab()`.
                --
                -- When 'noexpandtab' is set (ie. hard tabs are in use), backspace:
                --
                --    - On the left (ie. in the indent) will delete a tab.
                --    - On the right (when in trailing whitespace) will delete enough
                --      spaces to get back to the previous tabstop.
                --    - Everywhere else it will just delete the previous character.
                --
                -- For other buffers ('expandtab'), we let Neovim behave as standard and that
                -- yields intuitive behavior, unless the `dedent` parameter is truthy, in
                -- which case we issue <C-D> to dedent (see `:help i_CTRL-D`).
                local smart_bs = function(dedent)
                    local keys = nil
                    if vim.o.expandtab then
                        if dedent then
                            keys = rhs("<C-D>")
                        else
                            keys = rhs("<BS>")
                        end
                    else
                        local col = column()
                        local line = vim.api.nvim_get_current_line()
                        local prefix = line:sub(1, col)
                        if in_leading_indent() then
                            keys = rhs("<BS>")
                        else
                            local previous_char = prefix:sub(#prefix, #prefix)
                            if previous_char ~= " " then
                                keys = rhs("<BS>")
                            else
                                -- Delete enough spaces to take us back to the previous tabstop.
                                --
                                -- Originally I was calculating the number of <BS> to send, but
                                -- Neovim has some special casing that causes one <BS> to delete
                                -- multiple characters even when 'expandtab' is off (eg. if you hit
                                -- <BS> after pressing <CR> on a line with trailing whitespace and
                                -- Neovim inserts whitespace to match.
                                --
                                -- So, turn 'expandtab' on temporarily and let Neovim figure out
                                -- what a single <BS> should do.
                                --
                                -- See `:h i_CTRL-\_CTRL-O`.
                                keys = rhs("<C-\\><C-o>:set expandtab<CR><BS><C-\\><C-o>:set noexpandtab<CR>")
                            end
                        end
                    end
                    vim.api.nvim_feedkeys(keys, "nt", true)
                end

                -- In buffers where 'noexpandtab' is set (ie. hard tabs are in use), <Tab>:
                --
                --    - Inserts a tab on the left (for indentation).
                --    - Inserts spaces everywhere else (for alignment).
                --
                -- For other buffers (ie. where 'expandtab' applies), we use spaces everywhere.
                local smart_tab = function(opts)
                    local keys = nil
                    if vim.o.expandtab then
                        keys = "<Tab>" -- Neovim will insert spaces.
                    else
                        local col = column()
                        local line = vim.api.nvim_get_current_line()
                        local prefix = line:sub(1, col)
                        local in_leading_indent = prefix:find("^%s*$")
                        if in_leading_indent then
                            keys = "<Tab>" -- Neovim will insert a hard tab.
                        else
                            -- virtcol() returns last column occupied, so if cursor is on a
                            -- tab it will report `actual column + tabstop` instead of `actual
                            -- column`. So, get last column of previous character instead, and
                            -- add 1 to it.
                            local sw = shift_width()
                            local previous_char = prefix:sub(#prefix, #prefix)
                            local previous_column = #prefix - #previous_char + 1
                            local current_column = vim.fn.virtcol({ vim.fn.line("."), previous_column }) + 1
                            local remainder = (current_column - 1) % sw
                            local move = remainder == 0 and sw or sw - remainder
                            keys = (" "):rep(move)
                        end
                    end

                    vim.api.nvim_feedkeys(rhs(keys), "nt", true)
                end

                local select_next_item = function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end

                local select_prev_item = function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end

                -- Until https://github.com/hrsh7th/nvim-cmp/issues/1716
                -- (cmp.ConfirmBehavior.MatchSuffix) gets implemented, use this local wrapper
                -- to choose between `cmp.ConfirmBehavior.Insert` and
                -- `cmp.ConfirmBehavior.Replace`:
                local confirm = function(entry)
                    local behavior = cmp.ConfirmBehavior.Replace
                    if entry then
                        local completion_item = entry.completion_item
                        local newText = ""
                        if completion_item.textEdit then
                            newText = completion_item.textEdit.newText
                        elseif type(completion_item.insertText) == "string" and completion_item.insertText ~= "" then
                            newText = completion_item.insertText
                        else
                            newText = completion_item.word or completion_item.label or ""
                        end

                        -- How many characters will be different after the cursor position if we
                        -- replace?
                        local diff_after = math.max(0, entry.replace_range["end"].character + 1)
                            - entry.context.cursor.col

                        -- Does the text that will be replaced after the cursor match the suffix
                        -- of the `newText` to be inserted? If not, we should `Insert` instead.
                        if entry.context.cursor_after_line:sub(1, diff_after) ~= newText:sub(-diff_after) then
                            behavior = cmp.ConfirmBehavior.Insert
                        end
                    end
                    cmp.confirm({ select = true, behavior = behavior })
                end

                cmp.setup({
                    preselect = require("cmp").PreselectMode.None, -- 添加这一行
                    experimental = {
                        -- See also `toggle_ghost_text()` below.
                        ghost_text = true,
                    },

                    formatting = {
                        -- See: https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
                        format = function(entry, vim_item)
                            -- Set `kind` to "$icon $kind".
                            local original_kind_text = vim_item.kind
                            vim_item.kind = string.format("%s %s", lsp_kinds[vim_item.kind], vim_item.kind)
                            vim_item.menu = ({
                                buffer = "[Buffer]",
                                nvim_lsp = "[LSP]",
                                luasnip = "[LuaSnip]",
                                nvim_lua = "[Lua]",
                                latex_symbols = "[LaTeX]",
                                path = "[Path]",
                                copilot = "[Copilot]",
                            })[entry.source.name]
                            -- 为函数和方法添加 () 后缀，以便在菜单中区分
                            if original_kind_text == "Function" or original_kind_text == "Method" then
                                vim_item.abbr = vim_item.abbr .. "()"

                                -- 关键：告诉 cmp 这个函数项是纯文本，而不是 snippet
                                -- 这样选中后就不会自动填充参数了
                                -- LSP 协议: 1 = PlainText, 2 = Snippet
                                -- entry.completion_item.insertTextFormat = 1
                            end
                            vim_item.abbr = vim_item.abbr:gsub("~", "") -- 干掉占位符
                            return vim_item
                        end,
                    },

                    mapping = {
                        -- 会影响autopairs智能删除配对符号
                        -- ["<BS>"] = cmp.mapping(function(_fallback)
                        --     smart_bs()
                        -- end, { "i", "s" }),

                        ["<C-b>"] = cmp.mapping.scroll_docs(-4),

                        -- Choose a choice using vim.ui.select (ugh);
                        -- prettier would be a pop-up, but it will require a bit of config:
                        -- https://github.com/L3MON4D3/LuaSnip/wiki/Misc#choicenode-popup
                        -- ['<C-u>'] = require('luasnip.extras.select_choice'),

                        ["<C-e>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.close()
                            elseif has_luasnip and luasnip.choice_active() then
                                luasnip.jump(1)
                            else
                                fallback()
                            end
                        end, { "i", "s" }),

                        ["<C-f>"] = cmp.mapping.scroll_docs(4),
                        ["<C-j>"] = cmp.mapping(select_next_item),
                        ["<Down>"] = cmp.mapping(select_next_item),
                        ["<C-k>"] = cmp.mapping(select_prev_item),
                        ["<Up>"] = cmp.mapping(select_prev_item),

                        ["<CR>"] = cmp.mapping(function(fallback)
                            local is_visible = cmp.visible()
                            local selected_entry = cmp.get_selected_entry()
                            if is_visible then
                                if selected_entry then
                                    confirm(selected_entry)
                                else
                                    fallback()
                                end
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                        ["<S-Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif has_luasnip and in_snippet() and luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            elseif in_leading_indent() then
                                smart_bs(true) -- true means to dedent
                            elseif in_whitespace() then
                                smart_bs()
                            else
                                fallback()
                            end
                        end, { "i", "s" }),

                        ["<Tab>"] = cmp.mapping(function(_fallback)
                            if cmp.visible() then
                                -- If there is only one completion candidate, use it.
                                local entries = cmp.get_entries()
                                if #entries == 1 then
                                    confirm(entries[1])
                                else
                                    cmp.select_next_item()
                                end
                            elseif has_luasnip and luasnip.expand_or_locally_jumpable() then
                                luasnip.expand_or_jump()
                            elseif in_whitespace() then
                                smart_tab()
                            else
                                cmp.complete()
                            end
                        end, { "i", "s" }),
                    },

                    completion = {
                        completeopt = "menu,menuone,noinsert,noselect",
                    },

                    snippet = {
                        expand = function(args)
                            -- -- 检查补全项的 "body" 是否包含括号，以此判断是否为函数
                            -- -- 如果是函数，就不自动展开，直接返回，相当于只插入函数名
                            -- -- "select_choice" 是 luasnip 在没有可展开内容时的一个特殊值
                            -- if
                            -- 	string.find(args.body, "%(")
                            -- 	and string.find(args.body, "%)")
                            -- 	and args.body ~= "select_choice"
                            -- then
                            -- 	-- 你可以取消下面这行注释来调试，看看哪些内容被拦截了
                            -- 	-- print("Snippet expansion blocked for: " .. args.body)
                            -- 	return
                            -- end
                            if has_luasnip then
                                luasnip.lsp_expand(args.body)
                            end
                        end,
                    },

                    sources = cmp.config.sources({
                        { name = "luasnip" },
                        {
                            name = "nvim_lsp", -- 过滤掉lsp返回的结果中的恼人的恶心的无用的愚蠢的Text类型补全结果
                            entry_filter = function(entry, ctx)
                                return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
                            end,
                        },
                        { name = "nvim_lua" },
                        { name = "buffer" },
                        { name = "calc" },
                        -- { name = "copilot", priority = 60 }, -- 按需启用
                        { name = "emoji" },
                        { name = "path" },
                        -- 调用函数时，显示函数签名
                        -- { name = "nvim_lp_signature_help" },
                    }),

                    window = {
                        completion = cmp.config.window.bordered({
                            border = "single",
                            col_offset = -1,
                            scrollbar = false,
                            scrolloff = 3,
                            -- Default for bordered() is 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
                            -- Default for non-bordered, which we'll use here, is:
                            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
                        }),
                        documentation = cmp.config.window.bordered({
                            border = "solid",
                            scrollbar = false,
                            -- Default for bordered() is 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
                            -- Default for non-bordered is 'FloatBorder:NormalFloat'
                            -- Suggestion from: https://github.com/hrsh7th/nvim-cmp/issues/2042
                            -- is to use 'NormalFloat:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
                            -- but this also seems to suffice:
                            winhighlight = "CursorLine:Visual,Search:None",
                        }),
                    },
                })

                -- Only show ghost text at word boundaries, not inside keywords. Based on idea
                -- from: https://github.com/hrsh7th/nvim-cmp/issues/2035#issuecomment-2347186210

                local config = require("cmp.config")

                local toggle_ghost_text = function()
                    if vim.api.nvim_get_mode().mode ~= "i" then
                        return
                    end

                    local cursor_column = vim.fn.col(".")
                    local current_line_contents = vim.fn.getline(".")
                    local character_after_cursor = current_line_contents:sub(cursor_column, cursor_column)

                    local should_enable_ghost_text = character_after_cursor == ""
                        or vim.fn.match(character_after_cursor, [[\k]]) == -1

                    local current = config.get().experimental.ghost_text
                    if current ~= should_enable_ghost_text then
                        config.set_global({
                            experimental = {
                                ghost_text = should_enable_ghost_text,
                            },
                        })
                    end
                end

                vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, {
                    callback = toggle_ghost_text,
                })
                -- find more here: https://www.nerdfonts.com/cheat-sheet
                require("luasnip.loaders.from_vscode").lazy_load()
                -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
                cmp.setup.cmdline({ "/", "?" }, {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = {
                        { name = "buffer" },
                    },
                })

                -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
                cmp.setup.cmdline(":", {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources({
                        { name = "path" },
                    }, {
                        { name = "cmdline" },
                    }),
                    matching = { disallow_symbol_nonprefix_matching = false },
                })
            end
        end,
    },
}
