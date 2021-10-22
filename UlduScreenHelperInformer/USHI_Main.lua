UlduScreenHelperInformer = LibStub("AceAddon-3.0"):NewAddon("UlduScreenHelperInformer", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local addon = UlduScreenHelperInformer
local L = LibStub("AceLocale-3.0"):GetLocale("UlduScreenHelperInformer", true)
local deformat = 	LibStub("LibDeformat-3.0");
local AceConfig = 	LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB =		LibStub("AceDB-3.0")
local AceGUI = 		LibStub("AceGUI-3.0");

local tconcat, tostring, select = table.concat, tostring, select

local ADDON_NAME, addonTable = ...;
local defaults = 	addonTable.setting_defaults
local BossIDList = 	addonTable.BossIDList
local ItemIDList = 	addonTable.ItemIDList
local ColorList = 	addonTable.ColorList
local ADDON_NAME_LONG = 	addonTable.ADDON_NAME_LONG
local ADDON_NAME_SHORT = 	addonTable.ADDON_NAME_SHORT
local ADDON_VERSION = 		addonTable.ADDON_VERSION


local db_options, db_char, db_SI
local OptionsTable = {}
-- local Options_SI = {}


local bFrame
local myGroup
local selectTree
local Menu
local head
local temp_ref

function addon:OnInitialize()
    -- Called when the addon is loaded
	addon:GetDB()
	addon:test_fill_db_si()
	
    -- Register the options table
	self:CreateOptionsTable()
    AceConfig:RegisterOptionsTable("USHI-Table-1", OptionsTable.general)
    AceConfig:RegisterOptionsTable("USHI-Table-2", OptionsTable.screen_info)
    -- AceConfig:RegisterOptionsTable("USHI-Table-3", OptionsTable.screen_info2)
	
	-- Setup Blizzard option frames
	self.optionsFrames = {}
	-- The ordering here matters, it determines the order in the Blizzard Interface Options
	self.optionsFrames.general = 	AceConfigDialog:AddToBlizOptions("USHI-Table-1", ADDON_NAME_SHORT)
	self.optionsFrames.screen_info = AceConfigDialog:AddToBlizOptions("USHI-Table-2", "Screenshot Info",ADDON_NAME_SHORT)
	-- self.optionsFrames.screen_info2 = AceConfigDialog:AddToBlizOptions("USHI-Table-3", "Screenshot Info2",ADDON_NAME_SHORT)
	
	addon:testTree(ADDON_NAME_SHORT)
	-- self.optionsFrames.screen_info2 = AceConfigDialog:AddToBlizOptions(bFrame.frame, "Screenshot Info2",ADDON_NAME_SHORT)
	self.optionsFrames.screen_info2 = bFrame.frame
	temp_ref = self.optionsFrames.screen_info2.obj.children[1].children[1].tree[1]
	print("optionsFrames.screen_info2.obj.children[1].children[1].tree[1]",temp_ref)
	
	
	
	-- addon:RegisterEvent("ADDON_LOADED");
    addon:RegisterEvent("CHAT_MSG_LOOT","CheckChatForLoot");
    -- addon:RegisterEvent("CHAT_MSG_MONSTER_YELL");
    -- addon:RegisterEvent("CHAT_MSG_WHISPER");
    addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","CombatLogHandler");
    -- addon:RegisterEvent("PLAYER_ENTERING_WORLD");
    addon:RegisterEvent("RAID_INSTANCE_WELCOME", "OnRaidInstanceWelcome")
    -- addon:RegisterEvent("RAID_ROSTER_UPDATE");
	
	
	-- Register slash commands
	addon:RegisterChatCommand("ush", "OnSlashCommand")
end


function addon:testTree(parent)
	addon:PPrint("called addon:testTree(parent)")

	bFrame = AceGUI:Create("BlizOptionsGroup", "bFrame-Create");
	myGroup = AceGUI:Create("ScrollFrame", "myGroup-Create");
	selectTree = AceGUI:Create("TreeGroup");
	head = AceGUI:Create("Heading");
	
	-- BLIZZ options frame
	bFrame:SetName("bFrame-SetName", parent)
	bFrame:SetTitle(nil) --"bFrame-SetTitle"
	bFrame:SetLayout("Fill");
	
	-- Main Scroll Container Group in the BLIZZ options frame
	myGroup:SetFullWidth(true);
	myGroup:SetFullHeight(true);
	myGroup:SetLayout("Fill");
	
	Menu = {
		{
			text = "Shopping",
			value = "shop-value",
			func=function() print("FUNC!") end,
			children = {
				{
					text = "asdasda",
					value = "asdasdas-value",
				}
			}
		},
		{
			text = "Selling",
			value = "sell--value"
		},
		{
			text="Exceptions",
			value = "exclude-value"
		},
		{
			text = "Bank",
			value = "bank-value"
		},
		{
			text = "Repair",
			value = "repair-value"
		},
		{
			text = "Misc",
			value = "misc-value"
		},
		{
			text = "About",
			value = "about-value"
		},
	}
	
	-- tree widget
	selectTree:SetFullWidth(true);
	--selectTree:SetFullHeight(true);
	selectTree:SetLayout("List");
	selectTree:SetTree(Menu);

	

	head:SetFullWidth(true);
	head:SetText("test text header");
	selectTree:AddChild(head);
	
	-- selectTree:SetCallback("OnGroupSelected", function(group, event, id) Gnomexcel:PortWindow(id); end);
	selectTree:SetCallback("OnGroupSelected", function(_widget, _event, _uniquevalue)
		addon:TreeCallbackHandler(_widget, _event, _uniquevalue)
	end	)
	
	
	myGroup:AddChild(selectTree);

	bFrame:AddChild(myGroup);
	
	InterfaceOptions_AddCategory(bFrame.frame);
	
	
	self:RegisterChatCommand("ushi", "SlashCommandFunc")
end

function addon:TreeCallbackHandler(_widget, _event, _uniquevalue)

	print(" ")
	print("_widget",_widget);
	print("_event",_event);
	local id_separat = {("\001"):split(_uniquevalue)}
	
	-- print("_uniquevalue",":",id_separat[1],",",id_separat[2])
	print(string.gsub(_uniquevalue,"\001"," , "));
	
	selectTree:RefreshTree();

end



function addon:SlashCommandFunc()
	addon:PPrint("called the slash command!")
	addon:TreeUpdate()
	
	InterfaceOptionsFrame_OpenToCategory(bFrame.frame) 
	-- addon:test_table_sort()
end


function addon:OnEnable()
    -- Called when the addon is enabled
	-- print(ADDON_NAME)
	addon:PrintVersionState()
end

function addon:PrintVersionState()
	local addon_state
	if db_char.addon_active then
	-- "|cffaaaaaa"..tostring( ADDON_NAME_SHORT ).."|r:"
		addon_state = "|c"..ColorList["BLUE_LIGHT"].."active".."|r"
	else
		addon_state = "|c"..ColorList["GRAY"].."inactive".."|r"
	end
	addon:PPrint("Version",ADDON_VERSION,"(".. addon_state ..")")
end

function addon:OnDisable()
    -- Called when the addon is disabled
end



function addon:GetDB()
	self.db = AceDB:New("USHI_DB")
	if self.db.global == nil then self.db.global = {} end
	if self.db.global["OPTIONS"] == nil then self.db.global["OPTIONS"] = {} end
	if self.db.global["SCREEN INFO"] == nil then self.db.global["SCREEN INFO"] = {} end
	if self.db.char  == nil then self.db.char = {} end
	db_options = self.db.global["OPTIONS"]
	db_SI = self.db.global["SCREEN INFO"]
	db_char = self.db.char
	
	if db_char.addon_active == nil then 				db_char.addon_active = 					defaults.addon_active end
	if db_options.chat_output == nil then 				db_options.chat_output = 				defaults.chat_output end
	if db_options.screen_trigger == nil then 			db_options.screen_trigger = {} end
	if db_options.screen_trigger.FlameLevi == nil then 	db_options.screen_trigger.FlameLevi = 	defaults.screen_trigger.FlameLevi end
	if db_options.screen_trigger.Ignis == nil then 		db_options.screen_trigger.Ignis = 		defaults.screen_trigger.Ignis end
	if db_options.screen_trigger.Razorscale == nil then 	db_options.screen_trigger.Razorscale = defaults.screen_trigger.Razorscale end
	if db_options.screen_trigger.XT002 == nil then 		db_options.screen_trigger.XT002 = 		defaults.screen_trigger.XT002 end
	if db_options.screen_trigger.AssemblyIron == nil then 	db_options.screen_trigger.AssemblyIron = defaults.screen_trigger.AssemblyIron end
	if db_options.screen_trigger.Kologarn == nil then 	db_options.screen_trigger.Kologarn = 	defaults.screen_trigger.Kologarn end
	if db_options.screen_trigger.Algalon == nil then 	db_options.screen_trigger.Algalon = 	defaults.screen_trigger.Algalon end
	if db_options.screen_trigger.Auriaya == nil then 	db_options.screen_trigger.Auriaya = 	defaults.screen_trigger.Auriaya end
	if db_options.screen_trigger.Freya == nil then 		db_options.screen_trigger.Freya = 		defaults.screen_trigger.Freya end
	if db_options.screen_trigger.Thorim == nil then 	db_options.screen_trigger.Thorim = 		defaults.screen_trigger.Thorim end
	if db_options.screen_trigger.Hodir == nil then 		db_options.screen_trigger.Hodir = 		defaults.screen_trigger.Hodir end
	if db_options.screen_trigger.Mimiron == nil then 	db_options.screen_trigger.Mimiron = 	defaults.screen_trigger.Mimiron end
	if db_options.screen_trigger.Vezax == nil then 		db_options.screen_trigger.Vezax = 		defaults.screen_trigger.Vezax end
	if db_options.screen_trigger.Yogg == nil then 		db_options.screen_trigger.Yogg = 		defaults.screen_trigger.Yogg end
	if db_options.screen_trigger.val_drop == nil then 	db_options.screen_trigger.val_drop = 	defaults.screen_trigger.val_drop end
end

function addon:CreateOptionsTable()
	OptionsTable.general = {}
	OptionsTable.screen_info = {}
	OptionsTable.multiline_edit = {}


	OptionsTable.general = {
		name = ADDON_NAME_LONG,
		type = 'group',
		args = {
			addon_enable = {
				name = L["Enable Addon"],
				desc = L["DESC_OPTION_enable_addon"],
				type = "toggle",
				set = function(info,val) 
					db_char.addon_active = val 
					-- if v then addon:Enable() else addon:Disable() end
					addon:PrintVersionState()
				end,
				get = function(info) return db_char.addon_active end,
				order = 10
			},
			chat_output = {
				name = L["Chat output"],
				desc = L["DESC_OPTION_chat_output"],
				type = "toggle",
				set = function(info, val) db_options.chat_output = val end,
				get = function(info) return db_options.chat_output end,
				disabled = function() return not db_char.addon_active end,
				order = 15
			},
			
			displayheader_trigger = {
				order = 50,
				type = "header",
				name = L["Screenshot Triggers"],
			},
			trigger_boss_FlameLevi = {
				name = L["Flame Leviathan"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Flame Leviathan"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.FlameLevi = val end,
				get = function(info) return db_options.screen_trigger.FlameLevi end,
				disabled = function() return not db_char.addon_active end,
				order = 55
			},
			trigger_boss_Ignis = {
				name = L["Ignis the Furnace Master"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Ignis the Furnace Master"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Ignis = val end,
				get = function(info) return db_options.screen_trigger.Ignis end,
				disabled = function() return not db_char.addon_active end,
				order = 60
			},
			trigger_boss_Razorscale = {
				name = L["Razorscale"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Razorscale"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Razorscale = val end,
				get = function(info) return db_options.screen_trigger.Razorscale end,
				disabled = function() return not db_char.addon_active end,
				order = 70
			},
			trigger_boss_XT002 = {
				name = L["XT-002 Deconstructor"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["XT-002 Deconstructor"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.XT002 = val end,
				get = function(info) return db_options.screen_trigger.XT002 end,
				disabled = function() return not db_char.addon_active end,
				order = 75
			},
			trigger_boss_AssemblyIron = {
				name = L["Assembly of Iron"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Assembly of Iron"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.AssemblyIron = val end,
				get = function(info) return db_options.screen_trigger.AssemblyIron end,
				disabled = function() return not db_char.addon_active end,
				order = 80
			},
			trigger_boss_Kologarn = {
				name = L["Kologarn"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Kologarn"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Kologarn = val end,
				get = function(info) return db_options.screen_trigger.Kologarn end,
				disabled = function() return not db_char.addon_active end,
				order = 85
			},
			trigger_boss_Algalon = {
				name = L["Algalon the Observer"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Algalon the Observer"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Algalon = val end,
				get = function(info) return db_options.screen_trigger.Algalon end,
				disabled = function() return not db_char.addon_active end,
				order = 90
			},
			trigger_boss_Auriaya = {
				name = L["Auriaya"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Auriaya"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Auriaya = val end,
				get = function(info) return db_options.screen_trigger.Auriaya end,
				disabled = function() return not db_char.addon_active end,
				order = 95
			},
			trigger_boss_Freya = {
				name = L["Freya"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Freya"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Freya = val end,
				get = function(info) return db_options.screen_trigger.Freya end,
				disabled = function() return not db_char.addon_active end,
				order = 100
			},
			trigger_boss_Thorim = {
				name = L["Thorim"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Thorim"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Thorim = val end,
				get = function(info) return db_options.screen_trigger.Thorim end,
				disabled = function() return not db_char.addon_active end,
				order = 105
			},
			trigger_boss_Hodir = {
				name = L["Hodir"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Hodir"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Hodir = val end,
				get = function(info) return db_options.screen_trigger.Hodir end,
				disabled = function() return not db_char.addon_active end,
				order = 110
			},
			trigger_boss_Mimiron = {
				name = L["Mimiron"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Mimiron"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Mimiron = val end,
				get = function(info) return db_options.screen_trigger.Mimiron end,
				disabled = function() return not db_char.addon_active end,
				order = 115
			},
			trigger_boss_Vezax = {
				name = L["General Vezax"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["General Vezax"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Vezax = val end,
				get = function(info) return db_options.screen_trigger.Vezax end,
				disabled = function() return not db_char.addon_active end,
				order = 120
			},
			trigger_boss_Yogg = {
				name = L["Yogg-Saron"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["Yogg-Saron"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Yogg = val end,
				get = function(info) return db_options.screen_trigger.Yogg end,
				disabled = function() return not db_char.addon_active end,
				order = 125
			},
			trigger_val_drop = {
				name = L["Fragment looting"],
				desc = L["DESC_OPTION_trigger_val_drop"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.val_drop = val end,
				get = function(info) return db_options.screen_trigger.val_drop end,
				disabled = function() return not db_char.addon_active end,
				order = 130
			},
		},
	}
	
	
	OptionsTable.screen_info = {
		name = "Screenshot Info",
		type = 'group',
		args = {
			str = {
				type = 'group',
				order = 2,
				name = "Strength",
				desc = "Changes the display of Strength",
				args = {
					ap = {
						type = 'input',
						width = "full",
						multiline = 19,
						name = "Screenshot Info",
						desc = "Mark all and copy the text",
						-- arg = "showAPFromStr",
						get = function(info) return "test\ntest2" end,
						set = false, -- function(info, value) end,
						-- get = getProfileOption,
						-- set = setProfileOptionAndClearCache,
					},
					delete_this = {
						type = "execute",
						name = "Delete this Entry",
						order = -1,
						confirm = true,
						func = function()  end,
					}
				},
			},
			agi = {
				type = 'group',
				order = 3,
				name = "Agility",
				desc = "Changes the display of Agility",
				args = {
					crit = {
						type = 'toggle',
						width = "full",
						name = "Show Crit",
						desc = "Show Crit chance from Agility",
						arg = "showCritFromAgi",
						-- get = getProfileOption,
						-- set = setProfileOptionAndClearCache,
					},
				},
			},
			sta = {
				type = 'group',
				order = 4,
				name = "Stamina",
				desc = "Changes the display of Stamina",
				args = {
					hp = {
						type = 'toggle',
						width = "full",
						name = "Show Health",
						desc = "Show Health from Stamina",
						arg = "showHealthFromSta",
						-- get = getProfileOption,
						-- set = setProfileOptionAndClearCache,
					},
				},
			},
			int = {
				type = 'group',
				order = 5,
				name = "Intellect",
				desc = "Changes the display of Intellect",
				args = {
					spellcrit = {
						type = 'toggle',
						width = "full",
						name = "Show Spell Crit",
						desc = "Show Spell Crit chance from Intellect",
						arg = "showSpellCritFromInt",
						-- get = getProfileOption,
						-- set = setProfileOptionAndClearCache,
					},
				},
			},
			spi = {
				type = 'group',
				order = 6,
				name = "Spirit",
				desc = "Changes the display of Spirit",
				args = {
					mp5nc = {
						type = 'toggle',
						width = "full",
						name = "Show Mana Regen while NOT casting",
						desc = "Show Mana Regen while NOT casting from Spirit",
						arg = "showMP5NCFromSpi",
						-- get = getProfileOption,
						-- set = setProfileOptionAndClearCache,
					},
				},
			},
		}
	}
	
	
end

function addon:test_fill_db_si()
	db_SI["2021-10-01"] = {
		["12:31:45"] = {
			["icon"] = addonTable.IconList["Default"],
			["raidlead"] = "wulpho",
			["reason"] = "Default",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:31:55"]={
			["icon"] = addonTable.IconList["Fragment of Val'anyr"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Maricon received 1x Fragment of Val'anyr",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:00"]={
			["icon"] = addonTable.IconList["Flame Leviathan"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Flame Leviathan",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:01"]={
			["icon"] = addonTable.IconList["Ignis the Furnace Master"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Ignis the Furnace Master",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:02"]={
			["icon"] = addonTable.IconList["Razorscale"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Razorscale",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:03"]={
			["icon"] = addonTable.IconList["XT-002 Deconstructor"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "XT-002 Deconstructor",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:04"]={
			["icon"] = addonTable.IconList["Assembly of Iron"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Assembly of Iron",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:05"]={
			["icon"] = addonTable.IconList["Kologarn"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Kologarn",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:06"]={
			["icon"] = addonTable.IconList["Algalon the Observer"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Algalon the Observer",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:07"]={
			["icon"] = addonTable.IconList["Auriaya"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Auriaya",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:08"]={
			["icon"] = addonTable.IconList["Freya"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Freya",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:09"]={
			["icon"] = addonTable.IconList["Thorim"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Thorim",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:10"]={
			["icon"] = addonTable.IconList["Hodir"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Hodir",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:11"]={
			["icon"] = addonTable.IconList["Mimiron"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Mimiron",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:12"]={
			["icon"] = addonTable.IconList["General Vezax"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "General Vezax",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:13"]={
			["icon"] = addonTable.IconList["Yogg-Saron"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Yogg-Saron",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
	}
	
	db_SI["2021-10-22"] = {
		["12:31:45"] = {
			["icon"] = addonTable.IconList["Default"],
			["raidlead"] = "wulpho",
			["reason"] = "Default",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:31:55"]={
			["icon"] = addonTable.IconList["Fragment of Val'anyr"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Maricon received 1x Fragment of Val'anyr",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:00"]={
			["icon"] = addonTable.IconList["Flame Leviathan"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Flame Leviathan",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:01"]={
			["icon"] = addonTable.IconList["Ignis the Furnace Master"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Ignis the Furnace Master",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:02"]={
			["icon"] = addonTable.IconList["Razorscale"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Razorscale",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:03"]={
			["icon"] = addonTable.IconList["XT-002 Deconstructor"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "XT-002 Deconstructor",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:04"]={
			["icon"] = addonTable.IconList["Assembly of Iron"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Assembly of Iron",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:05"]={
			["icon"] = addonTable.IconList["Kologarn"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Kologarn",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:06"]={
			["icon"] = addonTable.IconList["Algalon the Observer"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Algalon the Observer",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:07"]={
			["icon"] = addonTable.IconList["Auriaya"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Auriaya",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:08"]={
			["icon"] = addonTable.IconList["Freya"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Freya",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:09"]={
			["icon"] = addonTable.IconList["Thorim"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Thorim",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:10"]={
			["icon"] = addonTable.IconList["Hodir"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Hodir",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:11"]={
			["icon"] = addonTable.IconList["Mimiron"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Mimiron",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:12"]={
			["icon"] = addonTable.IconList["General Vezax"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "General Vezax",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
		["12:32:13"]={
			["icon"] = addonTable.IconList["Yogg-Saron"],
			["raidlead"] = "wulphoqwe",
			["reason"] = "Yogg-Saron",
			["raid"] = {
				"asda",
				"assdda",
				"aswerwera",
				"asdfewda",
				"assdrerrrrrda",
			},
		},
	}
end

function addon:test_table_sort()
	print("\n-")
	local a_keys = {}
	local a = {
	   ["2021-10-23"] = {
		  ["12:32:11"] = { a=1 },
		  ["12:31:55"] = { a=1 },
		  ["12:32:12"] = { a=1 },
		  ["12:32:02"] = { a=1 },
		  ["12:32:13"] = { a=1 },
		  ["12:32:06"] = { a=1 },
		  ["12:32:03"] = { a=1 },
		  ["12:32:09"] = { a=1 },
		  ["12:32:10"] = { a=1 },
		  ["12:32:01"] = { a=1 },
		  ["12:32:05"] = { a=1 },
		  ["12:32:08"] = { a=1  },
		  ["12:32:00"] = { a=1  },
		  ["12:31:45"] = { a=1  },
		  ["12:32:07"] = { a=1  },
		  ["12:32:04"] = { a=1  }
	   },
	   ["2021-10-22"] = {
		  ["18:31:55"] = { a=1  },
		  ["18:31:45"] = { a=1 }
	   }
	}
	
	for k in pairs(a) do table.insert(a_keys, k) end
	for _, k in ipairs(a_keys) do 
		-- print(k, a[k]) 
		print(k) 
		local b = a[k]
		for k2 in pairs(b) do 
			print(" ",k2, b[k2]) 
		end
	end
	
	print(" split ---")
	table.sort(a_keys)
	
	for _, k in ipairs(a_keys) do 
		-- print(k, a[k]) 
		print(k)
		local b_keys = {}
		local b = a[k]
		for l in pairs(b) do table.insert(b_keys, l) end
		table.sort(b_keys)
		for _, k2 in ipairs(b_keys) do 
			print(" ",k2, b[k2]) 
		end
	end
	
end

function addon:TreeUpdate()
	local num_1, num_2
	local keys_1, keys_2
	local current_date_tbl, current_time_tbl, Menu_Sub
	-- Menu = {}
	for k, v in pairs(Menu) do
		Menu[k]=nil
	end
	
	-- db_SI
	keys_1 = {}
	num_1 = 1
	for k1 in pairs(db_SI) do table.insert(keys_1, k1) end -- fetch and store all "idx_date" keys
	table.sort(keys_1) -- sort "idx_date" keys
	for _, idx_date in ipairs(keys_1) do 
		current_date_tbl = db_SI[idx_date] -- fetch table of current idx_date
		Menu[num_1] = {}
		Menu[num_1].value = idx_date
		Menu[num_1].text = 	idx_date
		Menu[num_1].table_ref = current_date_tbl
		Menu[num_1].children = {}
		Menu_Sub = Menu[num_1].children
		num_1 = num_1 + 1
		
		keys_2 = {}
		num_2 = 1
		for k2 in pairs(current_date_tbl) do table.insert(keys_2, k2) end -- fetch and store all "idx_time" keys
		table.sort(keys_2) -- sort "idx_time" keys
		for _, idx_time in ipairs(keys_2) do 
			current_time_tbl = current_date_tbl[idx_time] -- fetch table of current idx_time
			Menu_Sub[num_2] = {}
			Menu_Sub[num_2].value = idx_time
			if current_time_tbl.icon == addonTable.IconList["Fragment of Val'anyr"] then
				Menu_Sub[num_2].text = 	"|cffff9933"..tostring( idx_time ).."|r"
			else
				Menu_Sub[num_2].text = 	idx_time
			end
			Menu_Sub[num_2].icon = 	current_time_tbl.icon
			Menu_Sub[num_2].table_ref = current_time_tbl
			num_2 = num_2 + 1
			
		end
	end
	
	self.db.global["MENU"] = Menu
	selectTree:RefreshTree();
	addon:PPrint("called addon:TreeUpdate()")
	
end




function addon:OnRaidInstanceWelcome(eventname, ...)
	args = {...}
	print("addon:OnRaidInstanceWelcome")
	print(eventname)
	
	-- local instanceName, instanceType, difficultyIndex, difficultyName, maxNumberOfPlayers, ?, dynamicInstance = GetInstanceInfo()
	local instanceName, instanceType, _, _, maxPlayers = GetInstanceInfo()
	print("instanceName",":",instanceName)
	print("instanceType",":",instanceType)
	print("maxPlayers",":",maxPlayers)
end

function addon:CombatLogHandler(eventname, ...)
    local _, combatEvent, _, _, _, destGUID, destName = ...;
	
    
    if (combatEvent == "UNIT_DIED" or combatEvent == "UNIT_DESTROYED") then
        local NPCID = MRT_GetNPCID(destGUID);
        if (NPCID and BossIDList[NPCID]) then
            -- MRT_AddBosskill(destName);
			self:PPrint(combatEvent..": ("..NPCID..")",destName)
        end
		
    end
end


-------------------------------
--  loot tracking functions  --
-------------------------------
-- track loot based on chatmessage recognized by event CHAT_MSG_LOOT
function addon:CheckChatForLoot(eventname, chatmsg)
    -- patterns LOOT_ITEM / LOOT_ITEM_SELF are also valid for LOOT_ITEM_MULTIPLE / LOOT_ITEM_SELF_MULTIPLE - but not the other way around - try these first
	
    -- first try: somebody else recieved multiple loot (most parameters)
    local playerName, itemLink, itemCount = deformat(chatmsg, LOOT_ITEM_MULTIPLE);
    -- next try: somebody else recieved single loot
    if (playerName == nil) then
        itemCount = 1;
        playerName, itemLink = deformat(chatmsg, LOOT_ITEM);
    end
    -- if player == nil, then next try: player recieved multiple loot
    if (playerName == nil) then
        playerName = UnitName("player");
        itemLink, itemCount = deformat(chatmsg, LOOT_ITEM_SELF_MULTIPLE);
    end
    -- if itemLink == nil, then last try: player recieved single loot
    if (itemLink == nil) then
        itemCount = 1;
        itemLink = deformat(chatmsg, LOOT_ITEM_SELF);
    end
    -- if itemLink == nil, then there was neither a LOOT_ITEM, nor a LOOT_ITEM_SELF message
    if (itemLink == nil) then 
        -- MRT_Debug("No valid lootevent recieved."); 
        return; 
    end
	
    -- if code reach this point, we should have a valid looter and a valid itemLink
    -- MRT_Debug("Item looted - Looter is "..playerName.." and loot is "..itemLink);
	
    -- example itemLink: |cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0|h[Broken Fang]|h|r
    -- strip the itemlink into its parts / may change to use deformat with easier pattern ("|c%s|H%s|h[%s]|h|r")
    local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]");
    local _, _, itemColor, _, itemId, _, _, _, _, _, _, _, _, itemName = string.find(itemLink, "|?c?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?");
    -- make the string a number
    itemId = tonumber(itemId);
    -- if major fuckup in first strip:
    -- if (itemString == nil) then MRT_Debug("ItemLink corrupted - no ItemString found."); return; end
    -- if major fuckup in second strip:
    -- if (itemId == nil) then MRT_Debug("ItemLink corrupted - no ItemId found."); return; end
	
    -- check options, if this item should be tracked (if not in list, then stop)
    if not (ItemIDList[itemId]) then return; end
	
    -- if code reach this point, we should have valid item information, an active raid and at least one bosskill entry - make a table!
    -- Note: If a CT-Raidtracker-compatible export need more iteminfo, check GetItemInfo() for more data
    local MRT_LootInfo = {
        ["ItemLink"] = itemLink,
        ["ItemString"] = itemString,
        ["ItemId"] = itemId,
        ["ItemName"] = itemName,
        ["ItemColor"] = itemColor,
        ["ItemCount"] = itemCount,
        ["Looter"] = playerName,
        -- ["DKPValue"] = 0,
        -- ["BossNumber"] = MRT_NumOfLastBoss,
        ["Time"] = time(),
    }
    -- tinsert(MRT_RaidLog[MRT_NumOfCurrentRaid]["Loot"], MRT_LootInfo);
    -- if (not MRT_Options["Tracking_AskForDKPValue"]) then return; end
    -- if (MRT_Options["Tracking_MinItemQualityToGetDKPValue"] > MRT_ItemColorValues[itemColor]) then return; end
    -- MRT_DKPFrame_AddToItemCostQueue(MRT_NumOfCurrentRaid, #MRT_RaidLog[MRT_NumOfCurrentRaid]["Loot"]);
	
	self:PPrint(playerName.." received "..itemCount.."x "..itemLink..".")
	-- self:Print(playerName.." received "..itemCount.."x "..itemLink..".")
	Screenshot()
	
end

----------------------------------
--  Iron Council Instancecheck  -- stolen from mizuki raidtracker
----------------------------------
function addon:IsInstanceUlduar(boss)
    local instanceInfoName = GetInstanceInfo();
    if (instanceInfoName == L["Ulduar"]) then
        return boss;
    else
        return nil;
    end
end

function addon:GetCurrentTime()
    if MRT_Options["Tracking_UseServerTime"] then
        local _, month, day, year = CalendarGetDate();
        local hour, minute = GetGameTime();
        return time( { year = year, month = month, day = day, hour = hour, min = minute, } );
    else
        return time();
    end
end

-- GetNPCID - returns the NPCID or nil, if GUID was no NPC
function addon:GetNPCID(GUID)
    local first3 = tonumber("0x"..strsub(GUID, 3, 5));
    local unitType = bit.band(first3, 0x007);
    if ((unitType == 0x003) or (unitType == 0x005)) then
        return tonumber("0x"..strsub(GUID, 9, 12));
    else
        return nil;
    end
end

local chatprefix = "|cff33ff99"..tostring( ADDON_NAME_SHORT ).."|r:"
function addon:PPrint(...)
	-- DEFAULT_CHAT_FRAME:AddMessage( chatprefix..tostring(msg) )
	-- LibStub("AceLocale-3.0"):Print(ADDON_NAME_SHORT,DEFAULT_CHAT_FRAME,...)
	local tmp={}
	local n=1
	tmp[n] = "|cff33ff99"..tostring( ADDON_NAME_SHORT ).."|r:"
	
	for i=1, select("#", ...) do
		n=n+1
		tmp[n] = tostring(select(i, ...))
	end
	DEFAULT_CHAT_FRAME:AddMessage( tconcat(tmp," ",1,n) )
end