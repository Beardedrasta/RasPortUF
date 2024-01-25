local _, core = ...
local mainFrame, buttonFrame, header, healthBar, healthText, manaBar, manaText, portrait, LevelBox, LevelText,
    inlayParent, inlay

core:AddModule("focus", "custom focus frame", function(L)
    if not core.db.profile.disabled["Unitframes"] or core.ElvUI then
        return
    end
    local unit = "focus"
    core:CreateMainFrameAndComponents(unit, -900, 250)

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

    mainFrame:Hide()

    local function RegisterEvents(frame, events, unit)
        for _, event in ipairs(events) do
            if unit then
                frame:RegisterUnitEvent(event, unit)
            else
                frame:RegisterEvent(event)
            end
        end
    end

    local generalEvents = {"UNIT_AURA", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "PLAYER_FOCUS_CHANGED"}

    local unitEvents = {"UNIT_HEALTH_FREQUENT", "UNIT_HEAL_PREDICTION", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER",
                        "UNIT_MAXHEALTH"}

    local eventHandlers = {
        PLAYER_FOCUS_CHANGED = function(unit)
            if UnitExists(unit) then
                core:UpdateHeaderPosition(header, unit, buttonFrame)
                core:SetupUnitPortrait(buttonFrame, "focus", buttonFrame:GetHeight() - 10, "RIGHT", -8, 0)
                core:ColorHealthBar(healthBar, unit)
                core:UpdateHealth(healthBar, healthText, unit)
                core:UpdateMana(manaBar, manaText, unit)
                core:UpdateAurasForCombatState(buttonFrame, unit, "buffs")
                LevelText:SetText(UnitLevel(unit))
                if core.db.profile.unitframes["Hide Level"] then
                    LevelBox:Hide()
                end
                mainFrame:Show()
            else
                mainFrame:Hide()
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
end)
