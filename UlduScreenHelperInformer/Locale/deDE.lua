local ADDON_NAME, addonTable = ...;

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "deDE")
if not L then return end

local SPACES = "     "
local RAIDLIMITED = "Das Addon beobachtet die Trigger für Screenshots oder Informer Einträge ausschließlich in ".."|c"..addonTable.ColorList["ORANGE"].."Ulduar (25)|r."

L["Informer Entries"] = "Informer Einträge"

L["DESC_OPTION_label_about"] = RAIDLIMITED

L["DESC_OPTION_header_saveToChar"] = "Charakter Einstellungen"
L["DESC_OPTION_header_saveToGlobal"] = "Globale Einstellungen"

L["Enable Addon"] = "Aktiviere USHI"
L["DESC_OPTION_enable_addon"] = "Das Addon aktivieren oder deaktivieren"

L["DESC_OPTION_slider_desc"] = "Wähle das Chatfenster aus, in welchem das Addon ausgeben soll."
L["DESC_OPTION_slider_useChatDEFAULT"] = "Standard Chatfenster"
L["DESC_OPTION_slider_useChatFrame"] = "Chatfenster "
L["DESC_OPTION_slider_hereIs_frame"] = "Hier ist "

L["Display Timestamp and Trigger"] = "Zeige Zeitstempel und Trigger"
L["DESC_OPTION_drop_outputEnable"] = "Wähle wie Zeitstempel und Trigger-Grund angezeigt werden, wenn ein Trigger erkannt wurde\n".."|c"..addonTable.ColorList["GRAY"].."(* Wenn ein Informer Eintrag aber kein Screenshot erstellt wird, wird nicht am Bildschirm ausgegeben)|r"
L["DESC_OPTION_dd_disabled"] = "Deaktiviert"
L["DESC_OPTION_dd_inChat"] = "im Chatfenster"
L["DESC_OPTION_dd_onScreen"] = "am Bildschirm*"
L["DESC_OPTION_dd_Chat&Screen"] = "Chatfenster & Bildschirm*"

L["Create Screenshots for"] = "Erstelle Screenshots für"
L["DESC_OPTION_drop_chooseCreateScreenOn"] = "Wähle wann ein Screenshot erstellt werden soll"
L["Create Informer Entries for"] = "Erstelle Informer Einträge für"
L["DESC_OPTION_drop_chooseCreateEntryOn"] = "Wähle wann ein Informer Eintrag erstellt werden soll"
L["DESC_OPTION_dd_never"] = "Niemals"
L["DESC_OPTION_dd_selectedTrigger"] = "Ausgewählte Trigger"
L["DESC_OPTION_dd_everyTrigger"] = "Alle Trigger"



L["Trigger"] = true
L["Triggers"] = "Trigger"

L["DESC_OPTION_trigger_boss_prefix"] = "Besiegen von "
L["Fragment looting"] = "|c"..addonTable.ColorList["ORANGE"].."Fragment Loot".."|r"
L["DESC_OPTION_trigger_val_drop"] = "Zuteilen eines Fragment von Val'anyr"
L["Mimirons Head looting"] = "|c"..addonTable.ColorList["PURPLE"].."Mimirons Kopf looting".."|r"
L["DESC_OPTION_trigger_mimi_drop"] = "Zuteilen von Mimirons Kopf"


L["Raidlead"] = "Raidleitung"
L["Raidweek"] = "Raidwoche"
L["Bosskills"] = true
L["Fragments"] = "Fragmente"

L["Mark and Copy"] = "Markieren und Kopieren"
L["Delete Entry"] = "Lösche Eintrag"
L["Delete Raidweek"] = "Lösche Raidwoche"

L["DESC_noSavedRaids"] = "Derzeit gibt es keine gespeicherten Raids zum anzeigen."

-- about panel
L["PANEL_ABOUT_text"] = "|c"..addonTable.ColorList["ORANGE"].."Ulduar Screenshot Helper & Informer (USHI)|r dient zur Unterstützung von Anwesenheitsmanagement in Ulduar Raids. Bei entsprechenden Trigger (Bosskills oder Lootvergabe) kann automatisch ein Screenshot oder Informer Eintrag erstellt werden. Informer Einträge enthalten die anwesenden Charaktere und können als Text kopiert werden.".."\n\n"..RAIDLIMITED;
L["PANEL_ABOUT_header_chatCommands"] = "Chat Befehle";
L["Commands"] = "Befehle";
L["Unknown Command"] = "Unbekannter Befehl"
L["PANEL_ABOUT_chatCommand_1"] = "[".."|c"..addonTable.ColorList["COL_USHI"].."/ushi|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi o|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi options|r]:\n"..SPACES.."Öffnet das Einstellungs Panel"
L["PANEL_ABOUT_chatCommand_2"] = "[".."|c"..addonTable.ColorList["COL_USHI"].."/ushi i|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi info|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi informer|r]:\n"..SPACES.."Öffnet das Informer Panel"
L["PANEL_ABOUT_chatCommand_3"] = "[".."|c"..addonTable.ColorList["COL_USHI"].."/ushi ?|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi help|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi about|r]:\n"..SPACES.."Öffnet das About Panel"
L["PANEL_ABOUT_text_2"] = (
	"Author: Telkar (Rising Gods, 2021)".."\n"..
	"Version: "..addonTable.ADDON_VERSION.."\n".."\n"..
	'Das notwendige Codeverständnis zur Erstellung dieses Addons wurde erreicht durch Untersuchen der Addons "MizusRaidTracker" und "ReagentRestocker".'
);


-- Ulduar 
L["ITEMNAME_FragmentValanyr"] = "Fragment von Val'anyr"
L["ITEMNAME_MimironsHead"] = "Mimirons Kopf"


L["ZONENAME_Ulduar"] = "Ulduar"
L["ZONENAME_SubAntechamber"] = "Die Vorkammer"
L["ZONENAME_SubAssemblyIron"] = "Die Versammlung des Eisens" --
L["ZONENAME_SubKologarn"] = "Der zerschmetterte Gang"
L["ZONENAME_SubFreya"] = "Das Konservatorium des Lebens" --
L["ZONENAME_SubThorim"] = "Der Donnerschlag" --
L["ZONENAME_SubHodir"] = "Die Hallen des Winters" --
L["ZONENAME_SubMimiron"] = "Der Funke der Imagination" --
L["ZONENAME_SubAlgalon"] = "Das himmlische Planetarium" --


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
L["BOSSNAME_Mimiron_Computer"] = "Computer";

L["BOSSNAME_GeneralVezax"] = "General Vezax";
L["BOSSNAME_YoggSaron"] = "Yogg-Saron";