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

local debug_flag = true
local ch_frame_3 = getglobal("ChatFrame".."3")
local ch_frame_6 = getglobal("ChatFrame".."6")


local db_options, db_char, db_SI
local OptionsTable = {}
-- local Options_SI = {}


local bFrame
local myGroup
local selectTree
local Menu
local head
local temp_ref

local LockoutID_temp = nil
local firstLogin = true
local firstRaidRosterUpdate = true
local isUlduRaid = false

local function DPrint(...)
	-- DEFAULT_CHAT_FRAME:AddMessage( chatprefix..tostring(msg) )
	-- LibStub("AceLocale-3.0"):Print(ADDON_NAME_SHORT,DEFAULT_CHAT_FRAME,...)
	if debug_flag then
		local tmp={}
		local n=1
		tmp[n] = "|cff33ffff"..tostring( ADDON_NAME_SHORT ).."-debug".."|r:"
		
		for i=1, select("#", ...) do
			n=n+1
			tmp[n] = tostring(select(i, ...))
		end
		DEFAULT_CHAT_FRAME:AddMessage( tconcat(tmp," ",1,n) )
	end
end

function addon:OnInitialize()
    -- Called when the addon is loaded
	addon:GetDB()
	addon:test_fill_db_si()
	
    -- Register the options table
	self:CreateOptionsTable()
    AceConfig:RegisterOptionsTable("USHI-Table-GENERAL", OptionsTable.general)
	
	-- Setup Blizzard option frames
	self.optionsFrames = {}
	-- self.optionsFrame = AceConfigDialog:AddToBlizOptions(MODNAME, nil, nil, "general")
	self.optionsFrames.general = AceConfigDialog:AddToBlizOptions("USHI-Table-GENERAL", ADDON_NAME_SHORT)
	
	addon:testTree(ADDON_NAME_SHORT)
	self.optionsFrames.screen_info = bFrame.frame
	InterfaceOptions_AddCategory(self.optionsFrames.screen_info);
	
	-- temp_ref = self.optionsFrames.screen_info.obj.children[1].children[1].tree[1]
	-- DPrint("optionsFrames.screen_info2.obj.children[1].children[1].tree[1]",temp_ref)
	
	
	
	
	-- Register slash commands
	addon:RegisterChatCommand("ushi", "OnSlashCommand")
end


function addon:testTree(parent)
	DPrint("called addon:testTree(parent)")

	bFrame = AceGUI:Create("BlizOptionsGroup", "bFrame-Create");
	myGroup = AceGUI:Create("ScrollFrame", "myGroup-Create");
	selectTree = AceGUI:Create("TreeGroup");
	head = AceGUI:Create("Heading");
	
	-- BLIZZ options frame
	bFrame:SetName("Screen Info", parent)
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
	
	-- InterfaceOptions_AddCategory(bFrame.frame);
	
	
	self:RegisterChatCommand("ushi", "SlashCommandFunc")
end

function addon:TreeCallbackHandler(_widget, _event, _uniquevalue)

	DPrint(" ")
	DPrint("_widget",_widget);
	DPrint("_event",_event);
	local id_separat = {("\001"):split(_uniquevalue)}
	
	-- print("_uniquevalue",":",id_separat[1],",",id_separat[2])
	DPrint(string.gsub(_uniquevalue,"\001"," , "));
	
	selectTree:RefreshTree();

end


local save_guid = nil
function addon:OnSlashCommand(input)
	-- DPrint("called the slash command!")
	-- addon:TreeUpdate()
	
	if input then input = strlower(input) end
	
	-- Open About panel if there's no parameters or if we do /arl about
	if not input or (input and input:trim() == "") or input == "i" or input == "info" then
		DPrint("SLASH:","Screen Informant.")
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrames["screen_info"]) 
	elseif (input == "o" or input == "options") then
		DPrint("SLASH:","Options.")
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrames["general"]) 
	elseif (input == "gen" or input == "generate") then
		DPrint("SLASH:","Generate Tree.")
		addon:TreeUpdate()
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.screen_info) 
	elseif (input == "unreg") then
		--
		DPrint("SLASH:","UnregisterEvent(CHAT_MSG_WHISPER.")
		addon:UnregisterEvent("CHAT_MSG_WHISPER");
	elseif (input == "test1") then
		--
		save_guid = UnitId("target")
		DPrint("SLASH:","save_guid",save_guid)
	elseif (input == "test2") then
		--
		DPrint("SLASH:","save_guid",UnitReaction("player",save_guid))
	else
		DPrint("SLASH:","Help.")
	end
end


function addon:OnEnable()
    -- Called when the addon is enabled
	-- print(ADDON_NAME)
	addon:PrintVersionState()
	
    addon:RegisterEvent("UPDATE_INSTANCE_INFO") -- for checking the raid id
	-- addon:RegisterEvent("ADDON_LOADED");
    addon:RegisterEvent("CHAT_MSG_LOOT","CheckChatForLoot");
    addon:RegisterEvent("CHAT_MSG_SYSTEM");
    addon:RegisterEvent("CHAT_MSG_MONSTER_YELL");
    addon:RegisterEvent("CHAT_MSG_MONSTER_SAY");
    -- addon:RegisterEvent("CHAT_MSG_WHISPER");
    addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    addon:RegisterEvent("PLAYER_ENTERING_WORLD");
    addon:RegisterEvent("RAID_INSTANCE_WELCOME")
    addon:RegisterEvent("RAID_ROSTER_UPDATE");
	
	addon:FetchLockoutID() -- try to fetch the raid id, if already exists
end

function addon:OnDisable()
    -- Called when the addon is disabled
	
    addon:UnregisterEvent("UPDATE_INSTANCE_INFO") -- for checking the raid id
	-- addon:UnregisterEvent("ADDON_LOADED");
    addon:UnregisterEvent("CHAT_MSG_LOOT");
    addon:UnregisterEvent("CHAT_MSG_SYSTEM");
    addon:UnregisterEvent("CHAT_MSG_MONSTER_YELL");
    addon:UnregisterEvent("CHAT_MSG_MONSTER_SAY");
    -- addon:UnregisterEvent("CHAT_MSG_WHISPER");
    addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    addon:UnregisterEvent("PLAYER_ENTERING_WORLD");
    addon:UnregisterEvent("RAID_INSTANCE_WELCOME")
    addon:UnregisterEvent("RAID_ROSTER_UPDATE");
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
	
	OptionsTable.general = {
		order = 1,
		type = 'group',
		name = ADDON_NAME_LONG,
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
				name = L["BOSSNAME_FlameLeviathan"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_FlameLeviathan"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.FlameLevi = val end,
				get = function(info) return db_options.screen_trigger.FlameLevi end,
				disabled = function() return not db_char.addon_active end,
				order = 55
			},
			trigger_boss_Ignis = {
				name = L["BOSSNAME_Ignis"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Ignis"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Ignis = val end,
				get = function(info) return db_options.screen_trigger.Ignis end,
				disabled = function() return not db_char.addon_active end,
				order = 60
			},
			trigger_boss_Razorscale = {
				name = L["BOSSNAME_Razorscale"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Razorscale"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Razorscale = val end,
				get = function(info) return db_options.screen_trigger.Razorscale end,
				disabled = function() return not db_char.addon_active end,
				order = 70
			},
			trigger_boss_XT002 = {
				name = L["BOSSNAME_XT002"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_XT002"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.XT002 = val end,
				get = function(info) return db_options.screen_trigger.XT002 end,
				disabled = function() return not db_char.addon_active end,
				order = 75
			},
			trigger_boss_AssemblyIron = {
				name = L["BOSSNAME_AssemblyIron"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_AssemblyIron"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.AssemblyIron = val end,
				get = function(info) return db_options.screen_trigger.AssemblyIron end,
				disabled = function() return not db_char.addon_active end,
				order = 80
			},
			trigger_boss_Kologarn = {
				name = L["BOSSNAME_Kologarn"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Kologarn"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Kologarn = val end,
				get = function(info) return db_options.screen_trigger.Kologarn end,
				disabled = function() return not db_char.addon_active end,
				order = 85
			},
			trigger_boss_Algalon = {
				name = L["BOSSNAME_Algalon"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Algalon"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Algalon = val end,
				get = function(info) return db_options.screen_trigger.Algalon end,
				disabled = function() return not db_char.addon_active end,
				order = 90
			},
			trigger_boss_Auriaya = {
				name = L["BOSSNAME_Auriaya"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Auriaya"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Auriaya = val end,
				get = function(info) return db_options.screen_trigger.Auriaya end,
				disabled = function() return not db_char.addon_active end,
				order = 95
			},
			trigger_boss_Freya = {
				name = L["BOSSNAME_Freya"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Freya"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Freya = val end,
				get = function(info) return db_options.screen_trigger.Freya end,
				disabled = function() return not db_char.addon_active end,
				order = 100
			},
			trigger_boss_Thorim = {
				name = L["BOSSNAME_Thorim"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Thorim"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Thorim = val end,
				get = function(info) return db_options.screen_trigger.Thorim end,
				disabled = function() return not db_char.addon_active end,
				order = 105
			},
			trigger_boss_Hodir = {
				name = L["BOSSNAME_Hodir"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Hodir"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Hodir = val end,
				get = function(info) return db_options.screen_trigger.Hodir end,
				disabled = function() return not db_char.addon_active end,
				order = 110
			},
			trigger_boss_Mimiron = {
				name = L["BOSSNAME_Mimiron"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Mimiron"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Mimiron = val end,
				get = function(info) return db_options.screen_trigger.Mimiron end,
				disabled = function() return not db_char.addon_active end,
				order = 115
			},
			trigger_boss_Vezax = {
				name = L["BOSSNAME_GeneralVezax"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_GeneralVezax"],
				type = "toggle",
				set = function(info, val) db_options.screen_trigger.Vezax = val end,
				get = function(info) return db_options.screen_trigger.Vezax end,
				disabled = function() return not db_char.addon_active end,
				order = 120
			},
			trigger_boss_Yogg = {
				name = L["BOSSNAME_YoggSaron"],
				desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_YoggSaron"],
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
		
	
end

function addon:test_fill_db_si()
	local temp_idweek
	-- db_SI = {}
	for k, v in pairs(db_SI) do
		db_SI[k]=nil
	end
	-- year, week, id
	
	db_SI["2021 W40: 512"] = {
		["10.01. 12:31:45"] = {
			["icon"] = addonTable.IconList["Default"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:31:55"]={
			["icon"] = addonTable.IconList["Fragment of Val'anyr"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:00"]={
			["icon"] = addonTable.IconList["Flame Leviathan"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:01"]={
			["icon"] = addonTable.IconList["Ignis the Furnace Master"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:02"]={
			["icon"] = addonTable.IconList["Razorscale"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:03"]={
			["icon"] = addonTable.IconList["XT-002 Deconstructor"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:04"]={
			["icon"] = addonTable.IconList["Assembly of Iron"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:05"]={
			["icon"] = addonTable.IconList["Kologarn"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:06"]={
			["icon"] = addonTable.IconList["Algalon the Observer"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:07"]={
			["icon"] = addonTable.IconList["Auriaya"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:08"]={
			["icon"] = addonTable.IconList["Freya"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:09"]={
			["icon"] = addonTable.IconList["Thorim"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:10"]={
			["icon"] = addonTable.IconList["Hodir"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:11"]={
			["icon"] = addonTable.IconList["Mimiron"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:12"]={
			["icon"] = addonTable.IconList["General Vezax"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
		["10.01. 12:32:13"]={
			["icon"] = addonTable.IconList["Yogg-Saron"],
			["ID"] = 512,
			["timestamp"] = "2021-10-01 12:31:55",
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
	
	db_SI["2021 W42: 2345"] = {
		["10.24. 12:31:45"] = {
			["icon"] = addonTable.IconList["Default"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:31:55",
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
		["10.24. 12:31:55"]={
			["icon"] = addonTable.IconList["Fragment of Val'anyr"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:31:55",
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
		["10.24. 12:32:00"]={
			["icon"] = addonTable.IconList["Flame Leviathan"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:00",
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
		["10.24. 12:32:01"]={
			["icon"] = addonTable.IconList["Ignis the Furnace Master"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:01",
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
		["10.24. 12:32:02"]={
			["icon"] = addonTable.IconList["Razorscale"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:02",
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
		["10.24. 12:32:03"]={
			["icon"] = addonTable.IconList["XT-002 Deconstructor"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:03",
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
		["10.24. 12:32:04"]={
			["icon"] = addonTable.IconList["Assembly of Iron"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:04",
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
		["10.24. 12:32:05"]={
			["icon"] = addonTable.IconList["Kologarn"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:05",
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
		["10.24. 12:32:06"]={
			["icon"] = addonTable.IconList["Algalon the Observer"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:06",
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
		["10.24. 12:32:07"]={
			["icon"] = addonTable.IconList["Auriaya"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:07",
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
		["10.24. 12:32:08"]={
			["icon"] = addonTable.IconList["Freya"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:08",
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
		["10.24. 12:32:09"]={
			["icon"] = addonTable.IconList["Thorim"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:09",
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
		["10.24. 12:32:10"]={
			["icon"] = addonTable.IconList["Hodir"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:10",
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
		["10.24. 12:32:11"]={
			["icon"] = addonTable.IconList["Mimiron"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:11",
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
		["10.24. 12:32:12"]={
			["icon"] = addonTable.IconList["General Vezax"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:12",
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
		["10.24. 12:32:13"]={
			["icon"] = addonTable.IconList["Yogg-Saron"],
			["ID"] = 2345,
			["timestamp"] = "2021-10-24 12:32:13",
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



function addon:TreeUpdate()
	local num_1, num_2
	local keys_1, keys_2
	local current_weekID_tbl, current_time_tbl, Menu_Sub
	local string_color
	
	-- Menu = {}
	for k, v in pairs(Menu) do
		Menu[k]=nil
	end
	
	-- db_SI
	keys_1 = {}
	num_1 = 1
	for k1 in pairs(db_SI) do table.insert(keys_1, k1) end -- fetch and store all "idx_weekID" keys
	table.sort(keys_1, function(a,b) return a>b end) -- sort "idx_weekID" keys
	for _, idx_weekID in ipairs(keys_1) do 
		current_weekID_tbl = db_SI[idx_weekID] -- fetch table of current idx_weekID
		Menu[num_1] = {}
		Menu[num_1].value = idx_weekID
		Menu[num_1].text = 	idx_weekID
		Menu[num_1].table_ref = current_weekID_tbl
		Menu[num_1].children = {}
		Menu_Sub = Menu[num_1].children
		num_1 = num_1 + 1
		
		keys_2 = {}
		num_2 = 1
		for k2 in pairs(current_weekID_tbl) do table.insert(keys_2, k2) end -- fetch and store all "idx_time" keys
		table.sort(keys_2, function(a,b) return a>b end) -- sort "idx_time" keys
		for _, idx_time in ipairs(keys_2) do 
			current_time_tbl = current_weekID_tbl[idx_time] -- fetch table of current idx_time
			
			string_color = nil -- default assignment: no color change of text
			if current_time_tbl.icon == addonTable.IconList["Fragment of Val'anyr"] then
				string_color = "FFff9933"	-- make fragments orange (legendary)
			elseif current_time_tbl.icon == addonTable.IconList["Algalon the Observer"] then
				string_color = "FF3fc7eb"	-- make Algalon light-blue (mage)
			elseif current_time_tbl.icon == addonTable.IconList["Yogg-Saron"] then
				string_color = "FFb048f8"	-- make Yogg-Saron purple (epic)
			end
			
			Menu_Sub[num_2] = {}
			if string_color then
				Menu_Sub[num_2].text = 	"|c"..string_color..tostring( idx_time ).."|r"
			else
				Menu_Sub[num_2].text = 	tostring(idx_time)
			end
			Menu_Sub[num_2].value = idx_time
			Menu_Sub[num_2].icon = 	current_time_tbl.icon
			Menu_Sub[num_2].table_ref = current_time_tbl
			num_2 = num_2 + 1
			
		end
	end
	
	self.db.global["MENU"] = Menu
	selectTree:RefreshTree();
	DPrint("called addon:TreeUpdate()")
	
end


function addon:FetchLockoutID()
	-- only try if we dont have the id grabbed yet
	if not LockoutID_temp then 
		RequestRaidInfo()	-- we need to call for [RequestRaidInfo], rest is handled in the UPDATE_INSTANCE_INFO event handler
	end 
end




function addon:CheckIfUlduRaid()
    if (GetNumRaidMembers() == 0) then
		addon:setUlduRaid(false)
	else
		-- local instanceName, instanceType, difficultyIndex, difficultyName, maxNumberOfPlayers, ?, dynamicInstance = GetInstanceInfo()
		local instanceName, instanceType, _, _, maxPlayers = GetInstanceInfo()
		
		-- if (instanceName==L["ZONENAME_Ulduar"] or instanceName=="Der Sonnenbrunnen") and (maxPlayers==25 or maxPlayers>0) then --DEBUG ignore raid size for now (at least >0)
		if (instanceName==L["ZONENAME_Ulduar"]) and (maxPlayers==25) then
			addon:FetchLockoutID()
			addon:setUlduRaid(true)
		else
			addon:setUlduRaid(false)
		end
	end
end




function addon:setUlduRaid(new_state)
	isUlduRaid = new_state
	DPrint("isUlduRaid", tostring(isUlduRaid) )
end

-- ********************************************************
-- ** Functions for Registered Events
-- ********************************************************

function addon:UPDATE_INSTANCE_INFO()
    -- Fired when data from [RequestRaidInfo] is available. 
	DPrint("addon:UPDATE_INSTANCE_INFO")
	
	-- only try if we are in uldu raid and we have not grabbed lockout id yet
	if isUlduRaid and not LockoutID_temp then 
	
		local index, reset_time, reset_date, reset_week
		local instanceName, instanceID, instanceResetSeconds, instanceDifficulty, locked, isRaid, maxPlayers
		for index=1,GetNumSavedInstances() do
			instanceName, instanceID, instanceResetSeconds, instanceDifficulty, locked, _, _, isRaid, maxPlayers, _ = GetSavedInstanceInfo(index)
			if locked  and (instanceName==L["ZONENAME_Ulduar"] or instanceName=="Der Sonnenbrunnen") and maxPlayers==25 then
			-- if locked  and (instanceName==L["ZONENAME_Ulduar"] ) and maxPlayers==25 then
				reset_time = time() + instanceResetSeconds -- get the time for when this id resets
				reset_date = date("*t", reset_time) -- turn to table {year = 1998, month = 9, day = 16, yday = 259, wday = 4, hour = 23, min = 48, sec = 10, isdst = false}
				reset_week = math.ceil( reset_date.yday / 7 ) -- take the year-day and divide by 7 to get the calendar-week-number
				-- string raid id: YEAR, WEEK, ID
				LockoutID_temp = tostring(reset_date.year)..","..tostring(reset_week)..","..tostring(instanceID)
				DPrint("LockoutID_temp",LockoutID_temp)
				break;
			end
		end -- for index=1,GetNumSavedInstances
		
	end -- if not LockoutID_temp
end

local INSTANCE_SAVED = _G["INSTANCE_SAVED"]
function addon:CHAT_MSG_SYSTEM(event, msg)
    -- You are now saved to this instances.
    -- Refresh RaidInfo
    if tostring(msg) == INSTANCE_SAVED then
		DPrint("CHAT_MSG_SYSTEM - INSTANCE_SAVED")
        RequestRaidInfo()
    end
end

function addon:CHAT_MSG_MONSTER_YELL(event,...)
	DPrint("CHAT_MSG_MONSTER_YELL")
	args = {...}
	
	local myPayload = ""
	for k, v in pairs(args) do
		myPayload = myPayload.."["..tostring(k).."]: "..tostring(v)..", "
	end
	DPrint(myPayload)
end

function addon:CHAT_MSG_MONSTER_SAY(event,...)
	DPrint("CHAT_MSG_MONSTER_SAY")
	args = {...}
	
	local myPayload = ""
	for k, v in pairs(args) do
		myPayload = myPayload.."["..tostring(k).."]: "..tostring(v)..", "
	end
	DPrint(myPayload)
end

function addon:RAID_INSTANCE_WELCOME()
	DPrint("addon:RAID_INSTANCE_WELCOME")
	
	-- local instanceName, instanceType, difficultyIndex, difficultyName, maxNumberOfPlayers, ?, dynamicInstance = GetInstanceInfo()
	local instanceName, instanceType, _, _, maxPlayers = GetInstanceInfo()
	DPrint(instanceName, maxPlayers)
	
	addon:CheckIfUlduRaid()
end


function addon:PLAYER_ENTERING_WORLD(...)
	DPrint("addon:PLAYER_ENTERING_WORLD")
	if firstLogin then
		firstLogin = false -- check only once
		addon:CheckIfUlduRaid()
	end
end


function addon:RAID_ROSTER_UPDATE(...)
	DPrint("addon:RAID_ROSTER_UPDATE")
	
	
    if firstRaidRosterUpdate then
		firstRaidRosterUpdate = false -- call only once
		addon:CheckIfUlduRaid()
    end
end


function addon:COMBAT_LOG_EVENT_UNFILTERED(eventname, ...)
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
    if (instanceInfoName == L["ZONENAME_Ulduar"]) then
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
	ch_frame_3:AddMessage( tconcat(tmp," ",1,n) )
	-- ch_frame_6:AddMessage( tconcat(tmp," ",1,n) )
	DEFAULT_CHAT_FRAME:AddMessage( tconcat(tmp," ",1,n) )
end
