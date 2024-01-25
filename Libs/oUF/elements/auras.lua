--[[
# Element: Auras

Handles creation and updating of aura icons.

## Widget

Auras   - A Frame to hold `Button`s representing both buffs and debuffs.
Buffs   - A Frame to hold `Button`s representing buffs.
Debuffs - A Frame to hold `Button`s representing debuffs.

## Notes

At least one of the above widgets must be present for the element to work.

## Options

.disableMouse       - Disables mouse events (boolean)
.enableCooldown     - Enable the cooldown spiral (boolean)
.size               - Aura icon size. Defaults to 16 (number)
.width              - Aura icon width. Takes priority over `size` (number)
.height             - Aura icon height. Takes priority over `size` (number)
.onlyShowPlayer     - Shows only auras created by player/vehicle (boolean)
.showStealableBuffs - Displays the stealable icon on buffs that can be stolen (boolean)
.spacing            - Spacing between each icon. Defaults to 0 (number)
.['spacing-x']      - Horizontal spacing between each icon. Takes priority over `spacing` (number)
.['spacing-y']      - Vertical spacing between each icon. Takes priority over `spacing` (number)
.['growth-x']       - Horizontal growth direction. Defaults to 'RIGHT' (string)
.['growth-y']       - Vertical growth direction. Defaults to 'UP' (string)
.initialAnchor      - Anchor point for the icons. Defaults to 'BOTTOMLEFT' (string)
.filter             - Custom filter list for auras to display. Defaults to 'HELPFUL' for buffs and 'HARMFUL' for
                      debuffs (string)
.tooltipAnchor      - Anchor point for the tooltip. Defaults to 'ANCHOR_TOPLEFT', however, if a frame has anchoring
                      restrictions it will be set to 'ANCHOR_CURSOR' (string)

## Options Auras

.numBuffs     - The maximum number of buffs to display. Defaults to 32 (number)
.numDebuffs   - The maximum number of debuffs to display. Defaults to 40 (number)
.numTotal     - The maximum number of auras to display. Prioritizes buffs over debuffs. Defaults to the sum of
                .numBuffs and .numDebuffs (number)
.gap          - Controls the creation of an invisible icon between buffs and debuffs. Defaults to false (boolean)
.buffFilter   - Custom filter list for buffs to display. Takes priority over `filter` (string)
.debuffFilter - Custom filter list for debuffs to display. Takes priority over `filter` (string)

## Options Buffs

.num - Number of buffs to display. Defaults to 32 (number)

## Options Debuffs

.num - Number of debuffs to display. Defaults to 40 (number)

## Attributes

button.caster   - the unit who cast the aura (string)
button.filter   - the filter list used to determine the visibility of the aura (string)
button.isDebuff - indicates if the button holds a debuff (boolean)
button.isPlayer - indicates if the aura caster is the player or their vehicle (boolean)

## Examples

    -- Position and size
    local Buffs = CreateFrame('Frame', nil, self)
    Buffs:SetPoint('RIGHT', self, 'LEFT')
    Buffs:SetSize(16 * 2, 16 * 16)

    -- Register with oUF
    self.Buffs = Buffs
--]] local _, RP = ...
local oUF = RP.oUF
local DB = RP.RasPortUF

local VISIBLE = 1
local CREATED = 2
local HIDDEN = 0

-- Lua APIs
local _G = getfenv(0)
local wipe = _G.wipe
local pcall = _G.pcall
local random = _G.random
local tinsert = _G.tinsert
local min = _G.math.min
local floor = _G.math.floor

-- WoW APIs
local CreateFrame = _G.CreateFrame
local UnitAura = _G.UnitAura
local UnitIsUnit = _G.UnitIsUnit
local GetTime = _G.GetTime
local GetSpellInfo = _G.GetSpellInfo
local GameTooltip = _G.GameTooltip
local PlaySound = _G.PlaySound
local PlaySoundFile = _G.PlaySoundFile
local C_Timer_After = _G.C_Timer.After
local InCombatLockdown = _G.InCombatLockdown
local GetSpellLink = _G.GetSpellLink
local GetSpellTexture = _G.GetSpellTexture
local MouseIsOver = _G.MouseIsOver
local CancelUnitBuff = _G.CancelUnitBuff
local GetTime = _G.GetTime

-- forceShow mod list of spell and type
local forceShow_Spells = {17, 642, 774, 1784, 2825, 5384, 32182, 45438, 46924, 47241, 49576, 54861}
local forceShow_deType = {'none', 'Magic', 'Curse', 'Poison', 'Disease'}

local function SetColorByProfile(self)
    local c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
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

local function UpdateTooltip(self)
    if (GameTooltip:IsForbidden()) then
        return
    end

    GameTooltip:SetUnitAura(self:GetParent().__owner.unit, self:GetID(), self.filter)
end

local function onEnter(self)
    if (GameTooltip:IsForbidden() or not self:IsVisible()) then
        return
    end

    -- Avoid parenting GameTooltip to frames with anchoring restrictions,
    -- otherwise it'll inherit said restrictions which will cause issues with
    -- its further positioning, clamping, etc
    GameTooltip:SetOwner(self, self:GetParent().__restricted and 'ANCHOR_CURSOR' or self:GetParent().tooltipAnchor)
    self:UpdateTooltip()
end

local function onLeave()
    if (GameTooltip:IsForbidden()) then
        return
    end

    GameTooltip:Hide()
end

local ceil = _G.math.ceil
local huge = _G.math.huge
local format = _G.string.format

-- format time
local function FormatTime(sec)
    if (sec == huge) then
        sec = 0
    end

    if (sec >= 86400) then
        return format('%dd', ceil(sec / 86400))
    elseif (sec >= 3600) then
        return format('%dh', ceil(sec / 3600))
    elseif (sec >= 60) then
        return format('%dm', ceil(sec / 60))
    elseif (sec >= 5) then
        return ceil(sec)
    else
        return format('%.1f', sec)
    end
end

-- aura timer
local function CreateAuraTimer(self, elapsed)
    if self.timeLeft then
        self.timeLeft = self.timeLeft - elapsed
        if self.timeLeft <= 0 then
            self:SetScript('OnUpdate', nil)
        else
            if self.timeLeft < 5 then
                RP:StartFlashAnim(self)
                RP:StartTransAnim(self)
            else
                RP:StopFlashAnim(self)
                RP:StopTransAnim(self)
            end
        end
    end
end

local function createAuraIcon(element, index)
    local button = CreateFrame('Button', element:GetDebugName() .. 'Button' .. index, element)

    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetBackdrop({
        edgeFile = "Interface\\AddOns\\RasPortUF\\Media\\border-thick.tga",
        tileEdge = true,
        edgeSize = 12
    })
    border:SetFrameLevel(button:GetFrameLevel() + 1)
    border:SetPoint('TOPLEFT', button, -6, 6)
    border:SetPoint('BOTTOMRIGHT', button, 6, -6)

    -- the way Blizz position it creates really weird gaps, so fix it
    local r, g, b = SetColorByProfile(border)
    border:SetBackdropBorderColor(r, g, b, 1)

    local cd = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
    cd:SetAllPoints()
    button.Cooldown = cd

    local icon = button:CreateTexture(nil, 'BORDER')
    icon:SetAllPoints()
    icon:SetTexCoord(.08, .92, .08, .92)
    button.icon = icon

    local overlay = button:CreateTexture(nil, 'OVERLAY')
    overlay:SetTexture([[Interface\AddOns\RasPortUF\Media\Button\\Auratex]])
    overlay:SetPoint('TOPLEFT', button, -7, 7)
    overlay:SetPoint('BOTTOMRIGHT', button, 7, -7)
    overlay:SetTexCoord(0, 1, 0, 1)
    button.overlay = overlay

    local stealable = button:CreateTexture(nil, 'OVERLAY')
    stealable:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
    stealable:SetPoint('TOPLEFT', -3, 3)
    stealable:SetPoint('BOTTOMRIGHT', 3, -3)
    stealable:SetBlendMode('ADD')
    button.stealable = stealable

    local holder = CreateFrame('Frame', nil, button)
    holder:SetAllPoints()
    holder:SetFrameLevel(button:GetFrameLevel() + 1)

    local timeText = holder:CreateFontString(nil, 'OVERLAY')
    timeText:SetFont('Interface\\AddOns\\RasPortUF\\Media\\Button\\EuroStyle Normal.ttf', 12, "OUTLINE")
    timeText:SetPoint("CENTER", 0, 0)
    timeText:SetJustifyH('LEFT')
    timeText:SetTextColor(1, 1, 1)
    button.timeText = timeText

    local countText = holder:CreateFontString(nil, 'OVERLAY')
    countText:SetFont('Interface\\AddOns\\RasPortUF\\Media\\Button\\EuroStyle Normal.ttf', 12, "OUTLINE")
    button.countText = countText

    local arrowTex = holder:CreateTexture(nil, 'OVERLAY')
    button.arrowTex = arrowTex

    local Highlight = CreateFrame("Frame", nil, button)
    Highlight:SetPoint("CENTER")
    Highlight:SetFrameLevel(button:GetFrameLevel() + 1)
    Highlight:Hide()
    button.Highlight = Highlight

    local iconHighlight = Highlight:CreateTexture(nil, 'ARTWORK')
    iconHighlight:SetAllPoints()
    iconHighlight:SetTexCoord(.08, .92, .08, .92)
    Highlight.Icon = iconHighlight

    local hlOverlay = Highlight:CreateTexture(nil, 'OVERLAY')
    hlOverlay:SetPoint('TOPLEFT', -7, 7)
    hlOverlay:SetPoint('BOTTOMRIGHT', 7, -7)
    hlOverlay:SetTexture([[Interface\AddOns\RasPortUF\Media\Button\Auratex.tga]])
    hlOverlay:SetTexCoord(0, 1, 0, 1)
    hlOverlay:SetBlendMode('ADD')
    Highlight.Overlay = hlOverlay

    local glyphIcon = Highlight:CreateTexture(nil, 'OVERLAY')
    glyphIcon:SetPoint('TOPRIGHT', 2, -1)
    glyphIcon:SetSize(16, 16)
    glyphIcon:SetTexture([[Interface\spellbook\glyphiconspellbook]])
    glyphIcon:SetBlendMode('ADD')
    Highlight.glyphIcon = glyphIcon

    button.UpdateTooltip = UpdateTooltip
    button:SetScript('OnEnter', onEnter)
    button:SetScript('OnLeave', onLeave)

    RP:CreateFlashAnimation(button)
    RP:CreateTransAnimation(button)

    --[[ Callback: Auras:PostCreateIcon(button)
	Called after a new aura button has been created.

	* self   - the widget holding the aura buttons
	* button - the newly created aura button (Button)
	--]]
    if (element.PostCreateIcon) then
        element:PostCreateIcon(button)
    end

    return button
end

local function UpdateHighlight(button)
    local Highlight = button.Highlight
    local AuraZoom = 1.2
    local buttonWidth, buttonHeight = button:GetSize()
    local overlayWidth, overlayHeight = button.overlay:GetSize()

    Highlight:SetSize(buttonWidth * AuraZoom, buttonHeight * AuraZoom)
    Highlight.Icon:SetTexture(button.icon:GetTexture())
end

local function OnEnterAura(button)
    if (not button or not button:IsShown()) then
        return
    end

    button:UpdateHighlight(button)
    button.Highlight:Show()
end

local function OnLeaveAura(button)
    button.Highlight:Hide()
end

local function OnMouseUpAura(button, mouseButton)
    if (not button or not button:IsShown()) then
        return
    end

    local frame = button:GetParent().__owner
    local link = GetSpellLink(button.spellID)
    local icon = GetSpellTexture(button.spellID)

    if (mouseButton == 'LeftButton') then
        ChatEdit_InsertLink(GetSpellLink(button.spellID))
        PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
    elseif (mouseButton == 'RightButton') then
        if (not InCombatLockdown()) then
            CancelUnitBuff(frame.unit, button:GetID(), button.filter)
        end
        button.Highlight:Hide()
        PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
    end

    C_Timer.After(0.25, function()
        if MouseIsOver(button) then
            OnEnterAura(button)
        end
    end)
end

local function customFilter(element, unit, button, name)
    if ((element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name)) then
        return true
    end
end

local function updateIcon(element, unit, index, offset, filter, isDebuff, visible)
    local name, icon, count, dispelType, duration, expiration, caster, isStealable, nameplateShowPersonal, spellID,
        canApply, isBossDebuff = UnitAura(unit, index, filter)

    if (element.forceShow) then
        spellID = forceShow_Spells[random(1, #forceShow_Spells)]
        name, _, icon = GetSpellInfo(spellID)
        count, dispelType, duration, expiration, caster = random(1, 10), forceShow_deType[random(1, #forceShow_deType)],
            18, GetTime() + 18, 'player'

    end

    if (not name) then
        return
    end

    local position = visible + offset + 1
    local button = element[position]
    if (not button) then
        --[[ Override: Auras:CreateIcon(position)
		Used to create the aura button at a given position.

		* self     - the widget holding the aura buttons
		* position - the position at which the aura button is to be created (number)

		## Returns

		* button - the button used to represent the aura (Button)
		--]]
        button = (element.CreateIcon or createAuraIcon)(element, position)

        tinsert(element, button)
        element.createdIcons = element.createdIcons + 1
    end

    element.active[position] = button

    button.name = name
    button.count = count
    button.caster = caster
    button.filter = filter
    button.spellID = spellID
    button.isDebuff = isDebuff
    button.isPlayer = caster == 'player' or button.caster == 'pet' or caster == 'vehicle'

    --[[ Override: Auras:CustomFilter(unit, button, ...)
	Defines a custom filter that controls if the aura button should be shown.

	* self   - the widget holding the aura buttons
	* unit   - the unit on which the aura is cast (string)
	* button - the button displaying the aura (Button)
	* ...    - the return values from [UnitAura](http://wowprogramming.com/docs/api/UnitAura.html)

	## Returns

	* show - indicates whether the aura button should be shown (boolean)
	--]]

    local show = element.forceShow
    if (not element.forceShow) then
        show = (element.CustomFilter or customFilter)(element, unit, button, name, icon, count, dispelType, duration,
            expiration, caster, isStealable, nameplateShowPersonal, spellID, canApply, isBossDebuff)
    end

    if (show) then
        -- We might want to consider delaying the creation of an actual cooldown
        -- object to this point, but I think that will just make things needlessly
        -- complicated.
        if (button.Cooldown and element.enableCooldown) then
            if (duration and duration > 0) then
                button.Cooldown:SetCooldown(expiration - duration, duration)
                button.Cooldown:Show()
                button.timeLeft = expiration - GetTime()
                button:SetScript('OnUpdate', CreateAuraTimer)
            else
                button.Cooldown:Hide()
                button:SetScript('OnUpdate', nil)
            end
        end

        if (button.Highlight and element.enableHighlight) then
            button.UpdateHighlight = UpdateHighlight
            button:HookScript('OnEnter', OnEnterAura)
            button:HookScript('OnLeave', OnLeaveAura)
            button:HookScript('OnMouseUp', OnMouseUpAura)
        end

        if (button.overlay) then
            if ((isDebuff and element.showDebuffType) or (not isDebuff and element.showBuffType) or element.showType) then
                local color = element.__owner.colors.debuff[dispelType] or element.__owner.colors.debuff.none

                button.overlay:SetVertexColor(color[1], color[2], color[3])
                button.overlay:Show()
            else
                button.overlay:Hide()
            end
        end

        if (button.stealable) then
            if (not isDebuff and isStealable and element.showStealableBuffs and not UnitIsUnit('player', unit)) then
                button.stealable:Show()
            else
                button.stealable:Hide()
            end
        end

        if (button.icon) then
            button.icon:SetTexture(icon)
        end
        if (button.count) then
            button.countText:SetText(count > 1 and count or '')
        end

        local size = element.size or 16
        button:SetSize(size, size)

        button:EnableMouse(not element.disableMouse)
        button:SetID(index)
        button:Show()

        --[[ Callback: Auras:PostUpdateIcon(unit, button, index, position)
		Called after the aura button has been updated.

		* self        - the widget holding the aura buttons
		* unit        - the unit on which the aura is cast (string)
		* button      - the updated aura button (Button)
		* index       - the index of the aura (number)
		* position    - the actual position of the aura button (number)
		* duration    - the aura duration in seconds (number?)
		* expiration  - the point in time when the aura will expire. Comparable to GetTime() (number)
		* dispelType  - the debuff type of the aura (string?)['Curse', 'Disease', 'Magic', 'Poison']
		* isStealable - whether the aura can be stolen or purged (boolean)
		--]]
        if (element.PostUpdateIcon) then
            element:PostUpdateIcon(unit, button, index, position, duration, expiration, dispelType, isStealable)
        end

        return VISIBLE
    elseif (element.forceShow) then
        local size = element.size or 16
        button:SetSize(size, size)
        button:Hide()

        if (element.PostUpdateIcon) then
            element:PostUpdateIcon(unit, button, index, position, duration, expiration, dispelType, isStealable)
        end

        return CREATED
    else
        return HIDDEN
    end
end

local function SetPosition(element, from, to)
    local width = element.width or element.size or 16
    local height = element.height or element.size or 16
    local sizex = width + (element['spacing-x'] or element.spacing or 0)
    local sizey = height + (element['spacing-y'] or element.spacing or 0)
    local anchor = element.initialAnchor or 'BOTTOMLEFT'
    local growthx = (element['growth-x'] == 'LEFT' and -1) or 1
    local growthy = (element['growth-y'] == 'DOWN' and -1) or 1
    local cols = floor(element:GetWidth() / sizex + 0.5)

    for i = from, to do
        local button = element.active[i]
        if (not button) then
            break
        end

        local col = (i - 1) % cols
        local row = floor((i - 1) / cols)

        button:ClearAllPoints()
        button:SetPoint(anchor, element, anchor, col * sizex * growthx, row * sizey * growthy)
    end
end

local function filterIcons(element, unit, filter, limit, isDebuff, offset, dontHide)
    if (not offset) then
        offset = 0
    end
    local index = 1
    local visible = 0
    local hidden = 0
    local created = 0

    while (visible < limit) do
        local result = updateIcon(element, unit, index, offset, filter, isDebuff, visible)
        if (not result) then
            break
        elseif (result == VISIBLE) then
            visible = visible + 1
        elseif (result == HIDDEN) then
            hidden = hidden + 1
        elseif (result == CREATED) then
            visible = visible + 1
            created = created + 1
        end

        index = index + 1
    end

    visible = visible - created

    if (not dontHide) then
        for i = visible + offset + 1, #element do
            element[i]:Hide()
        end
    end

    return visible, hidden
end

local function UpdateAuras(self, event, unit)
    if (self.unit ~= unit) then
        return
    end

    local auras = self.Auras
    if (auras) then
        --[[ Callback: Auras:PreUpdate(unit)
		Called before the element has been updated.

		* self - the widget holding the aura buttons
		* unit - the unit for which the update has been triggered (string)
		--]]
        if (auras.PreUpdate) then
            auras:PreUpdate(unit)
        end

        wipe(auras.active)

        local numBuffs = auras.numBuffs or 32
        local numDebuffs = auras.numDebuffs or 40
        local max = auras.numTotal or numBuffs + numDebuffs

        local visibleBuffs = filterIcons(auras, unit, auras.buffFilter or auras.filter or 'HELPFUL', min(numBuffs, max),
            nil, 0, true)

        local hasGap
        if (visibleBuffs ~= 0 and auras.gap) then
            hasGap = true
            visibleBuffs = visibleBuffs + 1

            local button = auras[visibleBuffs]
            if (not button) then
                button = (auras.CreateIcon or createAuraIcon)(auras, visibleBuffs)
                tinsert(auras, button)
                auras.createdIcons = auras.createdIcons + 1
            end

            -- Prevent the button from displaying anything.
            if (button.Cooldown) then
                button.Cooldown:Hide()
            end
            if (button.icon) then
                button.icon:SetTexture()
            end
            if (button.overlay) then
                button.overlay:Hide()
            end
            if (button.stealable) then
                button.stealable:Hide()
            end
            if (button.count) then
                button.countText:SetText()
            end

            button:EnableMouse(false)
            button:Show()

            --[[ Callback: Auras:PostUpdateGapIcon(unit, gapButton, visibleBuffs)
			Called after an invisible aura button has been created. Only used by Auras when the `gap` option is enabled.

			* self         - the widget holding the aura buttons
			* unit         - the unit that has the invisible aura button (string)
			* gapButton    - the invisible aura button (Button)
			* visibleBuffs - the number of currently visible aura buttons (number)
			--]]
            if (auras.PostUpdateGapIcon) then
                auras:PostUpdateGapIcon(unit, button, visibleBuffs)
            end
        end

        local visibleDebuffs = filterIcons(auras, unit, auras.debuffFilter or auras.filter or 'HARMFUL',
            min(numDebuffs, max - visibleBuffs), true, visibleBuffs)
        auras.visibleDebuffs = visibleDebuffs

        if (hasGap and visibleDebuffs == 0) then
            auras[visibleBuffs]:Hide()
            visibleBuffs = visibleBuffs - 1
        end

        auras.visibleBuffs = visibleBuffs
        auras.visibleAuras = auras.visibleBuffs + auras.visibleDebuffs

        local fromRange, toRange
        --[[ Callback: Auras:PreSetPosition(max)
		Called before the aura buttons have been (re-)anchored.

		* self - the widget holding the aura buttons
		* max  - the maximum possible number of aura buttons (number)

		## Returns

		* from - the offset of the first aura button to be (re-)anchored (number)
		* to   - the offset of the last aura button to be (re-)anchored (number)
		--]]
        if (auras.PreSetPosition) then
            fromRange, toRange = auras:PreSetPosition(max)
        end

        if (fromRange or auras.createdIcons > auras.anchoredIcons) then
            --[[ Override: Auras:SetPosition(from, to)
			Used to (re-)anchor the aura buttons.
			Called when new aura buttons have been created or if :PreSetPosition is defined.

			* self - the widget that holds the aura buttons
			* from - the offset of the first aura button to be (re-)anchored (number)
			* to   - the offset of the last aura button to be (re-)anchored (number)
			--]]
            (auras.SetPosition or SetPosition)(auras, fromRange or auras.anchoredIcons + 1,
                toRange or auras.createdIcons)
            auras.anchoredIcons = auras.createdIcons
        end

        --[[ Callback: Auras:PostUpdate(unit)
		Called after the element has been updated.

		* self - the widget holding the aura buttons
		* unit - the unit for which the update has been triggered (string)
		--]]
        if (auras.PostUpdate) then
            auras:PostUpdate(unit)
        end
    end

    local buffs = self.Buffs
    if (buffs) then
        if (buffs.PreUpdate) then
            buffs:PreUpdate(unit)
        end

        wipe(buffs.active)

        local numBuffs = buffs.num or 32
        local visibleBuffs = filterIcons(buffs, unit, buffs.filter or 'HELPFUL', numBuffs)
        buffs.visibleBuffs = visibleBuffs

        local fromRange, toRange
        if (buffs.PreSetPosition) then
            fromRange, toRange = buffs:PreSetPosition(numBuffs)
        end

        if (fromRange or buffs.createdIcons > buffs.anchoredIcons) then
            (buffs.SetPosition or SetPosition)(buffs, fromRange or buffs.anchoredIcons + 1,
                toRange or buffs.createdIcons)
            buffs.anchoredIcons = buffs.createdIcons
        end

        if (buffs.PostUpdate) then
            buffs:PostUpdate(unit)
        end
    end

    local debuffs = self.Debuffs
    if (debuffs) then
        if (debuffs.PreUpdate) then
            debuffs:PreUpdate(unit)
        end

        wipe(debuffs.active)

        local numDebuffs = debuffs.num or 40
        local visibleDebuffs = filterIcons(debuffs, unit, debuffs.filter or 'HARMFUL', numDebuffs, true)
        debuffs.visibleDebuffs = visibleDebuffs

        local fromRange, toRange
        if (debuffs.PreSetPosition) then
            fromRange, toRange = debuffs:PreSetPosition(numDebuffs)
        end

        if (fromRange or debuffs.createdIcons > debuffs.anchoredIcons) then
            (debuffs.SetPosition or SetPosition)(debuffs, fromRange or debuffs.anchoredIcons + 1,
                toRange or debuffs.createdIcons)
            debuffs.anchoredIcons = debuffs.createdIcons
        end

        if (debuffs.PostUpdate) then
            debuffs:PostUpdate(unit)
        end
    end
end

local function Update(self, event, unit)
    if (self.unit ~= unit) then
        return
    end

    UpdateAuras(self, event, unit)

    -- Assume no event means someone wants to re-anchor things. This is usually
    -- done by UpdateAllElements and :ForceUpdate.
    if (event == 'ForceUpdate' or not event) then
        local auras = self.Auras
        if (auras) then
            (auras.SetPosition or SetPosition)(auras, 1, auras.createdIcons)
        end

        local buffs = self.Buffs
        if (buffs) then
            (buffs.SetPosition or SetPosition)(buffs, 1, buffs.createdIcons)
        end

        local debuffs = self.Debuffs
        if (debuffs) then
            (debuffs.SetPosition or SetPosition)(debuffs, 1, debuffs.createdIcons)
        end
    end
end

local function ForceUpdate(element)
    return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
    if (self.Auras or self.Buffs or self.Debuffs) then
        self:RegisterEvent('UNIT_AURA', UpdateAuras)

        local auras = self.Auras
        if (auras) then
            auras.__owner = self
            -- check if there's any anchoring restrictions
            auras.__restricted = not pcall(self.GetCenter, self)
            auras.ForceUpdate = ForceUpdate
            auras.active = {}

            auras.createdIcons = auras.createdIcons or 0
            auras.anchoredIcons = 0
            auras.tooltipAnchor = auras.tooltipAnchor or 'ANCHOR_TOPLEFT'

            auras:Show()
        end

        local buffs = self.Buffs
        if (buffs) then
            buffs.__owner = self
            -- check if there's any anchoring restrictions
            buffs.__restricted = not pcall(self.GetCenter, self)
            buffs.ForceUpdate = ForceUpdate
            buffs.active = {}

            buffs.createdIcons = buffs.createdIcons or 0
            buffs.anchoredIcons = 0
            buffs.tooltipAnchor = buffs.tooltipAnchor or 'ANCHOR_TOPLEFT'

            buffs:Show()
        end

        local debuffs = self.Debuffs
        if (debuffs) then
            debuffs.__owner = self
            -- check if there's any anchoring restrictions
            debuffs.__restricted = not pcall(self.GetCenter, self)
            debuffs.ForceUpdate = ForceUpdate
            debuffs.active = {}

            debuffs.createdIcons = debuffs.createdIcons or 0
            debuffs.anchoredIcons = 0
            debuffs.tooltipAnchor = debuffs.tooltipAnchor or 'ANCHOR_TOPLEFT'

            debuffs:Show()
        end

        return true
    end
end

local function Disable(self)
    if (self.Auras or self.Buffs or self.Debuffs) then
        self:UnregisterEvent('UNIT_AURA', UpdateAuras)

        if (self.Auras) then
            self.Auras:Hide()
        end
        if (self.Buffs) then
            self.Buffs:Hide()
        end
        if (self.Debuffs) then
            self.Debuffs:Hide()
        end
    end
end

oUF:AddElement('Auras', Update, Enable, Disable)
