-- Element: Class Icon
-- Shows the class icon for the unit's class.

-- Widget
-- ClassIcon - Any UI widget that can display a texture.

-- Examples
-- Position and size
--[[ local ClassIcon = self:CreateTexture(nil, 'OVERLAY')
ClassIcon:SetSize(16, 16)
ClassIcon:SetPoint('CENTER', self, 'TOP', 0, -10) ]]

-- Register it with oUF
--[[ self.ClassIcon = ClassIcon ]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
    if self.unit ~= unit then return end
    local element = self.ClassIcon

    -- PreUpdate
    if(element.PreUpdate) then
        element:PreUpdate()
    end

    local _, class = UnitClass(unit)
    if class then
        local iconPath = "Interface\\AddOns\\RasPortUF\\Media\\ClassIcons\\" .. class
        element:SetTexture(iconPath)
        element:Show()
    else
        element:Hide()
    end

    -- PostUpdate
    if(element.PostUpdate) then
        return element:PostUpdate(class)
    end
end

local function Path(self, ...)
    return (self.ClassIcon.Override or Update) (self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
    local element = self.ClassIcon
    if(element) then
        element.__owner = self
        element.ForceUpdate = ForceUpdate

        self:RegisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
        self:RegisterEvent('PLAYER_TARGET_CHANGED', Path, true)

        return true
    end
end

local function Disable(self)
    local element = self.ClassIcon
    if(element) then
        element:Hide()

        self:UnregisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
        self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
    end
end

oUF:AddElement('ClassIcon', Path, Enable, Disable)