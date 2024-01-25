local _, RP = ...
local DB = RP.RasPortUF
local LSM = LibStub("LibSharedMedia-3.0")
local texturePath = "Interface\\AddOns\\RasPort\\Media\\Statusbar\\statusbar-texture.tga"
local MAX_BUFFS = 30
local COLOR_ABSORB = {0.8, 0.8, 0.2, 0.7}
local COLOR_AGGRO = {1, 0, 0, 0.7}
local blizzColor = {1, 0.81960791349411, 0, 1}
local playerFrames = RP.playerFrames

local N, oUF = RP.N, RP.oUF
local UF = N.UnitFrame

local _G = getfenv(0)
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

-------------
-- Player  --
-------------

local function CreatePlayerFrame(self, unit)
    -- Set the size of the unit frame
    self:SetSize(DB.db.profile["PowerWidth"], 32)

    -- Health bar setup
    UF:CreatePlayerAnchor()
    UF:CreateHeader(self, unit)
    UF:CreateHealthBar(self, unit)
    UF:CreateHPText(self)
    UF:CreatePerHP(self)
    UF:CreateCurHP(self)
    UF:CreatePowerBar(self)
    UF:CreatePPText(self)
    UF:CreateCurPP(self)
    UF:CreatePerPP(self)
    UF:CreateXpRep(self)
    --UF:CreateDHlight(self)
    UF:CreateBackground(self, self.Power, unit)
    UF:CreateHealPrediction(self)
    UF:CreateHealthSpark(self)
    self.Health.Spark:SetPoint('CENTER', self.Health:GetStatusBarTexture(), 'RIGHT', 1, 0)
    UF:CreatePowerSpark(self)
    self.Power.Spark:SetPoint('CENTER', self.Power:GetStatusBarTexture(), 'RIGHT', 1, 0)

    UF:CreateAuras(self, unit)

    self.Power:SetSize(DB.db.profile["PowerWidth"], 10)
    self.Power:SetPoint('TOP', self.Health, 'BOTTOM', 0, -1)

--[[     UF:CreateInlayParent(self)
    self.inlay:SetPoint("TOPLEFT", self, 0, 0)
    self.inlay:SetPoint("BOTTOMRIGHT", self, 0, 1)
    self.inlay:SetFrameLevel(self:GetFrameLevel() + 6)

    local border = RP:CreateBorder(self.inlay)
    border:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\Inlay\\unit-frame-inlay-both.tga")
    border:SetSize(16)
    border:SetOffset(-8)
    border:SetAlpha(0.2)
    self.Border = border ]]

    UF:CreatePortrait(self, unit)
    -- Portrait setup
    self.Point:SetSize(55, 55)
    self.Point:SetPoint('TOPLEFT', self, 'TOPLEFT', -45, 15)
    self.Point:SetFrameLevel(self:GetFrameLevel() + 7)

    UF:CreateLevelBox(self, unit)
    self.levelBox:SetPoint("BOTTOMRIGHT", self.Portrait, 10, -5)
    self.levelBox:SetFrameLevel(self:GetFrameLevel() + 7)

    --UF:CreateThreatHlight(self)

    UF:CreateCastbar(self)
    self.Castbar:SetPoint('TOPLEFT', self.Portrait, 'TOPLEFT', 10, 40)
    self.Castbar:SetSize(DB.db.profile["PowerWidth"] + 45, 15)

    local _, class = UnitClass("player")
    if class == "DEATHKNIGHT" then
        UF:CreateRunes(self)
    end

    UF:CreateElementHolder(self)

    UF:CombatIndicator(self)
    self.CombatIndicator:SetSize(26, 24)

    UF:LeaderIndicator(self)
    self.LeaderIndicator:SetSize(20, 20)

    UF:LooterIndicator(self)
    self.MasterLooterIndicator:SetSize(20, 20)

    UF:RestingIndicator(self)
    self.RestingIndicator:SetSize(25, 25)
    self.RestingIndicator:SetPoint('TOPLEFT', self.Point, 10, -1)

    UF:ResurrectIndicator(self)
    self.ResurrectIndicator:SetSize(20, 20)

    UF:ClassIcon(self)
    self.ClassIcon:SetSize(10, 10)
    self.IconBox:SetPoint("TOPRIGHT", self, 0, 5)
    --[[ UF:CreateCastBar(self, unit)
    self.Castbar:SetPoint('TOPLEFT', self.Portrait, 'TOPLEFT', 10, 35)
    self.Castbar:SetSize(DB.db.profile["PowerWidth"] + 45, 15)
 ]]

    self:HookScript('OnEnter', function()
        if not DB.db.profile["Hide Status Value"] then
            if DB.db.profile["Percentages"] then
                self.Health.PerHP:SetAlpha(0)
                self.Power.PerPP:SetAlpha(0)
                self.HPText:SetAlpha(1)
                self.PPText:SetAlpha(1)
                self.XpRep:SetAlpha(1)
            else
                self.Health.CurHP:SetAlpha(0)
                self.Power.CurPP:SetAlpha(0)
                self.HPText:SetAlpha(1)
                self.PPText:SetAlpha(1)
                self.XpRep:SetAlpha(1)
            end
        end
    end)
    self:HookScript('OnLeave', function()
        if not DB.db.profile["Hide Status Value"] then
            if DB.db.profile["Percentages"] then
                self.Health.PerHP:SetAlpha(1)
                self.Power.PerPP:SetAlpha(1)
                self.HPText:SetAlpha(0)
                self.PPText:SetAlpha(0)
                self.XpRep:SetAlpha(0)
            else
                self.Health.CurHP:SetAlpha(1)
                self.Power.CurPP:SetAlpha(1)
                self.HPText:SetAlpha(0)
                self.PPText:SetAlpha(0)
                self.XpRep:SetAlpha(0)
            end
        end
    end)

    self.unit = "player"
end

-------------
-- Target  --
-------------

local function CreateTargetFrame(self, unit)
    -- Set the size of the unit frame
    self:SetSize(DB.db.profile["PowerWidth"], 32)

    -- Health bar setup
    UF:CreateTargetAnchor()
    UF:CreateHeader(self, unit)
    UF:CreateHealthBar(self, unit)
    self.Health:SetReverseFill(true)
    UF:CreateHPText(self)
    UF:CreatePerHP(self)
    UF:CreateCurHP(self)
    UF:CreatePowerBar(self)
    self.Power:SetReverseFill(true)
    UF:CreatePPText(self)
    UF:CreateCurPP(self)
    UF:CreatePerPP(self)
    --UF:CreateDHlight(self)
    UF:CreateBackground(self, self.Power, unit)
    UF:CreateHealPrediction(self)
    UF:CreateHealthSpark(self)
    self.Health.Spark:SetPoint('CENTER', self.Health:GetStatusBarTexture(), 'LEFT', 0, 0)
    UF:CreatePowerSpark(self)
    self.Power.Spark:SetPoint('CENTER', self.Power:GetStatusBarTexture(), 'LEFT', -1, 0)

    UF:CreateAuras(self, unit)
    self.Buffs:SetPoint('LEFT', self, "RIGHT", 79, -73)
    --[[ UF:CreateAuraBars(self)
    self.Auras:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 75) ]]

    self.Power:SetSize(DB.db.profile["PowerWidth"], 10)
    self.Power:SetPoint('TOP', self.Health, 'BOTTOM', 0, -1)

--[[     UF:CreateInlayParent(self)
    self.inlay:SetPoint("TOPLEFT", self.Health, 0, 0)
    self.inlay:SetPoint("BOTTOMRIGHT", self.Power, 0, 0)
    self.inlay:SetFrameLevel(self:GetFrameLevel() + 6)

    local border = RP:CreateBorder(self.inlay)
    border:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\Inlay\\unit-frame-inlay-both.tga")
    border:SetSize(16)
    border:SetOffset(-8)
    border:SetAlpha(0.2)
    self.Border = border ]]

    UF:CreatePortrait(self, unit)
    -- Portrait setup
    self.Point:SetSize(55, 55)
    self.Point:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 45, 15)
    self.Point:SetFrameLevel(self:GetFrameLevel() + 7)

    UF:CreateLevelBox(self, unit)
    self.levelBox:SetPoint("BOTTOMLEFT", self.Portrait, -10, -5)
    self.levelBox:SetFrameLevel(self:GetFrameLevel() + 7)

    --UF:CreateThreatHlight(self)

    UF:CreateCastbar(self)
    self.Castbar:SetPoint('TOPLEFT', self.Health, 'TOPLEFT', 15, 40)
    self.Castbar:SetSize(DB.db.profile["PowerWidth"] + 45, 15)

    local _, class = UnitClass("player")
    if class == "DEATHKNIGHT" then
        UF:CreateRunes(self)
    end

    UF:CreateElementHolder(self)

    UF:LeaderIndicator(self)
    self.LeaderIndicator:SetSize(20, 20)
    

    UF:LooterIndicator(self)
    self.MasterLooterIndicator:SetSize(20, 20)

    UF:ResurrectIndicator(self)
    self.ResurrectIndicator:SetSize(20, 20)

    UF:ClassIcon(self)
    self.ClassIcon:SetSize(10, 10)
    self.IconBox:SetPoint("TOPLEFT", self, 0, 5)
    --[[ UF:CreateCastBar(self, unit)
    self.Castbar:SetPoint('TOPLEFT', self.Portrait, 'TOPLEFT', 10, 35)
    self.Castbar:SetSize(DB.db.profile["PowerWidth"] + 45, 15)
 ]]

    self:HookScript('OnEnter', function()
        if DB.db.profile["Percentages"] then
            self.Health.PerHP:SetAlpha(0)
            self.Power.PerPP:SetAlpha(0)
            self.HPText:SetAlpha(1)
            self.PPText:SetAlpha(1)
        else
            self.Health.CurHP:SetAlpha(0)
            self.Power.CurPP:SetAlpha(0)
            self.HPText:SetAlpha(1)
            self.PPText:SetAlpha(1)
        end
    end)
    self:HookScript('OnLeave', function()
        if DB.db.profile["Percentages"] then
            self.Health.PerHP:SetAlpha(1)
            self.Power.PerPP:SetAlpha(1)
            self.HPText:SetAlpha(0)
            self.PPText:SetAlpha(0)
        else
            self.Health.CurHP:SetAlpha(1)
            self.Power.CurPP:SetAlpha(1)
            self.HPText:SetAlpha(0)
            self.PPText:SetAlpha(0)
        end
    end)

    self.unit = "target"
end


-------------
---  Pet  ---
-------------

local function CreatePetFrame(self, unit)
    self:SetSize(100, 22)

    UF:CreateHeader(self)
    UF:CreateHealthBar(self, unit)
    UF:CreateHPText(self)
    UF:CreatePerHP(self)
    UF:CreateCurHP(self)
    UF:CreatePowerBar(self)
    UF:CreateBackground(self, self.Power, unit)
    UF:CreateHealPrediction(self)
    self.Power:SetSize(DB.db.profile["PowerWidth"] - 65, 5)
    self.Power:SetPoint('TOP', self.Health, 'BOTTOM', 0, -1)
    UF:CreatePortrait(self)
    self.Point:SetSize(40, 40)
    self.Point:SetPoint('TOPLEFT', self, 'TOPLEFT', -33, 12)
    self.Point:SetFrameLevel(self:GetFrameLevel() + 7)

    self.unit = "pet"
end

-------------
-- Target  --
-------------

local function Shared(self, unit)
    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    if unit == "player" then
        CreatePlayerFrame(self, unit)
    elseif unit == "target" then
        CreateTargetFrame(self, unit)
    elseif unit == "pet" then
        CreatePetFrame(self, unit)
    end
end

oUF:RegisterStyle('RastaUF', Shared)
oUF:SetActiveStyle('RastaUF')

oUF:Factory(function(self)
    self:SetActiveStyle("RastaUF")

    local playerFrame = self:Spawn('player', 'player')
    playerFrame:SetPoint('TOPLEFT', UF.playerAnchor, 'BOTTOMLEFT', 0, -2)
    table.insert(UF, playerFrame)

    local targetFrame = self:Spawn('target', 'target')
    targetFrame:SetPoint('TOPRIGHT', UF.targetAnchor, 'BOTTOMRIGHT', 0, -2)
    table.insert(UF, targetFrame)

    local petFrame = self:Spawn('pet', 'pet')
    petFrame:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 15, -30)
    table.insert(UF, petFrame)

    --[[ local p = self:Spawn("pet")
    p:SetPoint("LEFT", f, -100, 0) ]]

    --[[ local tf = self:Spawn("target")
    tf:SetPoint("CENTER", UIParent, "CENTER", 300, 0) ]]
    --[[ local ttf = self:Spawn("targettarget")
    ttf:SetPoint("RIGHT", tf, 150, 0) ]]

    --[[ local ff = self:Spawn("focus")
    ff:SetPoint("CENTER", UIParent, "CENTER", -800, 0) ]]

end)
