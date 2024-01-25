local _, core = ...
local mainFrame, header, healthBar, healthText, manaBar, manaText, portrait, inlayParent, inlay

core:AddModule("targetOftarget", "custom target of target frame", function(L)
    if not core.db.profile.disabled["Unitframes"] or core.ElvUI then
        return
    end
    local unit = "targettarget"
    core:CreateSmallFrameAndComponents(unit, 170, 15, core.frameComponents["target"].mainFrame)

    local myFrameComponents = core.frameComponents[unit]
    if myFrameComponents then
        mainFrame = myFrameComponents.mainFrame
        header = myFrameComponents.header
        healthBar = myFrameComponents.healthBar
        healthText = myFrameComponents.healthText
        manaBar = myFrameComponents.manaBar
        manaText = myFrameComponents.manaText
        portrait = myFrameComponents.portrait
        inlayParent = myFrameComponents.inlayParent
        inlay = myFrameComponents.inlay
    end
    mainFrame:Hide()
    manaText:Hide()

    local function RegisterEvents(frame, events, unit)
        for _, event in ipairs(events) do
            if unit then
                frame:RegisterUnitEvent(event, unit)
            else
                frame:RegisterEvent(event)
            end
        end
    end

    local classIcon = inlayParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classIcon:SetDrawLayer("OVERLAY", 7)
    classIcon:SetPoint("TOPRIGHT", mainFrame, 0, -1)
    classIcon:Show()

    local generalEvents = {"PLAYER_LOGIN", "PLAYER_TARGET_CHANGED"}

    local unitEvents = {"UNIT_HEALTH_FREQUENT", "UNIT_HEAL_PREDICTION", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER",
                        "UNIT_MAXHEALTH"}

    local eventHandlers = {
        PLAYER_TARGET_CHANGED = function(unit)
            if UnitExists(unit) then
                header:SetText(UnitName(unit))
                core:ColorHealthBar(healthBar, unit)
                core:UpdateHealth(healthBar, healthText, unit)
                core:UpdateMana(manaBar, manaText, unit)
                mainFrame:Show()
                core:UpdateClassIcon(classIcon, unit, 14)
            else
                mainFrame:Hide()
            end
        end,
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
end)
