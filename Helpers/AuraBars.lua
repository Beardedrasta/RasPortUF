local _, RP = ...

-- Lua APIs
local _G = getfenv(0)
local unpack = _G.unpack
local huge = _G.math.huge
local tsort = _G.table.sort

-- WoW APIs
local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local UnitClass = _G.UnitClass
local UnitIsPlayer = _G.UnitIsPlayer

-- oUF_Nihlathak
local N, C, oUF = RP.N, RP.C, RP.oUF
local UF = N.UnitFrame
local FormatTime = RP.FormatTime
local playerClass = N.playerClass

-- Register Libs
local LSM = LibStub('LibSharedMedia-3.0')

local AuraBar = {}

-- aura bar timer
local function CreateBarTimer(button, elapsed)
    button.elapsed = button.timeLeft + elapsed

    if (button.elapsed > 0.01) then
        button.timeLeft = button.timeLeft - elapsed

        if (button.timeLeft > 0) then
            -- button animation
            if (button.isPlayer and (button.timeLeft < 5)) then
                RP:StartTransAnim(button)
            else
                RP:StopTransAnim(button)
            end
            -- time text
            if (button.timeLeft < 600) then
                button.bar:SetValue(button.timeLeft) -- set bar value
                button.timeText:SetFormattedText(FormatTime(button.timeLeft))
                -- text color
                local r, g, b = oUF:ColorGradient(button.timeLeft, button.duration, 1, .3, .3, 1, 1, 0, 1, 1, 1)
                button.timeText:SetTextColor(r, g, b)
            else
                button:SetScript('OnUpdate', nil)
                button.timeText:SetText('')
            end
        end

        button.elapsed = 0
    end
end

function AuraBar:PostCreateIcon(button)
    local db = RP.RasPortUF.db.profile
    local frame = self.__owner
    local barWidth = frame:GetWidth()

    self.enableCooldown = true -- cooldown spiral
    button.Cooldown.noCooldownCount = true -- hide OmniCC's CooldownCount

    local overlay = CreateFrame('Frame', nil, button, 'BackdropTemplate')
    overlay:SetPoint('TOPLEFT', button, -1, 1)
    overlay:SetPoint('BOTTOMRIGHT', button, 1, -1)
    overlay:SetBackdrop({
        bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1
    })
    overlay:SetBackdropColor(0, 0, 0, 0)
    overlay:SetBackdropBorderColor(0, 0, 0, 1)
    overlay:SetFrameLevel(0)

    local bar = CreateFrame('StatusBar', nil, button, 'BackdropTemplate')
    bar:SetPoint('BOTTOMLEFT', button, 'BOTTOMRIGHT', 4, 0)
    bar:SetSize(barWidth - db["Buff Size"] - 4, db["Buff Size"])
    bar:SetStatusBarTexture("Interface\\AddOns\\RasPortUF\\Media\\RasPort")
    bar:SetFrameLevel(1)
    button.bar = bar

    local bg = CreateFrame('StatusBar', nil, bar, 'BackdropTemplate')
    bg:SetPoint('TOPLEFT', -1, 1)
    bg:SetPoint('BOTTOMRIGHT', 1, -1)
    bg:SetBackdrop({
        bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1
    })
    bg:SetBackdropColor(.2, .2, .2, .2)
    bg:SetBackdropBorderColor(0, 0, 0, 1)
    bg:SetFrameLevel(0)

    local spark = bar:CreateTexture(nil, 'OVERLAY')
    spark:SetPoint('CENTER', bar:GetStatusBarTexture(), 'RIGHT')
    spark:SetSize(8, 20)
    spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
    spark:SetBlendMode('ADD')
    bar.spark = spark

    local nameText = bar:CreateFontString(nil, 'OVERLAY')
    nameText:SetFont(LSM:Fetch("font", db["Font"]), 12, "OUTLINE")
    nameText:SetWidth(bar:GetWidth() * 0.7)
    nameText:SetJustifyH('LEFT')
    nameText:SetWordWrap(false)
    button.nameText = nameText

    button.timeText:SetFont(LSM:Fetch("font", db["Font"]), 12, "OUTLINE")
    button.timeText:SetPoint('BOTTOMLEFT', bar, 'TOPRIGHT', -20, -1)
    button.timeText:SetJustifyH('LEFT')

    button.countText:SetFont(LSM:Fetch("font", db["Font"]), 12, "OUTLINE")
    button.countText:SetPoint('BOTTOMLEFT', bar, 'TOPLEFT', 2, -1)
    button.countText:SetTextColor(1.0, 	.82,	0.1)

    button.arrowTex:SetPoint('BOTTOMLEFT', -6, -4)
    button.arrowTex:SetSize(20, 16)
    button.arrowTex:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\garrow")
    button.arrowTex:SetAlpha(0)

    RP:CreateTransAnimation(button)
end

function AuraBar:PostUpdateIcon(_, button, _, _, duration, expiration, dispelType)
    -- bar text
    button.nameText:SetText(button.name)
    if (button.count and button.count > 1) then
        button.countText:SetFormattedText('<%d>', button.count)
        button.nameText:SetPoint('LEFT', button.countText, 'RIGHT', -2, 1)
    else
        button.countText:SetText('')
        button.nameText:SetPoint('BOTTOMLEFT', button.bar, 'TOPLEFT', 2, -1)
    end
    -- bar timer
    if (duration and duration > 0) then
        button.duration = duration
        button.timeLeft = expiration - GetTime()
        button:SetScript('OnUpdate', CreateBarTimer)
        button.bar:SetMinMaxValues(0, duration)
        button.bar.spark:Show()
        -- bar color
        if (button.isDebuff) then
            local color = oUF.colors.debuff[dispelType or 'none']
            button.bar:SetStatusBarColor(color.r, color.g, color.b, .8)
        else
            local casterIsPlayer = UnitIsPlayer(button.caster)
            if (casterIsPlayer) then
                local _, classToken = UnitClass(button.caster)
                local color = oUF.colors.class[classToken]
                button.bar:SetStatusBarColor(color.r, color.g, color.b, .8)
            else
                button.bar:SetStatusBarColor(1, .5, .25, .8)
            end
        end
    else
        button.timeLeft = huge
        button.bar:SetValue(0)
        button.bar:SetStatusBarColor(.2, .2, .2, .2)
        button.bar.spark:Hide()
    end
end

function AuraBar:CustomFilter(_, button, name, _, _, _, _, _, _, _, _, spellID, _, isBossDebuff)
    if (not name) then
        return
    end

    if (C.AuraList.ALL[spellID] or (button.isPlayer and C.AuraList[playerClass][spellID]) or isBossDebuff) and
        (not RP:GetAura(spellID)) then
        return true
    end
end

function AuraBar:PreSetPosition()
    if (#self.active > 1) then
        tsort(self.active, function(a, b)
            if (a:IsShown() and b:IsShown()) then
                return a.timeLeft < b.timeLeft
            else
                return a:IsShown()
            end
        end)
    end

    return 1, self.visibleAuras
end

local function UpdateAuraBars(frame)
    local element = frame.Auras
    local config = C.db.AuraBars

    if config.enable then
        element.Holder:Show()
    else
        element.Holder:Hide()
    end

    element.spacing = 4
    element.size = config.IconSize
    element.numTotal = config.Amount
    element.barHeight = config.Height
    element.forceShow = C.db.forceShowAuras
    element:SetSize(element.size, (element.size + element.spacing) * element.numTotal)

    for i = 1, element.createdIcons do
        element[i].bar:SetHeight(element.barHeight)
        element[i].nameText:SetFont(LSM:Fetch("font", db["Font"]), 12, "OUTLINE")
    end

    if frame:IsElementEnabled('Auras') then
        element:ForceUpdate()
    end
end

function UF:CreateAuraBars(frame)
    local Holder = CreateFrame('Frame', nil, frame)
    local Auras = RP:Mixin(CreateFrame('Frame', 'AuraBars', Holder), AuraBar)
    Auras.Holder = Holder

    frame.Auras = Auras
    frame.UpdateAuraBars = UpdateAuraBars
end
