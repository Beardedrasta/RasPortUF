--[[
# Element: Resting Indicator

Toggles the visibility of an indicator based on the player's resting status.

## Widget

RestingIndicator - Any UI widget.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local RestingIndicator = self:CreateTexture(nil, 'OVERLAY')
    RestingIndicator:SetSize(16, 16)
    RestingIndicator:SetPoint('TOPLEFT', self)

    -- Register it with oUF
    self.RestingIndicator = RestingIndicator
--]] local _, ns = ...
local oUF = ns.oUF

local function CreateAnimations(texture)
    -- Create the fade-in animation
    local fadeInAnimGroup = texture:CreateAnimationGroup()
    local fadeIn = fadeInAnimGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(1.5)
    fadeIn:SetOrder(1)
    fadeIn:SetSmoothing("OUT")

    -- Create the fade-out animation
    local fadeOutAnimGroup = texture:CreateAnimationGroup()
    local fadeOut = fadeOutAnimGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(1.5)
    fadeOut:SetOrder(2)
    fadeOut:SetSmoothing("OUT")

    return fadeInAnimGroup, fadeOutAnimGroup
end

local function StartSequence(element)
    element.z1FadeIn:Play()
end

local function Update(self, event)
    local element = self.RestingIndicator

    if not element.z1 then
        element.z1 = self.RestingIndicator:CreateTexture(nil, 'OVERLAY')
        element.z1:SetTexture([[Interface\AddOns\RasPortUF\Media\Portrait\sleepindicator]])
        element.z1:SetPoint("LEFT")
        element.z1:SetSize(7, 7)

        element.z2 = self.RestingIndicator:CreateTexture(nil, 'OVERLAY')
        element.z2:SetTexture([[Interface\AddOns\RasPortUF\Media\Portrait\sleepindicator]])
        element.z2:SetPoint("LEFT", element.z1, -4, 6)
        element.z2:SetSize(10, 10)

        element.z3 = self.RestingIndicator:CreateTexture(nil, 'OVERLAY')
        element.z3:SetTexture([[Interface\AddOns\RasPortUF\Media\Portrait\sleepindicator]])
        element.z3:SetPoint("LEFT", element.z2, -8, 2)
        element.z3:SetSize(13, 13)

        -- Set texture paths and positions here for element.z1, element.z2, element.z3
    end

    -- Create animations for each 'Z' texture if they don't exist
    if not element.z1FadeIn then
        element.z1FadeIn, element.z1FadeOut = CreateAnimations(element.z1)
        element.z2FadeIn, element.z2FadeOut = CreateAnimations(element.z2)
        element.z3FadeIn, element.z3FadeOut = CreateAnimations(element.z3)

        -- Synchronize the fade-out animations to start after the fade-ins
        element.z1FadeIn:SetScript("OnFinished", function()
            element.z1FadeOut:Play()
            element.z2FadeOut:Play()
            element.z3FadeOut:Play()
        end)

        -- Restart the sequence after fade-outs complete
        element.z3FadeOut:SetScript("OnFinished", function()
                element.z1:SetAlpha(0)
                element.z2:SetAlpha(0)
                element.z3:SetAlpha(0)
                element.z1FadeIn:Play()
                element.z2FadeIn:Play()
                element.z3FadeIn:Play()
        end)
    end

    --[[ 	local animGroup = element:CreateAnimationGroup()

	local pulse = animGroup:CreateAnimation("Alpha")
    pulse:SetFromAlpha(0.5)
    pulse:SetToAlpha(1.0)
    pulse:SetDuration(0.5)
    pulse:SetOrder(1)
    pulse:SetSmoothing("IN_OUT")

    animGroup:SetLooping("BOUNCE") ]]

    local function StartFlashingIndicator()
        element.z1FadeIn:Play()
        element.z2FadeIn:Play()
        element.z3FadeIn:Play()
    end

    local function StopFlashingIndicator()
        element.z1FadeIn:Stop()
        element.z2FadeIn:Stop()
        element.z3FadeIn:Stop()
    end

    --[[ Callback: RestingIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the RestingIndicator element
	--]]
    if (element.PreUpdate) then
        element:PreUpdate()
    end

    local isResting = IsResting()
    if (isResting) then
        element:Show()
        StartFlashingIndicator()
    else
        element:Hide()
        StopFlashingIndicator()
    end

    --[[ Callback: RestingIndicator:PostUpdate(isResting)
	Called after the element has been updated.

	* self      - the RestingIndicator element
	* isResting - indicates if the player is resting (boolean)
	--]]
    if (element.PostUpdate) then
        return element:PostUpdate(isResting)
    end
end

local function Path(self, ...)
    --[[ Override: RestingIndicator.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
    return (self.RestingIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
    local element = self.RestingIndicator
    if (element and UnitIsUnit(unit, 'player')) then
        element.__owner = self
        element.ForceUpdate = ForceUpdate

        self:RegisterEvent('PLAYER_UPDATE_RESTING', Path, true)

        if (element:IsObjectType('Texture') and not element:GetTexture()) then
            element:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
            element:SetTexCoord(0, 0.5, 0, 0.421875)
        end

        return true
    end
end

local function Disable(self)
    local element = self.RestingIndicator
    if (element) then
        element:Hide()

        self:UnregisterEvent('PLAYER_UPDATE_RESTING', Path)
    end
end

oUF:AddElement('RestingIndicator', Path, Enable, Disable)
