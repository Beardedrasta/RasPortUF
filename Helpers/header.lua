local _, RP = ...
local oUF = RP.oUF
local DB = RP.RasPortUF
local LSM = LibStub("LibSharedMedia-3.0")
local headers = {}
local blizzColor = {1, 0.81960791349411, 0, 1}

local N = RP.N
local _G = getfenv(0)
local next = _G.next

--[[ function RP:CreateHeader(frame, unit)
    local header = frame:CreateFontString(nil, "OVERLAY")
    header:SetFont(LSM:Fetch("font", core.db.profile.unitframes["Font"]), core.db.profile.unitframes["Name Font Size"],
        "OUTLINE")
    header:SetText(UnitName(unit))
    header:SetTextColor(unpack(blizzColor))
    header:SetPoint("TOP", frame, 0, 25)
    headers[unit] = header

    return header
end

local function UpdateHeader(unit)
    local header = headers[unit]
    if header then
        header:SetText(UnitName(unit))
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateHeader("target") -- Call the update function
    end
end)


function core:UpdateHeaderPosition(fontString, unit, anchor)
    fontString:SetText(UnitName(unit))
    fontString:SetFont(LSM:Fetch("font", core.db.profile.unitframes["Font"]),
        core.db.profile.unitframes["Name Font Size"], "OUTLINE")

    local yOffset = 0 -- Set this to your desired value.

    fontString:ClearAllPoints()
    if unit == "target" then
        fontString:SetPoint("BOTTOM", anchor, "TOP", -30, yOffset)
    else
        fontString:SetPoint("BOTTOM", anchor, "TOP", 30, yOffset)
    end
end ]]

do
	local LSM = LibStub("LibSharedMedia-3.0")

	local function update(obj, f, s)
		s = s or select(2, obj:GetFont())
		if s <= 0 then
			s = 12 -- cooldowns' default font size is -1450 for some reason
		end

		obj:SetFont(LSM:Fetch("font", DB.db.profile["Font"]), DB.db.profile["Font Size"], "OUTLINE")

		if DB.db.profile.shadow then
			obj:SetShadowOffset(1, -1)
		else
			obj:SetShadowOffset(0, 0)
		end
	end

	local objects = {}

	local proto = {}

	function proto:UpdateFont(s)
		local t = objects[self]
		if not t then return end

		update(self, t, s)
	end

	local module = {
		cooldown = {},
		unit = {},
		button = {},
		statusbar = {},
	}

	function module:Capture(obj, t)
		if obj:GetObjectType() ~= "FontString" then
			return
		elseif not self[t] then
			return
		elseif objects[obj] or self[t][obj] then
			return
		end

		RP:Mixin(obj, proto)

		self[t][obj] = true
		objects[obj] = t
	end

	function module:Release(obj)
		for k in next, proto do
			obj[k] = nil
		end

		self[objects[obj]] = true
		objects[obj] = nil
	end

	function module:UpdateAll(t)
		if not self[t] then return end

		for obj in next, self[t] do
			update(obj, t)
		end
	end

	N.FontStrings = module
end

