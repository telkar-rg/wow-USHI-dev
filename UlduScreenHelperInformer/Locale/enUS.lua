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
L["ITEMNAME_FragmentValanyr"] = "Fragment of Val'anyr"


L["ZONENAME_Ulduar"] = "Ulduar"
L["ZONENAME_SubAntechamber"] = "The Antechamber"
L["ZONENAME_SubKologarn"] = "The Shattered Walkway"
L["ZONENAME_SubFreya"] = "The Conservatory of Life"
L["ZONENAME_SubThorim"] = "The Clash of Thunder"
L["ZONENAME_SubHodir"] = "The Halls of Winter"
L["ZONENAME_SubMimiron"] = "The Spark of Imagination"


L["BOSSNAME_FlameLeviathan"] = "Flame Leviathan"
L["BOSSNAME_Ignis"] = "Ignis the Furnace Master"
L["BOSSNAME_Razorscale"] = "Razorscale"
L["BOSSNAME_XT002"] = "XT-002 Deconstructor"

L["BOSSNAME_AssemblyIron"] = "Assembly of Iron"
L["BOSSNAME_Steelbreaker"] = "Steelbreaker"
L["BOSSNAME_RunemasterMolgeim"] = "Runemaster Molgeim"
L["BOSSNAME_StormcallerBrundir"] = "Stormcaller Brundir"
L["BOSSNAME_Kologarn"] = "Kologarn"
L["BOSSNAME_Algalon"] = "Algalon the Observer"

L["BOSSNAME_Auriaya"] = "Auriaya"
L["BOSSNAME_Freya"] = "Freya"
L["BOSSNAME_Thorim"] = "Thorim"
L["BOSSNAME_Hodir"] = "Hodir"
L["BOSSNAME_Mimiron"] = "Mimiron"

L["BOSSNAME_GeneralVezax"] = "General Vezax"
L["BOSSNAME_YoggSaron"] = "Yogg-Saron"
