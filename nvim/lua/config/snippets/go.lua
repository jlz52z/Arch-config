local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local fmt = require("luasnip.extras.fmt").fmt
local m = extras.m
local l = extras.l
local postfix = require("luasnip.extras.postfix").postfix

-- 引入 fmta
local fmta = require("luasnip.extras.fmt").fmta
 
-- 定义一个名为 "iferr" 的 snippet
local iferr_snippet = s("iferr", fmta(
    -- 使用 fmta 和 <> 作为占位符
    [[
if err != nil {
    return <>
}
]],
    {
        i(1) 
    }
))
 
return {
    iferr_snippet,
}, {
}
