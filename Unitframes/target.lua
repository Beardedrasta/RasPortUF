local _, RP = ...
local DB = RP.RasPortUF
local LSM = LibStub("LibSharedMedia-3.0")
local texturePath = "Interface\\AddOns\\RasPort\\Media\\Statusbar\\statusbar-texture.tga"
local MAX_BUFFS = 30
local COLOR_ABSORB = {0.8, 0.8, 0.2, 0.7}
local COLOR_AGGRO = {1, 0, 0, 0.7}
local blizzColor = {1, 0.81960791349411, 0, 1}
local playerFrames = RP.playerFrames

local N, oUF = RP.N, RP.oUF
local UF = N.UnitFrame

local _G = getfenv(0)
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

core:AddModule("target", "custom target frame", function(L)
    if not core.db.profile.disabled["Unitframes"] or core.ElvUI then
        return
    end
    local unit = "target"

    core:CreateMainFrameAndComponents(unit, 300, 200)

    local myFrameComponents = core.frameComponents[unit]
    if myFrameComponents then
        mainFrame = myFrameComponents.mainFrame
        buttonFrame = myFrameComponents.buttonFrame
        header = myFrameComponents.header
        healthBar = myFrameComponents.healthBar
        healthText = myFrameComponents.healthText
        manaBar = myFrameComponents.manaBar
        manaText = myFrameComponents.manaText
        portrait = myFrameComponents.portrait
        LevelBox = myFrameComponents.LevelBox
        LevelText = myFrameComponents.LevelText
        inlayParent = myFrameComponents.inlayParent
        inlay = myFrameComponents.inlay
    end

    local eliteText = buttonFrame:CreateFontString(nil, "OVERLAY")
    eliteText:SetPoint("TOPRIGHT", buttonFrame, "TOPRIGHT", -12, 10)
    eliteText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    local function UpdateEliteText()
        local classification = UnitClassification("target")
        if classification == "elite" then
            eliteText:SetText("ELITE")
            eliteText:Show()
            eliteText:SetTextColor(0.8, 0.2, 1) -- White color
        elseif classification == "boss" then
            eliteText:SetText("BOSS")
            eliteText:Show()
            eliteText:SetTextColor(1, 0.5, 0) -- White color
        else
            eliteText:SetText("") -- Clear text if not elite
            eliteText:Hide()
        end
    end

    local classIcon = inlayParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classIcon:SetDrawLayer("OVERLAY", 7)
    classIcon:SetPoint("TOPRIGHT", buttonFrame, 0, -1)
    classIcon:SetText(
        "|TInterface\\AddOns\\RasPort\\Media\\Statusbar\\unit-frame-icons:16:16:0:0:256:256:100:132:166:198|t")
    classIcon:Show()

    local function SetBannerOnPortrait(portrait)
        local faction = UnitFactionGroup("target")

        -- Check if bannerHolder already exists. If not, create it.
        if not portrait.bannerHolder then
            portrait.bannerHolder = CreateFrame("Frame", nil, portrait)
            portrait.bannerHolder:SetPoint("TOP", portrait, "BOTTOM", 5, 10)
            portrait.bannerHolder:SetSize(40, 44)

            portrait.bannerElement = portrait.bannerHolder:CreateTexture(nil, "ARTWORK", nil, 0)
            portrait.bannerElement:SetPoint("TOPLEFT", portrait.bannerHolder, "TOPLEFT", 7, -10)
            portrait.bannerElement:SetSize(25, 25)

            portrait.banner = portrait.bannerHolder:CreateTexture(nil, "ARTWORK", nil, -1)
            portrait.banner:SetAllPoints()
        end

        -- Update the textures.
        if faction then
            portrait.bannerElement:SetTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\pvp-banner-" .. faction .. ".tga")
            portrait.bannerElement:SetTexCoord(102 / 256, 162 / 256, 22 / 128, 82 / 128)
            portrait.bannerElement:Show()

            portrait.banner:SetTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\pvp-banner-" .. faction .. ".tga")
            portrait.banner:SetTexCoord(1 / 256, 101 / 256, 1 / 128, 109 / 128)
        else
            portrait.bannerElement:SetTexture(nil)
            portrait.banner:SetTexture(nil)
        end

        return portrait.bannerElement, portrait.banner
    end

    -- Create the CastBar
    local castBar = CreateFrame("StatusBar", nil, buttonFrame, "BackdropTemplate")
    castBar:SetSize(215, 20)
    castBar:SetPoint("BOTTOM", buttonFrame, "TOP", 0, 25)
    castBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    castBar:SetStatusBarColor(0.4, 0.4, 0.9, 1)
    castBar:Hide()

    -- Border frame, slightly larger than the castBar
    local borderFrame = CreateFrame("Frame", nil, castBar, "BackdropTemplate")
    borderFrame:SetSize(castBar:GetWidth() + 8, castBar:GetHeight() + 8) -- Adjust these values for your preferred border thickness
    borderFrame:SetPoint("CENTER", castBar, "CENTER")
    borderFrame:SetBackdrop({
        edgeFile = "Interface\\AddOns\\RasPort\\Media\\UnitFrames\\border-thick.tga",
        edgeSize = 8,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        } -- Adjust these values to push the border closer
    })
    local r, g, b = core:ColorTexture(borderFrame)
    borderFrame:SetBackdropBorderColor(r, g, b, 1)

    local inset = 2
    castBar.bg = castBar:CreateTexture(nil, "BACKGROUND")
    castBar.bg:SetPoint("CENTER", castBar)
    castBar.bg:SetSize(castBar:GetWidth(), castBar:GetHeight())
    castBar.bg:SetColorTexture(0.1, 0.1, 0.1, 1)

    castBar.spellName = castBar:CreateFontString(nil, "OVERLAY")
    castBar.spellName:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    castBar.spellName:SetPoint("LEFT", castBar, "LEFT", 5, 0)

    local shakeAnimGroup = castBar:CreateAnimationGroup()
    local shake1 = shakeAnimGroup:CreateAnimation("Translation")
    local shake2 = shakeAnimGroup:CreateAnimation("Translation")
    local shake3 = shakeAnimGroup:CreateAnimation("Translation")

    shake1:SetDuration(0.1)
    shake1:SetOrder(1)
    shake1:SetSmoothing("OUT")
    shake1:SetOffset(-5, 0)

    shake2:SetDuration(0.1)
    shake2:SetOrder(2)
    shake2:SetSmoothing("IN")
    shake2:SetOffset(5, 0)

    shake3:SetDuration(0.1)
    shake3:SetOrder(3)
    shake3:SetSmoothing("OUT")
    shake3:SetOffset(-5, 0)

    -- Stop the shake animation when it's finished
    shakeAnimGroup:SetScript("OnFinished", function()
        shakeAnimGroup:Stop()
    end)

    local wasInterrupted = false

    local function UpdateCastBar(unit)
        local name, _, _, _, endTimeMS, _, _, notInterruptible, _ = UnitCastingInfo(unit)

        if name then
            castBar.spellName:SetText(name)
            castBar:SetMinMaxValues(0, (endTimeMS - GetTime() * 1000) / 1000)
            castBar:SetValue(0)
            castBar:Show()

            if notInterruptible then
                castBar:SetStatusBarColor(0.7, 0.7, 0, 1) -- Default color
            else
                castBar:SetStatusBarColor(0.6, 0.2, 0.9, 1) -- Purple
            end
        else
            castBar:Hide()
        end
    end

    castBar:SetScript("OnUpdate", function(self, elapsed)
        local currentVal = self:GetValue()
        local min, max = self:GetMinMaxValues()
        if not wasInterrupted and currentVal < max then
            self:SetValue(currentVal + elapsed)
        elseif wasInterrupted then
            -- Keep the castBar visible during the shake animation
        else
            self:Hide()
        end
    end)

    local function RegisterEvents(frame, events, unit)
        for _, event in ipairs(events) do
            if unit then
                frame:RegisterUnitEvent(event, unit)
            else
                frame:RegisterEvent(event)
            end
        end
    end

    local generalEvents = {"UNIT_AURA", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "PLAYER_TARGET_CHANGED",
                           "PLAYER_UPDATE_RESTING"}

    local unitEvents = {"UNIT_HEALTH_FREQUENT", "UNIT_HEAL_PREDICTION", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER",
                        "UNIT_MAXHEALTH", "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED"}

    local eventHandlers = {
        PLAYER_TARGET_CHANGED = function(unit)
            if UnitExists(unit) then
                core:UpdateHeaderPosition(header, unit, buttonFrame)
                core:SetupUnitPortrait(buttonFrame, "target", buttonFrame:GetHeight() - 10, "RIGHT", -8, 0)
                core:ColorHealthBar(healthBar, unit)
                core:UpdateHealth(healthBar, healthText, unit)
                core:UpdateMana(manaBar, manaText, unit)
                core:UpdateAurasForCombatState(buttonFrame, unit, "buffs")
                LevelText:SetText(UnitLevel(unit))
                SetBannerOnPortrait(portrait)
                core:UpdateClassIcon(classIcon, unit, 16)
                
                if core.db.profile.unitframes["Hide Level"] then
                    LevelBox:Hide()
                end
                

                mainFrame:SetAlpha(1)
                wasInterrupted = false
                UpdateCastBar(unit)
            else
                mainFrame:SetAlpha(0)
            end
        end,
        UNIT_AURA = function(unit)
            if InCombatLockdown() then
                core:UpdateAurasForCombatState(buttonFrame, unit, "debuffs")
            else
                core:UpdateAurasForCombatState(buttonFrame, unit, "buffs")
            end
        end,
        PLAYER_REGEN_DISABLED = function(unit)
            core:UpdateAurasForCombatState(buttonFrame, unit, "debuffs")
        end,
        PLAYER_REGEN_ENABLED = function(unit)
            core:UpdateAurasForCombatState(buttonFrame, unit, "buffs")
            core:UpdateHealth(healthBar, healthText, unit)
            core:UpdateMana(manaBar, manaText, unit)
        end,
        UNIT_SPELLCAST_START = function(unit)
            wasInterrupted = false
            UpdateCastBar(unit)
        end,
        UNIT_SPELLCAST_STOP = function(unit)
            if not wasInterrupted then
                castBar:Hide()
            end
        end,
        UNIT_SPELLCAST_INTERRUPTED = function(unit)
            wasInterrupted = true
            shakeAnimGroup:Play()
            castBar:SetStatusBarColor(1, 0, 0)
            castBar.spellName:SetText("INTERRUPTED")

            C_Timer.After(shakeAnimGroup:GetDuration(), function()
                castBar:Hide()
            end)
        end
    }

    for _, event in ipairs(unitEvents) do
        if event:find("HEALTH") then
            eventHandlers[event] = function(unit)
                core:UpdateHealth(healthBar, healthText, unit)
            end
        elseif event:find("POWER") then
            eventHandlers[event] = function(unit)
                core:UpdateMana(manaBar, manaText, unit)
            end
        end
    end

    RegisterEvents(mainFrame, generalEvents)
    RegisterEvents(mainFrame, unitEvents, unit)

    mainFrame:SetScript("OnEvent", function(self, event, ...)
        local handler = eventHandlers[event]
        if handler then
            handler(unit)
        end
    end)

    mainFrame:SetAlpha(0)
end)
