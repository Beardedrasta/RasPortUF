local _, RP = ...

local raceMap = {
    ["Night Elf"] = "NightElf",
    ["Human"] = "Human",
    ["Orc"] = "Orc",
    ["Dwarf"] = "Dwarf",
    ["Gnome"] = "Gnome",
    ["Draenei"] = "Draenei",
    ["Undead"] = "Undead",
    ["Tauren"] = "Tauren",
    ["Troll"] = "Troll",
    ["Blood Elf"] = "BloodElf"
}

local genderMap = {
    [2] = "Male",
    [3] = "Female"
}

-- Use the mapped race name if it exists, otherwise use the file name
local mappedRace = raceMap[race] or fileName

function RP:SetupUnitPortrait(frame, unit, size, point, offsetX, offsetY)
    -- name the portrait based on the unit
    local portraitName = unit .. "Portrait"

    -- Ensure global portraits table
    _G["Portraits"] = _G["Portraits"] or {}

    if not _G["Portraits"][portraitName] then
        local portrait = CreateFrame("Frame", nil, frame)
        portrait:SetSize(size, size)
        portrait:SetPoint(point, frame, point, offsetX, offsetY)
        portrait.texture = portrait:CreateTexture(nil)
        portrait.texture:SetAllPoints(portrait)
        portrait.texture:SetDrawLayer("BACKGROUND", 7)

        portrait.bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        portrait.bg:SetPoint("CENTER", portrait, "CENTER", 0, 0)
        portrait.bg:SetSize(size + 15, size + 15)
        portrait.bg:SetFrameLevel(1)

        _G["Portraits"][portraitName] = portrait
    end

    local portrait = _G["Portraits"][portraitName]

    if UnitExists(unit) then
        local race, fileName = UnitRace(unit)
        local gender = genderMap[UnitSex(unit)]
        local mappedRace = raceMap[race] or fileName

        -- Ensure that the mapped race is not nil
        if mappedRace then
            local texturePath = "Interface\\AddOns\\RasPort\\Media\\UnitFrames\\" .. mappedRace .. gender .. ".tga"

            -- Check if the file exists, if not use the default Blizzard portrait
            if GetFileIDFromPath(texturePath) then
                portrait.texture:SetTexture(texturePath)
            else
                SetPortraitTexture(portrait.texture, unit)
            end
        else
            SetPortraitTexture(portrait.texture, unit)
        end
    else
        -- Use the default Blizzard function to set a 2D portrait for the unit
        SetPortraitTexture(portrait.texture, unit)
    end
end

