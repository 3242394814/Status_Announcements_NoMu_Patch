---@diagnostic disable: lowercase-global
name = "快捷宣告(Nomu)补丁"
author = "冰冰羊"
description = [[
需要同时开启原 快捷宣告(Nomu) 模组

修复在选人界面宣告激活的技能点时崩溃的问题
修复宣告海难/猪镇世界温度时崩溃的问题
修复无法正常宣告海难/猪镇当前(白天/黄昏/夜晚)阶段剩余时间的BUG
修复宣告IA船上装备的物品时崩溃的问题
修复因Show Me导致的无法宣告暖石信息的问题

优化季节宣告相关功能
]]
version = "1.1.2"
dst_compatible = true
dont_starve_compatible = false
client_only_mod = true
all_clients_require_mod = false
icon_atlas = "images/modicon.xml"
icon = "modicon.tex"
forumthread = ""
api_version_dst = 10
priority = -10000002

-- 这玩意对客户端Mod来说好像没法用..
-- mod_dependencies = {
--     {
--         workshop = "workshop-2784715091",
--     },
-- }