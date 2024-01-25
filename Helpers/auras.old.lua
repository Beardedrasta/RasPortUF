local _, core = ...
local MAX_BUFFS = 30
local MAX_PER_ROW = 6
local GAP = 3

function core:CreateIcons(container, anchor, unit)
    local ICON_SIZE = core.db.profile.unitframes["Buff Size"] or 25
    for i = 1, MAX_BUFFS do
        local icon = CreateFrame("Frame", nil, anchor)
        icon:SetSize(ICON_SIZE, ICON_SIZE)
        icon:SetFrameLevel(icon:GetFrameLevel() + 1)

        local row = math.floor((i - 1) / MAX_PER_ROW)
        local col = (i - 1) % MAX_PER_ROW

        if unit == "target" or unit == "targettarget" then
            icon:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 5 + col * (ICON_SIZE + GAP), -5 - row * (ICON_SIZE + GAP))
        else
            icon:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", -5 - col * (ICON_SIZE + GAP), -5 - row * (ICON_SIZE + GAP))
        end
        icon.texture = icon:CreateTexture(nil)
        icon.texture:SetAllPoints(icon)
        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown:SetAllPoints(icon)
        icon.cooldown:SetFrameLevel(icon:GetFrameLevel() + 1)
        icon.stack = icon:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
        icon.stack:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
        icon.stack:SetDrawLayer("OVERLAY", 7)
        icon.stack:SetParent(icon.cooldown)

        container[i] = icon
    end
end

function core:UpdateAuras(unit, isBuff, frame)
    local index = 1
    local auraFunction = isBuff and UnitBuff or UnitDebuff

    for i = 1, MAX_BUFFS do
        local name, icon, count, debuffType, duration, expirationTime, caster = auraFunction(unit, i)
        local container = isBuff and frame.buffs or frame.debuffs

        if name then
            if not  isBuff and core.db.profile.unitframes["Player Debuffs"] and caster ~= "player" then
                container[i]:Hide()
            else
                local auraIcon = container[index]
                auraIcon.texture:SetTexture(icon)

                local point, relativeTo, relativePoint, xOffset, yOffset = auraIcon:GetPoint()

                auraIcon.stack:SetText(count > 1 and count or "")

                if duration and duration > 0 then
                    auraIcon.cooldown:SetCooldown(expirationTime - duration, duration)
                else
                    auraIcon.cooldown:Hide()
                end

                auraIcon:Show()
                index = index + 1
            end
        end
    end

    local container = isBuff and frame.buffs or frame.debuffs
    for i = index, MAX_BUFFS do
        container[i]:Hide()
    end
end
