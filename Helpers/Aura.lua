local _, RP = ...

-- Lua APIs
local _G = getfenv(0)
local unpack = _G.unpack
local huge = _G.math.huge
local ceil = _G.math.ceil
local tsort = _G.table.sort

-- WoW APIs
local CreateFrame = _G.CreateFrame
local CancelUnitBuff = _G.CancelUnitBuff
local GetTime = _G.GetTime
local GetSpellLink = _G.GetSpellLink
local GetSpellTexture = _G.GetSpellTexture
local MouseIsOver = _G.MouseIsOver
local UnitIsUnit = _G.UnitIsUnit
local UnitIsFriend = _G.UnitIsFriend
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsCharmed = _G.UnitIsCharmed
local UnitIsPossessed = _G.UnitIsPossessed
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitPlayerControlled = _G.UnitPlayerControlled
local ChatEdit_InsertLink = _G.ChatEdit_InsertLink
local InCombatLockdown = _G.InCombatLockdown
local IsModifierKeyDown = _G.IsModifierKeyDown
local PlaySound = _G.PlaySound
local PlaySoundFile = _G.PlaySoundFile
local C_Timer_After = _G.C_Timer.After

-- oUF_Nihlathak
local DB = RP.RasPortUF
local N, oUF = RP.N, RP.oUF
local UF = N.UnitFrame
local FormatTime = RP.FormatTime
local DispelList = RP.DispelList

-- Register Libs
local LSM = LibStub('LibSharedMedia-3.0')

local Auras = {}

-- mouseover zoom in auras
local function HighlightAura(button)
    local Highlight = CreateFrame('Frame', nil, button)
    Highlight:SetPoint('CENTER')
    Highlight:SetFrameLevel(button:GetFrameLevel() + 1)
    Highlight:Hide()

    local icon = Highlight:CreateTexture(nil, 'ARTWORK')
    icon:SetAllPoints()
    icon:SetTexCoord(.08, .92, .08, .92)
    Highlight.Icon = icon

    local overlay = Highlight:CreateTexture(nil, 'OVERLAY')
    overlay:SetPoint('CENTER')
    Highlight.Overlay = overlay

    local glyphIcon = Highlight:CreateTexture(nil, 'OVERLAY')
    glyphIcon:SetPoint('TOPRIGHT', 5, 1)
    glyphIcon:SetSize(16, 16)
    glyphIcon:SetTexture([[Interface\spellbook\glyphiconspellbook]])
    glyphIcon:SetBlendMode('ADD')
    Highlight.glyphIcon = glyphIcon

    button.Highlight = Highlight
end

-- hook function
local function UpdateHighlight(button)
    local Highlight = button.Highlight
    local AuraZoom = button.config.AuraZoom
    local buttonWidth, buttonHeight = button:GetSize()
    local overlayWidth, overlayHeight = button.Overlay:GetSize()

    Highlight:SetSize(buttonWidth * AuraZoom, buttonHeight * AuraZoom)
    Highlight.Icon:SetTexture(button.Icon:GetTexture())
    Highlight.Overlay:SetTexture(button.Overlay:GetTexture())
    Highlight.Overlay:SetSize(overlayWidth * AuraZoom, overlayHeight * AuraZoom)
    Highlight.Overlay:SetVertexColor(button.Overlay:GetVertexColor())
end

local function OnEnterAura(button)
    if (not button or not button:IsShown()) then return end

    button:UpdateHighlight()
    button.Highlight:Show()
end

local function OnLeaveAura(button)
    button.Highlight:Hide()
end

local function OnMouseUpAura(button, mouseButton)
    if (not button or not button:IsShown()) then return end

    local frame = button:GetParent().__owner
    local link = GetSpellLink(button.spellID)
    local icon = GetSpellTexture(button.spellID)

    if (IsModifierKeyDown()) then
        RP:AddAura(button.spellID)
        --RP:Print('|T' .. icon .. ':0|t', link, "L.CustomAurasAdded")
        --PlaySoundFile(C.Addaura)
        -- refresh
        RP:UpdateAuras()
        RP:UpdateCustomAuras()
        UpdateHighlight(button)
    elseif (mouseButton == 'LeftButton') then
        ChatEdit_InsertLink(GetSpellLink(button.spellID))
        PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
    elseif (mouseButton == 'RightButton') then
        if (not InCombatLockdown()) then
            CancelUnitBuff(frame.unit, button:GetID(), button.filter)
        end
        button.Highlight:Hide()
        PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
    end

    C_Timer_After(0.25, function() if MouseIsOver(button) then OnEnterAura(button) end end)
end

-- aura timer
local function CreateAuraTimer(button, elapsed)
    button.elapsed = button.timeLeft + elapsed

    if (button.elapsed > 0.05) then
        button.timeLeft = button.timeLeft - elapsed

        if (button.timeLeft > 0) then
            -- button animation
            if (button.isPlayer and button.timeLeft < button.config.AnimThreshold) then
                RP:StartFlashAnim(button)
                RP:StartTransAnim(button)
            else
                RP:StopFlashAnim(button)
                RP:StopTransAnim(button)
            end
            -- update time text
            if (button.timeLeft < button.config.TimeThreshold) then
                button.timeText:SetFormattedText(FormatTime(button.timeLeft))
                -- set text color
                if (button.timeLeft < 5) then
                    button.timeText:SetTextColor(1, .3, .3)
                elseif (button.timeLeft < 10) then
                    button.timeText:SetTextColor(1, 1, 0)
                else
                    button.timeText:SetTextColor(1, 1, 1, 1)
                end
            else
                button.timeText:SetText('')
                button:SetScript('OnUpdate', nil)
            end
        else
            RP:StopFlashAnim(button)
            RP:StopTransAnim(button)
            button.timeText:SetText('')
            button:SetScript('OnUpdate', nil)
        end

        button.elapsed = 0
    end
end

function Auras:PostCreateButton(button)
    local config = DB.db.profile.auras
    button.config = config
    button.Cooldown.noCooldownCount = true -- hide OmniCC's CooldownCount

    button.Icon:SetTexCoord(.08, .92, .08, .92)

    button.Overlay:SetTexture(C.Auratex)
    button.Overlay:SetPoint('TOPLEFT', -config.OverlayofsX, config.OverlayofsY)
    button.Overlay:SetPoint('BOTTOMRIGHT', config.OverlayofsX, -config.OverlayofsY)
    button.Overlay:SetTexCoord(0, 1, 0, 1)
    button.Overlay.Hide = function() button.Overlay:SetVertexColor(1, 1, 1, 1) end

    button.timeText:SetFont(LSM:Fetch('font', config.TimeFont), config.TimeSize, config.TimeFlag)
    button.timeText:SetPoint(config.TimeAnchor, config.TimeofsX, config.TimeofsY)
    button.timeText:SetJustifyH('LEFT')
    button.timeText:SetTextColor(1, 1, 1, 1)

    button.countText:SetFont(LSM:Fetch('font', config.TimeFont), config.TimeSize, config.TimeFlag)
    button.countText:SetPoint('BOTTOMRIGHT', 2, -1)
    button.countText:SetTextColor(1, 1, 1, 1)

    button.arrowTex:SetPoint('BOTTOMLEFT', -6, -4)
    button.arrowTex:SetSize(20, 16)
    button.arrowTex:SetTexture(config.Garrow)
    button.arrowTex:SetAlpha(0)

    button.UpdateHighlight = UpdateHighlight
    button:HookScript('OnEnter', OnEnterAura)
    button:HookScript('OnLeave', OnLeaveAura)
    button:HookScript('OnMouseUp', OnMouseUpAura)

    HighlightAura(button)

    RP:CreateFlashAnimation(button)
    RP:CreateTransAnimation(button)
end

function Auras:PostUpdateButton(unit, button, _, _, duration, expiration, dispelType, isStealable)
    -- aura classification
    button.isFriend = UnitIsFriend('player', unit)
    button.isCharmed = UnitIsPlayer(unit) and UnitIsCharmed(unit) or UnitIsPossessed(unit)
    button.isEnemyBuff = not button.isFriend and not button.isCharmed and not button.isDebuff
    button.isNpcBuff = not button.isDebuff and not UnitIsPlayer(unit) and not UnitPlayerControlled(unit)
    button.canDispel = button.isFriend and not button.isCharmed and button.isDebuff and DispelList[dispelType]
    button.canPurge = button.isEnemyBuff and not button.isCharmed and (dispelType == 'Magic') or isStealable
    -- aura timer
    if (duration and duration > 0) and (button.isPlayer or button.isFriend or button.isEnemyBuff) then
        button.timeLeft = expiration - GetTime()
        button:SetScript('OnUpdate', CreateAuraTimer)
    else
        button.timeLeft = huge
    end
    -- aura type
    if (button.isDebuff) then
        if (button.isPlayer or button.isFriend) then
            local color = oUF.colors.debuff[dispelType or 'none']
            button.Icon:SetDesaturated(false)
            button.Overlay:SetVertexColor(color.r, color.g, color.b, 0.8)
        else
            button.Icon:SetDesaturated(true)
        end
        if (button.canDispel) then
            N:StartGlow(button, 'Pixel', C.CountColor, 4, nil, 8, nil, 1, 1, false)
        else
            N:StopGlow(button, 'Pixel')
        end
    else
        if (button.isPlayer or button.isNpcBuff) then
            button.Icon:SetDesaturated(false)
        else
            button.Icon:SetDesaturated(true)
        end
        if (button.canPurge) then
            button.Icon:SetDesaturated(false)
            N:StartGlow(button, 'AutoCast', C.TimeColor, nil, .25, nil, 1, 1)
        else
            N:StopGlow(button, 'AutoCast')
        end
    end
end

function Auras:CustomFilter(unit, button, _, _, _, _, duration, expiration, caster, _, _, spellID, _, isBossDebuff)
    local isDeadOrGhost = UnitIsDeadOrGhost(unit)
    local noDuration = duration == 0 and expiration == 0 --and C.db.Auras.noDuration
    local maxDuration = button.isDebuff or duration == 0 or duration >= 0 --C.db.Auras.maxDuration or C.db.Auras.maxDuration == 0
    local casterIsUnit = unit and caster and UnitIsUnit(unit, caster)
    local isFriendDebuff = button.isDebuff and UnitIsFriend('player', unit) and not UnitIsCharmed(unit)
    local isRelevant =  button.canDispel or button.canPurge or isBossDebuff or isFriendDebuff
    local isIrrelevant = not button.isPlayer and not casterIsUnit
    local shouldBeShown = isDeadOrGhost or (not noDuration and maxDuration) and (isRelevant or not isIrrelevant) and (not RP:GetAura(spellID))

    if (shouldBeShown) then
        return true
    end
end

local function SortAuras(a, b)
    if (a:IsShown() and b:IsShown()) then
        if (a.isPlayer ~= b.isPlayer) then
            return a.isPlayer
        end
        if (a.canDispel ~= b.canDispel) then
            return a.canDispel
        end
        if (a.canPurge ~= b.canPurge) then
            return a.canPurge
        end

        return a.timeLeft < b.timeLeft
    else
        return a:IsShown()
    end
end

function Auras:PreSetPosition()
    if (#self.active > 1) then
        tsort(self.active, SortAuras)
    end

    return 1, self.visibleBuffs or self.visibleDebuffs
end

function Auras:UpdateCDs()
    local config = DB.db.profile.auras
    if config.hideCDs then
        self.enableCooldown = true
    else
        self.enableCooldown = false
        for i = 1, self.createdButtons do
            self[i].Cooldown:Clear()
        end
    end
end

function Auras:UpdateSize()
    local config = DB.db.profile.auras
    local unit = self.__owner.unit

    if (unit == 'player' or unit == 'target') then
        self.size = config.AuraSize
    else
        self.size = config.AuraSizeFP
    end

    self.spacing = config.AuraSpacing
    self:SetSize((self.size + self.spacing) * self.perrow, self.size + self.spacing)
end

function Auras:UpdateFont()
    local config = DB.db.profile.auras
    for i = 1, self.createdButtons do
        self[i].timeText:ClearAllPoints()
        self[i].timeText:SetPoint(config.TimeAnchor, config.TimeofsX, config.TimeofsY)
        self[i].timeText:SetFont(LSM:Fetch('font', config.TimeFont), config.TimeSize, config.TimeFlag)
        self[i].countText:SetFont(LSM:Fetch('font', config.TimeFont), config.TimeSize, config.TimeFlag)
    end
end

function Auras:UpdateOverlay()
    local config = DB.db.profile.auras
    for i = 1, self.createdButtons do
        self[i].Overlay:SetPoint('TOPLEFT', -config.OverlayofsX, config.OverlayofsY)
        self[i].Overlay:SetPoint('BOTTOMRIGHT', config.OverlayofsX, -config.OverlayofsY)
    end
end

local updateFunc = {}

function updateFunc:UpdateAuras(auratype)
    local config = DB.db.profile.auras
    local element = self[auratype]
    element:UpdateCDs()
    element:UpdateSize()
    element:UpdateFont()
    element:UpdateOverlay()
    element.forceShow = config.forceShowAuras

    if self:IsElementEnabled('Auras') then
        element:ForceUpdate()
    end
end

function updateFunc:UpdateAllAuras()
    if self.Buffs then
        self:UpdateAuras('Buffs')
    end
    if self.Debuffs then
        self:UpdateAuras('Debuffs')
    end
end

local function AdjustDebuffsAnchor(self)
    local buffs = self.__owner.Buffs
    local debuffs = self.__owner.Debuffs
    local visibleBuffs = self.visibleBuffs
    local buffsRow = ceil(visibleBuffs / buffs.perrow)

    if (visibleBuffs == 0) then
        debuffs:SetPoint(buffs:GetPoint())
    else
        debuffs:SetPoint('BOTTOMLEFT', buffs, 0, buffsRow * (buffs.size + buffs.spacing))
    end
end

local function AdjustAurabarsAnchor(self)
    local auras = self.__owner.Auras
    local debuffs = self.__owner.Debuffs
    local visibleDebuffs = self.visibleDebuffs
    local debuffsRow = ceil(visibleDebuffs / debuffs.perrow)

    if (auras) then
        auras:SetPoint('BOTTOMLEFT', debuffs, 'TOPLEFT', 0, debuffsRow * (debuffs.size + debuffs.spacing))
    end
end

-- create unit auras
function UF:CreateAuras(frame, auratype)
    RP:Mixin(frame, updateFunc)

    local UnitAuras = RP:Mixin(CreateFrame('Frame', nil, frame), Auras)

    if (frame.unit == 'target' or frame.unit == 'focus') and (auratype == 'Buffs') then
        UnitAuras.PostUpdate = AdjustDebuffsAnchor
    elseif (frame.unit == 'target' or frame.unit == 'focus') and (auratype == 'Debuffs') then
        UnitAuras.PostUpdate = AdjustAurabarsAnchor
    end

    frame[auratype] = UnitAuras
end