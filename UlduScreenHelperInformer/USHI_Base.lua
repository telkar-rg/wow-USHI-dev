local ADDON_NAME, addonTable = ...;

addonTable.ADDON_NAME_LONG 	= "Ulduar Screenshot Helper & Informer"
addonTable.ADDON_NAME_SHORT = "USHI"
addonTable.ADDON_VERSION 	= GetAddOnMetadata(ADDON_NAME, "Version")

local a1,a2,a3 = strsplit(".", addonTable.ADDON_VERSION)
a1 = tonumber(a1 or 0) or 0
a2 = tonumber(a2 or 0) or 0
a3 = tonumber(a3 or 0) or 0
addonTable.ADDON_VERSION_NUM = (a1*100 + a2)*100 + a3

addonTable.ColorList = {
	["COL_USHI"] =	"FF33ff99",
	["WHITE"] =		"FFffffff",
	["BLACK"] =		"FF000000",
	["GRAY"] =		"FFaaaaaa",
	["BLUE"] =		"FF0000ff",
	["BLUE_LIGHT"] ="FF44aaff",
	["ORANGE"] =	"FFff9933",
	["CYAN"] =		"FF00ffff",
	["YELLOW"] =	"FFffff00",
	["PURPLE"] =	"FFb048f8",
}
