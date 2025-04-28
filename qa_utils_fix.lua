-- 降雨预测 大部分代码来自快捷宣告（中文）https://steamcommunity.com/sharedfiles/filedetails/?id=2785634357
GLOBAL.QA_UTILS.PredictRainStart = function()
        -- 一场雨什么时候下由上限决定、什么时候停由下限决定
        -- 冬天第二天上涨速率是50
        -- 水分 = 水分速率下限 + (水分速率上限 - 水分速率下限) * {1 - Sin[Π * (当前季节剩余天数, 包括当天) / 当前季节总天数]}

        -- 水分速率上下限
        local MOISTURE_RATES = { }
        if TheWorld:HasTag("island") then
            MOISTURE_RATES = {
                MIN = {
                    mild =  0,
                    wet =   3,
                    green = 3,
                    dry =   0,
                },
                MAX = {
                    mild =  0.1, --og: autumn = 0, --TODO, there should be no rain in mild at all....
                    wet =   3.75,
                    green = 3.75,
                    dry =   -0.2, --I figured making it dry this way is more fun -M
                }
            }
        elseif TheWorld:HasTag("porkland") then
            MOISTURE_RATES = {
                MIN = {
                    temperate = .25,
                    humid = 3,
                    lush = 0,
                    aporkalypse = .1
                },
                MAX = {
                    temperate = 1.0,

                    humid = 3.75,
                    lush = -0.2,  -- in ds it's 0
                    aporkalypse = .5
                }
            }
        else
            MOISTURE_RATES = {
                MIN = {
                    autumn = .25,
                    winter = .25,
                    spring = 3,
                    summer = .1
                },
                MAX = {
                    autumn = 1.0,
                    winter = 1.0,
                    spring = 3.75,
                    summer = .5
                }
            }
        end
        local world = TheWorld:HasTag("porkland") and "PORKLAND"
                    or TheWorld:HasTag("island") and "SHIPWRECKED"
                    or TheWorld:HasTag("cave") and "CAVES"
                    or "SURFACE"  -- 默认

        local remainingsecondsinday = TUNING.TOTAL_DAY_TIME - (TheWorld.state.time * TUNING.TOTAL_DAY_TIME)
        local totalseconds = 0
        local rain = false

        local season = TheWorld.state.season
        local seasonprogress = TheWorld.state.seasonprogress
        local elapseddaysinseason = TheWorld.state.elapseddaysinseason
        local remainingdaysinseason = TheWorld.state.remainingdaysinseason
        local totaldaysinseason = remainingdaysinseason / (1 - seasonprogress)
        local _totaldaysinseason = elapseddaysinseason + remainingdaysinseason

        local moisture = TheWorld.state.moisture
        local moistureceil = TheWorld.state.moistureceil

        while elapseddaysinseason < _totaldaysinseason do
            local moisturerate

            if world == "SURFACE" and season == "winter" and elapseddaysinseason == 2 then
                moisturerate = 50
            elseif world == "SHIPWRECKED" then
                if season == "green" then
                    seasonprogress = (elapseddaysinseason - 5) / (TheWorld.state.greenlength - 5)
                elseif season == "wet" then
                    seasonprogress = seasonprogress * 1.5
                end
                local p = 1 - math.sin(PI * seasonprogress)
                moisturerate = (season == "green" and elapseddaysinseason <= 5 and 0) or MOISTURE_RATES.MIN[season] + p * (MOISTURE_RATES.MAX[season] - MOISTURE_RATES.MIN[season])
            else
                local p = 1 - math.sin(PI * seasonprogress)
                moisturerate = MOISTURE_RATES.MIN[season] + p * (MOISTURE_RATES.MAX[season] - MOISTURE_RATES.MIN[season])
            end

            local _moisture = moisture + (moisturerate * remainingsecondsinday)

            if _moisture >= moistureceil then
                totalseconds = totalseconds + ((moistureceil - moisture) / moisturerate)
                rain = true
                break
            else
                moisture = _moisture
                totalseconds = totalseconds + remainingsecondsinday
                remainingsecondsinday = TUNING.TOTAL_DAY_TIME
                elapseddaysinseason = elapseddaysinseason + 1
                remainingdaysinseason = remainingdaysinseason - 1
                seasonprogress = 1 - (remainingdaysinseason / totaldaysinseason)
            end
        end

        return world, totalseconds, rain
end

-- 停雨预测 大部分代码来自快捷宣告（中文）https://steamcommunity.com/sharedfiles/filedetails/?id=2785634357
GLOBAL.QA_UTILS.PredictRainStop = function()
    local PRECIP_RATE_SCALE = 10
    local MIN_PRECIP_RATE = .1

    local world = TheWorld:HasTag("porkland") and "PORKLAND"
                or TheWorld:HasTag("island") and "SHIPWRECKED"
                or TheWorld:HasTag("cave") and "CAVES"
                or "SURFACE"  -- 默认
    local dbgstr = (TheWorld.net.components.weather ~= nil and TheWorld.net.components.weather:GetDebugString()) or
                    (TheWorld:HasTag("island") and TheWorld.net.components.shipwreckedweather ~= nil and TheWorld.net.components.shipwreckedweather:GetDebugString())	or
                    (TheWorld:HasTag("cave") and TheWorld.net.components.caveweather ~= nil and TheWorld.net.components.caveweather:GetDebugString()) or
                    (TheWorld:HasTag("porkland") and TheWorld.net.components.plateauweather ~= nil and TheWorld.net.components.plateauweather:GetDebugString())

    dbgstr = string.gsub(dbgstr," ","")
    --local _, _, moisture, moisturefloor, moistureceil, moisturerate, preciprate, peakprecipitationrate = string.find(dbgstr, ".*moisture:(%d+.%d+)%((%d+.%d+)/(%d+.%d+)%) %+ (%d+.%d+), preciprate:%((%d+.%d+) of (%d+.%d+)%).*")	--新版刀子雨天气信息的文本格式改了,  导致它获取不到数字，更改下列方式
    --local _, _, moisture, moisturefloor, moistureceil, preciprate, peakprecipitationrate = string.find(dbgstr, ".*moisture:(%d+.%d+)%((%d+.%d+)/(%d+.%d+)%).*preciprate:%((%d+.%d+)of(%d+.%d+)%).*")
    local pattern = "moisture:([%-%d%.]+)%(([%-%d%.]+)/([%-%d%.]+)%).-preciprate:%(([%-%d%.]+)%s*of%s*([%-%d%.]+)%)"
    local moisture, moisturefloor, moistureceil, preciprate, peakprecipitationrate = string.match(dbgstr, pattern)

    moisture = moisture and tonumber(moisture) or 0
    moisturefloor = moisturefloor and tonumber(moisturefloor) or 0
    moistureceil = moistureceil and tonumber(moistureceil) or 0
    preciprate = preciprate and tonumber(preciprate) or 0
    --moisturerate = moisturerate and tonumber(moisturerate) or 0
    peakprecipitationrate = peakprecipitationrate and tonumber(peakprecipitationrate) or 0

    local totalseconds = 0

    while moisture > moisturefloor do
        if preciprate > 0 then
            local p = math.max(0, math.min(1, (moisture - moisturefloor) / (moistureceil - moisturefloor)))
            local rate = MIN_PRECIP_RATE + (1 - MIN_PRECIP_RATE) * math.sin(p * PI)

            preciprate = math.min(rate, peakprecipitationrate)
            moisture = math.max(moisture - preciprate * FRAMES * PRECIP_RATE_SCALE, 0)

            totalseconds = totalseconds + FRAMES
        else
            break
        end
    end

    return world, totalseconds
end

if ModManager:GetMod("workshop-2784715091").postinitfns.ComponentPostInit.clock then
    ModManager:GetMod("workshop-2784715091").postinitfns.ComponentPostInit.clock[1] = function(clock) -- 覆盖原模组的HOOK方法，兼容宣告海难/猪镇当前阶段剩余时间
        local oldGetDebugString = clock.GetDebugString_tropical or clock.GetDebugString_plateau or clock.GetDebugString
        local oldDump = clock.Dump_tropical or clock.Dump_plateau or clock.Dump

        local value
        value = getval(oldGetDebugString, '_phase')
        local _phase
        clock._phase = value
        _phase = value

        local _remainingtimeinphase
        value = getval(oldGetDebugString, '_remainingtimeinphase')
        clock._remainingtimeinphase = value
        _remainingtimeinphase = value

        local _segs = getval(oldDump, '_segs')
        local _totaltimeinphase = getval(oldDump,'_totaltimeinphase')

        if _totaltimeinphase and _remainingtimeinphase and _segs and _phase then
            clock.CalcRemainTimeOfDay = function()
                local time_of_day = _totaltimeinphase:value() - _remainingtimeinphase:value()
                for i = 1, _phase:value() - 1 do
                    time_of_day = time_of_day + _segs[i]:value() * TUNING.SEG_TIME
                end
                return TUNING.TOTAL_DAY_TIME - time_of_day
            end
        end
    end
else
    print("[快捷宣告(Nomu)补丁] 警告：HOOK clock失败")
end