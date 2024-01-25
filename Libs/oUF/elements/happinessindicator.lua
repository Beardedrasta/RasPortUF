--[[
# Element: HappinessIndicator

Handles the visibility and updating of player pet happiness.

## Widget

.texture - A `Texture` used to display the pet's happiness icon.

HappinessIndicator - A `Frame` used to display the pet's happiness icon.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local HappinessIndicator = CreateFrame('Frame', nil, self)
	HappinessIndicator:SetSize(18, 18)
	HappinessIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.HappinessIndicator = HappinessIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(not unit or self.unit ~= unit) then return end

	local element = self.HappinessIndicator

	--[[ Callback: HappinessIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the HappinessIndicator element
	--]]
	if (element.PreUpdate) then
		element:PreUpdate()
	end

	local _, isHunterPet = HasPetUI()
	local happiness, damagePercentage, loyaltyRate = GetPetHappiness()

	if (isHunterPet and happiness) then
		if (happiness == 1) then
			element.texture:SetTexCoord(0.375, 0.5625, 0, 0.359375)
		elseif (happiness == 2) then
			element.texture:SetTexCoord(0.1875, 0.375, 0, 0.359375)
		elseif (happiness == 3) then
			element.texture:SetTexCoord(0, 0.1875, 0, 0.359375)
		end

		element.tooltip = _G['PET_HAPPINESS' .. happiness]
		element.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage)

		if (loyaltyRate < 0) then
			element.tooltipLoyalty = _G['LOSING_LOYALTY']
		elseif (loyaltyRate > 0) then
			element.tooltipLoyalty = _G['GAINING_LOYALTY']
		else
			element.tooltipLoyalty = nil
		end

		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: HappinessIndicator:PostUpdate(happiness)
	Called after the element has been updated.

	* self 				- the HappinessIndicator element
	* happiness        	- the numerical happiness value of the pet (1 = unhappy, 2 = content, 3 = happy) (number)
	* damagePercentage 	- damage modifier, happiness affects this (unhappy = 75%, content = 100%, happy = 125%) (number)
	--]]
	if (element.PostUpdate) then
		return element:PostUpdate(unit, happiness, damagePercentage)
	end
end

local function Path(self, ...)
	--[[ Override: HappinessIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.HappinessIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.HappinessIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_HAPPINESS', Path, true)
		self:RegisterEvent('PET_UI_UPDATE', Path, true)

		if (not element.texture) then
			element.texture = element:CreateTexture(nil, 'OVERLAY')
			element.texture:SetAllPoints(element)
		end

		if (element.texture:IsObjectType('Texture') and not element.texture:GetTexture()) then
			element.texture:SetTexture([[Interface\PetPaperDollFrame\UI-PetHappiness]])
		end

		element:SetScript('OnEnter', function()
			if (element.tooltip) then
				GameTooltip:SetOwner(element, 'ANCHOR_RIGHT', 0, 5)
				GameTooltip:SetText(element.tooltip)

				if (element.tooltipDamage) then
					GameTooltip:AddLine(element.tooltipDamage)
				end
				if (element.tooltipLoyalty) then
					GameTooltip:AddLine(element.tooltipLoyalty)
				end

				GameTooltip:Show()
			end
		end)

		element:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)

		return true
	end
end

local function Disable(self)
	local element = self.HappinessIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_HAPPINESS', Path)
		self:UnregisterEvent('PET_UI_UPDATE', Path)
	end
end

oUF:AddElement('happinessindicator', Path, Enable, Disable)