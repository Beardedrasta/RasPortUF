local _, RP = ...;

local RasPortUF = CreateFrame("Frame")

local frame, utarget, header, healthBar, healthBarTarget, healthText, healthTextTarget
local manaBar, manaBarTarget, manaText, manaTextTarget, portrait, portraitTarget, levelBox, levelBoxTarget
local LSM = LibStub("LibSharedMedia-3.0")
local texturePath = "Interface\\AddOns\\RasPort\\Media\\Statusbar\\RasPort.tga"
local customFontPath = "Interface\\AddOns\\RasPort\\Media\\Fonts\\Finalnew.ttf"
local blizzColor = {1, 0.81960791349411, 0, 1}
local sections = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}
local addonpath = "Interface\\AddOns\\RasPort"
local c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
local COLOR_ABSORB = {0.8, 0.8, 0.2, 0.7}
local COLOR_AGGRO = {1, 0, 0, 0.7}
local MAX_BUFFS = 30
RasPortUF.configUpdated = false
