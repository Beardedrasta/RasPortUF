--[[
# Element: Runes

Handles the visibility and updating of Death Knight's runes.

## Widget

Runes - An `table` holding `StatusBar`s.

## Sub-Widgets

.bg - A `Texture` used as a background. It will inherit the color of the main StatusBar.

## Notes

A default texture will be applied if the sub-widgets are StatusBars and don't have a texture set.

## Sub-Widgets Options

.multiplier - Used to tint the background based on the main widgets R, G and B values. Defaults to 1 (number)[0-1]

## Examples

    local Runes = {}
    for index = 1, 6 do
        -- Position and size of the rune bar indicators
        local Rune = CreateFrame('StatusBar', nil, self)
        Rune:SetSize(120 / 6, 20)
        Rune:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * 120 / 6, 0)

        Runes[index] = Rune
    end

    -- Register with oUF
    self.Runes = Runes
--]]

if(select(2, UnitClass('player')) ~= 'DEATHKNIGHT') then return end

local _, ns = ...
local oUF = ns.oUF

-- Lua APIs
local _G = getfenv(0)
local ipairs = _G.ipairs

-- WoW APIs
local GetTime = _G.GetTime
local GetRuneType = _G.GetRuneType
local GetRuneCooldown = _G.GetRuneCooldown
local UnitHasVehicleUI = _G.UnitHasVehicleUI

local runemap = {1, 2, 5, 6, 3, 4}

local function onUpdate(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)

	if self.PostUpdateColor then
		self:PostUpdateColor()
	end
end

local function UpdateRuneType(rune, runeID, alt)
	rune.runeType = GetRuneType(runeID) or alt

	return rune
end

local function ColorRune(self, bar, runeType)
	local color = runeType and self.colors.runes[runeType] or self.colors.power.RUNES
	local r, g, b = color[1], color[2], color[3]
	bar:SetStatusBarColor(r, g, b)

	local bg = bar.bg
	if bg then
		local mu = bg.multiplier or 1
		bg:SetVertexColor(r * mu, g * mu, b * mu)
	end

	return color, r, g, b
end

local function UpdateColor(self, event, runeID, alt)
	local element = self.Runes

	local rune, specType
	if runeID and event == 'RUNE_TYPE_UPDATE' then
		rune = UpdateRuneType(element[runemap[runeID]], runeID, alt)
	end

	local color, r, g, b
	if rune then
		color, r, g, b = ColorRune(self, rune, specType or rune.runeType)
	else
		for i = 1, #element do
			local bar = element[i]
			if not bar.runeType then
				bar.runeType = GetRuneType(runemap[i])
			end

			color, r, g, b = ColorRune(self, bar, specType or bar.runeType)
		end
	end

	--[[ Callback: Runes:PostUpdateColor(r, g, b)
	Called after the element color has been updated.

	* self - the Runes element
	* r    - the red component of the used color (number)[0-1]
	* g    - the green component of the used color (number)[0-1]
	* b    - the blue component of the used color (number)[0-1]
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(r, g, b, color)
	end
end

local function ColorPath(self, ...)
	--[[ Override: Runes.UpdateColor(self, event, ...)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.Runes.UpdateColor or UpdateColor) (self, ...)
end

local function Update(self, event)
	local element = self.Runes

	local allReady = true
	local currentTime = GetTime()
	local hasVehicle = UnitHasVehicleUI('player')
	for index, runeID in ipairs(runemap) do
		local rune = element[index]
		if not rune then break end

		if hasVehicle then
			rune:Hide()

			allReady = false
		else
			local start, duration, runeReady = GetRuneCooldown(runeID)
			if runeReady then
				rune:SetMinMaxValues(0, 1)
				rune:SetValue(1)
				rune:SetScript('OnUpdate', nil)
			elseif start then
				rune.duration = currentTime - start
				rune:SetMinMaxValues(0, duration)
				rune:SetValue(0)
				rune:SetScript('OnUpdate', onUpdate)
			end

			if not runeReady then
				allReady = false
			end

			rune:Show()
		end
	end

	--[[ Callback: Runes:PostUpdate(runemap)
	Called after the element has been updated.

	* self    - the Runes element
	* runemap - the ordered list of runes' indices (table)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(runemap, hasVehicle, allReady)
	end
end

local function Path(self, ...)
	--[[ Override: Runes.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.Runes.Override or Update) (self, ...)
end

local function AllPath(...)
	Path(...)
	ColorPath(...)
end

local function ForceUpdate(element)
	Path(element.__owner, 'ForceUpdate')
	ColorPath(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.Runes
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for i = 1, #element do
			local rune = element[i]
			if(rune:IsObjectType('StatusBar') and not rune:GetStatusBarTexture()) then
				rune:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		self:RegisterEvent('RUNE_TYPE_UPDATE', ColorPath, true)
		self:RegisterEvent('RUNE_POWER_UPDATE', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.Runes
	if(element) then
		for i = 1, #element do
			element[i]:Hide()
		end

		self:UnregisterEvent('RUNE_TYPE_UPDATE', ColorPath)
		self:UnregisterEvent('RUNE_POWER_UPDATE', Path)
	end
end

oUF:AddElement('Runes', AllPath, Enable, Disable)