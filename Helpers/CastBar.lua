local _, RP = ...
local DB = RP.RasPortUF

-- Lua APIs
local _G = getfenv(0)

-- WoW APIs
local CreateFrame = _G.CreateFrame

-- oUF_Nihlathak
local N, C = RP.N, RP.C
local UF = N.UnitFrame

-- Register Libs
local LSM = LibStub('LibSharedMedia-3.0')

local Castbar = {}

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

local function resetAttributes(self)
    local alpha = self:GetAlpha() - 0.025
    if (alpha > 0) then
        self:SetAlpha(alpha)
    else
        self.castID = nil
        self.casting = nil
        self.channeling = nil
        self.notInterruptible = nil
        self.spellID = nil
        self:Hide()
    end
end

function Castbar:OnUpdate(elapsed)
    if (self.casting or self.channeling) then
        local isCasting = self.casting
        if (isCasting) then
            self.duration = self.duration + elapsed
            if (self.duration >= self.max) then
                resetAttributes(self)
                return
            end
        else
            self.duration = self.duration - elapsed
            if (self.duration <= 0) then
                resetAttributes(self)
                return
            end
        end
        local unit = self.__owner.unit
        if (unit == 'player') then
            if (self.delay ~= 0) then
                self.Time:SetFormattedText('%.1f | |cffff4250%s%.1f|r', self.duration, isCasting and '+' or '-',
                    self.delay)
            else
                self.Time:SetFormattedText('%.1f | %.1f', self.duration, self.max)
            end
        else
            self.Time:SetFormattedText('%.1f | %.1f', self.duration,
                self.casting and self.max + self.delay or self.max - self.delay)
        end
        self:SetValue(self.duration)
    else
        resetAttributes(self)
    end
end

function Castbar:PostCastStart()
    self:SetAlpha(1.0)

    if self.notInterruptible then
        self:SetStatusBarColor(0.7, 0.7, 0, 0.6)
    else
        if self.casting then
            self:SetStatusBarColor(0, 1, 0, 0.5)
        elseif self.channeling then
            self:SetStatusBarColor(0.1, 0.6, 1, 0.5)
        end
    end

    local texture = self.Icon:GetTexture()
    if (not texture) or (texture == 136235) then
        self.Icon:SetTexture(136243)
    end
end

function Castbar:PostCastFail()
    self:SetStatusBarColor(1, 0.25, 0.25, 1)
end

function Castbar:UpdateFont()
    local unit = self.__owner.unit

    if (unit == 'player') or (unit == 'target') then
        self.FontSize = C.db.Castbar.fontsize
    else
        self.FontSize = C.db.Castbar.fontsize - 2
    end

    self.Text:SetFont(LSM:Fetch('font', C.db.Castbar.textfont), C.db.Castbar.fontsize, C.db.Castbar.fontflag)
    self.Time:SetFont(LSM:Fetch('font', C.db.Castbar.timefont), C.db.Castbar.fontsize, C.db.Castbar.fontflag)

    self.Text:ClearAllPoints()
    self.Text:SetPoint(C.db.Castbar.textpoint, C.db.Castbar.textofsX, C.db.Castbar.textofsY)

    self.Time:ClearAllPoints()
    self.Time:SetPoint(C.db.Castbar.timepoint, C.db.Castbar.timeofsX, C.db.Castbar.timeofsY)
end

function Castbar:UpdateTexture()
    self:SetStatusBarTexture(LSM:Fetch('statusbar', C.db.Castbar.texture))
end

local updateFunc = {}

function updateFunc:UpdateCastbar()
    local element = self.Castbar
    element:UpdateFont()
    element:UpdateTexture()

    if C.db.Castbar.enable then
        if not self:IsElementEnabled('Castbar') then
            self:EnableElement('Castbar')
        end
    else
        if self:IsElementEnabled('Castbar') then
            self:DisableElement('Castbar')
        end
    end

    if self:IsElementEnabled('Castbar') then
        element:ForceUpdate()
    end
end

function UF:CreateCastbar(frame)
    RP:Mixin(frame, updateFunc)

    local cb = RP:Mixin(CreateFrame('StatusBar', nil, frame), Castbar)
    cb:SetStatusBarTexture("Interface\\AddOns\\RasPortUF\\Media\\RasPort")
    cb:SetFrameLevel(frame.Health:GetFrameLevel() + 1)

    local Text = cb:CreateFontString(nil, 'OVERLAY')
    Text:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
    Text:SetPoint('LEFT', 1, 0)
    Text:SetJustifyH('LEFT')
    Text:SetWordWrap(false)
    cb.Text = Text

    local Time = cb:CreateFontString(nil, 'OVERLAY')
    Time:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")
    Time:SetPoint("RIGHT", 0, 0)
    Time:SetJustifyH('RIGHT')
    cb.Time = Time

    local Icon = cb:CreateTexture(nil, 'OVERLAY')
    Icon:SetPoint('RIGHT', cb, 'LEFT', -4, 0)
    Icon:SetSize(15, 15)
    Icon:SetTexCoord(.08, .92, .08, .92)
    cb.Icon = Icon

    local IconBD = CreateFrame('Frame', nil, cb, 'BackdropTemplate')
    IconBD:SetPoint('TOPLEFT', cb.Icon, -1, 1)
    IconBD:SetPoint('BOTTOMRIGHT', cb.Icon, 1, -1)
    IconBD:SetBackdrop({
        bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1
    })
    IconBD:SetBackdropColor(0, 0, 0, 0)
    IconBD:SetBackdropBorderColor(0, 0, 0, 1)
    IconBD:SetFrameLevel(cb:GetFrameLevel())

    local Spark = cb:CreateTexture(nil, 'OVERLAY')
    Spark:SetPoint('CENTER', cb:GetStatusBarTexture(), 'RIGHT')
    Spark:SetHeight(15)
    Spark:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\spark")
    Spark:SetVertexColor(1, 0.8, 0)
    Spark:SetBlendMode('ADD')
    cb.Spark = Spark

    frame.Castbar = cb

    local border = CreateFrame("Frame", nil, cb, "BackdropTemplate")
    border:SetBackdrop({
        edgeFile = "Interface\\AddOns\\RasPort\\Media\\UnitFrames\\border-thick.tga",
        tileEdge = true,
        edgeSize = 12,
        insets = {
            left = 6,
            right = 6,
            top = 6,
            bottom = 6
        }
    })
    border:SetFrameLevel(frame:GetFrameLevel() + 7)
    border:SetFrameStrata("LOW")

    -- the way Blizz position it creates really weird gaps, so fix it
    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", Icon, "TOPLEFT", -6, 6)
    border:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", 6, -7)
    local r, g, b = SetColorByProfile(border)
    border:SetBackdropBorderColor(r, g, b, 1)

    local backdrop = CreateFrame("Frame", nil, cb, "BackdropTemplate")
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
    backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)
    backdrop:SetFrameStrata("BACKGROUND")
    backdrop:SetBackdropColor(0.1, 0.1, 0.1, 1)

    backdrop:SetAllPoints(border)
end
