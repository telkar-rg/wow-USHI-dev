local ADDON_NAME, addonTable = ...;

local ADDON_NAME, addonTable = ...;

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)
if not L then return end
local ORANGE = "|cffff9933"

L["Enable Addon"] = "Enable USHI"
L["DESC_OPTION_enable_addon"] = "Enable or disable Ulduar Screenshot Helper (stored per character)"

L["Chat output"] = true
L["DESC_OPTION_chat_output"] = "Toggles the output of time stamp and trigger reason"
L["Screenshot Triggers"] = true

L["DESC_OPTION_trigger_boss_prefix"] = "Screenshot after kill of "
L["Fragment looting"] = ORANGE.."Fragment looting".."|r"
L["DESC_OPTION_trigger_val_drop"] = "Screenshot after looting of Fragment of Val'anyr"






-- Ulduar 
L["Ulduar"] = true
L["Fragment of Val'anyr"] = true

L["Flame Leviathan"] = true
L["Ignis the Furnace Master"] = true
L["Razorscale"] = true
L["XT-002 Deconstructor"] = true

L["Assembly of Iron"] = true
L["Steelbreaker"] = true
L["Runemaster Molgeim"] = true
L["Stormcaller Brundir"] = true
L["Kologarn"] = true
L["Algalon the Observer"] = true

L["Auriaya"] = true
L["Freya"] = true
L["Thorim"] = true
L["Hodir"] = true
L["Mimiron"] = true

L["General Vezax"] = true
L["Yogg-Saron"] = true
