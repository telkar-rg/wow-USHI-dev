local ADDON_NAME, addonTable = ...;

local ADDON_NAME, addonTable = ...;

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)
if not L then return end

local SPACES = "     "
local RAIDLIMITED = "The Addon observes triggers for Screenshots or Informer Entries only in ".."|c"..addonTable.ColorList["ORANGE"].."Ulduar (25)|r."

L["Informer Entries"] = true

L["DESC_OPTION_label_about"] = RAIDLIMITED

L["DESC_OPTION_header_saveToChar"] = "Character Settings"
L["DESC_OPTION_header_saveToGlobal"] = "Global Settings"

L["Enable Addon"] = "Enable USHI"
L["DESC_OPTION_enable_addon"] = "Enable or disable the Addon)"

L["DESC_OPTION_slider_desc"] = "Select the chat frame in which the addon will output to"
L["DESC_OPTION_slider_useChatDEFAULT"] = "Default chat frame"
L["DESC_OPTION_slider_useChatFrame"] = "Chat frame "
L["DESC_OPTION_slider_hereIs_frame"] = "Here is "

L["Display Timestamp and Trigger"] = true
L["DESC_OPTION_drop_outputEnable"] = "Set how the timestamp and trigger source are displayed when a trigger is detected\n".."|c"..addonTable.ColorList["GRAY"].."(* If an Informer Entry but no Screenshot is created, then this will not be displayed on Screen)|r"
L["DESC_OPTION_dd_disabled"] = "Deactivated"
L["DESC_OPTION_dd_inChat"] = "in Chat Window"
L["DESC_OPTION_dd_onScreen"] = "on Screen*"
L["DESC_OPTION_dd_Chat&Screen"] = "Chat Window & Screen*"

L["Create Screenshots for"] = "Create Screenshots for"
L["DESC_OPTION_drop_chooseCreateScreenOn"] = "Set when Screenshots shall be created"
L["Create Informer Entries for"] = "Create Informer Entries for"
L["DESC_OPTION_drop_chooseCreateEntryOn"] = "Set when an Informer Entry shall be created"
L["DESC_OPTION_dd_never"] = "Never"
L["DESC_OPTION_dd_selectedTrigger"] = "Selected Triggers"
L["DESC_OPTION_dd_everyTrigger"] = "Every Trigger"

L["Chat output"] = true
L["DESC_OPTION_chat_output"] = "Toggles the output of time stamp and trigger reason"
L["Screenshot Triggers"] = true
L["Trigger"] = true
L["Triggers"] = true

L["DESC_OPTION_trigger_boss_prefix"] = "Defeat of "
L["Fragment looting"] = "|c"..addonTable.ColorList["ORANGE"].."Fragment looting".."|r"
L["DESC_OPTION_trigger_val_drop"] = "Looting of Fragment of Val'anyr"
L["Mimirons Head looting"] = "|c"..addonTable.ColorList["PURPLE"].."Mimiron's Head looting".."|r"
L["DESC_OPTION_trigger_mimi_drop"] = "Looting of Mimiron's Head"


L["Raidlead"] = true
L["Raidweek"] = true
L["Bosskills"] = true
L["Fragments"] = true

L["Mark and Copy"] = true
L["Delete Entry"] = true
L["Delete Raidweek"] = true

L["DESC_noSavedRaids"] = "Currently there are no saved raids to show."

-- about panel
L["PANEL_ABOUT_text"] = "|c"..addonTable.ColorList["ORANGE"].."Ulduar Screenshot Helper & Informer (USHI)|r serves to aid in attendance management in Ulduar raids. For certain triggers (boss kills or loot distribution) a Screenshot or Informer Entry can be created automatically. Informer Entries contain the attending characters and can be copied as text.".."\n\n"..RAIDLIMITED;
L["PANEL_ABOUT_header_chatCommands"] = "Chat Commands"
L["Commands"] = true
L["Unknown Command"] = true
L["PANEL_ABOUT_chatCommand_1"] = "[".."|c"..addonTable.ColorList["COL_USHI"].."/ushi|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi o|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi options|r]:\n"..SPACES.."Opens the Settings Panel"
L["PANEL_ABOUT_chatCommand_2"] = "[".."|c"..addonTable.ColorList["COL_USHI"].."/ushi i|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi info|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi informer|r]:\n"..SPACES.."Opens the Informer Panel"
L["PANEL_ABOUT_chatCommand_3"] = "[".."|c"..addonTable.ColorList["COL_USHI"].."/ushi ?|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi help|r], [".."|c"..addonTable.ColorList["COL_USHI"].."/ushi about|r]:\n"..SPACES.."Opens the About Panel"
L["PANEL_ABOUT_text_2"] = (
	"Author: Telkar (Rising Gods, 2021)".."\n"..
	"Version: "..addonTable.ADDON_VERSION.."\n".."\n"..
	'The necessary Know-How to create this Addon was gained by analyzing the Addons "MizusRaidTracker" and "ReagentRestocker".'
);



-- Ulduar 
L["ITEMNAME_FragmentValanyr"] = "Fragment of Val'anyr"
L["ITEMNAME_MimironsHead"] = "Mimiron's Head"


L["ZONENAME_Ulduar"] = "Ulduar"
L["ZONENAME_SubAntechamber"] = "The Antechamber"
L["ZONENAME_SubAssemblyIron"] = "The Assembly of Iron" --
L["ZONENAME_SubKologarn"] = "The Shattered Walkway"
L["ZONENAME_SubFreya"] = "The Conservatory of Life" --
L["ZONENAME_SubThorim"] = "The Clash of Thunder" --
L["ZONENAME_SubHodir"] = "The Halls of Winter" --
L["ZONENAME_SubMimiron"] = "The Spark of Imagination" --
L["ZONENAME_SubAlgalon"] = "The Celestial Planetarium" --


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
L["BOSSNAME_Mimiron_Computer"] = "Computer"

L["BOSSNAME_GeneralVezax"] = "General Vezax"
L["BOSSNAME_YoggSaron"] = "Yogg-Saron"


L["BOSSYELL_Algalon_engage_trigger"] = "Your actions are illogical. All possible results for this encounter have been calculated. The Pantheon will receive the Observer's message regardless of outcome."
L["BOSSYELL_Algalon_end_trigger"] = "I have seen worlds bathed in the Makers' flames."

L["BOSSYELL_Steelbreaker_engage_trigger"] = "You will not defeat the Assembly of Iron so easily, invaders!"
L["BOSSYELL_RunemasterMolgeim_engage_trigger"] = "Nothing short of total decimation will suffice."
L["BOSSYELL_StormcallerBrundir_engage_trigger"] = "Whether the world's greatest gnats or the world's greatest heroes, you are still only mortal."
L["BOSSYELL_Steelbreaker_end_trigger"] = "Impossible..." -- Hardmode - Steelbreaker last
L["BOSSYELL_RunemasterMolgeim_end_trigger"] = "^What have you gained from my defeat?" -- Semi-Hardmode - Runemaster Molgeim last
L["BOSSYELL_StormcallerBrundir_end_trigger"] = "You rush headlong into the maw of madness!" -- Normalmode - Stormcaller Brundir last

L["BOSSYELL_Freya_engage_trigger1"] = "The Conservatory must be protected!"
L["BOSSYELL_Freya_engage_trigger2"] = "Elders grant me your strength!"
L["BOSSYELL_Freya_conservator_trigger"] = "Eonar, your servant requires aid!"
L["BOSSYELL_Freya_detonate_trigger"] = "The swarm of the elements shall overtake you!"
L["BOSSYELL_Freya_elementals_trigger"] = "Children, assist me!"
L["BOSSYELL_Freya_tree_trigger"] = "A |cFF00FFFFLifebinder's Gift|r begins to grow!"
L["BOSSYELL_Freya_end_trigger"] = "His hold on me dissipates. I can see clearly once more. Thank you, heroes."

L["BOSSYELL_Hodir_engage_trigger"] = "You will suffer for this trespass!"
L["BOSSYELL_Hodir_end_trigger"] = "I... I am released from his grasp... at last."

L["BOSSYELL_Mimiron_engage_trigger"] = "^We haven't much time, friends!"
L["BOSSYELL_Mimiron_phase2_trigger"] = "^WONDERFUL! Positively marvelous results!"
L["BOSSYELL_Mimiron_phase3_trigger"] = "^Thank you, friends!"
L["BOSSYELL_Mimiron_phase4_trigger"] = "^Preliminary testing phase complete"
L["BOSSYELL_Mimiron_hardmode_trigger"] = "^Now, why would you go and do something like that?"
L["BOSSYELL_Mimiron_end_trigger"] = "^It would appear that I've made a slight miscalculation."

L["BOSSYELL_Thorim_phase2_trigger"] = "Interlopers! You mortals who dare to interfere with my sport will pay.... Wait--you..."
L["BOSSYELL_Thorim_phase3_trigger"] = "Impertinent whelps, you dare challenge me atop my pedestal? I will crush you myself!"
L["BOSSYELL_Thorim_end_trigger"] = "Stay your arms! I yield!"

