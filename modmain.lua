GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})

function getval(fn, path)
    if fn == nil or type(fn)~="function" then return end
    local val = fn
    local i
    for entry in path:gmatch("[^%.]+") do
        i = 1
        while true do
            local name, value = debug.getupvalue(val, i)
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i = i + 1
        end
    end
    return val, i
end

function setval(fn, path, new)
    if fn == nil or type(fn)~="function" then return end
    local val = fn
    local prev = nil
    local i
    for entry in path:gmatch("[^%.]+") do
        i = 1
        prev = val
        while true do
            local name, value = debug.getupvalue(val, i)
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i = i + 1
        end
    end
    debug.setupvalue(prev, i, new)
end

if not rawget(_G, "NOMU_QA") then return end

----- 快捷宣告(NoMu)模组，更新宣告内容预设 -----
AddSimPostInit(function()
    TheGlobalInstance:DoTaskInTime(0.1,function()
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.SEASON.FORMATS.DEFAULT = string.gsub(GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.SEASON.FORMATS.DEFAULT, "{SEASON}天", "{SEASON}")
        GLOBAL.NOMU_QA.SCHEME.SEASON.FORMATS.DEFAULT = string.gsub(GLOBAL.NOMU_QA.SCHEME.SEASON.FORMATS.DEFAULT, "{SEASON}天", "{SEASON}")

        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.FORMATS.NO_RAIN = GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.FORMATS.NO_RAIN == '{WORLD}气温：{TEMPERATURE}°，{SEASON}天不再{WEATHER}' and "{WORLD}气温：{TEMPERATURE}°，{WEATHER}尚未接近。" or GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.FORMATS.NO_RAIN
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WORLD.SHIPWRECKED = "海难"
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WORLD.VOLCANO = "火山"
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WORLD.PORKLAND = "猪镇"
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.TEMPERATE = "降雨" -- 平和季
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.HUMID = "降雨" -- 潮湿季
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.LUSH = "降雨" -- 繁茂季
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.APORKALYPSE = "降雨" -- 大灾变
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.GREEN = "降雨" -- 雨季
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.DRY = "降雨" -- 旱季
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.MILD = "降雨" -- 温和季
        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.WET = "飓风" --  飓风季

        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.FORMATS.NO_RAIN = GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.FORMATS.NO_RAIN == '{WORLD}气温：{TEMPERATURE}°，{SEASON}天不再{WEATHER}' and "{WORLD}气温：{TEMPERATURE}°，{WEATHER}尚未接近。" or GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.FORMATS.NO_RAIN
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WORLD.SHIPWRECKED = "海难"
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WORLD.VOLCANO = "火山"
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WORLD.PORKLAND = "猪镇"
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.TEMPERATE = "降雨" -- 平和季
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.HUMID = "降雨" -- 潮湿季
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.LUSH = "降雨" -- 繁茂季
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.APORKALYPSE = "降雨" -- 大灾变
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.GREEN = "降雨" -- 雨季
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.DRY = "降雨" -- 旱季
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.MILD = "降雨" -- 温和季
        GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WEATHER.WET = "飓风" --  飓风季
    end)
end)

modimport("qa_utils_fix.lua")

-- 宣告消息
local function Announce(message, no_whisper)
    message = message:gsub("(%d)\176(C|F)", "%1°%2") -- 修复无法宣告暖石温度的问题...show me用的 ° 是 "\176" 这个玩意无法被Say出来...
    local whisper = GLOBAL.NOMU_QA.DATA.DEFAULT_WHISPER ~= TheInput:IsKeyDown(KEY_LCTRL)
    if no_whisper then
        whisper = false
    end
    TheNet:Say(STRINGS.LMB .. ' ' .. message, whisper)
    return true
end

local function GetMapping(qa, category, key)
    local prefab = ThePlayer.prefab:upper()
    return GLOBAL.NOMU_QA.DATA.CHARACTER_SPECIFIC and qa.MAPPINGS[prefab] and qa.MAPPINGS[prefab][category] and qa.MAPPINGS[prefab][category][key] or qa.MAPPINGS.DEFAULT[category][key]
end

local function AnnounceBadge(qa, current, max, category)
    local fmts = {
        CURRENT = math.floor(current + 0.5),
        MAX = max,
        MESSAGE = GetMapping(qa, 'MESSAGE', category)
    }
    if GetMapping(qa, 'SYMBOL', 'EMOJI') and TheInventory:CheckOwnership('emoji_' .. GetMapping(qa, 'SYMBOL', 'EMOJI')) then
        fmts.SYMBOL = ':' .. GetMapping(qa, 'SYMBOL', 'EMOJI') .. ':'
    else
        fmts.SYMBOL = GetMapping(qa, 'SYMBOL', 'TEXT')
    end
    return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
end

-- 处理“shift + alt + 鼠标左键”
local function OnHUDMouseButton(HUD)
    local status = HUD.controls.status
    local default_thresholds = { .15, .35, .55, .75 }
    local levels = { 'EMPTY', 'LOW', 'MID', 'HIGH', 'FULL' }
    local function get_category(thresholds, percent)
        local i = 1
        while thresholds[i] ~= nil and percent >= thresholds[i] do
            i = i + 1
        end
        return i
    end

    -- 饱食度
    if status.stomach and status.stomach.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.STOMACH
        local current = ThePlayer.player_classified.currenthunger:value()
        local max = ThePlayer.player_classified.maxhunger:value()
        local category = levels[get_category(default_thresholds, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 精神值
    if status.brain and status.brain.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.SANITY
        local current = ThePlayer.player_classified.currentsanity:value()
        local max = ThePlayer.player_classified.maxsanity:value()
        local category = levels[get_category(default_thresholds, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 生命值
    if status.heart and status.heart.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.HEALTH
        local current = ThePlayer.player_classified.currenthealth:value()
        local max = ThePlayer.player_classified.maxhealth:value()
        local category = levels[get_category({ .25, .5, .75, 1 }, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 潮湿度
    if status.moisturemeter and status.moisturemeter.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.WETNESS
        local current = ThePlayer.player_classified.moisture:value()
        local max = ThePlayer.player_classified.maxmoisture:value()
        local category = levels[get_category(default_thresholds, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 木头值
    if status.wereness and status.wereness.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.LOG_METER
        local max = 100
        local current = ThePlayer.player_classified.currentwereness:value()
        local category = levels[get_category({ .25, .5, .7, .9 }, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 人物温度
    if status.temperature and status.temperature.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.TEMPERATURE
        local temp = ThePlayer:GetTemperature()
        local fmts = {
            TEMPERATURE = string.format('%d', temp),
            MESSAGE = GetMapping(qa, 'MESSAGE', 'GOOD')
        }
        if temp >= TUNING.OVERHEAT_TEMP then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'BURNING')
        elseif temp >= TUNING.OVERHEAT_TEMP - 5 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'HOT')
        elseif temp >= TUNING.OVERHEAT_TEMP - 15 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'WARM')
        elseif temp <= 0 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'FREEZING')
        elseif temp <= 5 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'COLD')
        elseif temp <= 15 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'COOL')
        end
        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
    end

    -- 世界温度和降雨
    if status.worldtemp and status.worldtemp.focus then
        local SEASON = GLOBAL.STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[TheWorld.state.season:upper()]
        if SEASON == '春' or SEASON == '夏' or SEASON == '秋' or SEASON == '冬' then
            SEASON = SEASON .. '季'
        end

        local qa = GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN
        local   fmts = {
            TEMPERATURE = math.floor(TheWorld.state.temperature + 0.5),
            SEASON = SEASON,
            WEATHER = GetMapping(qa, 'WEATHER', TheWorld.state.season:upper())
        }
        local qa_fmt = qa.FORMATS.NO_RAIN
        if TheWorld.state.pop ~= 1 then
            local world, total_seconds, rain = GLOBAL.QA_UTILS.PredictRainStart()
            fmts.WORLD = GetMapping(qa, 'WORLD', world)
            if rain then
                fmts.DAYS, fmts.MINUTES, fmts.SECONDS = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                qa_fmt = qa.FORMATS.START_RAIN
            end
        else
            local world, total_seconds = GLOBAL.QA_UTILS.PredictRainStop()
            fmts.WORLD = GetMapping(qa, 'WORLD', world)
            fmts.DAYS, fmts.MINUTES, fmts.SECONDS = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
            qa_fmt = qa.FORMATS.STOP_RAIN
        end
        return Announce(subfmt(qa_fmt, fmts))
    end

    -- 季节
    if HUD.controls.seasonclock and HUD.controls.seasonclock.focus or status.season and status.season.focus then
        local SEASON = GLOBAL.STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[TheWorld.state.season:upper()]
        if SEASON == '春' or SEASON == '夏' or SEASON == '秋' or SEASON == '冬' then
            SEASON = SEASON .. '季'
        end
        local DAYS_LEFT = TheWorld.state.remainingdaysinseason
        if DAYS_LEFT == 10000 then DAYS_LEFT = "∞" end

        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SEASON.FORMATS.DEFAULT, {
            SEASON = SEASON,
            DAYS_LEFT = DAYS_LEFT,
        }))
    end

    -- 月相
    if HUD.controls.clock and HUD.controls.clock._moonanim and HUD.controls.clock._moonanim.focus and HUD.controls.clock._moonanim.moontext then
        local qa = GLOBAL.NOMU_QA.SCHEME.MOON_PHASE
        if string.find(tostring(HUD.controls.clock._moonanim.moontext), '?') ~= nil then
            ThePlayer.components.talker:Say(qa.FORMATS.FAILED)
            return
        end
        local moonment = string.match(tostring(HUD.controls.clock._moonanim.moontext), '(%d+)') or 0
        if moonment == 0 then
            return
        end
        local worldment = TheWorld.state.cycles + 1 or 0
        if worldment == 0 then
            return
        end
        local fmts = {
            INTERVAL = GetMapping(qa, 'INTERVAL', 'COMMA')
        }
        local moonleft = moonment - worldment

        if moonleft >= 10 then
            fmts.PHASE1 = GetMapping(qa, 'MOON', 'FULL')
            fmts.PHASE2 = GetMapping(qa, 'MOON', 'NEW')
        else
            fmts.PHASE1 = GetMapping(qa, 'MOON', 'NEW')
            fmts.PHASE2 = GetMapping(qa, 'MOON', 'FULL')
        end

        local judge = moonleft % 10
        if judge <= 1 then
            if judge == 0 then
                fmts.RECENT = GetMapping(qa, 'RECENT', 'TODAY')
            else
                fmts.RECENT = GetMapping(qa, 'RECENT', 'TOMORROW')
            end
            judge = judge + 10
            fmts.PHASE1, fmts.PHASE2 = fmts.PHASE2, fmts.PHASE1
            if worldment < 20 then
                return Announce(subfmt(qa.FORMATS.MOON, fmts))
            end
        elseif judge >= 8 then
            fmts.RECENT = GetMapping(qa, 'RECENT', 'AFTER')
        else
            fmts.RECENT = ''
            fmts.PHASE1 = ''
            fmts.INTERVAL = GetMapping(qa, 'INTERVAL', 'NONE')
        end
        fmts.LEFT = judge
        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
    end

    -- 时钟
    if HUD.controls.clock and HUD.controls.clock.focus then
        local clock = TheWorld.net.components.clock
        if clock and clock._remainingtimeinphase and clock._phase and clock.CalcRemainTimeOfDay then
            local qa = GLOBAL.NOMU_QA.SCHEME.CLOCK
            local phases = { 'DAY', 'DUSK', 'NIGHT' }
            local function _format_time(seconds)
                local minutes = math.modf(seconds / 60)
                seconds = math.modf(math.fmod(seconds, 60))
                local message = ''
                if minutes > 0 then
                    message = message .. tostring(minutes) .. GetMapping(qa, 'TIME', 'MINUTES')
                end
                message = message .. tostring(seconds) .. GetMapping(qa, 'TIME', 'SECONDS')
                return message
            end

            local fmt = qa.FORMATS.DEFAULT
            local fmts = {
                PHASE = GetMapping(qa, 'PHASE', phases[clock._phase:value()]),
                PHASE_REMAIN = _format_time(clock._remainingtimeinphase:value()),
                DAY_REMAIN = _format_time(clock.CalcRemainTimeOfDay())
            }

            if TheWorld.GetNightmareData then
                local data = TheWorld:GetNightmareData()
                fmt = data.remain == 0 and data.total ~= 0 and qa.FORMATS.NIGHTMARE_LOCK or qa.FORMATS.NIGHTMARE
                fmts.NIGHTMARE = GetMapping(qa, 'NIGHTMARE', data.phase:upper())
                fmts.REMAIN = _format_time(data.remain)
                fmts.TOTAL = _format_time(data.total)
            end

            return Announce(subfmt(fmt, fmts))
        end
    end

    -- 船生命值
    if status.boatmeter and status.boatmeter.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.BOAT
        local health = { 'EMPTY', 'LOW', 'MID', 'HIGH', 'FULL' }
        local max = status.boatmeter.boat.components.healthsyncer.max_health
        local step = max / 5 + 1
        local current = status.boatmeter.boat.components.healthsyncer:GetPercent() * max
        local idx = math.floor(current / step) + 1
        return Announce(subfmt(qa.FORMATS.DEFAULT, {
            CURRENT = math.floor(current + 0.5),
            MAX = max,
            MESSAGE = GetMapping(qa, 'MESSAGE', health[idx])
        }))
    end

    -- 温蒂：阿比盖尔
    if status.pethealthbadge and status.pethealthbadge.focus then
        local badge = status.pethealthbadge
        if not badge.nomu_max or not badge.nomu_percent then
            return
        end
        local qa = GLOBAL.NOMU_QA.SCHEME.ABIGAIL
        local max = badge.nomu_max
        local current = badge.nomu_percent * max
        local step = max / 5 + 1
        local idx = math.floor(current / step) + 1

        return AnnounceBadge(qa, current, max, levels[idx])
    end

    -- 沃尔夫冈：力量值
    if status.mightybadge and status.mightybadge.focus then
        local badge = status.mightybadge
        if not badge.nomu_percent then
            return
        end
        local qa = GLOBAL.NOMU_QA.SCHEME.MIGHTINESS
        badge.nomu_max = badge.nomu_max or 100
        local mightiness_levels = { 'WIMPY', 'NORMAL', 'MIGHTY' }
        local max = badge.nomu_max
        local current = badge.nomu_percent * max
        local idx = 1
        if current >= TUNING.MIGHTY_THRESHOLD then
            idx = 3
        elseif current >= TUNING.WIMPY_THRESHOLD then
            idx = 2
        end

        return AnnounceBadge(qa, current, max, mightiness_levels[idx])
    end

    -- 薇格弗德：灵感值
    if status.inspirationbadge and status.inspirationbadge.focus then
        local badge = status.inspirationbadge
        if not badge.nomu_percent then
            return
        end
        local qa = GLOBAL.NOMU_QA.SCHEME.INSPIRATION
        badge.nomu_max = badge.nomu_max or 100
        local max = badge.nomu_max
        local current = badge.nomu_percent * max
        local idx = 1
        if badge.nomu_percent >= TUNING.BATTLESONG_THRESHOLDS[3] then
            idx = 4
        elseif badge.nomu_percent >= TUNING.BATTLESONG_THRESHOLDS[2] then
            idx = 3
        elseif badge.nomu_percent >= TUNING.BATTLESONG_THRESHOLDS[1] then
            idx = 2
        end

        return AnnounceBadge(qa, current, max, levels[idx])
    end

    -- WX78: 能量值
    if HUD.controls.secondary_status and HUD.controls.secondary_status.upgrademodulesdisplay and HUD.controls.secondary_status.upgrademodulesdisplay.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.ENERGY
        local widget = HUD.controls.secondary_status.upgrademodulesdisplay
        local current = widget.energy_level
        local energy_levels = { 'ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX' }
        local fmts = {
            CURRENT = math.floor(current + 0.5),
            MAX = TUNING.WX78_MAXELECTRICCHARGE,
            USED = widget.slots_in_use,
            MESSAGE = GetMapping(qa, 'MESSAGE', energy_levels[current + 1])
        }
        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
    end

    --烹饪锅
    if HUD.controls and HUD.controls.foodcrafting and HUD.controls.foodcrafting.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.COOK
        if HUD.controls.foodcrafting.focusItem and HUD.controls.foodcrafting.focusItem.focus then
            local recipe = HUD.controls.foodcrafting.focusItem.recipe
            local popup = HUD.controls.foodcrafting.focusItem.recipepopup
            local name = STRINGS.NAMES[string.upper(recipe.name)] or recipe.name
            if popup and popup.focus then
                local fmts = {
                    TYPE = GetMapping(qa, 'TYPE', 'POS'),
                    NAME = name
                }
                local fmt
                local value
                if popup.health and popup.health.focus then
                    value = recipe.health
                    fmt = qa.FORMATS.HEALTH
                end
                if popup.sanity and popup.sanity.focus then
                    value = recipe.sanity
                    fmt = qa.FORMATS.SANITY
                end
                if popup.hunger and popup.hunger.focus then
                    value = recipe.hunger
                    fmt = qa.FORMATS.HUNGER
                end
                if value then
                    if type(value) == 'number' and value < 0 then
                        fmts.TYPE = GetMapping(qa, 'TYPE', 'NEG')
                        value = -value
                    end
                    fmts.VALUE = not recipe.unlocked and '?' or type(value) == 'number' and value ~= 0 and string.format("%g", (math.floor(value * 10 + 0.5) / 10)) or '-'
                    return Announce(subfmt(fmt, fmts))
                end
                if popup.name and popup.name.focus and popup.hunger and popup.sanity and popup.health then
                    return Announce(subfmt(qa.FORMATS.FOOD, {
                        NAME = name, HUNGER = popup.hunger:GetString(), SANITY = popup.sanity:GetString(), HEALTH = popup.health:GetString()
                    }))
                end
                if popup.ingredients then
                    for _, ingredient in ipairs(popup.ingredients) do
                        if ingredient.focus then
                            return Announce(subfmt(qa.FORMATS[ingredient.is_min and 'MIN_INGREDIENT' or ingredient.quantity > 0 and 'MAX_INGREDIENT' or 'ZERO_INGREDIENT'], {
                                NAME = name, INGREDIENT = ingredient.localized_name, NUM = ingredient.quantity
                            }))
                        end
                    end
                end
            else
                if (recipe.readytocook or recipe.reqsmatch) and recipe.unlocked then
                    return Announce(subfmt(qa.FORMATS.CAN, { NAME = name }))
                else
                    return Announce(subfmt(qa.FORMATS.NEED, { NAME = name }))
                end
            end
        end
    end
end

AddClassPostConstruct('screens/playerhud', function(PlayerHud)
    if getval(PlayerHud.OnMouseButton,"OnHUDMouseButton") then
        setval(PlayerHud.OnMouseButton,"OnHUDMouseButton",OnHUDMouseButton)
    else
        print("[快捷宣告(Nomu)补丁] 警告：OnHUDMouseButton HOOK失败")
    end

    AddClassPostConstruct('widgets/invslot', function(SlotClass)
        local _AnnounceItem = getval(SlotClass.OnControl,"AnnounceItem")
        if _AnnounceItem then
            setval(_AnnounceItem,"Announce",Announce) -- 我修复了因Show Me导致的无法宣告暖石温度的BUG，现在需要把我修好的Announce函数设置到原AnnounceItem函数里

            PlayerHud._StatusAnnouncer.AnnounceItem = function(_, slot) -- 修复岛屿冒险模组宣告船只装备的物品时崩溃的问题
                return _AnnounceItem(slot,'invslot')
            end
        else
            print("[快捷宣告(Nomu)补丁] 警告：AnnounceItem HOOK失败")
        end
    end)
end)



--技能树
AddClassPostConstruct('widgets/redux/skilltreebuilder', function(SkillTreeBuilder)
    local oldOnControl = getval(SkillTreeBuilder.OnControl,"oldOnControl")
    if oldOnControl then
        function SkillTreeBuilder:OnControl(control, down, ...)
            if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
                for k, v in pairs(self.skillgraphics) do
                    if v.button and v.button.focus and v.status and self.skilltreedef and self.skilltreedef[k] and self.skilltreedef[k].title then
                        local name = self.fromfrontend and type(self.fromfrontend) == "table" and self.fromfrontend.data and self.fromfrontend.data.name or '' -- 加一个类型验证来修复选人界面宣告时崩溃的问题
                        if v.status.activated then
                            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.ACTIVATED, { NAME = name, SKILL = self.skilltreedef[k].title }))
                        elseif v.status.activatable then
                            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.CAN_ACTIVATE, { NAME = name, SKILL = self.skilltreedef[k].title }))
                        end
                    end
                end
            end
            return oldOnControl(self, control, down, ...)
        end
    else
        print("[快捷宣告(Nomu)补丁] 警告：技能树宣告相关功能HOOK失败")
    end
end)