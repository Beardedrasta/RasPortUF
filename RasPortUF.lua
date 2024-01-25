local addon, RP = ...
RP.RasPortUF = LibStub("AceAddon-3.0"):NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0")


-- Register Libs
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Lua APIs
local _G = getfenv(0)
local type = _G.type
local next = _G.next
local pairs = _G.pairs
local print = _G.print
local select = _G.select
local max = _G.math.max
local min = _G.math.min
local ceil = _G.math.ceil
local huge = _G.math.huge
local format = _G.string.format
local tinsert = _G.table.insert

-- WoW APIs
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local IsPlayerSpell = _G.IsPlayerSpell
local IsSpellKnown = _G.IsSpellKnown
local InCombatLockdown = _G.InCombatLockdown
local CloseDropDownMenus = _G.CloseDropDownMenus
local GetLocale = _G.GetLocale
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetPhysicalScreenSize = _G.GetPhysicalScreenSize
local PlaySound = _G.PlaySound

local playerFrames  = {}
RP.playerframes = playerFrames
local N, C, L, oUF = {}, {}, {}, RP.oUF
RP.N, RP.C, RP.L = N, C, L
_G[addon] = {N, -- function
C, -- config
L, -- locale
oUF -- oUF
}


C.Title = addon .. 'DB'
N.Title = GetAddOnMetadata(addon, 'Title')
N.Version = GetAddOnMetadata(addon, 'Version')

N.UnitFrame = {}
N.UnitFrame.objects = {}
N.UnitFrame.headers = {}
N.UnitFrame.raidgroup = {}

local UF = N.UnitFrame

function L.GetLocale(locale)
    return GetLocale() == locale
end

N.playerClass = select(2, UnitClass('player'))

local defaults = {
    profile = {}
}

-- format time
function RP.FormatTime(sec)
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
        return format('%d', ceil(sec))
    else
        return format('%.1f', sec)
    end
end

-- where ​... are the mixins to mixin
function RP:Mixin(object, ...)
    for i = 1, select('#', ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            object[k] = v
        end
    end

    return object
end

function RP:GetAura(id)
    return RP.RasPortUF.db.profile.CustomAuras[id]
end

local defaults = {
    profile = {
        minimap = {
            hide = false
        },
        Class = true,
        Blackout = false,
        ["Custom Color"] = false,
        uiCustomColor = {
            red = 1,
            green = 1,
            blue = 1,
            alpha = 1
        },
        displayPercent = false,
        configUnlock = false,
        friendly = {0, 1, 0},
        hostile = {1, 0, 0},
        neutral = {1, 1, 0},
        HideLevel = false,
        classColorNames = true,
        ["size"] = 1,
        ["Hide Level"] = false,
        ["Hide Icon"] = false,
        ["Hide Indicator"] = false,
        ["Name Font Size"] = 16,
        ["Font Size"] = 12,
        ["horizontalPosition"] = 0,
        ["verticalPosition"] = 0,
        playerOffsetY = -200,
        targetOffsetY = -200,
        ["Buff Size"] = 25,
        ["Font"] = "Friz Quadrata TT",
        ["Outline"] = "OUTLINE",
        ["Player Debuffs"] = true,
        ["3DPortrait"] = true,
        ['PowerWidth'] = 200,
        ['CustomAuras'] = {
            [4] = true,
            [5] = true,
            [7] = true,
        },
        ["Percentages"] = true,
        ["Hide Status Value"] = false,
        ["Lock Frames"] = true,
        ["FramePositions"] = {
            player = {
                point = "CENTER",
                x = -200,
                y = -300,
            },
            target = {
                point = "CENTER",
                x = 200,
                y = -300,
            }
        },
    }
}

function RP.RasPortUF:OpenConfig()
    if not self.configOpen then
        AceConfigDialog:Open("RasPortUF")
        self.configOpen = true -- Config is now open
    else
        AceConfigDialog:Close("RasPortUF")
        self.configOpen = false -- Config is now closed
    end
end

local function OnConfigClosed()
    RP.RasPortUF.configOpen = false
end

AceConfigDialog:SetDefaultSize("RasPortUF", 800, 600) -- Assuming default size is desired
AceConfigDialog.OnHide = OnConfigClosed

local RasPortLDB = LibStub("LibDataBroker-1.1"):NewDataObject("RasPortUF", {
    type = "launcher",
    text = "RasPort_UF",
    icon = "Interface\\AddOns\\RasPortUF\\Media\\minimap.tga",
    OnClick = function(clickedFrame, button)
        if button == "LeftButton" then
            RP.RasPortUF:OpenConfig() -- This will now correctly open or close the config
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("RasPort - Unitframes")
        tt:AddLine("Left Click to open config")
    end
})
local icon = LibStub("LibDBIcon-1.0")

function RP.RasPortUF:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RasPortUFDB", defaults, true)
    icon:Register("RasPortUF", RasPortLDB, self.db.profile.minimap)
    self.configOpen = false
    self:RegisterChatCommand("rpuf", "ChatCommand")
end

function RP.RasPortUF:OpenConfig()
    AceConfigDialog:Open("RasPortUF")
end

function RP.RasPortUF:CloseConfig()
    AceConfigDialog:Close("RasPortUF")
end

local options = {
    name = "RasPort_UF",
    handler = RP.RasPortUF,
    type = "group",
    args = {
        minimap = {
            order = 1,
            type = "toggle",
            name = "Show Minimap Icon",
            desc = "Toggle the display of the minimap icon",
            get = function()
                return not RP.RasPortUF.db.profile.minimap.hide
            end,
            set = function(_, value)
                RP.RasPortUF.db.profile.minimap.hide = not value
                if value then
                    icon:Show("RasPortUF")
                else
                    icon:Hide("RasPortUF")
                end
            end
        },
        class = {
            order = 2,
            type = "toggle",
            name = "Class Color",
            get = function()
                return RP.RasPortUF.db.profile.Class
            end,
            set = function(_, value)
                RP.RasPortUF.db.profile.Class = value
                if value then
                    RP.RasPortUF.db.profile.Blackout = false
                    RP.RasPortUF.db.profile["Custom Color"] = false
                end
            end,
        },
        blackout = {
            order = 3,
            type = "toggle",
            name = "Blackout",
            get = function()
                return RP.RasPortUF.db.profile.Blackout
            end,
            set = function(_, value)
                RP.RasPortUF.db.profile.Blackout = value
                if value then
                    RP.RasPortUF.db.profile.Class = false
                    RP.RasPortUF.db.profile["Custom Color"] = false
                end
            end
        },
        customcolor = {
            order = 4,
            type = "toggle",
            name = "Custom Color",
            get = function()
                return RP.RasPortUF.db.profile["Custom Color"]
            end,
            set = function(_, value)
                RP.RasPortUF.db.profile["Custom Color"] = value
                if value then
                    RP.RasPortUF.db.profile.Class = false
                    RP.RasPortUF.db.profile.Blackout = false
                end
            end
        },
        customcolorpicker = {
            order = 5,
            type = "color",
            name = "Custom Color Picker",
            hidden = function()
                return not RP.RasPortUF.db.profile["Custom Color"]
            end,
            get = "GetColor",
            set = "SetColor",
        },
        powerWidth = {
            order = 8,
            type = 'range',
            name = 'Width',
            desc = 'Adjust the width of the unitframe\n(If DK reload to adjust the rune bar)',
            min = 125,
            max = 300,
            step = 1,
            get = function(info)
                return RP.RasPortUF.db.profile.PowerWidth
            end,
            set = function(info, value)
                RP.RasPortUF.db.profile.PowerWidth = value
                UF:UpdatePowerBar(value)
            end,
        },
        values = {
            order = 10,
            type = "toggle",
            name = "Hide Status Values",
            desc = 'Show the Health and Mana text values.',
            get = function()
                return RP.RasPortUF.db.profile["Hide Status Value"]
            end,
            set = function(_, value)
                RP.RasPortUF.db.profile["Hide Status Value"] = value
                UF:UpdateAll()
            end,
        },
        percentage = {
            order = 10,
            type = "toggle",
            name = "Percentage",
            desc = 'Show % value on the health and mana bar',
            get = function()
                return RP.RasPortUF.db.profile["Percentages"]
            end,
            set = function(_, value)
                RP.RasPortUF.db.profile["Percentages"] = value
                UF:UpdateAll()
            end,
        },
        hidelevel = {
            order = 11,
            type = "toggle",
            name = "Hide Level",
            desc = 'Hide the unit level',
            get = function()
                return RP.RasPortUF.db.profile["Hide Level"]
            end,
            set = function(_, value)
                RP.RasPortUF.db.profile["Hide Level"] = value
                UF:UpdateAll()
            end,
        },
        hideicon = {
            order = 12,
            type = "toggle",
            name = "Hide Icon",
            desc = 'Hide the unit icon',
            get = function()
                return RP.RasPortUF.db.profile["Hide Icon"]
            end,
            set = function(_, value)
                RP.RasPortUF.db.profile["Hide Icon"] = value
                UF:UpdateAll()
            end,
        },
        lockframe = {
            order = 13,
            type = "toggle",
            name = "Lock Frames",
            desc = 'Locks and unlocks unitframes',
            get = function()
                return RP.RasPortUF.db.profile["Lock Frames"]
            end,
            set = function(_, value)
                RP.RasPortUF.db.profile["Lock Frames"] = value
                UF:UnlockFrames()
            end,
        },
    }
}

--Color
function RP.RasPortUF:GetColor(info)
    return self.db.profile.uiCustomColor.red, self.db.profile.uiCustomColor.green, self.db.profile.uiCustomColor.blue, self.db.profile.uiCustomColor.alpha
end
function RP.RasPortUF:SetColor(_, r,g,b,a)
    self.db.profile.uiCustomColor.red = r 
    self.db.profile.uiCustomColor.green = g
    self.db.profile.uiCustomColor.blue = b
    self.db.profile.uiCustomColor.alpha = a
end

AceConfig:RegisterOptionsTable("RasPortUF", options)
AceConfigDialog:AddToBlizOptions("RasPortUF", "RasPortUF")

function RP.RasPortUF:Print(...)
    print("|cffff6347RasPort_UF|r:", ...)
end
