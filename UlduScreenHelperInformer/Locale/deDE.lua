local ADDON_NAME, addonTable = ...;

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "deDE")
if not L then return end
local ORANGE = "|cffff9933"

L["Enable Addon"] = "Aktiviere USHI"
L["DESC_OPTION_enable_addon"] = "Ulduar Screenshot Helper aktivieren oder deaktivieren (pro Character gespeichert)"

L["Chat output"] = "Chat Ausgabe"
L["DESC_OPTION_chat_output"] = "Ein-/Ausschalten der Ausgabe von Zeitstempel und Auslösegrund"
L["Screenshot Triggers"] = "Screenshot Auslöser"

L["DESC_OPTION_trigger_boss_prefix"] = "Screenshot nach Besiegen von "
L["Fragment looting"] = ORANGE.."Fragment Loot".."|r"
L["DESC_OPTION_trigger_val_drop"] = "Screenshot nach Zuteilen eines Fragment von Val'anyr"




-- Ulduar 
L["ITEMNAME_FragmentValanyr"] = "Fragment von Val'anyr"


L["ZONENAME_Ulduar"] = "Ulduar"
L["ZONENAME_SubAntechamber"] = "Die Vorkammer"
L["ZONENAME_SubKologarn"] = "Der zerschmetterte Gang"
L["ZONENAME_SubFreya"] = "Das Konservatorium des Lebens"
L["ZONENAME_SubThorim"] = "Der Donnerschlag"
L["ZONENAME_SubHodir"] = "Die Hallen des Winters"
L["ZONENAME_SubMimiron"] = "Der Funke der Imagination"


L["BOSSNAME_FlameLeviathan"] = "Flammenleviathan";
L["BOSSNAME_Ignis"] = "Ignis, Meister des Eisenwerks";
L["BOSSNAME_Razorscale"] = "Klingenschuppe";
L["BOSSNAME_XT002"] = "XT-002 Dekonstruktor";

L["BOSSNAME_AssemblyIron"] = "Versammlung des Eisens";
L["BOSSNAME_Steelbreaker"] = "Stahlbrecher";
L["BOSSNAME_RunemasterMolgeim"] = "Runenmeister Molgeim";
L["BOSSNAME_StormcallerBrundir"] = "Sturmrufer Brundir";
L["BOSSNAME_Kologarn"] = "Kologarn";
L["BOSSNAME_Algalon"] = "Algalon der Beobachter";

L["BOSSNAME_Auriaya"] = "Auriaya";
L["BOSSNAME_Freya"] = "Freya";
L["BOSSNAME_Thorim"] = "Thorim";
L["BOSSNAME_Hodir"] = "Hodir";
L["BOSSNAME_Mimiron"] = "Mimiron";

L["BOSSNAME_GeneralVezax"] = "General Vezax";
L["BOSSNAME_YoggSaron"] = "Yogg-Saron";