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
    [34297] = "Kologarn",
    [33515] = "Auriaya",
        -- Freya, Hodir, Mimiron and Thorim will need bossyells - they don't die
    [33271] = "General Vezax",
    [33288] = "Yogg-Saron",
        -- Algalon needs a bossyell - he doesn't die
}

addonTable.UlduarSubZoneList = {
	["Das Konservatorium des Lebens"]
}

addonTable.IconList = {
    ["Default"] = 					"Interface\\Icons\\".."inv_misc_questionmark",
    ["Fragment of Val'anyr"] = 		"Interface\\Icons\\".."inv_ingot_titansteel_red",
    ["Flame Leviathan"] = 			"Interface\\Icons\\".."ability_vehicle_siegeenginecharge",--"inv_misc_wrench_02", --"achievement_boss_theflameleviathan_01",
    ["Ignis the Furnace Master"] = 	"Interface\\Icons\\".."spell_fire_immolation", --"achievement_boss_ignis_01",
    ["Razorscale"] = 				"Interface\\Icons\\".."ability_mount_razorscale",--"achievement_boss_razorscale",
	["XT-002 Deconstructor"] = 		"Interface\\Icons\\".."spell_brokenheart",--"achievement_boss_xt002deconstructor_01",
	["Assembly of Iron"] = 			"Interface\\Icons\\".."achievement_boss_theironcouncil_01", --"achievement_dungeon_ulduarraid_irondwarf_01",
	["Kologarn"] = 					"Interface\\Icons\\".."inv_elemental_primal_earth",--"achievement_boss_kologarn_01",
	["Algalon the Observer"] = 		"Interface\\Icons\\".."achievement_boss_algalon_01",--"achievement_boss_algalon_01",
	["Auriaya"] = 					"Interface\\Icons\\".."ability_mount_blackpanther",--"achievement_boss_auriaya_01",
	["Freya"] = 					"Interface\\Icons\\".."inv_sigil_freya",--"achievement_boss_freya_01",
	["Thorim"] = 					"Interface\\Icons\\".."inv_sigil_thorim",--"achievement_boss_thorim",
	["Hodir"] = 					"Interface\\Icons\\".."inv_sigil_hodir",--"achievement_boss_hodir_01",
	["Mimiron"] = 					"Interface\\Icons\\".."inv_sigil_mimiron",--"achievement_boss_mimiron_01",
	["General Vezax"] = 			"Interface\\Icons\\".."inv_misc_ahnqirajtrinket_05",--"achievement_boss_generalvezax_01",
	["Yogg-Saron"] = 				"Interface\\Icons\\".."spell_shadow_shadesofdarkness",--"achievement_boss_yoggsaron_01",
}


addonTable.ItemIDList = {
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

