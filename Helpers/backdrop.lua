local _, RP = ...
local DB = RP.RasPortUF
local c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

local function SetColorByProfile(self)
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

function RP:CreateBackdrop(parent, edgeSize, topx, topy, bottomx, bottomy, btopx, btopy, bbottomx, bbottomy)
    local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    border:SetBackdrop({
        edgeFile = "Interface\\AddOns\\RasPort\\Media\\UnitFrames\\border-thick.tga",
        tileEdge = true,
        edgeSize = edgeSize or 6,
        insets = {
            left = 6,
            right = 6,
            top = 6,
            bottom = 6
        }
    })
    border:SetFrameLevel(parent:GetFrameLevel() + 1)

    border:SetPoint("TOPLEFT", parent, topx or -3, topy or 3)
    border:SetPoint("BOTTOMRIGHT", parent, bottomx or 3, bottomy or -3)
    local r, g, b = SetColorByProfile(border)
    border:SetBackdropBorderColor(r, g, b, 1)

    local backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    backdrop:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = true,
        tileSize = 8,
        insets = {
            left = 6,
            right = 6,
            top = 6,
            bottom = 6
        }
    })
    backdrop:SetFrameLevel(parent:GetFrameLevel() - 1)
    backdrop:SetFrameStrata("BACKGROUND")
    backdrop:SetBackdropColor(0.1, 0.1, 0.1, 1)

    backdrop:SetPoint("TOPLEFT", border, btopx or -3, btopy or 3)
    backdrop:SetPoint("BOTTOMRIGHT", border, bbottomx or 3, bbottomy or -3)

    return border, backdrop
end
