local _, RP = ...
local DB = RP.RasPortUF
local LSM = LibStub("LibSharedMedia-3.0")
local texturePath = "Interface\\AddOns\\RasPortUF\\Media\\Statusbar\\Gloss"
local MAX_BUFFS = 30
local COLOR_ABSORB = {0.8, 0.8, 0.2, 0.7}
local COLOR_AGGRO = {1, 0, 0, 0.7}
local blizzColor = {1, 0.81960791349411, 0, 1}
local headers = {}
local Runes = {}

local N, oUF = RP.N, RP.oUF
local UF = N.UnitFrame

-- Lua APIs
local _G = getfenv(0)
local unpack = _G.unpack
local rad = _G.math.rad

-------------------------------------------------------------------------------
-- Big Frames
--

local function SetColorByProfile(self)
    local c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
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


function UF:CreateBackground(frame, anchor, unit)
    local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    bg:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
    bg:SetHorizTile(true)
    bg:SetVertTile(true)
    bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    if unit == "pet" then
        bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 14, 2)
    else
        bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 2)
    end
    bg:SetVertexColor(0.25, 0.25, 0.25)

    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetBackdrop({
        edgeFile = "Interface\\AddOns\\RasPortUF\\Media\\border-thick.tga",
        tileEdge = true,
        edgeSize = 12,
        insets = {
            left = 6,
            right = 6,
            top = 6,
            bottom = 6
        }
    })
    border:SetFrameLevel(frame:GetFrameLevel() + 3)
    border:SetFrameStrata("LOW")
    local r, g, b = SetColorByProfile(border)
    border:SetBackdropBorderColor(r, g, b, 1)
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -6.4, 7)
    if unit == "pet" then
        border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 19, -5)
    else
        border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 6, -5)
    end

    return bg, border
end

local function CreatePlayerPortrait(frame, unit)
    local circMask = frame:CreateTexture(nil, "OVERLAY", nil, 0)
    circMask:SetTexture('Interface\\AddOns\\RasPortUF\\Media\\Portrait\\circle.tga')
    circMask:SetPoint('RIGHT', frame, 'LEFT')
    circMask:SetSize(50, 50)

    if DB.db.profile["3DPortrait"] then
        -- 3D Portrait
        -- Position and size
        --[[ local Portrait = CreateFrame('PlayerModel', nil, circMask)
        Portrait:SetSize(32, 32)
        Portrait:SetPoint("CENTER") ]]
        -- Register it with oUF
        frame.Portrait = Portrait
    else
        -- 2D Portrait
        local Portrait = frame:CreateTexture(nil, 'OVERLAY')
        Portrait:SetSize(32, 32)

        if unit == "target" then
            Portrait:SetPoint('LEFT', frame, 'RIGHT')
        else
            Portrait:SetPoint('RIGHT', frame, 'LEFT')
        end

        -- Register it with oUF
        frame.Portrait = Portrait
    end
end

-- health Bar
function UF:CreateHealthBar(frame, unit)
    local Health = CreateFrame('StatusBar', nil, frame)
    Health:SetStatusBarTexture(texturePath)
    Health:SetStatusBarColor(0.1, 0.1, 0.1)
    Health:SetFrameLevel(3)

    -- Define the offsets once, adjust these values as needed
    local topOffset = 0
    local bottomOffset = 0
    local leftOffset = 0
    local rightOffset = -4

    if unit == "player" or unit == "focus" then
        topOffset = 0
        bottomOffset = 15
        Health:SetSize(DB.db.profile["PowerWidth"], 20)
    elseif unit == "target" then
        Health:SetReverseFill(true)
        topOffset = 0
        bottomOffset = 15
        Health:SetSize(DB.db.profile["PowerWidth"], 20)
    elseif unit == "targettarget" then
        Health:SetReverseFill(true)
        topOffset = 0
        bottomOffset = 4
    elseif unit == "pet" then
        topOffset = 0
        bottomOffset = 15
        Health:SetSize(DB.db.profile["PowerWidth"] - 65, 15)
    end

    -- Set the anchor points with the defined offsets
    Health:SetPoint('TOPLEFT', frame, 'TOPLEFT', leftOffset, topOffset)

    -- background
    local Background = Health:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints()
    Background:SetTexture(texturePath)
    Background:SetVertexColor(0.4, 0.4, 0.4)
    Background:SetAlpha(0.6)

    Health.Smooth = true
    Health.colorTapping = true
    Health.colorClass = true
    Health.colorReaction = true
    Health.colorHealth = true

    frame.Health = Health
end


function UF:CreateInlayParent(frame, unit)
    local inlayParent = CreateFrame("Frame", nil, frame)

    frame.inlay = inlayParent
end

function UF:CreateHPText(frame)
    if not DB.db.profile["Hide Status Value"] then
        local HPText = frame.Health:CreateFontString(nil, 'OVERLAY')
        HPText:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
        HPText:SetTextColor(unpack(blizzColor))
        HPText:SetPoint('CENTER')
        HPText:SetAlpha(0)
        frame:Tag(HPText, '[hp]')

        frame.HPText = HPText
    end
end

-- curhp value
function UF:CreateCurHP(frame)
    if not DB.db.profile["Hide Status Value"] then
        local CurHP = frame.Health:CreateFontString(nil, 'OVERLAY')
        CurHP:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
        CurHP:SetTextColor(unpack(blizzColor))
        CurHP:SetPoint('CENTER')
        if DB.db.profile["Percentages"] then
            CurHP:SetAlpha(0)
        else
            CurHP:SetAlpha(1)
        end
        frame:Tag(CurHP, '[curhp]')

        frame.Health.CurHP = CurHP
    end
end

function UF:CreatePerHP(frame)
    if not DB.db.profile["Hide Status Value"] then
        local PerHP = frame.Health:CreateFontString(nil, 'OVERLAY')
        PerHP:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
        PerHP:SetTextColor(unpack(blizzColor))
        PerHP:SetPoint('CENTER')
        if DB.db.profile["Percentages"] then
            PerHP:SetAlpha(1)
        else
            PerHP:SetAlpha(0)
        end
        frame:Tag(PerHP, '[perhp]')

        frame.Health.PerHP = PerHP
    end
end

function UF:CreateXpRep(frame)
    local XpRep = frame:CreateFontString(nil, 'OVERLAY')
    XpRep:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), 10, "OUTLINE")
    XpRep:SetPoint('TOP', frame.Power, 'BOTTOM', 0, -5)
    XpRep:SetAlpha(0)
    frame:Tag(XpRep, '[Exp][Rep]')

    frame.XpRep = XpRep
end

function UF:CreateDHlight(frame)
    local DHlight = frame.Health:CreateTexture(nil, 'OVERLAY')
    DHlight:SetPoint('BOTTOMLEFT', frame.Health, -40, -4)
    DHlight:SetPoint('BOTTOMRIGHT', frame.Health, 40, -4)
    DHlight:SetHeight(2)
    DHlight:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\threat")
    DHlight:SetBlendMode('ADD')
    DHlight:Hide()

    frame.DebuffHighlight = DHlight
end

function UF:CreatePowerBar(frame, unit)
    local Power = CreateFrame('StatusBar', nil, frame)
    if unit == "target" then
        Power:SetReverseFill(true)
    end
    Power:SetStatusBarTexture(texturePath)
    Power:SetFrameLevel(4)

    -- background
    local Background = Power:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints()
    Background:SetTexture(texturePath)
    Background:SetVertexColor(0.4, 0.4, 0.4)
    Background:SetAlpha(0.5)

    Power.Smooth = true
    Power.colorPower = true
    Power.frequentUpdates = true

    frame.Power = Power
end

function UF:CreatePPText(frame)
    if not DB.db.profile["Hide Status Value"] then
        local PPText = frame.Power:CreateFontString(nil, 'OVERLAY')
        PPText:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
        PPText:SetTextColor(unpack(blizzColor))
        PPText:SetPoint('CENTER')
        PPText:SetAlpha(0)
        frame:Tag(PPText, '[pp]')

        frame.PPText = PPText
    end
end

function UF:CreateCurPP(frame)
    if not DB.db.profile["Hide Status Value"] then
        local CurPP = frame.Power:CreateFontString(nil, 'OVERLAY')
        CurPP:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
        CurPP:SetTextColor(unpack(blizzColor))
        CurPP:SetPoint('CENTER')
        if DB.db.profile["Percentages"] then
            CurPP:SetAlpha(0)
        else
            CurPP:SetAlpha(1)
        end
        frame:Tag(CurPP, '[curpp]')

        frame.Power.CurPP = CurPP
    end
end

function UF:CreatePerPP(frame)
    if not DB.db.profile["Hide Status Value"] then
        local PerPP = frame.Power:CreateFontString(nil, 'OVERLAY')
        PerPP:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
        PerPP:SetTextColor(unpack(blizzColor))
        PerPP:SetPoint('CENTER')
        if DB.db.profile["Percentages"] then
            PerPP:SetAlpha(1)
        else
            PerPP:SetAlpha(0)
        end
        frame:Tag(PerPP, '[perpp]')

        frame.Power.PerPP = PerPP
    end
end

function UF:UpdatePowerBar(powerWidth)
    for _, frame in ipairs(UF) do -- Iterate over your player frames
        if frame then
            frame:SetWidth(powerWidth + 2)
            frame.Health:SetWidth(powerWidth)
            frame.Power:SetWidth(powerWidth)
            frame.Castbar:SetSize(DB.db.profile["PowerWidth"] + 45, 15)
            -- Update any other elements affected by the Power bar's size
            -- ...
        end
    end
end

function UF:UpdateStatusText(size)
    for _, frame in ipairs(UF) do -- Iterate over your player frames
        if frame then
            if not DB.db.profile["Hide Status Value"] then
                frame.Power.CurPP:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"],
                    "OUTLINE")
                frame.HPText:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
                frame.Health.CurHP:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"],
                    "OUTLINE")
                frame.PPText:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
                -- Update any other elements affected by the Power bar's size
                -- ...
            end
        end
    end
end

function UF:UpdateStatusBarValue()
    for _, frame in ipairs(UF) do -- Iterate over your player frames
        if not DB.db.profile["Hide Status Value"] then
            if DB.db.profile["Percentages"] then
                frame.Health.PerHP:SetAlpha(1)
                frame.Power.CurPP:SetAlpha(0)
                frame.Health.CurHP:SetAlpha(0)
                frame.Power.PerPP:SetAlpha(1)
            else
                frame.Health.PerHP:SetAlpha(0)
                frame.Power.CurPP:SetAlpha(1)
                frame.Health.CurHP:SetAlpha(1)
                frame.Power.PerPP:SetAlpha(0)
            end
        end
    end
end

function UF:CreatePlayerAnchor()
    local playerAnchor = CreateFrame("Frame", "RasPlayer", UIParent, "BackdropTemplate")
    playerAnchor:SetPoint(DB.db.profile["FramePositions"].player.point, UIParent, DB.db.profile["FramePositions"].player.x, DB.db.profile["FramePositions"].player.y)
    playerAnchor:SetSize(40, 30)
    playerAnchor:SetBackdrop({
        bgFile = "Interface\\HELPFRAME\\DarkSandstone-Tile",
        edgeFile = "Interface\\AddOns\\RasPortUF\\Media\\border-thick.tga",
        tileEdge = true,
        edgeSize = 12,
        insets = {
            left = 6,
            right = 6,
            top = 6,
            bottom = 6
        }
    })
    playerAnchor:SetBackdropColor(0, 1, 0, 0.5)
    playerAnchor:SetMovable(true)
    playerAnchor:EnableMouse(true)
    playerAnchor:RegisterForDrag("LeftButton")
    playerAnchor:SetScript("OnDragStart", playerAnchor.StartMoving)
    playerAnchor:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        -- Save the frame position to your configuration
        DB.db.profile["FramePositions"].player.point = point
        DB.db.profile["FramePositions"].player.x = x
        DB.db.profile["FramePositions"].player.y = y
    end)
    playerAnchor:SetAlpha(1)
    
    if DB.db.profile["Lock Frames"] then
        playerAnchor:SetAlpha(0)
    else
        playerAnchor:SetAlpha(1)
    end
    
    UF.playerAnchor = playerAnchor
    end

    function UF:CreateTargetAnchor()
        local targetAnchor = CreateFrame("Frame", "RasTarget", UIParent, "BackdropTemplate")
        targetAnchor:SetPoint(DB.db.profile["FramePositions"].target.point, UIParent, DB.db.profile["FramePositions"].target.x, DB.db.profile["FramePositions"].target.y)
        targetAnchor:SetSize(40, 30)
        targetAnchor:SetBackdrop({
            bgFile = "Interface\\HELPFRAME\\DarkSandstone-Tile",
            edgeFile = "Interface\\AddOns\\RasPortUF\\Media\\border-thick.tga",
            tileEdge = true,
            edgeSize = 12,
            insets = {
                left = 6,
                right = 6,
                top = 6,
                bottom = 6
            }
        })
        targetAnchor:SetBackdropColor(0, 1, 0, 0.5)
        targetAnchor:SetMovable(true)
        targetAnchor:EnableMouse(true)
        targetAnchor:RegisterForDrag("LeftButton")
        targetAnchor:SetScript("OnDragStart", targetAnchor.StartMoving)
        targetAnchor:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local point, _, relativePoint, x, y = self:GetPoint()
            -- Save the frame position to your configuration
            DB.db.profile["FramePositions"].target.point = point
            DB.db.profile["FramePositions"].target.x = x
            DB.db.profile["FramePositions"].target.y = y
        end)
        targetAnchor:SetAlpha(1)
        
        if DB.db.profile["Lock Frames"] then
            targetAnchor:SetAlpha(0)
        else
            targetAnchor:SetAlpha(1)
        end
        
        UF.targetAnchor = targetAnchor
        end

function UF:UnlockFrames()
    if not DB.db.profile["Lock Frames"] then
    UF.playerAnchor:SetMovable(true)
    UF.playerAnchor:EnableMouse(true)
    UF.playerAnchor:SetAlpha(1)

    UF.targetAnchor:SetMovable(true)
    UF.targetAnchor:EnableMouse(true)
    UF.targetAnchor:SetAlpha(1)
else
    UF.playerAnchor:SetMovable(false)
    UF.playerAnchor:EnableMouse(false)
    UF.playerAnchor:SetAlpha(0)

    UF.targetAnchor:SetMovable(false)
    UF.targetAnchor:EnableMouse(false)
    UF.targetAnchor:SetAlpha(0)
end
end

function UF:CreateThreatHlight(frame)
    local Thrt = frame.Health:CreateTexture(nil, 'OVERLAY')
    Thrt:SetPoint('BOTTOMLEFT', frame.Portrait, 40, 8)
    Thrt:SetPoint('BOTTOMRIGHT', frame.Health, 0, -4)
    Thrt:SetHeight(2)
    Thrt:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\threat")
    Thrt:SetBlendMode('ADD')
    Thrt:Hide()

    frame.ThreatIndicator = Thrt
end

function UF:CreateHealPrediction(frame)
    local health = frame.Health

    local myBar = CreateFrame('StatusBar', nil, health)
    myBar:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT')
    myBar:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
    myBar:SetWidth(frame:GetWidth())
    myBar:SetStatusBarTexture("Interface\\AddOns\\RasPortUF\\Media\\Healbar")
    myBar:SetStatusBarColor(.15, 1.0, .15)
    myBar:SetAlpha(0.6)
    myBar:SetFrameLevel(health:GetFrameLevel())
    myBar.Smooth = true

    local otherBar = CreateFrame('StatusBar', nil, health)
    otherBar:SetPoint('TOPLEFT', myBar:GetStatusBarTexture(), 'TOPRIGHT')
    otherBar:SetPoint('BOTTOMLEFT', myBar:GetStatusBarTexture(), 'BOTTOMRIGHT')
    otherBar:SetWidth(frame:GetWidth())
    otherBar:SetStatusBarTexture("Interface\\AddOns\\RasPortUF\\Media\\Healbar")
    otherBar:SetStatusBarColor(1.0, 1.0, 0.1)
    otherBar:SetAlpha(0.6)
    otherBar:SetFrameLevel(health:GetFrameLevel())
    otherBar.Smooth = true

    frame.HealthPrediction = {
        myBar = myBar,
        otherBar = otherBar,
        maxOverflow = 1.0
    }
end

local function UpdateSpark(spark, min, max, value)
    if value <= min or value >= max then
        spark:Hide()
    else
        spark:Show()
    end
end

function UF:CreateHealthSpark(frame, unit)
    local Spark = frame.Health:CreateTexture(nil, 'OVERLAY')
    Spark:SetHeight(20)
    Spark:SetWidth(10)
    Spark:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\spark")
    Spark:SetBlendMode('ADD')

    frame.Health.Spark = Spark

    frame.Health:HookScript('OnValueChanged', function(self, value)
        local min, max = self:GetMinMaxValues()
        UpdateSpark(Spark, min, max, value)
    end)
end

function UF:CreatePowerSpark(frame)
    local Spark = frame.Power:CreateTexture(nil, 'OVERLAY')
    Spark:SetHeight(8)
    Spark:SetWidth(10)
    Spark:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\spark")
    Spark:SetBlendMode('ADD')
    Spark:SetVertexColor(1, 1, 1)

    frame.Power.Spark = Spark

    frame.Power:HookScript('OnValueChanged', function(self, value)
        local min, max = self:GetMinMaxValues()
        UpdateSpark(Spark, min, max, value)
    end)
end

function UF:CreateCastBar(frame, unit)
    -- Position and size
    local Castbar = CreateFrame('StatusBar', nil, frame)
    Castbar:SetStatusBarTexture(texturePath)

    -- Add a background
    local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Castbar)
    Background:SetColorTexture(0, 0, 0, 0.5)

    -- Add a spark
    local Spark = Castbar:CreateTexture(nil, 'OVERLAY')
    Spark:SetSize(10, 20)
    Spark:SetBlendMode('ADD')
    Spark:SetPoint('CENTER', Castbar:GetStatusBarTexture(), 'RIGHT', 0, 0)

    -- Add a timer
    local Time = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Time:SetPoint('RIGHT', Castbar, -5, 0)

    -- Add spell text
    local Text = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Text:SetPoint('LEFT', Castbar)

    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, 'OVERLAY')
    Icon:SetSize(15, 15)
    Icon:SetPoint('TOPLEFT', Castbar, 'TOPLEFT', -15, 0)

    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, 'OVERLAY')

    -- Register it with oUF
    Castbar.bg = Background
    Castbar.Spark = Spark
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.SafeZone = SafeZone
    frame.Castbar = Castbar

    local border = CreateFrame("Frame", nil, Castbar, "BackdropTemplate")
    border:SetBackdrop({
        edgeFile = "Interface\\AddOns\\RasPort\\Media\\UnitFrames\\border-thick.tga",
        tileEdge = true,
        edgeSize = 12,
        insets = {
            left = 6,
            right = 6,
            top = 6,
            bottom = 6
        }
    })
    border:SetFrameLevel(frame:GetFrameLevel() + 7)
    border:SetFrameStrata("LOW")

    -- the way Blizz position it creates really weird gaps, so fix it
    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", Icon, "TOPLEFT", -6, 6)
    border:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMRIGHT", 6, -7)
    local r, g, b = SetColorByProfile(border)
    border:SetBackdropBorderColor(r, g, b, 1)
end

function UF:CreateRunes(frame)
    for i = 1, 6 do
        local Rune = CreateFrame('StatusBar', 'Runes' .. i, frame)
        Rune:SetSize(frame:GetWidth() / 6 - 2, 8)
        Rune:SetStatusBarTexture(texturePath)
        Rune:SetPoint('TOPLEFT', frame.Power, 'BOTTOMLEFT', (i - 1) * frame:GetWidth() / 6 + 2, -6)

        RP:CreateBackdrop(Rune, false)

        Runes[i] = Rune
    end

    frame.Runes = Runes
end

function UF:CreateElementHolder(frame)
    local ElementHolder = CreateFrame('Frame', nil, frame.Health)
    ElementHolder:SetAllPoints()
    ElementHolder:SetFrameLevel(frame.Health:GetFrameLevel() + 2)

    frame.Element = ElementHolder
end

function UF:CombatIndicator(frame)
    local CIi = frame.Element:CreateTexture(nil, 'OVERLAY')
    CIi:SetPoint('LEFT', 5, 1)
    CIi:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\combat")
    CIi:SetVertexColor(1, 0.2, 0.2, 1)

    frame.CombatIndicator = CIi
end

function UF:LeaderIndicator(frame)
    local LIi = frame.Element:CreateTexture(nil, 'OVERLAY')
    LIi:SetPoint('TOPLEFT', frame.Portrait, -9, 15)
    LIi:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\roleicon")

    frame.LeaderIndicator = LIi
end

function UF:LooterIndicator(frame)
    local MLi = frame.Element:CreateTexture(nil, 'OVERLAY')
    MLi:SetPoint('LEFT', frame.LeaderIndicator, 'RIGHT', 0, 0)
    MLi:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\looter")
    MLi:SetVertexColor(0.9, 0.7, 0, 1)

    frame.MasterLooterIndicator = MLi
end


function UF:RestingIndicator(frame)
    local RSi = CreateFrame("Frame", nil, frame)
    RSi:SetFrameLevel(frame:GetFrameLevel() + 7)
    --RSi:SetTexture([[Interface\AddOns\RasPortUF\Media\Portrait\sleepindicator]])
    --RSi:SetTexCoord(0, 0.5, 0, 0.421875)
    --RSi:SetVertexColor(unpack(blizzColor))

    frame.RestingIndicator = RSi
end

function UF:ClassIcon(frame)
    local iconBox = CreateFrame("Frame", nil, frame)
    iconBox:SetSize(12, 12)
    iconBox:SetFrameLevel(frame:GetFrameLevel() + 7)

    iconBox.border = iconBox:CreateTexture(nil, "OVERLAY")
    iconBox.border:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\Portrait\\PORTRAIT-RING.blp")
    iconBox.border:SetAllPoints()
    local r, g, b = SetColorByProfile(iconBox.border)
    iconBox.border:SetVertexColor(r, g, b, 1)

    if DB.db.profile["Hide Icon"] then
        iconBox:Hide()
    end

    local CLi = iconBox:CreateTexture(nil, 'OVERLAY')
    CLi:SetPoint('CENTER')

    local Mask = iconBox:CreateMaskTexture()
    Mask:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\Portrait\\circle.tga")
    Mask:SetAllPoints(CLi)
    CLi:AddMaskTexture(Mask)

    frame.ClassIcon = CLi
    frame.IconBox = iconBox
end

function UF:CreateHeader(frame, unit)
    if not DB then
        -- DB is not initialized yet, so you should handle this case appropriately.
        -- Maybe throw an error, or set up a callback/event handler for when DB is ready.
        error("Database not initialized.")
        return
    end
    local header = frame:CreateFontString(nil, "OVERLAY")
    if unit == "player" or unit == "target" then
        header:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Name Font Size"], "OUTLINE")
        header:SetPoint("TOP", frame, 0, 20)
    else
        header:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), 12, "OUTLINE")
        header:SetPoint("TOP", frame, 0, 15)
    end
    header:SetTextColor(unpack(blizzColor))
    frame:Tag(header, "[name] [shortclassification]")

    return header
end

function UF:ResurrectIndicator(frame)
    local Res = frame.Element:CreateTexture(nil, 'OVERLAY')
    Res:SetPoint('CENTER')

    frame.ResurrectIndicator = Res
end

local function UpdatePortrait(frame)
    frame.Portrait:ForceUpdate()
end


function UF:CreatePortrait(frame, unit)
    local portPoint = CreateFrame('Frame', nil, frame)

    local Portrait = portPoint:CreateTexture(nil, "ARTWORK")
    if unit == "player" or unit == "target" then
        Portrait:SetSize(45, 45)
    else
        Portrait:SetSize(30, 30)
    end
    Portrait:SetPoint("CENTER")

    local Mask = portPoint:CreateMaskTexture()
    Mask:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\Portrait\\circle.tga")
    Mask:SetAllPoints(Portrait)
    Portrait:AddMaskTexture(Mask)

    Portrait.border = portPoint:CreateTexture(nil, "ARTWORK")
    Portrait.border:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\Portrait\\PORTRAIT-RING.blp")
    Portrait.border:SetPoint("TOPLEFT", 1, -1)
    Portrait.border:SetPoint("BOTTOMRIGHT", -1, 1)
    local r, g, b = SetColorByProfile(Portrait.border)
    Portrait.border:SetVertexColor(r, g, b, 1)

    frame.Portrait = Portrait
    frame.UpdatePortrait = UpdatePortrait
    frame.Point = portPoint
end

function UF:CreateLevelBox(frame, unit)
    -- Create the level box frame
    local levelBox = CreateFrame("Frame", nil, frame)
    levelBox:SetSize(20, 20)

    levelBox.bg = levelBox:CreateTexture(nil, "OVERLAY")
    levelBox.bg:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\Portrait\\circle")
    levelBox.bg:SetAllPoints()
    levelBox.bg:SetVertexColor(0.15, 0.15, 0.15, 1)

    levelBox.border = levelBox:CreateTexture(nil, "OVERLAY")
    levelBox.border:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\Portrait\\PORTRAIT-RING.blp")
    levelBox.border:SetAllPoints()
    local r, g, b = SetColorByProfile(levelBox.border)
    levelBox.border:SetVertexColor(r, g, b, 1)


    local levelText = levelBox:CreateFontString(nil, "OVERLAY")
    levelText:SetPoint("CENTER", 0.5, 0)
    levelText:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), 12, "OUTLINE")
    levelText:SetText(UnitLevel(unit))
    levelText:SetTextColor(unpack(blizzColor))
    frame:Tag(levelText, "[smartlevel]")
    if DB.db.profile["Hide Level"] then
        levelBox:Hide()
    end
    frame.levelBox = levelBox
end

function UF:UpdateLevelText()
    for _, frame in ipairs(UF) do -- Iterate over your player frames
        if DB.db.profile["Hide Level"] then
            frame.levelBox:Hide()
        else
            frame.levelBox:Show()
        end
        if DB.db.profile["Hide Icon"] then
            frame.IconBox:Hide()
        else
            frame.IconBox:Show()
        end
    end
end

local function CreatePowerBar(frame, health, unit)
    local power = CreateFrame("StatusBar", nil, frame)
    power:SetStatusBarTexture(texturePath)
    power:SetHeight(10)
    power:SetPoint("BOTTOMLEFT", health, "BOTTOMLEFT", -1, -12)
    power:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, -4)
    if unit == "target" then
        power:SetReverseFill(true)
    end
    frame.Power = power

    power.frequentUpdates = true
    power.colorPower = true

    local manaSpark = power:CreateTexture(nil, "OVERLAY")
    manaSpark:SetDrawLayer("OVERLAY", 7)
    manaSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    manaSpark:SetBlendMode("ADD")
    manaSpark:SetPoint("CENTER", power, "RIGHT", 0, 0)
    manaSpark:Hide()

    local function UpdateManaSpark()
        local currentMana = UnitPower(unit)
        local maxMana = UnitPowerMax(unit)
        local percentage = currentMana / maxMana
        local sparkPosition = percentage * power:GetWidth() - manaSpark:GetWidth() / 2

        if unit == "target" then
            manaSpark:SetSize(3, 15)
            manaSpark:SetPoint("RIGHT", power, "RIGHT", -sparkPosition - 0.5, 0) -- Adjusted to the RIGHT point for reverse fill
        else
            manaSpark:SetSize(5, 20)
            manaSpark:SetPoint("LEFT", power, "LEFT", sparkPosition + 0.5, 0)
        end

        if percentage == 1 or percentage == 0 then
            manaSpark:Hide()
        else
            manaSpark:Show()
        end
    end

    power:SetScript("OnValueChanged", function()
        UpdateManaSpark()
    end)

    return power
end

function UF:CreateBuffs(frame, unit)
    local Buffs = CreateFrame('Frame', nil, frame, "BackdropTemplate")
    Buffs:SetPoint('RIGHT', frame, "LEFT", -55, -73)
    Buffs:SetSize(DB.db.profile["Buff Size"] * 7, DB.db.profile["Buff Size"] * 7)

    Buffs.overlay = true
    Buffs.enableHighlight = true
    Buffs.enableCooldown = true
    Buffs.count = true
    Buffs.size = DB.db.profile["Buff Size"] or 16
    Buffs.spacing = DB.db.profile["Spacing"] or 6
    Buffs['growth-x'] = "LEFT"
    Buffs['growth-y'] = "DOWN"
    Buffs.initialAnchor = "TOPRIGHT"
    if DB.db.profile["Player Debuffs"] then
        Buffs.onlyShowPlayer = true
    end

    frame.Buffs = Buffs
end

function UF:CreateDebuffs(frame)
    local Debuffs = CreateFrame('Frame', nil, frame)
    Debuffs:SetPoint('BOTTOMRIGHT', frame, "BOTTOMRIGHT", -5, -27)
    Debuffs:SetSize(DB.db.profile["Buff Size"] * 7, DB.db.profile["Buff Size"] * 16)

    frame.Debuffs = Debuffs
    Debuffs.enableCooldown = true
    Debuffs.size = DB.db.profile["Debuff Size"] or 20
    Debuffs.spacing = DB.db.profile["Spacing"] or 6
    Debuffs['growth-x'] = "LEFT"
    Debuffs['growth-y'] = "DOWN"
    Debuffs.initialAnchor = "BOTTOMRIGHT"
    if DB.db.profile["Player Debuffs"] then
        Debuffs.onlyShowPlayer = true
    end

    local BuffsCombatFrame = CreateFrame("Frame")
    BuffsCombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    BuffsCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    BuffsCombatFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            frame.Buffs:Hide()
        else
            frame.Buffs:Show()
        end
    end)

    return Debuffs
end

function UF:CreateAuras(frame)
    -- This function will now call the separate buff and debuff creation functions
    self:CreateBuffs(frame)
    self:CreateDebuffs(frame)
end

local function UpdateCastBar(frame, unit)
    local name, _, _, _, endTimeMS, _, _, notInterruptible, _ = UnitCastingInfo(unit)

    if notInterruptible then
        frame:SetStatusBarColor(0.7, 0.7, 0, 1) -- Default color
    else
        frame:SetStatusBarColor(0.6, 0.2, 0.9, 1) -- Purple
    end
end

function UF:UpdateAll(value)
    UF:UpdateLevelText()
    UF:UpdateStatusBarValue()
    UF:UpdateStatusText(value)
end

--[[ function core:CreateHeader(frame, unit)
    local header = frame:CreateFontString(nil, "OVERLAY")
    header:SetFont(LSM:Fetch("font", core.db.profile.unitframes["Font"]), core.db.profile.unitframes["Name Font Size"],
        "OUTLINE")
    header:SetText(UnitName(unit))
    header:SetTextColor(unpack(blizzColor))
    return header
end

function core:CreateHealthBar(frame, unit)
    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetSize(154, 30)
    healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
    healthBar:SetValue(UnitHealth(unit))
    healthBar:SetStatusBarTexture(texturePath)
    healthBar:SetFrameLevel(1)
    if unit == "target" then
        healthBar:SetPoint("TOP", frame, "TOP", -24, -7)
        healthBar:SetReverseFill(true)
        healthBar:GetStatusBarTexture():SetTexCoord(1, 0, 0, 1)
    else
        healthBar:SetPoint("TOP", frame, "TOP", 24, -7)
    end
    healthBar:EnableMouse(true)

    local healingPredictionBar = CreateFrame("StatusBar", nil, healthBar)
    healingPredictionBar:SetAllPoints(healthBar)
    healingPredictionBar:SetStatusBarTexture(texturePath)
    healingPredictionBar:SetStatusBarColor(0, 1, 0, 0.5)
    healingPredictionBar:SetMinMaxValues(0, UnitHealthMax(unit))
    healingPredictionBar:SetFrameLevel(healthBar:GetFrameLevel() + 1)
    healingPredictionBar:Hide()

    return healthBar
end

function core:CreateHealthText(frame, unit)
    local healthText = frame:CreateFontString(nil, "OVERLAY")
    healthText:SetPoint("CENTER", frame, "CENTER")
    healthText:SetFont(LSM:Fetch("font", core.db.profile.unitframes["Font"]),
        core.db.profile.unitframes["Health Font Size"], "THINOUTLINE")
    healthText:SetText(UnitHealth(unit) .. " / " .. UnitHealthMax(unit))
    healthText:SetTextColor(unpack(blizzColor))
    healthText:Hide()

    return healthText
end

function core:CreateManaBar(frame, anchor, unit)
    local manaBar = CreateFrame("StatusBar", nil, frame)
    manaBar:SetSize(155, 10)
    manaBar:SetPoint("TOP", anchor, "BOTTOM", 0, -2)
    manaBar:SetMinMaxValues(0, UnitPowerMax(unit))
    manaBar:SetValue(UnitPower(unit))
    manaBar:SetStatusBarTexture(texturePath)
    manaBar:SetStatusBarColor(0, 0.5, 7)
    manaBar:SetFrameLevel(1)
    manaBar:EnableMouse(true)

    if unit == "target" then
        manaBar:SetReverseFill(true)
    end

    local manaSpark = manaBar:CreateTexture(nil, "OVERLAY")
    manaSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    manaSpark:SetSize(5, 15)
    manaSpark:SetBlendMode("ADD")
    manaSpark:SetPoint("CENTER", manaBar, "RIGHT", 0, 0)
    manaSpark:Hide()

    local function UpdateManaSpark()
        local currentMana = UnitPower(unit)
        local maxMana = UnitPowerMax(unit)
        local percentage = currentMana / maxMana
        local sparkPosition = percentage * manaBar:GetWidth() - manaSpark:GetWidth() / 2

        if unit == "target" then
            manaSpark:SetPoint("RIGHT", manaBar, "RIGHT", -sparkPosition, 0) -- Adjusted to the RIGHT point for reverse fill
        else
            manaSpark:SetPoint("LEFT", manaBar, "LEFT", sparkPosition, 0)
        end

        if percentage == 1 or percentage == 0 then
            manaSpark:Hide()
        else
            manaSpark:Show()
        end
    end

    manaBar:SetScript("OnValueChanged", function()
        UpdateManaSpark()
    end)

    return manaBar
end

function core:CreateManaText(frame, unit)
    local manaText = frame:CreateFontString(nil, "OVERLAY")
    manaText:SetPoint("CENTER", frame, "CENTER")
    manaText:SetFont(LSM:Fetch("font", core.db.profile.unitframes["Font"]), 12, "OUTLINE")
    manaText:SetText(UnitPower(unit) .. " / " .. UnitPowerMax(unit))
    manaText:SetTextColor(unpack(blizzColor))
    manaText:Hide()

    return manaText
end

function core:CreatePortrait(frame, unit)
    local portrait = CreateFrame("Frame", nil, frame)
    portrait:SetSize(50, frame:GetHeight() - 10)
    portrait:EnableMouse(true)

    local sep = portrait:CreateTexture(nil, "OVERLAY", nil, 0)
    sep:SetTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\statusbar-sep.tga")
    sep:SetSize(12, 43)
    local r, g, b = core:ColorTexture(sep)
    sep:SetVertexColor(r, g, b, 1)
    if unit == "target" then
        sep:SetPoint("LEFT", portrait, 0, 0)
        portrait:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
        core:SetupUnitPortrait(frame, unit, frame:GetHeight() - 10, "RIGHT", -8, 0)
    else
        sep:SetPoint("RIGHT", portrait, 0, 0)
        portrait:SetPoint("LEFT", frame, "LEFT", 8, 0)
        core:SetupUnitPortrait(frame, unit, frame:GetHeight() - 10, "LEFT", 8, 0)
    end
    return portrait
end

function core:CreateLevelBox(parentFrame, unit)
    -- Create the level box frame
    local levelBox = CreateFrame("Frame", nil, parentFrame)
    levelBox:SetSize(30, 27)
    levelBox:EnableMouse(true)
    if unit == "target" then
        levelBox:SetPoint("BOTTOMRIGHT", parentFrame, 32, -5)
    else
        levelBox:SetPoint("BOTTOMLEFT", parentFrame, -32, -5)
    end
    core:CreateBackdrop(levelBox)

    return levelBox
end

function core:CreateLevelText(parentFrame, unit)
    local levelBoxtext = parentFrame:CreateFontString(nil, "OVERLAY")
    levelBoxtext:SetPoint("CENTER", parentFrame, 0, -1)
    levelBoxtext:SetFont(LSM:Fetch("font", core.db.profile.unitframes["Font"]), 12, "OUTLINE")
    levelBoxtext:SetText(UnitLevel(unit))
    levelBoxtext:SetTextColor(unpack(blizzColor))

    return levelBoxtext
end

function core:CreateInlayParent(parentFrame, unit)
    local inlayParent = CreateFrame("Frame", nil, parentFrame)
    inlayParent:SetSize(155, 43)
    inlayParent:EnableMouse(true)
    if unit == "target" then
        inlayParent:SetPoint("CENTER", parentFrame, -24, 0)
    else
        inlayParent:SetPoint("CENTER", parentFrame, 24, 0)
    end

    return inlayParent
end

function core:CreateSeperator(frame, point)
    local tex1 = frame:CreateTexture(nil, "OVERLAY", nil, 1)
    tex1:SetTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\unit-frame-sep-horiz.tga")
    tex1:SetTexCoord(1 / 32, 17 / 32, 14 / 64, 26 / 64)
    tex1:SetSize(4, 12 / 2)
    tex1:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -2, -4)
    tex1:SetSnapToPixelGrid(false)
    tex1:SetTexelSnappingBias(0)

    local tex3 = frame:CreateTexture(nil, "OVERLAY", nil, 1)
    tex3:SetTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\unit-frame-sep-horiz.tga")
    tex3:SetTexCoord(1 / 32, 17 / 32, 27 / 64, 39 / 64)
    tex3:SetSize(4, 12 / 2)
    tex3:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", 2, -4)
    tex3:SetSnapToPixelGrid(false)
    tex3:SetTexelSnappingBias(0)

    local tex2 = frame:CreateTexture(nil, "OVERLAY", nil, 0)
    tex2:SetTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\unit-frame-sep-horiz-main.tga", "REPEAT", "REPEAT")
    tex2:SetPoint("TOPLEFT", tex1, "TOPRIGHT", -0.15742, 1.39)
    tex2:SetPoint("BOTTOMRIGHT", tex3, "BOTTOMLEFT", 0.3, -1.5)
    tex2:SetSnapToPixelGrid(false)
    tex2:SetTexelSnappingBias(0)
end


function core:UpdateClassIcon(fontString, unit, size)
    local _, class = UnitClass(unit)
    local textSize = "|TInterface\\AddOns\\RasPort\\Media\\Statusbar\\unit-frame-icons:" .. size .. ":" .. size .. ":0:0:256:256:"
    if class == "WARRIOR" then --
        fontString:SetText(textSize .. "1:33:166:198|t")
    elseif class == "DEATHKNIGHT" then --
        fontString:SetText(textSize .. "67:99:199:231|t")
    elseif class == "PALADIN" then --
        fontString:SetText(textSize .. "34:66:199:231|t")
    elseif class == "HUNTER" then --
        fontString:SetText(textSize .. "133:165:166:198|t")
    elseif class == "ROGUE" then --
        fontString:SetText(textSize .. "67:99:166:198|t")
    elseif class == "PRIEST" then --
        fontString:SetText(textSize .. "199:231:166:198|t")
    elseif class == "SHAMAN" then  --
        fontString:SetText(textSize .. "166:198:166:198|t")
    elseif class == "MAGE" then 
        fontString:SetText(textSize .. "34:66:166:198|t")
    elseif class == "WARLOCK" then
        fontString:SetText(textSize .. "1:33:199:231|t")
    elseif class == "DRUID" then
        fontString:SetText(textSize .. "100:132:166:198|t")
    end
end

function core:UpdateHealthPrediction(frame, anchor, unit)
    local currentHealth = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local predictedHeal = UnitGetIncomingHeals(unit) or 0
    local predictedEndValue = currentHealth + predictedHeal

    if predictedEndValue > maxHealth then
        predictedHeal = maxHealth - currentHealth
    end

    frame:SetPoint("LEFT", anchor, "LEFT", (currentHealth / maxHealth) * anchor:GetWidth(), 0)
    frame:SetWidth((predictedHeal / maxHealth) * anchor:GetWidth())

    if predictedHeal > 0 then
        frame:Show()
    else
        frame:Hide()
    end
end

local function SetBarValues(bar, text, value, maxValue, displayPercent)
    bar:SetMinMaxValues(0, maxValue)
    bar:SetValue(value)
    if displayPercent then
        local percent = (value / maxValue) * 100
        text:SetText(string.format("%.0f%%", percent))
    else
        local abbreviatedValue = core:AbbreviateNumber(value)
        local abbreviatedMaxValue = core:AbbreviateNumber(maxValue)
        text:SetText(abbreviatedValue .. " / " .. abbreviatedMaxValue)
    end
end

function core:UpdateHealth(frame, text, unit)
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    SetBarValues(frame, text, health, maxHealth, core.db.profile.unitframes["Percent"])
end

function core:UpdateMana(frame, text, unit)
    local mana = UnitPower(unit)
    local maxMana = UnitPowerMax(unit)
    SetBarValues(frame, text, mana, maxMana, core.db.profile.unitframes["Percent"])
end

function core:InitializeAurasForFrame(specificFrame, unit)
    specificFrame.debuffs = {}
    specificFrame.buffs = {}
    core:CreateIcons(specificFrame.debuffs, specificFrame, unit)
    core:CreateIcons(specificFrame.buffs, specificFrame, unit)
end

-- function core:UpdateDebuffs(frame)
-- core:UpdateAuras(frame)
-- end

function core:UpdateAuraSize(frame)
    local buffSize = core.db.profile.unitframes["Buff Size"]
    if not buffSize then
        return
    end
    for i = 1, MAX_BUFFS do
        frame.debuffs[i]:SetSize(buffSize, buffSize)
        frame.buffs[i]:SetSize(buffSize, buffSize)
    end
end

function core:UpdateAurasForCombatState(frame, unit, auraType)
    if not frame or (auraType ~= "buffs" and auraType ~= "debuffs") then
        return
    end

    local oppositeAuraType = auraType == "buffs" and "debuffs" or "buffs"

    if InCombatLockdown() then
        if auraType == "debuffs" then
            core:UpdateAuras(unit, false, frame)
        else -- If showing buffs in combat, ensure we update them
            core:UpdateAuras(unit, true, frame)
        end
        for i = 1, MAX_BUFFS do
            frame[oppositeAuraType][i]:Hide()
        end
    else
        if auraType == "buffs" then
            core:UpdateAuras(unit, true, frame)
        else -- If showing debuffs out of combat, ensure we update them
            core:UpdateAuras(unit, false, frame)
        end
        for i = 1, MAX_BUFFS do
            frame[oppositeAuraType][i]:Hide()
        end
    end
end

local absorbSpells = {
    ["Power Word: Shield"] = true
    -- ["Another Absorb Spell Name"] = true,
    -- ...
}

local function HasAbsorbBuff(unit)
    for i = 1, 40 do
        local name = UnitBuff(unit, i)
        if not name then
            break
        end

        if absorbSpells[name] then
            return true
        end
    end
    return false
end

function core:SetupUnits()
    local baseXForPlayer = -300
    local baseXForTarget = 300
    local separationOffset = core.db.profile.unitframes.separationOffset or 0

    --core.frameComponents["player"].mainFrame:SetPoint("CENTER", UIParent, "CENTER", baseXForPlayer - separationOffset,
            --core.db.profile.unitframes.playerOffsetY)
    core.frameComponents["target"].mainFrame:SetPoint("CENTER", UIParent, "CENTER", baseXForTarget + separationOffset,
            core.db.profile.unitframes.targetOffsetY)
end

function core:SetFrameScale(scale)
    if not InCombatLockdown() then
        --core.frameComponents["player"].buttonFrame:SetScale(scale)
        core.frameComponents["target"].buttonFrame:SetScale(scale)
        --core.frameComponents["focus"].buttonFrame:SetScale(scale)
        --core.frameComponents["pet"].mainFrame:SetScale(scale)
        core.frameComponents["targettarget"].mainFrame:SetScale(scale)
        core.db.profile.unitframes["size"] = scale
    end
end

core.ApplySettings = function(settings)
    settings = settings or core.db.profile.unitframes
    for k, v in pairs(defaults) do
        if settings[k] == nil then
            settings[k] = v
        end
    end


    --header:SetFont(font, settings["Name Font Size"], "OUTLINE")
    if core.frameComponents then
        core:SetFrameScale(core.db.profile.unitframes["size"])
        --core:UpdateHeaderPosition(core.frameComponents["player"].header, "player", core.frameComponents["player"].buttonFrame)
        core:UpdateHeaderPosition(core.frameComponents["target"].header, "target", core.frameComponents["target"].buttonFrame)
        --core.frameComponents["player"].healthText:SetFont(LSM:Fetch("font", core.db.profile.unitframes["Font"]), core.db.profile.unitframes["Health Font Size"], "THINOUTLINE")
        core.frameComponents["target"].healthText:SetFont(LSM:Fetch("font", core.db.profile.unitframes["Font"]), core.db.profile.unitframes["Health Font Size"], "THINOUTLINE")
    end

end ]]

--[[ function core:CreateMainFrameAndComponents(unit, x, y)
    local frameComponents = {}
    if not core.frameComponents then
        core.frameComponents = {}
    end

    frameComponents.mainFrame = core:CreateMainFrame(unit, x, y)
    frameComponents.buttonFrame = core:CreateButtonFrame(frameComponents.mainFrame, "RasPortUF_" .. unit .. "Frame", unit)
    frameComponents.dropdown = core:CreateDropdownFrame(frameComponents.buttonFrame, unit)
    frameComponents.header = core:CreateHeader(frameComponents.mainFrame, unit)
    frameComponents.healthBar = core:CreateHealthBar(frameComponents.buttonFrame, unit)
    frameComponents.healthText = core:CreateHealthText(frameComponents.healthBar, unit)
    frameComponents.sep = core:CreateSeperator(frameComponents.buttonFrame, frameComponents.healthBar)
    frameComponents.manaBar = core:CreateManaBar(frameComponents.buttonFrame, frameComponents.healthBar, unit)
    frameComponents.manaText = core:CreateManaText(frameComponents.manaBar, unit)
    frameComponents.portrait = core:CreatePortrait(frameComponents.buttonFrame, unit)
    frameComponents.LevelBox = core:CreateLevelBox(frameComponents.portrait, unit)
    frameComponents.LevelText = core:CreateLevelText(frameComponents.LevelBox, unit)
    frameComponents.inlayParent = core:CreateInlayParent(frameComponents.buttonFrame, unit)
    frameComponents.inlay = core:CreateBorder(frameComponents.inlayParent)
    -- ... (other components creation)

    if unit == "target" then
        frameComponents.inlay:SetTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\unit-frame-inlay-left.tga")
    else
        frameComponents.inlay:SetTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\unit-frame-inlay-right.tga")
    end

    core:InitializeAurasForFrame(frameComponents.buttonFrame, unit)

    core.frameComponents[unit] = frameComponents

    return frameComponents
end ]]

-------------------------------------------------------------------------------
-- Small Frames
--

function UF:CreateSmallFrame(frame, name, unit, x, y)
    local mainFrame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    mainFrame:SetSize(100, 40)
    if unit == "pet" then
        mainFrame:SetPoint("CENTER", frame, "CENTER", x, y)
    else
        mainFrame:SetPoint("CENTER", frame, "CENTER", x, y)
    end
    mainFrame:Show()
    mainFrame:SetScale(RP.db.profile.unitframes["size"])
    RP:CreateBackdrop(mainFrame)
    mainFrame:EnableMouse(true)

    mainFrame:SetScript("OnEnter", function()
        RP.frameComponents[unit].healthText:Show()
        RP.frameComponents[unit].manaText:Show()
    end)
    mainFrame:SetScript("OnLeave", function()
        RP.frameComponents[unit].healthText:Hide()
        RP.frameComponents[unit].manaText:Hide()
    end)

    return mainFrame
end
--[[ 
function UF:CreateSmallHeader(frame, unit)
    local header = frame:CreateFontString(nil, "OVERLAY")
    header:SetFont(LSM:Fetch("font", RP.db.profile.unitframes["Font"]), 12, "OUTLINE")
    header:SetText(UnitName(unit))
    header:SetTextColor(unpack(blizzColor))
    header:SetPoint("BOTTOM", frame, "TOP", 0, -5)
    return header
end

function UF:CreateSmallHealth(frame, unit)
    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetSize(87, 20)
    healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
    healthBar:SetValue(UnitHealth(unit))
    healthBar:SetStatusBarTexture(texturePath)
    healthBar:SetPoint("TOP", frame, "TOP", 0, -6)
    healthBar:SetFrameLevel(1)

    if unit == "targettarget" then
        healthBar:SetReverseFill(true)
    end

    return healthBar
end

function UF:CreateSmallHealthText(frame, unit)
    local healthText = frame:CreateFontString(nil, "OVERLAY")
    healthText:SetPoint("CENTER", frame, "CENTER")
    healthText:SetFont(LSM:Fetch("font", RP.db.profile.unitframes["Font"]), 10, "THINOUTLINE")
    healthText:SetText(UnitHealth(unit) .. " / " .. UnitHealthMax(unit))
    healthText:SetTextColor(unpack(blizzColor))
    healthText:Hide()

    return healthText
end

function UF:CreateSmallMana(frame, anchor, unit)
    local manaBar = CreateFrame("StatusBar", nil, frame)
    manaBar:SetSize(87, 5)
    manaBar:SetPoint("TOP", anchor, "BOTTOM", 0, -2)
    manaBar:SetMinMaxValues(0, UnitPowerMax(unit))
    manaBar:SetValue(UnitPower(unit))
    manaBar:SetStatusBarTexture(texturePath)
    manaBar:SetStatusBarColor(0, 0.5, 7)
    manaBar:SetFrameLevel(1)

    if unit == "targettarget" then
        manaBar:SetReverseFill(true)
    end

    local manaSpark = manaBar:CreateTexture(nil, "OVERLAY")
    manaSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    manaSpark:SetSize(20, 25)
    manaSpark:SetBlendMode("ADD")
    manaSpark:SetPoint("CENTER", manaBar, "RIGHT", 0, 0)
    manaSpark:Hide()

    local function UpdateManaSpark()
        local currentMana = UnitPower(unit)
        local maxMana = UnitPowerMax(unit)
        local percentage = currentMana / maxMana
        local sparkPosition = percentage * manaBar:GetWidth() - manaSpark:GetWidth() / 2

        if unit == "targettarget" then
            manaSpark:SetPoint("RIGHT", manaBar, "RIGHT", -sparkPosition, 0) -- Adjusted to the RIGHT point for reverse fill
        else
            manaSpark:SetPoint("LEFT", manaBar, "LEFT", sparkPosition, 0)
        end

        if percentage == 1 or percentage == 0 then
            manaSpark:Hide()
        else
            manaSpark:Show()
        end
    end

    manaBar:SetScript("OnValueChanged", function()
        UpdateManaSpark()
    end)

    return manaBar
end

function UF:CreateSmallManaText(frame, unit)
    local manaText = frame:CreateFontString(nil, "OVERLAY")
    manaText:SetPoint("CENTER", frame, "CENTER")
    manaText:SetFont(LSM:Fetch("font", core.db.profile.unitframes["Font"]), 10, "OUTLINE")
    manaText:SetText(UnitPower(unit) .. " / " .. UnitPowerMax(unit))
    manaText:SetTextColor(unpack(blizzColor))

    return manaText
end

function core:CreateSmallInlay(parentFrame, unit)
    local inlayParent = CreateFrame("Frame", nil, parentFrame)
    inlayParent:SetSize(90, 28)
    inlayParent:SetPoint("CENTER", parentFrame, 0, 0)

    return inlayParent
end

function core:CreateSmallFrameAndComponents(unit, x, y, frame)
    local frameComponents = {}
    if not core.frameComponents then
        core.frameComponents = {}
    end

    frameComponents.mainFrame = core:CreateSmallFrame(frame, "RasPortUF_" .. unit .. "Frame", unit, x, y)
    frameComponents.header = core:CreateSmallHeader(frameComponents.mainFrame, unit)
    frameComponents.healthBar = core:CreateSmallHealth(frameComponents.mainFrame, unit)
    frameComponents.healthText = core:CreateSmallHealthText(frameComponents.healthBar, unit)
    frameComponents.manaBar = core:CreateSmallMana(frameComponents.mainFrame, frameComponents.healthBar, unit)
    frameComponents.manaText = core:CreateSmallManaText(frameComponents.manaBar, unit)
    -- frameComponents.LevelBox = core:CreateLevelBox(frameComponents.portrait, unit)
    -- frameComponents.LevelText = core:CreateLevelText(frameComponents.LevelBox, unit)
    frameComponents.inlayParent = core:CreateSmallInlay(frameComponents.mainFrame, unit)
    frameComponents.inlay = core:CreateBorder(frameComponents.inlayParent)
    -- ... (other components creation)
    frameComponents.inlay:SetTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\unit-frame-inlay-both.tga")
    -- core:InitializeAurasForFrame(frameComponents.buttonFrame)

    core.frameComponents[unit] = frameComponents

    return frameComponents
end ]]
