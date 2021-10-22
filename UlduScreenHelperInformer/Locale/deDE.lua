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
L["Fragment looting"] = ORANGE.."Fragment Loot"
L["DESC_OPTION_trigger_val_drop"] = "Screenshot nach Zuteilen eines Fragments von Val'anyr"




-- Ulduar 
L["Ulduar"] = "Ulduar"

L["Flame Leviathan"] = "Flammenleviathan";
L["Ignis the Furnace Master"] = "Ignis, Meister des Eisenwerks";
L["Razorscale"] = "Klingenschuppe";
L["XT-002 Deconstructor"] = "XT-002 Dekonstruktor";

L["Assembly of Iron"] = "Versammlung des Eisens";
L["Steelbreaker"] = "Stahlbrecher";
L["Runemaster Molgeim"] = "Runenmeister Molgeim";
L["Stormcaller Brundir"] = "Sturmrufer Brundir";
L["Kologarn"] = "Kologarn";
L["Algalon the Observer"] = "Algalon der Beobachter";

L["Auriaya"] = "Auriaya";
L["Freya"] = "Freya";
L["Thorim"] = "Thorim";
L["Hodir"] = "Hodir";
L["Mimiron"] = "Mimiron";

L["General Vezax"] = "General Vezax";
L["Yogg-Saron"] = "Yogg-Saron";