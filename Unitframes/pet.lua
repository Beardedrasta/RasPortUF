local _, core = ...
local mainFrame, header, healthBar, healthText, manaBar, manaText, portrait, inlayParent, inlay

core:AddModule("pet", "custom pet frame", function(L)
    if not core.db.profile.disabled["Unitframes"] or core.ElvUI then
        return
    end
    local unit = "pet"
    core:CreateSmallFrameAndComponents(unit, -200, 0, core.frameComponents["player"].mainFrame)

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

    local function RegisterEvents(frame, events, unit)
        for _, event in ipairs(events) do
            if unit then
                frame:RegisterUnitEvent(event, unit)
            else
                frame:RegisterEvent(event)
            end
        end
    end

    local generalEvents = {"PLAYER_LOGIN"}

    local unitEvents = {"UNIT_HEALTH_FREQUENT", "UNIT_HEAL_PREDICTION", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER",
                        "UNIT_MAXHEALTH"}

    local eventHandlers = {
        PLAYER_LOGIN = function(unit)
            if UnitExists(unit) then
                core:UpdateHeaderPosition(header, unit, mainFrame)
                core:ColorHealthBar(healthBar, unit)
                core:UpdateHealth(healthBar, healthText, unit)
                core:UpdateMana(manaBar, manaText, unit)
                mainFrame:Show()
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
