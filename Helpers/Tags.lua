local _, ns = ...
local oUF = ns.oUF

-- Lua APIs
local _G = getfenv(0)
local floor = _G.math.floor
local strlen = _G.string.len
local strsub = _G.string.sub
local strbyte = _G.string.byte
local format = _G.string.format

-- WoW APIs
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local UnitLevel = _G.UnitLevel
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitIsDead = _G.UnitIsDead
local UnitIsGhost = _G.UnitIsGhost
local UnitReaction = _G.UnitReaction
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied= _G.UnitIsTapDenied
local UnitIsConnected = _G.UnitIsConnected
local UnitIsFeignDeath = _G.UnitIsFeignDeath
local UnitPlayerControlled = _G.UnitPlayerControlled
local GetMaxPlayerLevel = _G.GetMaxPlayerLevel
local GetXPExhaustion = _G.GetXPExhaustion
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo

-- format number
local function ShortValue(value)
    if (value <= 999) then return value end

	if (value >= 1e6) then
		return format('%.1fm', value / 1e6)
	elseif (value >= 1e3) then
		return format('%.1fk', value / 1e3)
	end
end

-- unit status
local function GetUnitStatus(unit)
    if (not UnitIsConnected(unit)) then
		return format('|c%s%s|r', 'ffff0000', 'OFF')
    end
    if (UnitIsFeignDeath(unit) and not UnitIsDead(unit)) then
		return format('|c%s%s|r', 'ffffcc00', 'F.Dead')
    end
    if (not UnitIsFeignDeath(unit) and UnitIsDead(unit)) then
		return format('|c%s%s|r', 'ffff3700', 'Dead')
	end
    if (UnitIsGhost(unit)) then
		return format('|c%s%s|r', 'ffff3333', 'GHO')
    end
end

-- unit perhp
local function GetUnitPerHealth(unit, colored)
    local cur, max = UnitHealth(unit), UnitHealthMax(unit)

    if (max == 0) then return end

    local r, g, b
    local perhp = floor(cur / max * 100 + .5)

    if (colored) then
        r, g, b = oUF:ColorGradient(cur, max, 1, .1, .1, 1, 1, 0, .1, 1, .1)
        return format('|cff%02x%02x%02x%d|r', r * 255, g * 255, b * 255, perhp)
    else
        r, g, b = oUF:ColorGradient(cur, max, 1, .1, .1, 1, 1, 0, 1, 1, 1)
        return format('|cff%02x%02x%02x%d|r', r * 255, g * 255, b * 255, perhp)
    end
end

-- utf8sub
local function utf8sub(string, numChars, dots)
    local bytes = strlen(string)
	if (bytes <= numChars) then
		return string
	else
		local len, pos = 0, 1
		while (pos <= bytes) do
			len = len + 1
			local c = strbyte(string, pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 194 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 244) then
				pos = pos + 4
			end
			if (len == numChars) then break end
		end

		if (len == numChars and pos <= bytes) then
			return strsub(string, 1, pos - 1) .. (dots and '.' or '')
		else
			return string
		end
	end
end

---------------------
-- oUF custom tags --
---------------------
oUF.Tags.Methods['hp'] = function(unit)
    return UnitHealth(unit) .. ' - ' .. UnitHealthMax(unit)
end
oUF.Tags.Events['hp'] = 'UNIT_CONNECTION UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags.Methods['shorthp'] = function(unit)
    local cur, max = UnitHealth(unit), UnitHealthMax(unit)
    local shortCurHP, shortMaxHP = ShortValue(cur), ShortValue(max)

    return shortCurHP .. ' - ' .. shortMaxHP
end
oUF.Tags.Events['shorthp'] = 'UNIT_CONNECTION UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags.Methods['curhp'] = function(unit)
    local curHP = UnitHealth(unit)

    return ShortValue(curHP)
end
oUF.Tags.Events['curhp'] = 'UNIT_CONNECTION UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags.Methods['perstatus'] = function(unit)
    local unitStatus = GetUnitStatus(unit)
    local perHP = GetUnitPerHealth(unit, true)

    if (not unitStatus) then
		return perHP
    else
        return unitStatus
    end
end
oUF.Tags.Events['perstatus'] = 'UNIT_CONNECTION UNIT_FLAGS UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags.Methods['perstatus%'] = function(unit)
    local unitStatus = GetUnitStatus(unit)
    local perHP = GetUnitPerHealth(unit)

    if (unitStatus) then
		return unitStatus
    else
        return perHP .. '|c' .. 'ff0090ff' .. '%|r'
    end
end
oUF.Tags.Events['perstatus%'] = 'UNIT_CONNECTION UNIT_FLAGS UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags.Methods['pp'] = function(unit)
    return UnitPower(unit) .. ' - ' .. UnitPowerMax(unit)
end
oUF.Tags.Events['pp'] = 'UNIT_CONNECTION UNIT_POWER_UPDATE UNIT_MAXPOWER'

oUF.Tags.Methods['shortpp'] = function(unit)
    local cur, max = UnitPower(unit), UnitPowerMax(unit)
    local shortCurPP, shortMaxPP = ShortValue(cur), ShortValue(max)

    return shortCurPP .. ' - ' .. shortMaxPP
end
oUF.Tags.Events['shortpp'] = 'UNIT_CONNECTION UNIT_POWER_UPDATE UNIT_MAXPOWER'

oUF.Tags.Methods['curpp'] = function(unit)
    local curPP = UnitPower(unit)

    return ShortValue(curPP)
end
oUF.Tags.Events['curpp'] = 'UNIT_CONNECTION UNIT_POWER_UPDATE UNIT_MAXPOWER'

oUF.Tags.Methods['namecolor'] = function(unit)
    local colors = oUF.colors
    local _, classToken = UnitClass(unit)
    local reactionToken = UnitReaction(unit, 'player')

    if (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
        return format('|c%s', colors.tapped.hex)
    elseif (UnitIsPlayer(unit) and classToken) then
        return format('|c%s', colors.class[classToken].hex)
    else
        return format('|c%s', colors.reaction[reactionToken or 4].hex)
    end
end
oUF.Tags.Events['namecolor'] = 'UNIT_FACTION UNIT_NAME_UPDATE'

oUF.Tags.Methods['raidmissinghpname'] = function(unit, realUnit)
    local unitName = UnitName(realUnit or unit)
    local missingHP = UnitHealthMax(unit) - UnitHealth(unit)
    local shortmsHP = ShortValue(missingHP)

    if UnitIsFeignDeath(unit) then
		return 'F.D'
	end
    if UnitIsDead(unit) then
		return 'RIP'
	end
    if UnitIsGhost(unit) then
		return 'GHO'
	end
    if UnitIsConnected(unit) and (missingHP > 0) then
        return '-' .. shortmsHP
    elseif (unitName) then
        return utf8sub(unitName, 4, false)
    end
end
oUF.Tags.Events['raidmissinghpname'] = 'UNIT_CONNECTION UNIT_FLAGS UNIT_NAME_UPDATE UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags.Methods['raidpetmissinghpname'] = function(unit, realUnit)
    local unitName = UnitName(realUnit or unit)
    local missingHP = UnitHealthMax(unit) - UnitHealth(unit)
    local shortmsHP = ShortValue(missingHP)

    if UnitIsDead(unit) then
        return 'RIP'
    end
    if (missingHP > 0) then
        return '-' .. shortmsHP
    elseif (unitName) then
        return utf8sub(unitName, 4, false)
    end
end
oUF.Tags.Events['raidpetmissinghpname'] = 'UNIT_PET UNIT_NAME_UPDATE UNIT_HEALTH UNIT_MAXHEALTH'

-- xp/rep
oUF.Tags.Methods['Exp'] = function()
    if (UnitLevel('player') < GetMaxPlayerLevel()) then
        local xp, xpmax = UnitXP('player'), UnitXPMax('player')
        local perxp = floor(xp / xpmax * 100 + 0.5)

        if GetXPExhaustion() then
            return format('XP: %s (|cff00FF00%.1f%%|r)/%s (|cff40E0D0%.1f%% R|r)', ShortValue(xp), perxp, ShortValue(xpmax), (GetXPExhaustion() or 0) / xpmax * 100)
        else
            return format('XP: %s (%.1f%%)/%s', ShortValue(xp), perxp, ShortValue(xpmax))
        end
    else
        return
    end
end
oUF.Tags.Events['Exp'] = 'UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_XP_UPDATE UPDATE_EXHAUSTION'

oUF.Tags.Methods['Rep'] = function()
    local name, standingID, min, max, cur = GetWatchedFactionInfo()

    if name then
        local color = oUF.colors.reaction[standingID]
        return format('|c%s%s: %s/%s|r', color:GenerateHexColor(), name, cur - min, max - min)
    else
        return
    end
end
oUF.Tags.Events['Rep'] = 'UPDATE_FACTION CHAT_MSG_COMBAT_FACTION_CHANGE'

-- need this for oUF to update tags properly
oUF.Tags.SharedEvents['UPDATE_FACTION'] = true
oUF.Tags.SharedEvents['CHAT_MSG_COMBAT_FACTION_CHANGE'] = true