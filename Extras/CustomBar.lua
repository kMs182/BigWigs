assert(BigWigs, "BigWigs not found!")

----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.0"):new("BigWigsCustomBar")

L:RegisterTranslations("enUS", function() return {
	["bwcb"] = true,
	["Custom Bars"] = true,
	["<seconds> <bar text>"] = true,
	["Starts a custom bar with the parameters."] = true,
	["%s: %s"] = true,
	["%s: Timer [%s] finished."] = true,
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsCustomBar = BigWigs:NewModule(L["Custom Bars"], "AceConsole-2.0")
BigWigsCustomBar.revision = tonumber(string.sub("$Revision$", 12, -3))
BigWigsCustomBar.defaults = {
	enabled = true,
}
BigWigsCustomBar.external = true

------------------------------
--      Initialization      --
------------------------------

function BigWigsCustomBar:OnInitialize()
	self:RegisterChatCommand({"/"..L["bwcb"]}, {
		type = "text",
		name = L["Custom Bars"],
		desc = L["Starts a custom bar with the parameters."],
		get = false,
		set = function(v) BigWigsCustomBar:TriggerEvent("BigWigs_SendSync", "BWCustomBar "..v) end,
		usage = L["<seconds> <bar text>"],
		disabled = function() return (not IsRaidLeader() and not IsRaidOfficer()) and UnitInRaid("player") end,
	})
end

function BigWigsCustomBar:OnEnable()
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCustomBar", 2)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsCustomBar:BigWigs_RecvSync(sync, rest, nick)
	if sync ~= "BWCustomBar" or not rest or not nick or not self.db.profile.enabled then return end

	if UnitInRaid("player") then
		for i = 1, GetNumRaidMembers() do
			local name, rank = GetRaidRosterInfo(i)
			if name == nick then
				if rank == 0 then
					return
				else
					break
				end
			end
		end
	end

	local _, _, seconds, barText = string.find(rest, "(%d+) (.*)")
	if not seconds or not barText then return end
	seconds = tonumber(seconds)
	if seconds == nil then return end

	self:ScheduleEvent("bwcb"..nick..barText, "BigWigs_Message", seconds, string.format(L["%s: Timer [%s] finished."], nick, barText), "Attention")
	self:TriggerEvent("BigWigs_StartBar", self, string.format(L["%s: %s"], nick, barText), seconds, "Interface\\Icons\\INV_Misc_PocketWatch_01")
end

