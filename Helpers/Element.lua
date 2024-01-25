local _, ns = ...

-- Lua APIs
local _G = getfenv(0)
local unpack = _G.unpack
local rad = _G.math.rad

-- WoW APIs
local CreateFrame = _G.CreateFrame
local UnitIsUnit = _G.UnitIsUnit

-- oUF_Nihlathak
local N, C = ns.N, ns.C
local UF = N.UnitFrame

-- mouseover highlight
function UF:CreateMovHlight(frame)
    local MovHlight = frame.Health:CreateTexture(nil, 'ARTWORK')
    MovHlight:SetPoint('TOPLEFT', frame.Health, -40, 4)
    MovHlight:SetPoint('TOPRIGHT', frame.Health, 40, 4)
    MovHlight:SetHeight(3)
    MovHlight:SetTexture(C.movH)
	MovHlight:SetBlendMode('ADD')
    MovHlight:SetVertexColor(1, 1, 1, 1)
    MovHlight:SetTexCoord(0, 1, 1, 0)
	MovHlight:Hide()

    frame.MovHlight = MovHlight
end

-- threat highlight
function UF:CreateThreatHlight(frame)
	local Thrt = frame.Health:CreateTexture(nil, 'OVERLAY')
	Thrt:SetPoint('TOPLEFT', frame.Health, -40, 4)
	Thrt:SetPoint('TOPRIGHT', frame.Health, 40, 4)
	Thrt:SetHeight(2)
	Thrt:SetTexture(C.thdH)
	Thrt:SetBlendMode('ADD')
	Thrt:Hide()

	frame.ThreatIndicator = Thrt
end

function UF:CreateThreatGlow(frame)
	local Thrt = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
	Thrt:SetPoint('TOPLEFT', frame.Health, -5, 5)
    Thrt:SetPoint('BOTTOMRIGHT', frame.Health, 5, -5)
	Thrt:SetBackdrop(C.frameBD)
	Thrt:SetFrameLevel(frame.Health:GetFrameLevel() + 1)
	Thrt:Hide()

	frame.ThreatIndicator = Thrt
end

-- debuff highlight
function UF:CreateDHlight(frame)
	local DHlight = frame.Health:CreateTexture(nil, 'OVERLAY')
	DHlight:SetPoint('BOTTOMLEFT', frame.Health, -40, -4)
	DHlight:SetPoint('BOTTOMRIGHT', frame.Health, 40, -4)
	DHlight:SetHeight(2)
	DHlight:SetTexture(C.thdH)
	DHlight:SetBlendMode('ADD')
	DHlight:Hide()

	frame.DebuffHighlight = DHlight
end

function UF:CreateRDHlight(frame)
	local RDHlight = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
	RDHlight:SetPoint('TOPLEFT', frame.Health, -4, 4)
    RDHlight:SetPoint('BOTTOMRIGHT', frame.Health, 4, -4)
	RDHlight:SetBackdrop(C.frameBD)
	RDHlight:SetFrameLevel(frame.Health:GetFrameLevel() + 2)
	RDHlight:Hide()

	frame.DebuffHighlightBorder = RDHlight
end

-- target highlight
local function UpdateTargetGlow(frame)
	if (not frame.unit) then return end

	if (UnitIsUnit('target', frame.unit)) then
		N:StartFlashAnim(frame.TargetGlow)
	else
		N:StopFlashAnim(frame.TargetGlow)
	end
end

function UF:CreateTargetGlow(frame)
	local TargetGlow = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
	TargetGlow:SetPoint('TOPLEFT', frame.Health, -4, 4)
    TargetGlow:SetPoint('BOTTOMRIGHT', frame.Health, 4, -4)
	TargetGlow:SetBackdrop(C.frameBD)
	TargetGlow:SetBackdropBorderColor(1, 0.9, 0)
	TargetGlow:SetFrameLevel(frame.Health:GetFrameLevel() + 3)
	TargetGlow:SetAlpha(0)

	N:CreateFlashAnimation(TargetGlow)

	frame.TargetGlow = TargetGlow

	frame:RegisterEvent('RAID_ROSTER_UPDATE', UpdateTargetGlow, true)
	frame:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateTargetGlow, true)
end

-- fader
local function UpdateFader(frame)
	local element = frame.Fader
	element.timeToFadeIn = C.db.Fader.timeToFadeIn
	element.timeToFadeOut = C.db.Fader.timeToFadeOut
	element.alphaToFadeOut = C.db.Fader.alphaToFadeOut

    if C.db.Fader.enable then
		if not frame:IsElementEnabled('Fader') then
        	frame:EnableElement('Fader')
		end
    else
		if frame:IsElementEnabled('Fader') then
        	frame:DisableElement('Fader')
		end
		N:FrameFadeIn(frame, 1.0, frame:GetAlpha(), 1.0)
    end

	if frame:IsElementEnabled('Fader') then
		element:ForceUpdate()
	end
end

function UF:CreateFader(frame)
	local Fader = {
		timeToFadeIn = C.db.Fader.timeToFadeIn,
		timeToFadeOut = C.db.Fader.timeToFadeOut,
		alphaToFadeOut = C.db.Fader.alphaToFadeOut,
	}

	frame.Fader = Fader
	frame.UpdateFader = UpdateFader
end

-- portrait
local function UpdatePortrait(frame)
    frame.Portrait:SetAlpha(C.db.pAlpha)
	frame.Portrait:ForceUpdate()
end

local function PostUpdatePortrait(element, unit)
	-- mimic ModelAlphaFix, so when the module updates the correct alpha is set
	local frame = element.__owner
	local alpha = C.db.pAlpha or 1
	element:SetModelAlpha(alpha * frame:GetAlpha())

	if (not element.state) then
		element:SetCamDistanceScale(0.75)
		element:SetPosition(0, 0, -0.125)
	else
		if (unit == 'target') or (unit == 'focus') then
			element:SetCamDistanceScale(3)
			element:MakeCurrentCameraCustom()
			element:SetCameraFacing(rad(25))
		elseif (unit == 'player') or (unit == 'pet') or (unit == 'party') then
			element:SetCamDistanceScale(3)
			element:MakeCurrentCameraCustom()
			element:SetCameraFacing(rad(-25))
		else
			element:SetCamDistanceScale(3.5)
			element:MakeCurrentCameraCustom()
			element:SetCameraFacing(rad(0))
		end
	end
end

-- fix model widgets bug thanks for ElvUI kodewdle
local function ModelAlphaFix(frame, value)
	local Portrait = frame.Portrait
	if (Portrait) then
		local alpha = value * Portrait:GetAlpha()
		Portrait:SetModelAlpha(alpha)
	end
end

function UF:CreatePortrait(frame)
	local lightValues = {
		omnidirectional = false,
		point = CreateVector3D(-1, 1, -1),
		ambientIntensity = 1.05,
		ambientColor = CreateColor(1, 1, 1)
	}

	local Portrait = CreateFrame('PlayerModel', nil, frame.Health)
	Portrait:SetAllPoints()
	Portrait:SetAlpha(C.db.pAlpha)
	Portrait:SetLight(true, lightValues)
	Portrait:SetFrameLevel(frame.Health:GetFrameLevel())

	-- https://github.com/Stanzilla/WoWUIBugs/issues/295
	_G.hooksecurefunc(frame, 'SetAlpha', ModelAlphaFix)

	Portrait.PostUpdate = PostUpdatePortrait

	frame.Portrait = Portrait
	frame.UpdatePortrait = UpdatePortrait
end

-- spell range
function UF:CreateSpellRange(frame)
	frame.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.6
	}
end

-- healcomm
function UF:CreateHealPrediction(frame)
	local health = frame.Health

	local myBar = CreateFrame('StatusBar', nil, health)
	myBar:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT')
	myBar:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
	myBar:SetWidth(frame:GetWidth())
	myBar:SetStatusBarTexture(C.Healbar)
	myBar:SetStatusBarColor(unpack(C.SelfColor))
	myBar:SetAlpha(0.6)
	myBar:SetFrameLevel(health:GetFrameLevel())
	myBar.Smooth = true

	local otherBar = CreateFrame('StatusBar', nil, health)
	otherBar:SetPoint('TOPLEFT', myBar:GetStatusBarTexture(), 'TOPRIGHT')
	otherBar:SetPoint('BOTTOMLEFT', myBar:GetStatusBarTexture(), 'BOTTOMRIGHT')
	otherBar:SetWidth(frame:GetWidth())
	otherBar:SetStatusBarTexture(C.Healbar)
	otherBar:SetStatusBarColor(unpack(C.OtherColor))
	otherBar:SetAlpha(0.6)
	otherBar:SetFrameLevel(health:GetFrameLevel())
	otherBar.Smooth = true

	frame.HealthPrediction = {
		myBar = myBar,
		otherBar = otherBar,
		maxOverflow = 1.0
	}
end

local function UpdateRunes(frame)
	local element = frame.Runes

    if C.db.Runes then
		if not frame:IsElementEnabled('Runes') then
        	frame:EnableElement('Runes')
		end
    else
		if frame:IsElementEnabled('Runes') then
        	frame:DisableElement('Runes')
		end
    end

	if frame:IsElementEnabled('Runes') then
		element:ForceUpdate()
	end
end

function UF:CreateRunes(frame)
	local Runes = {}
	for i = 1, 6 do
		local Rune = CreateFrame('StatusBar', 'Runes' .. i, frame)
		Rune:SetSize(frame:GetWidth() / 6 - 2, 8)
		Rune:SetPoint('TOPLEFT', frame.Power, 'BOTTOMLEFT', (i - 1) * frame:GetWidth() / 6 + 2, -6)

		Runes[i] = Rune
	end

    frame.Runes = Runes
	frame.UpdateRunes = UpdateRunes
end

local function UpdateTotems(frame)
	local element = frame.Totems

    if C.db.Totems then
		if not frame:IsElementEnabled('Totems') then
        	frame:EnableElement('Totems')
		end
    else
		if frame:IsElementEnabled('Totems') then
        	frame:DisableElement('Totems')
		end
    end

	if frame:IsElementEnabled('Totems') then
		element:ForceUpdate()
	end
end

function UF:CreateTotems(frame)
	local Totems = {}
	for i = 1, 4 do
		local Totem = CreateFrame('Button', 'Totem' .. i, frame)
		Totem:SetSize(26, 26)
		Totem:SetPoint('RIGHT', frame.Health, 'LEFT',  -40, -5)
		Totem:SetPoint('TOP', frame.Health, 'BOTTOM', 0, i * (Totem:GetHeight() + 1))

		local Icon = Totem:CreateTexture(nil, 'OVERLAY')
		Icon:SetAllPoints()

		local Cooldown = CreateFrame('Cooldown', nil, Totem, 'CooldownFrameTemplate')
		Cooldown:SetAllPoints()

		Totem.Icon = Icon
		Totem.Cooldown = Cooldown

		Totems[i] = Totem
	end

	frame.Totems = Totems
	frame.UpdateTotems = UpdateTotems
end

local function UpdateClassPower(frame)
	local element = frame.ClassPower

    if C.db.ClassPower then
		if not frame:IsElementEnabled('ClassPower') then
        	frame:EnableElement('ClassPower')
		end
    else
		if frame:IsElementEnabled('ClassPower') then
			frame:DisableElement('ClassPower')
		end
    end

	if frame:IsElementEnabled('ClassPower') then
		element:ForceUpdate()
	end
end

local function PostUpdateClassPowerColor(element)
	local ClassPowerColor = {
		[1] = {	.1,	.9, .1	},
		[2] = {	.1, .9, .1	},
		[3] = {	.9, .9, .1	},
		[4] = {	.9, .9, .1	},
		[5] = {	.9, .1, .1	},
	}

	for i = 1, #element do
		local Bar = element[i]
		Bar:SetStatusBarColor(unpack(ClassPowerColor[i]))
	end
end

function UF:CreateClassPower(frame)
	local ClassPower = {}
	for i = 1, 5 do
		local Bar = CreateFrame('StatusBar', 'ClassPower' .. i, frame)
		Bar:SetSize(32, 32)
		Bar:SetPoint('TOPLEFT', frame.Power, 'BOTTOMLEFT', (i - 1) * frame:GetWidth() / 5, 0)
		Bar:SetStatusBarTexture(C.CPt)

		ClassPower[i] = Bar
	end
	ClassPower.PostUpdateColor = PostUpdateClassPowerColor

	frame.ClassPower = ClassPower
	frame.UpdateClassPower = UpdateClassPower
end

-- Create Holder for Elements
function UF:CreateElementHolder(frame)
	local ElementHolder = CreateFrame('Frame', nil, frame.Health)
	ElementHolder:SetAllPoints()
	ElementHolder:SetFrameLevel(frame.Health:GetFrameLevel() + 1)

	frame.Element = ElementHolder
end

function UF:CombatIndicator(frame)
	local CIi = frame.Element:CreateTexture(nil, 'OVERLAY')
	CIi:SetPoint('LEFT', 2, 1)
	CIi:SetTexture(C.Cit)

	frame.CombatIndicator = CIi
end

function UF:LeaderIndicator(frame)
	local LIi = frame.Element:CreateTexture(nil, 'OVERLAY')
	LIi:SetPoint('LEFT', frame.CombatIndicator, 'RIGHT', -1, -1)
	LIi:SetTexture(C.Lit)

	frame.LeaderIndicator = LIi
end

function UF:LooterIndicator(frame)
	local MLi = frame.Element:CreateTexture(nil, 'OVERLAY')
	MLi:SetPoint('LEFT', frame.LeaderIndicator, 'RIGHT', 0, 1)
	MLi:SetTexture(C.MLi)

	frame.MasterLooterIndicator = MLi
end

function UF:FeignIndicator(frame)
	local FDi = frame.Element:CreateTexture(nil, 'OVERLAY')
    FDi:SetPoint('CENTER')

	frame.FeignIndicator = FDi
end

function UF:FlagsIndicator(frame)
	local Flag = frame.Element:CreateTexture(nil, 'OVERLAY')
	Flag:SetPoint('TOPRIGHT', 2, 1)

	frame.FlagsIndicator = Flag
end

function UF:LFGRoleIndicator(frame)
	local LFG = frame.Element:CreateTexture(nil, 'OVERLAY')
    LFG:SetPoint('CENTER')
	LFG:SetTexture(C.Lfg)

	frame.GroupRoleIndicator = LFG
end

function UF:OfflineIndicator(frame)
	local Off = frame.Element:CreateTexture(nil, 'OVERLAY')
    Off:SetPoint('CENTER')

    frame.OfflineIndicator = Off
end

function UF:ResurrectIndicator(frame)
	local Res = frame.Element:CreateTexture(nil, 'OVERLAY')
    Res:SetPoint('CENTER')

	frame.ResurrectIndicator = Res
end

function UF:RestingIndicator(frame)
	local RSi = frame.Element:CreateTexture(nil, 'OVERLAY')
	RSi:SetPoint('TOPRIGHT', 9, 9)
	RSi:SetTexture(C.Rit)

	frame.RestingIndicator = RSi
end

function UF:RaidTargetIndicator(frame)
	local RTi = frame:CreateTexture(nil, 'OVERLAY')
	RTi:SetTexture(C.RTi)

	if (frame.unit == 'targettarget' or frame.unit == 'focustarget' or frame.unit == 'maintanktarget') then
		RTi:SetPoint('BOTTOM', frame.Health, 'TOP', 0, -2)
	elseif (frame.unit == 'maintank') then
        RTi:SetPoint('RIGHT', frame.Health, 'LEFT', -4, 0)
	else
		RTi:SetPoint('LEFT', frame.Health, 'RIGHT', 4, 0)
    end

	frame.RaidTargetIndicator = RTi
end

function UF:ReadyCheckIndicator(frame)
	local RCi = frame:CreateTexture(nil, 'OVERLAY')
	RCi:SetPoint('LEFT', frame.Health, 'RIGHT', 4, 0)
	RCi:SetSize(18, 18)

    frame.ReadyCheckIndicator = RCi
end

function UF:HappinessIndicator(frame)
	local PHi = CreateFrame('Frame', nil, frame)
	PHi:SetPoint('RIGHT', frame.Health, 'LEFT', -4, 0)
	PHi:SetSize(18, 18)

	frame.HappinessIndicator = PHi
end