local L = LibStub("AceLocale-3.0"):GetLocale("UlduScreenHelperInformer", true)

local ADDON_NAME, addonTable = ...;



addonTable.setting_defaults = {
	addon_active = true,
	-- chat_output = true,
	useChatFrame = 0, --default chat frame
	outputEnable = 4, -- default to BOTH
	chooseCreateScreenOn = 3, -- for selected bosses/trigger
	chooseCreateEntryOn = 3, -- for every boss/trigger
	screen_trigger = {
		[L["BOSSNAME_FlameLeviathan"]] = nil,
		[L["BOSSNAME_Ignis"]] = nil,
		[L["BOSSNAME_Razorscale"]] = nil,
		[L["BOSSNAME_XT002"]] = true,
		[L["BOSSNAME_AssemblyIron"]] = nil,
		[L["BOSSNAME_Kologarn"]] = nil,
		[L["BOSSNAME_Algalon"]] = true,
		[L["BOSSNAME_Auriaya"]] = nil,
		[L["BOSSNAME_Freya"]] = nil,
		[L["BOSSNAME_Thorim"]] = nil,
		[L["BOSSNAME_Hodir"]] = nil,
		[L["BOSSNAME_Mimiron"]] = nil,
		[L["BOSSNAME_GeneralVezax"]] = nil,
		[L["BOSSNAME_YoggSaron"]] = true,
		[L["ITEMNAME_FragmentValanyr"]] = true,
		[L["ITEMNAME_MimironsHead"]] = true,
	},
}

-----------------------------------
--  ID-List of trackable Bosses  --
-----------------------------------
addonTable.BossIDList = {
	-- [4076] = "Schabe",
	-- [2110] = "Schwarze Ratte",
	-- [721] = "Kaninchen Ratte",
	-- [1412] = "Eichhörnchen",
	-- [32498] = "Gletscherpinguin",
	
    -- [34797] = "Icehowl",
    -- [34780] = "Lord Jaraxxus",
    -- [34564] = "Anub'arak",    
    -- [31125] = "Archavon the Stone Watcher",
    -- [33993] = "Emalon the Storm Watcher",
    -- [35013] = "Koralon the Flame Watcher",
    -- [38433] = "Toravon the Ice Watcher",
    -- [1010818] = "Halion",
    -- [40142] = "Halion",
    -- [39863] = "Halion",
    -- [39751] = "Baltharus",
    -- [39899] = "Baltharus",
    -- [39747] = "Saviana ",
    -- [39746] = "Zarithrian ",

    [33113] = "BOSSNAME_FlameLeviathan",
    [33118] = "BOSSNAME_Ignis",
    [33186] = "BOSSNAME_Razorscale",
    [33293] = "BOSSNAME_XT002",
        -- The Assembly of Iron will need bossyell for correct tracking
    [32930] = "BOSSNAME_Kologarn",
    [34297] = "BOSSNAME_Kologarn",-- there is a second id used, for some reason
    [33515] = "BOSSNAME_Auriaya",
        -- Freya, Hodir, Mimiron and Thorim will need bossyells - they don't die
    [33271] = "BOSSNAME_GeneralVezax",
    [33288] = "BOSSNAME_YoggSaron",
        -- Algalon needs a bossyell - he doesn't die
}


addonTable.ItemIDList_Screenshot = {
	[45038] = "ITEMNAME_FragmentValanyr",
	[45693] = "ITEMNAME_MimironsHead",
	-- [43102] = "Frozen Orb",
	-- [36912] = "Saronite Ore",
}

addonTable.IronCouncilNames = {
	[L["BOSSNAME_Steelbreaker"]] =  	L["BOSSNAME_AssemblyIron"],
	[L["BOSSNAME_RunemasterMolgeim"]] = L["BOSSNAME_AssemblyIron"],
	[L["BOSSNAME_StormcallerBrundir"]] = L["BOSSNAME_AssemblyIron"], 
}
	
addonTable.BossSubZoneList = {
	[L["BOSSNAME_Steelbreaker"]] =  	L["ZONENAME_SubAssemblyIron"],
	[L["BOSSNAME_RunemasterMolgeim"]] = L["ZONENAME_SubAssemblyIron"],
	[L["BOSSNAME_StormcallerBrundir"]] = L["ZONENAME_SubAssemblyIron"],
	
	-- [L["BOSSNAME_Freya"]] =  L["ZONENAME_SubFreya"],	--fixed
	-- [L["BOSSNAME_Thorim"]] = L["ZONENAME_SubThorim"],	-- unused
	-- [L["BOSSNAME_Hodir"]] =  L["ZONENAME_SubHodir"],	-- unused
	
	-- [L["BOSSNAME_Mimiron"]] = L["ZONENAME_SubMimiron"],	-- unused
	-- [L["BOSSNAME_Mimiron_Computer"]] = L["ZONENAME_SubMimiron"],	-- unused
}

-- List of Bosses for which we have to use their Defeat Yell
addonTable.BossDefeatYellList = {
	-- [L["BOSSNAME_Steelbreaker"]] =  	L["BOSSYELL_Steelbreaker_end_trigger"],
	-- [L["BOSSNAME_RunemasterMolgeim"]] = L["BOSSYELL_RunemasterMolgeim_end_trigger"],
	-- [L["BOSSNAME_StormcallerBrundir"]] = L["BOSSYELL_StormcallerBrundir_end_trigger"],
	
	[L["BOSSNAME_Freya"]] =  L["BOSSYELL_Freya_end_trigger"],	-- BUGGY auf RG! --fixed
	[L["BOSSNAME_Thorim"]] = L["BOSSYELL_Thorim_end_trigger"],
	[L["BOSSNAME_Hodir"]] =  L["BOSSYELL_Hodir_end_trigger"],
	[L["BOSSNAME_Mimiron"]] = L["BOSSYELL_Mimiron_end_trigger"],
	
	[L["BOSSNAME_Algalon"]] = L["BOSSYELL_Algalon_end_trigger"],
}

addonTable.IconList = {
	["Default"] = 					"Interface\\Icons\\".."inv_misc_questionmark",
	[L["ITEMNAME_MimironsHead"]] = 	"Interface\\Icons\\".."inv_misc_enggizmos_03",
	[L["ITEMNAME_FragmentValanyr"]] = "Interface\\Icons\\".."inv_ingot_titansteel_red",
	
	[L["BOSSNAME_FlameLeviathan"]] = "Interface\\Icons\\".."ability_vehicle_siegeenginecharge", --"inv_misc_wrench_02" --"achievement_boss_theflameleviathan_01",
	[L["BOSSNAME_Ignis"]] = 		"Interface\\Icons\\".."spell_fire_immolation", --"achievement_boss_ignis_01",
	[L["BOSSNAME_Razorscale"]] = 	"Interface\\Icons\\".."ability_mount_razorscale", --"achievement_boss_razorscale",
	[L["BOSSNAME_XT002"]] = 		"Interface\\Icons\\".."spell_brokenheart", --"achievement_boss_xt002deconstructor_01",
	[L["BOSSNAME_AssemblyIron"]] = 	"Interface\\Icons\\".."achievement_boss_theironcouncil_01", --"achievement_dungeon_ulduarraid_irondwarf_01",
	[L["BOSSNAME_Steelbreaker"]] = 	"Interface\\Icons\\".."achievement_boss_theironcouncil_01", --"achievement_dungeon_ulduarraid_irondwarf_01",
	[L["BOSSNAME_RunemasterMolgeim"]] = "Interface\\Icons\\".."achievement_boss_theironcouncil_01", --"achievement_dungeon_ulduarraid_irondwarf_01",
	[L["BOSSNAME_StormcallerBrundir"]] = "Interface\\Icons\\".."achievement_boss_theironcouncil_01", --"achievement_dungeon_ulduarraid_irondwarf_01",
	[L["BOSSNAME_Kologarn"]] = 		"Interface\\Icons\\".."inv_elemental_primal_earth", --"achievement_boss_kologarn_01",
	[L["BOSSNAME_Algalon"]] = 		"Interface\\Icons\\".."achievement_boss_algalon_01", --"achievement_boss_algalon_01",
	[L["BOSSNAME_Auriaya"]] = 		"Interface\\Icons\\".."ability_mount_blackpanther", --"achievement_boss_auriaya_01",
	[L["BOSSNAME_Freya"]] = 		"Interface\\Icons\\".."inv_sigil_freya", --"achievement_boss_freya_01",
	[L["BOSSNAME_Thorim"]] = 		"Interface\\Icons\\".."inv_sigil_thorim", --"achievement_boss_thorim",
	[L["BOSSNAME_Hodir"]] = 		"Interface\\Icons\\".."inv_sigil_hodir", --"achievement_boss_hodir_01",
	[L["BOSSNAME_Mimiron"]] = 		"Interface\\Icons\\".."inv_sigil_mimiron", --"achievement_boss_mimiron_01",
	[L["BOSSNAME_GeneralVezax"]] = 	"Interface\\Icons\\".."inv_misc_ahnqirajtrinket_05", --"achievement_boss_generalvezax_01",
	[L["BOSSNAME_YoggSaron"]] = 	"Interface\\Icons\\".."spell_shadow_shadesofdarkness", --"achievement_boss_yoggsaron_01"
}

do
	local t_now, key_time
	local t1 = date("*t", time())
	local t2 = date("*t", time()+111)
	local t3 = date("*t", time()+333)
	addonTable.TestDBEntry = {}
	
	t_now = t1
	addonTable.TestDBEntry["key"] = string.format("%d W%02d: %d", t_now.year, math.ceil( t_now.yday / 7 ), -1)
	
	t_now = t1
	key_time = string.format("%d-%02d-%02d %02d:%02d:%02d", t_now.year, t_now.month, t_now.day, t_now.hour, t_now.min, t_now.sec)
	addonTable.TestDBEntry[1] = {
		["trigger-type"] = "Bosskill",
		["trigger-text"] = L["BOSSNAME_XT002"],
		["raidlead"] = "shadowcrag",
		["ID"] = -1,
		["timestamp"] = key_time,
		["icon"] = "Interface\\Icons\\spell_brokenheart",
		["raid"] = {
			["GROUP1"] = {
				"mountainscar (Offline)", -- [1]
				"shadowcrag", -- [2]
				"spiritsprinter", -- [3]
				"flamewillow", -- [4]
				"warriver", -- [5]
			},
			["GROUP2"] = {
				"silverdream (Offline)", -- [1]
				"wolfshade", -- [2]
				"bluescar", -- [3]
				"shieldeyes (Offline)", -- [4]
				"commoncrest (Offline)", -- [5]
			},
			["GROUP3"] = {
				"clawsnow", -- [1]
				"mountainheart", -- [2]
				"cliffbrace", -- [3]
				"regaldown", -- [4]
				"autumngrain", -- [5]
			},
			["GROUP4"] = {
				"leafwalker", -- [1]
				"tuskshadow", -- [2]
				"slatesteel", -- [3]
				"greenstriker", -- [4]
				"twoglade", -- [5]
			},
			["GROUP5"] = {
				"leafkiller", -- [1]
				"chestorb", -- [2]
				"havengrain", -- [3]
				"grassdane", -- [4]
				"regalblood", -- [5]
			},
			["GROUP8"] = {
				"fistgrove (Offline)", -- [1]
				"cleareyes (Offline)", -- [2]
				"autumnbough (Offline)", -- [3]
			},
		},
	}
	
	t_now = t2
	key_time = string.format("%d-%02d-%02d %02d:%02d:%02d", t_now.year, t_now.month, t_now.day, t_now.hour, t_now.min, t_now.sec)
	addonTable.TestDBEntry[2] = {
		["trigger-type"] = "Loot",
		["trigger-text"] = L["ITEMNAME_FragmentValanyr"]..": wolfshade",
		["raidlead"] = "shadowcrag",
		["ID"] = -1,
		["timestamp"] = key_time,
		["icon"] = "Interface\\Icons\\inv_ingot_titansteel_red",
		["raid"] = {
			["GROUP1"] = {
				"mountainscar (Offline)", -- [1]
				"shadowcrag", -- [2]
				"spiritsprinter", -- [3]
				"flamewillow", -- [4]
				"warriver", -- [5]
			},
			["GROUP2"] = {
				"wolfshade", -- [2]
				"bluescar", -- [3]
				"fisthammer", -- [3]
			},
			["GROUP3"] = {
				"clawsnow", -- [1]
				"mountainheart", -- [2]
				"regaldown", -- [4]
				"autumngrain", -- [5]
				"hellbraid", -- [5]
			},
			["GROUP4"] = {
				"leafwalker", -- [1]
				"slatesteel", -- [3]
				"greenstriker", -- [4]
				"twoglade", -- [5]
				"horsefollower", -- [5]
			},
			["GROUP5"] = {
				"leafkiller", -- [1]
				"havengrain", -- [3]
				"grassdane", -- [4]
				"frostbleeder", -- [5]
			},
			["GROUP8"] = {
				"steelsnout (Offline)", -- [1]
				"cleareyes (Offline)", -- [2]
			},
		},
	}
	
	t_now = t3
	key_time = string.format("%d-%02d-%02d %02d:%02d:%02d", t_now.year, t_now.month, t_now.day, t_now.hour, t_now.min, t_now.sec)
	addonTable.TestDBEntry[3] = {
		["trigger-type"] = "Bosskill",
		["trigger-text"] = L["BOSSNAME_Hodir"],
		["raidlead"] = "shadowcrag",
		["ID"] = -1,
		["timestamp"] = key_time,
		["icon"] = "Interface\\Icons\\inv_sigil_hodir",
		["raid"] = {
			["GROUP1"] = {
				"flintdust", -- [1]
				"shadowcrag", -- [2]
				"spiritsprinter", -- [3]
				"warriver", -- [4]
			},
			["GROUP2"] = {
				"wolfshade", -- [2]
				"bluescar", -- [3]
				"rosefury", -- [4]
			},
			["GROUP3"] = {
				"mountainheart", -- [2]
				"cliffbrace", -- [3]
				"regaldown", -- [4]
				"autumngrain", -- [5]
				"alpendream", -- [5]
			},
			["GROUP4"] = {
				"leafwalker", -- [1]
				"tuskshadow", -- [2]
				"slatesteel (Offline)", -- [3]
				"greenstriker", -- [4]
				"twoglade", -- [5]
			},
			["GROUP5"] = {
				"leafkiller", -- [1]
				"havengrain", -- [3]
				"regalblood", -- [5]
			},
		},
	}
end