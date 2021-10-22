local L = LibStub("AceLocale-3.0"):GetLocale("UlduScreenHelperInformer", true)

local ADDON_NAME, addonTable = ...;

addonTable.ADDON_NAME_LONG = 	"Ulduar Screenshot Helper & Informer"
addonTable.ADDON_NAME_SHORT = 	"USHI"
addonTable.ADDON_VERSION = 		"1.1"

addonTable.setting_defaults = {
	addon_active = true,
	chat_output = true,
	screen_trigger = {
		FlameLevi = false,
		Ignis = false,
		Razorscale = false,
		XT002 = true,
		AssemblyIron = false,
		Kologarn = false,
		Algalon = true,
		Auriaya = false,
		Freya = false,
		Thorim = false,
		Hodir = false,
		Mimiron = false,
		Vezax = false,
		Yogg = true,
		val_drop = true,
	},
}

-----------------------------------
--  ID-List of trackable Bosses  --
-----------------------------------
addonTable.BossIDList = {
	[4076] = "Schabe",
	[2110] = "Schwarze Ratte",
	[721] = "Kaninchen Ratte",
	[1412] = "Eichhörnchen",
	[32498] = "Gletscherpinguin",

    [33113] = "Flame Leviathan",
    [33118] = "Ignis the Furnace Master",
    [33186] = "Razorscale",
    [33293] = "XT-002 Deconstructor",
        -- The Assembly of Iron will need bossyell for correct tracking
    [32930] = "Kologarn",
    [34297] = "Kologarn",-- there is a second id used, for some reason
    [33515] = "Auriaya",
        -- Freya, Hodir, Mimiron and Thorim will need bossyells - they don't die
    [33271] = "General Vezax",
    [33288] = "Yogg-Saron",
        -- Algalon needs a bossyell - he doesn't die
}
addonTable.BossSubZoneList = {
	[L["BOSSNAME_Freya"]] =  L["ZONENAME_SubFreya"],
	[L["BOSSNAME_Thorim"]] = L["ZONENAME_SubThorim"],
	[L["BOSSNAME_Hodir"]] =  L["ZONENAME_SubHodir"],
	[L["BOSSNAME_Mimiron"]] = L["ZONENAME_SubMimiron"],
	-- ["Malygos"] = "Auge der Ewigkeit",
	-- ["Kael'thas Sonnenwanderer"] = "Auge der Ewigkeit",
}

addonTable.IconList = {}
addonTable.IconList["Default"] = 					"Interface\\Icons\\".."inv_misc_questionmark"
addonTable.IconList[L["ITEMNAME_FragmentValanyr"]] = "Interface\\Icons\\".."inv_ingot_titansteel_red"
addonTable.IconList[L["BOSSNAME_FlameLeviathan"]] = "Interface\\Icons\\".."ability_vehicle_siegeenginecharge" --"inv_misc_wrench_02" --"achievement_boss_theflameleviathan_01"
addonTable.IconList[L["BOSSNAME_Ignis"]] = 			"Interface\\Icons\\".."spell_fire_immolation" --"achievement_boss_ignis_01"
addonTable.IconList[L["BOSSNAME_Razorscale"]] = 	"Interface\\Icons\\".."ability_mount_razorscale" --"achievement_boss_razorscale"
addonTable.IconList[L["BOSSNAME_XT002"]] = 			"Interface\\Icons\\".."spell_brokenheart" --"achievement_boss_xt002deconstructor_01"
addonTable.IconList[L["BOSSNAME_AssemblyIron"]] = 	"Interface\\Icons\\".."achievement_boss_theironcouncil_01" --"achievement_dungeon_ulduarraid_irondwarf_01"
addonTable.IconList[L["BOSSNAME_Kologarn"]] = 		"Interface\\Icons\\".."inv_elemental_primal_earth" --"achievement_boss_kologarn_01"
addonTable.IconList[L["BOSSNAME_Algalon"]] = 		"Interface\\Icons\\".."achievement_boss_algalon_01" --"achievement_boss_algalon_01"
addonTable.IconList[L["BOSSNAME_Auriaya"]] = 		"Interface\\Icons\\".."ability_mount_blackpanther" --"achievement_boss_auriaya_01"
addonTable.IconList[L["BOSSNAME_Freya"]] = 			"Interface\\Icons\\".."inv_sigil_freya" --"achievement_boss_freya_01"
addonTable.IconList[L["BOSSNAME_Thorim"]] = 		"Interface\\Icons\\".."inv_sigil_thorim" --"achievement_boss_thorim"
addonTable.IconList[L["BOSSNAME_Hodir"]] = 			"Interface\\Icons\\".."inv_sigil_hodir" --"achievement_boss_hodir_01"
addonTable.IconList[L["BOSSNAME_Mimiron"]] = 		"Interface\\Icons\\".."inv_sigil_mimiron" --"achievement_boss_mimiron_01"
addonTable.IconList[L["BOSSNAME_GeneralVezax"]] = 	"Interface\\Icons\\".."inv_misc_ahnqirajtrinket_05" --"achievement_boss_generalvezax_01"
addonTable.IconList[L["BOSSNAME_YoggSaron"]] = 		"Interface\\Icons\\".."spell_shadow_shadesofdarkness" --"achievement_boss_yoggsaron_01"



addonTable.ItemIDList_SubZoneBoss = {
	-- [29434] = "Emblem der Gerechtigkeit",
	[47241] = "Emblem of Triumph",
}
addonTable.ItemIDList_Screenshot = {
	[45038] = "Val'anyr Fragment",
	[43102] = "Frozen Orb",
	-- [36912] = "Saronite Ore",
}

addonTable.ColorList = {
	["WHITE"] =		"ff".."ffffff",
	["BLACK"] =		"ff".."000000",
	["GRAY"] =		"ff".."aaaaaa",
	["BLUE"] =		"ff".."0000ff",
	["BLUE_LIGHT"] ="ff".."44aaff",
}

