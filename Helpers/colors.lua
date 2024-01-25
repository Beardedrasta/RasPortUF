local _, RP = ...
local DB = RP.RasPortUF
local c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

function RP:ColorHealthBar(statusbar, unit)
    if not unit then
        return
    elseif UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if class then
            local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
            statusbar:SetStatusBarColor(color.r, color.g, color.b)
            return
        end
    end

    local r, g, b = UnitSelectionColor(unit)
    if r == 0 then
        r = core.db.profile.blizzarduf["Friendly"].red
        g = core.db.profile.blizzarduf["Friendly"].green
        b = core.db.profile.blizzarduf["Friendly"].blue
    elseif g == 0 then
        r = core.db.profile.blizzarduf["Hostile"].red
        g = core.db.profile.blizzarduf["Hostile"].green
        b = core.db.profile.blizzarduf["Hostile"].blue
    else
        r = core.db.profile.blizzarduf["Neutral"].red
        g = core.db.profile.blizzarduf["Neutral"].green
        b = core.db.profile.blizzarduf["Neutral"].blue
    end

    statusbar:SetStatusBarColor(r, g, b)
end

function RP:ColorTexture()
    local p = DB.db.profile
    if p.Class then
        return c.r, c.g, c.b
    elseif p.Blackout then
        return 0.15, 0.15, 0.15
    elseif p["Custom Color"] then
        return p.uiCustomColor.red, p.uiCustomColor.green, p.uiCustomColor.blue
    end
    return 1, 0, 0
end

function RP:UpdateManaBar(statusbar, unit)
    local powerType, powerToken = UnitPowerType(unit)

    if powerToken == "ENERGY" then
        -- Energy (golden yellow)
        statusbar:SetStatusBarColor(1, 0.84, 0)
    elseif powerToken == "RAGE" then
        -- Rage (dark red)
        statusbar:SetStatusBarColor(0.7, 0.1, 0.1)
    elseif powerToken == "MANA" then
        -- Mana (baby blue)
        statusbar:SetStatusBarColor(0, 0.5, 7)
    end
end

local COLOR_ABSORB = {0.8, 0.8, 0.2, 0.7}
local COLOR_AGGRO = {1, 0, 0, 0.7}

function RP:CreateGlowBorder(frame, color)
    local glowSize = 22

    local glowTexture = frame:CreateTexture(nil, 'BACKGROUND')
    glowTexture:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse")
    glowTexture:SetPoint("TOPLEFT", frame, "TOPLEFT", -glowSize - 2, glowSize)
    glowTexture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", glowSize + 2, -glowSize)
    glowTexture:SetDesaturated(true)
    glowTexture:SetBlendMode("ADD")
    glowTexture:SetVertexColor(unpack(color or COLOR_ABSORB))

    glowTexture:Hide()

    return glowTexture
end
