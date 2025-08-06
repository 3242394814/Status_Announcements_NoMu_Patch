GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})

Upvaluehelper = require "utils/bbgoat_upvaluehelper"

-- 给基地投影模组也擦个屁股，现在TheNet:Say的内容不能有\n，否则第二行的内容会被吞。
-- NoMu去哪了！？？？？？？？？？
if rawget(_G,"BSPJ") and (GLOBAL.BSPJ.DATA) and (STRINGS.BSPJ and STRINGS.BSPJ.QUICK_ANNOUNCE_FORMAT) then
    STRINGS.BSPJ.QUICK_ANNOUNCE_FORMAT = string.gsub(STRINGS.BSPJ.QUICK_ANNOUNCE_FORMAT, "\n", " | ")

    -- 捕获聊天信息中的坐标
    local oldNetworking_Say = GLOBAL.Networking_Say
    GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, ...)
        if GLOBAL.BSPJ.DATA.CAPTURE_ANNOUNCE and message and ThePlayer and (GLOBAL.BSPJ.DATA.CAPTURE_SELF or userid ~= ThePlayer.userid) then
            -- '[BSPJ] 坐标(%.2f, %.2f, %.2f)需要一个"%s" | (%s#%d#%.2f#%s#%s#%s#%.2f#%.2f#%.2f)'
            local _, _, x, y, z, n, p, layer, rotation, build, anim, bank, s1, s2, s3 = string.find(
                    message, '%[BSPJ][^(]-%(([^,]*),%s*([^,]*),%s*([^)]*)%)[^"]-"(.*)" | %(([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)%)')
            if x and y and z and n and p and layer and rotation and build and s1 and s2 and s3 then
                x, y, z, layer, rotation, s1, s2, s3 = tonumber(x), tonumber(y), tonumber(z), tonumber(layer), tonumber(rotation), tonumber(s1), tonumber(s2), tonumber(s3)
                if anim == 'nil' then
                    anim = nil
                end
                if bank == 'nil' then
                    bank = nil
                end
                local flag = true
                for _, item in ipairs(GLOBAL.BSPJ.ANNOUNCEMENTS) do
                    if item.prefab == p and item.x == x and item.y == y and item.z == z and item.name == n then
                        flag = false
                        break
                    end
                end
                if flag then
                    table.insert(GLOBAL.BSPJ.ANNOUNCEMENTS, 1, {
                        announcer = name, x = x, y = y, z = z, name = n, prefab = p,
                        layer = layer, build = build, anim = anim, bank = bank,
                        scale = { s1, s2, s3 }, rotation = rotation
                    })
                    ThePlayer.components.talker:Say(STRINGS.BSPJ.MESSAGE_CAPTURED)
                end
            end
        end
        return oldNetworking_Say(guid, userid, name, prefab, message, ...)
    end
end

--------------------------------------------------------------------以下为快捷宣告(NoMu)的补丁--------------------------------------------------------------------

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
    message = message:gsub("(%d)\176([CF）])", "%1°%2") -- 修复无法宣告暖石温度的问题...show me用的 ° 是 "\176" 这个玩意无法被Say出来...
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


-- 将部分物品视为同一个prefab，解决宣告数量不准确的问题
local ITEM_PREFAB_ALIAS = {
    -- 鹿角
    deer_antler1 = "deer_antler",
    deer_antler2 = "deer_antler",
    deer_antler3 = "deer_antler",
    -- 还有啥呢？好难猜呀
}

local function CountItem_ALIAS(container, name, prefab)
    local num_found = 0
    local items = container:GetItems()
    for _, v in pairs(items) do
        if v and ITEM_PREFAB_ALIAS[v.prefab] == prefab and v:GetDisplayName() == name then
            if v.replica.stackable ~= nil then
                num_found = num_found + v.replica.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if container.GetActiveItem then
        local active_item = container:GetActiveItem()
        if active_item and ITEM_PREFAB_ALIAS[active_item.prefab] == prefab and active_item:GetDisplayName() == name then
            if active_item.replica.stackable ~= nil then
                num_found = num_found + active_item.replica.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if container.GetOverflowContainer then
        local overflow = container:GetOverflowContainer()
        if overflow ~= nil then
            local overflow_found = CountItem_ALIAS(overflow, name, prefab)
            num_found = num_found + overflow_found
        end
    end

    return num_found
end

local get_container_name,CountItemWithName,SUSPICIOUS_MARBLE,RECHARGEABLE_PREFABS,SHOW_ME_ON

local function AnnounceItem(slot, classname)
    local item = slot.tile.item
    local container = slot.container
    local percent
    local percent_type
    if slot.tile.percent then
        percent = slot.tile.percent:GetString()
        percent_type = "DURABILITY"
    elseif slot.tile.hasspoilage then
        percent = math.floor(item.replica.inventoryitem.classified.perish:value() * (1 / .62)) .. "%"
        percent_type = "FRESHNESS"
    end
    if container == nil or (container and container.type == "pack") then
        container = ThePlayer.replica.inventory
    end
    local num_equipped = 0
    local num_equipped_name = 0
    if not container.type then
        for _, _slot in pairs(EQUIPSLOTS) do
            local equipped_item = container:GetEquippedItem(_slot)
            if equipped_item and equipped_item.prefab == item.prefab then
                num_equipped = num_equipped + (equipped_item.replica.stackable and equipped_item.replica.stackable:StackSize() or 1)
                if equipped_item.name == item.name then
                    num_equipped_name = num_equipped_name + (equipped_item.replica.stackable and equipped_item.replica.stackable:StackSize() or 1)
                end
            end
        end
    end
    local container_name = get_container_name(container.type and container.inst)
    if not container_name then
        local player = container.inst.entity:GetParent()
        local constructionbuilder = player and player.components and player.components.constructionbuilder
        if constructionbuilder and constructionbuilder.constructionsite then
            container_name = get_container_name(constructionbuilder.constructionsite)
        end
    end

    local name = item.prefab and STRINGS.NAMES[item.prefab:upper()] or STRINGS.NOMU_QA.UNKNOWN_NAME
    local _, num_found = container:Has(item.prefab, 1)
    local num_found_name = CountItemWithName(container, item:GetDisplayName(), item.prefab)
    num_found_name = num_found_name + num_equipped_name
    num_found = num_found + num_equipped
    local item_name = string.gsub(item:GetBasicDisplayName(), '\n', ' ')
    if name == STRINGS.NOMU_QA.UNKNOWN_NAME and num_found == num_found_name then
        name = item_name
    end

    local qa = GLOBAL.NOMU_QA.SCHEME.ITEM
    local fmts = {
        PRONOUN = GetMapping(qa, 'PRONOUN', 'I'),
        NUM = num_found,
        EQUIP_NUM = num_equipped,
        ITEM = name,
        ITEM_NAME = item_name ~= name and subfmt(GetMapping(qa, 'WORDS', 'ITEM_NAME'), { NUM = num_found_name, NAME = item_name }) or '',
        IN_CONTAINER = '',
        WITH_PERCENT = '',
        POST_STATE = '',
        SHOW_ME = '',
        ITEM_NUM = num_equipped ~= num_found and subfmt(GetMapping(qa, 'WORDS', 'ITEM_NUM'), { NUM = num_found }) or '',
    }

    if container_name then
        fmts.PRONOUN = GetMapping(qa, 'PRONOUN', 'WE')
        fmts.IN_CONTAINER = subfmt(GetMapping(qa, 'WORDS', 'IN_CONTAINER'), {
            NAME = container_name
        })
    end

    if percent then
        local this_one = num_found > 1 and GetMapping(qa, 'WORDS', 'THIS_ONE') or ''
        fmts.WITH_PERCENT = subfmt(GetMapping(qa, 'WORDS', 'WITH_PERCENT'), {
            THIS_ONE = this_one,
            PERCENT = percent,
            TYPE = GetMapping(qa, 'PERCENT_TYPE', percent_type)
        })
    end

    if item.prefab == 'heatrock' then
        --'heatrock_fantasy', 'heat_rock', 'heatrock_fire'
        -- hash('heatrock_fantasy3.tex')
        local temp_range = {
            [4264163310] = 1, [3706253814] = 1, [2098310090] = 1,
            [1108760303] = 2, [550850807] = 2, [3237874379] = 2,
            [2248324592] = 3, [1690415096] = 3, [82471372] = 3,
            [3387888881] = 4, [2829979385] = 4, [1222035661] = 4,
            [232485874] = 5, [3969543674] = 5, [2361599950] = 5
        }
        local temp_category = { 'COLD', 'COOL', 'NORMAL', 'WARM', 'HOT' }
        if item.replica and item.replica.inventoryitem and item.replica.inventoryitem.GetImage then
            local range = temp_range[item.replica.inventoryitem:GetImage()]
            if range and temp_category[range] then
                fmts.POST_STATE = GetMapping(qa, 'HEAT_ROCK', temp_category[range])
            end
        end
    end

    if SUSPICIOUS_MARBLE[item.prefab] then
        fmts.POST_STATE = subfmt(GetMapping(qa, 'WORDS', 'SUSPICIOUS_MARBLE'), { NAME = SUSPICIOUS_MARBLE[item.prefab] })
    end

    if RECHARGEABLE_PREFABS[item.prefab] and item.replica.inventoryitem.classified then
        local seconds = (180 - item.replica.inventoryitem.classified.recharge:value()) / 180 * RECHARGEABLE_PREFABS[item.prefab]
        local minutes = math.modf(seconds / 60)
        if seconds == 0 then
            fmts.POST_STATE = GetMapping(qa, 'RECHARGE', 'FULL')
        else
            seconds = math.modf(math.fmod(seconds, 60))
            local message = ''
            if minutes > 0 then
                message = message .. tostring(minutes) .. GetMapping(qa, 'TIME', 'MINUTES')
            end
            message = message .. tostring(seconds) .. GetMapping(qa, 'TIME', 'SECONDS')
            fmts.POST_STATE = subfmt(GetMapping(qa, 'RECHARGE', 'CHARGING'), { TIME = message })
        end
    end

    if SHOW_ME_ON and (GLOBAL.NOMU_QA.DATA.SHOW_ME == 1 or GLOBAL.NOMU_QA.DATA.SHOW_ME == 2 and item:HasTag('unwrappable')) then
        local n_line_name = #(string.split(item:GetDisplayName(), '\n'))
        local items = GLOBAL.QA_UTILS.ParseHoverText(n_line_name + (classname == 'invslot' and 3 or 2), -1)
        if #items > 0 then
            fmts.SHOW_ME = subfmt(GetMapping(qa, 'WORDS', 'SHOW_ME'), { SHOW_ME = table.concat(items, STRINGS.NOMU_QA.COMMA) })
        end
    end

    -- 修改部分
    if ITEM_PREFAB_ALIAS[item.prefab] then
        fmts.NUM = CountItem_ALIAS(container, item:GetDisplayName(), ITEM_PREFAB_ALIAS[item.prefab])
    end

    return Announce(subfmt(classname == 'invslot' and qa.FORMATS.INV_SLOT or qa.FORMATS.EQUIP_SLOT, fmts))
end

AddClassPostConstruct('screens/playerhud', function(PlayerHud)
    Upvaluehelper.SetUpvalue(PlayerHud.OnMouseButton, OnHUDMouseButton, "OnHUDMouseButton")

    AddClassPostConstruct('widgets/invslot', function(SlotClass)
        local _AnnounceItem = Upvaluehelper.GetUpvalue(SlotClass.OnControl, "AnnounceItem")
        get_container_name = Upvaluehelper.GetUpvalue(_AnnounceItem, "get_container_name")
        CountItemWithName = Upvaluehelper.GetUpvalue(_AnnounceItem, "CountItemWithName")
        SUSPICIOUS_MARBLE = Upvaluehelper.GetUpvalue(_AnnounceItem, "SUSPICIOUS_MARBLE")
        RECHARGEABLE_PREFABS = Upvaluehelper.GetUpvalue(_AnnounceItem, "RECHARGEABLE_PREFABS")
        SHOW_ME_ON = Upvaluehelper.GetUpvalue(_AnnounceItem, "SHOW_ME_ON")

        Upvaluehelper.SetUpvalue(SlotClass.OnControl, AnnounceItem, "AnnounceItem")

        PlayerHud._StatusAnnouncer.AnnounceItem = function(_, slot) -- 修复岛屿冒险模组宣告船只装备的物品时崩溃的问题
            return _AnnounceItem(slot,'invslot')
        end
    end)
end)



--技能树
AddClassPostConstruct('widgets/redux/skilltreebuilder', function(SkillTreeBuilder)
    local oldOnControl = Upvaluehelper.GetUpvalue(SkillTreeBuilder.OnControl, "oldOnControl")
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
end)



-- 宣告周围物品 重写（此部分代码定义在原模组modmain.lua的第1199行）

local IsDefaultScreen

-- 删除原模组添加的事件
local event = TheInput.onmousebutton.events.onmousebutton
for i,_ in pairs (event) do
    local fn = i.fn
    local data = debug.getinfo(fn, "S")
    if string.match(data.source, "mods/workshop%-2784715091/modmain.lua") then
        IsDefaultScreen = Upvaluehelper.GetUpvalue(fn,"IsDefaultScreen")
        event[i] = nil
    end
end

-- Alt+Shift+鼠标左键宣告周围物品
AddComponentPostInit("playercontroller", function(self, inst)
    if inst ~= GLOBAL.ThePlayer then return end
    local PlayerControllerOnControl = self.OnControl
    self.OnControl = function(self, control, down, ...)

        if not (IsDefaultScreen() and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) and TheInput:IsKeyDown(KEY_LSHIFT) and down) then
            return PlayerControllerOnControl(self, control, down, ...)
        end

        local entity = ConsoleWorldEntityUnderMouse()
        local qa = GLOBAL.NOMU_QA.SCHEME.ENV
        if control == GLOBAL.CONTROL_PRIMARY then -- 鼠标左键点击
            if entity then
                if not TheInput:IsKeyDown(KEY_LCTRL) and entity:HasTag('player') then
                    Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.DEFAULT, { NAME = entity:GetDisplayName() }))
                    return
                end
                local px, py, pz = entity:GetPosition():Get()
                local entities = TheSim:FindEntities(px, py, pz, 40)
                local count_name = 0
                local count_prefab = 0
                for _, v in ipairs(entities) do
                    if v.entity:IsVisible() and v.prefab == entity.prefab then
                        if v.replica and v.replica.stackable ~= nil then
                            count_prefab = count_prefab + v.replica.stackable:StackSize()
                            if v:GetDisplayName() == entity:GetDisplayName() then
                                count_name = count_name + v.replica.stackable:StackSize()
                            end
                        else
                            count_prefab = count_prefab + 1
                            if v:GetDisplayName() == entity:GetDisplayName() then
                                count_name = count_name + 1
                            end
                        end
                    end
                end
                local prefab_name = entity.prefab and STRINGS.NAMES[entity.prefab:upper()]
                local no_whisper = entity:HasTag('player')
                local display_name = string.gsub(entity:GetDisplayName(), '\n', ' ')
                if SUSPICIOUS_MARBLE[entity.prefab] then
                    prefab_name = prefab_name .. ' ' .. SUSPICIOUS_MARBLE[entity.prefab]
                    display_name = prefab_name
                end

                local show_me = ''
                if SHOW_ME_ON and (GLOBAL.NOMU_QA.DATA.SHOW_ME == 1 or GLOBAL.NOMU_QA.DATA.SHOW_ME == 2 and entity:HasTag('unwrappable')) then
                    local n_line_name = #(string.split(entity:GetDisplayName(), '\n'))
                    local items = GLOBAL.QA_UTILS.ParseHoverText(n_line_name + 1, nil, nil, 2)
                    if #items > 0 then
                        show_me = subfmt(GetMapping(qa, 'WORDS', 'SHOW_ME'), { SHOW_ME = table.concat(items, STRINGS.NOMU_QA.COMMA) })
                    end
                end

                if not prefab_name then
                    if count_name == 1 then
                        Announce(subfmt(qa.FORMATS.SINGLE, { NAME = display_name, SHOW_ME = show_me }), no_whisper)
                        return
                    else
                        Announce(subfmt(qa.FORMATS.DEFAULT, { NUM = count_name, NAME = display_name, SHOW_ME = show_me }), no_whisper)
                        return
                    end
                else
                    if prefab_name ~= display_name then
                        Announce(subfmt(qa.FORMATS.NAMED, { NUM_PREFAB = count_prefab, PREFAB_NAME = prefab_name, NUM = count_name, NAME = display_name, SHOW_ME = show_me }), no_whisper)
                        return
                    else
                        Announce(subfmt(qa.FORMATS.DEFAULT, { NUM = count_prefab, NAME = prefab_name, SHOW_ME = show_me }), no_whisper)
                        return
                    end
                end
            end
        end
        return PlayerControllerOnControl(self, control, down, ...)
    end
end)

-- Alt+Shift+鼠标中键宣告
TheInput:AddMouseButtonHandler(function(button, down)
    if not (IsDefaultScreen() and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) and TheInput:IsKeyDown(KEY_LSHIFT) and down) then
        return
    end

    local entity = ConsoleWorldEntityUnderMouse()
    local qa = GLOBAL.NOMU_QA.SCHEME.ENV
    if button == MOUSEBUTTON_MIDDLE then -- 鼠标中键点击，上面的方法只能识别到鼠标左右键，所以中键维持原样
        if entity then
            if not TheInput:IsKeyDown(KEY_LCTRL) and entity:HasTag('player') then
                if entity == ThePlayer then
                    Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.PING, { PING = TheNet:GetAveragePing() }))
                else
                    Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.GREET, { NAME = entity:GetDisplayName() }))
                end
                return
            end
            ThePlayer.components.talker:Say(subfmt(qa.FORMATS.CODE, { PREFAB = entity.prefab, NAME = entity:GetDisplayName() }), 5)
        end
    end
end)