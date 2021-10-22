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
local ItemIDList = 	addonTable.ItemIDList_Screenshot
local ItemIDList_SubZoneBoss = 	addonTable.ItemIDList_SubZoneBoss
local ColorList = 	addonTable.ColorList
local ADDON_NAME_LONG = 	addonTable.ADDON_NAME_LONG
local ADDON_NAME_SHORT = 	addonTable.ADDON_NAME_SHORT
local ADDON_VERSION = 		addonTable.ADDON_VERSION

local debug_flag = true
local debug_allInstances = true
-- local ch_frame_3 = getglobal("ChatFrame".."3")
-- local ch_frame_6 = getglobal("ChatFrame".."6")


local db_options, db_char, db_SI
local OptionsTable = {}
-- local Options_SI = {}
local SI_MenuTable = {}


local LockoutID_key = nil
local LockoutID_value = nil
local firstLogin
local isUlduRaid = false
local isSubZoneBoss = nil

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
		-- ch_frame_3:AddMessage( tconcat(tmp," ",1,n) )
		DEFAULT_CHAT_FRAME:AddMessage( tconcat(tmp," ",1,n) )
	end
end

function addon:OnInitialize()
    -- Called when the addon is loaded
	addon:GetDB()
	-- addon:test_fill_db_si()
	
    -- Register the options table
	self:CreateOptionsTable()
    AceConfig:RegisterOptionsTable("USHI-Table-GENERAL", OptionsTable.general)
	
	-- Setup Blizzard option frames
	self.optionsFrames = {}
	-- self.optionsFrame = AceConfigDialog:AddToBlizOptions(MODNAME, nil, nil, "general")
	self.optionsFrames.general = AceConfigDialog:AddToBlizOptions("USHI-Table-GENERAL", ADDON_NAME_SHORT)
	
	
	self.optionsFrames.screen_info = addon:makeOptionsTree(ADDON_NAME_SHORT)
	-- self.optionsFrames.screen_info.refresh = addon:TreeUpdate; -- assign a refresh function
	InterfaceOptions_AddCategory(self.optionsFrames.screen_info, ADDON_NAME_SHORT);
	
	
	addon:TreeUpdate()
	
	local panel_option
	print("screen_info")
	panel_option = "name"
	print(panel_option,self.optionsFrames.screen_info[panel_option])
	panel_option = "parent"
	print(panel_option,self.optionsFrames.screen_info[panel_option])
	panel_option = "okay"
	print(panel_option,self.optionsFrames.screen_info[panel_option])
	panel_option = "cancel"
	print(panel_option,self.optionsFrames.screen_info[panel_option])
	panel_option = "default"
	print(panel_option,self.optionsFrames.screen_info[panel_option])
	panel_option = "refresh"
	print(panel_option,self.optionsFrames.screen_info[panel_option])
end

function addon:OnEnable()
    -- Called when the addon is enabled
	-- print(ADDON_NAME)
	addon:PrintVersionState()
	
    addon:RegisterEvent("PLAYER_ENTERING_WORLD");
    addon:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	
	-- Register slash commands
	addon:RegisterChatCommand("ushi", "OnSlashCommand")
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
    -- addon:UnregisterEvent("RAID_INSTANCE_WELCOME")
    addon:UnregisterEvent("RAID_ROSTER_UPDATE");
    addon:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
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
	elseif (input == "test_instance") then
		--
		DPrint("SLASH:","test_instance")
		addon:CHAT_MSG_SYSTEM(nil, INSTANCE_SAVED)
	elseif (input == "test_screen") then
		addon:ExecuteScreenshot("Loot", L["ITEMNAME_FragmentValanyr"], L["ITEMNAME_FragmentValanyr"]..": Wulpho")
	elseif (input == "test_raid") then
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML
		
		for i = 1,5 do -- getglobal("MAX_RAID_MEMBERS") do
			name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
			if name then
				print(',[i]:', i, ',[name]:', name, ',[rank]:', rank, ',[subgroup]:', subgroup, ',[level]:', level, ',[class]:', class, ',[fileName]:', fileName, ',[zone]:', zone, ',[online]:', online, ',[isDead]:', isDead, ',[role]:', role, ',[isML]:', isML)
			end
		end
	else
		DPrint("SLASH:","Help.")
	end
end


function addon:makeOptionsTree(parent)
	DPrint("called addon:makeOptionsTree(parent)")
	
	
	local bFrame, myGroup, selectTree, head, Menu

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
	
	
	for k,v in pairs(SI_MenuTable) do
		SI_MenuTable[k] = nil
	end
	-- bFrame, myGroup, selectTree, head, Menu
	SI_MenuTable.frame = bFrame.frame
	SI_MenuTable.myGroup = myGroup
	SI_MenuTable.selectTree = selectTree
	SI_MenuTable.Menu = Menu
	
	return bFrame.frame -- return the frame for blizz options
end

function addon:TreeCallbackHandler(_widget, _event, _uniquevalue)
	local Menu = SI_MenuTable.Menu
	local selectTree = SI_MenuTable.selectTree
	local myGroup = SI_MenuTable.myGroup
	
	local my_ref = _widget.tree
	
	-- DPrint("_widget",_widget);
	-- DPrint("my_ref",my_ref);
	local id_separat = {("\001"):split(_uniquevalue)}
	-- DPrint(("\001"):split(_uniquevalue));
	
	-- container:ReleaseChildren() -- Release all child frames of this container.
	selectTree:ReleaseChildren()
	
	if id_separat[1] and db_SI[id_separat[1]] then
		-- The top level entry exists
		if id_separat[2] and db_SI[id_separat[1]][id_separat[2]] then
			-- if a 2nd level entry exists
			local ref_table = db_SI[id_separat[1]][id_separat[2]];
			
			
			local InlineGroup_header = AceGUI:Create("SimpleGroup")
			selectTree:AddChild(InlineGroup_header)
			
			local Icon = AceGUI:Create("Icon")
			Icon:SetImage(ref_table["icon"])
			Icon:SetImageSize(30,30)
			
			local Label = AceGUI:Create("Label")
			Label:SetText(ref_table["timestamp"].." ("..ref_table["ID"]..")\n"..ref_table["trigger-text"])
			
			InlineGroup_header:SetLayout("Flow")
			Icon:SetRelativeWidth(0.12)
			Label:SetRelativeWidth(0.88)
			InlineGroup_header:AddChild(Icon)
			InlineGroup_header:AddChild(Label)
			
			local MultiLineEditBox = AceGUI:Create("MultiLineEditBox")
			MultiLineEditBox:SetFullWidth(true)
			MultiLineEditBox:SetLabel(nil)
			MultiLineEditBox:SetNumLines(20)
			MultiLineEditBox:SetText(addon:formatRaidSummary(ref_table) )
			selectTree:AddChild(MultiLineEditBox)
			
			local Button = AceGUI:Create("Button")
			Button:SetText("Delete this entry")
			selectTree:AddChild(Button)
		else
			-- if there is only the top level
			DPrint("there is only the top level");
			local ref_table = db_SI[id_separat[1]];
			
			local num_bosses = 0
			local num_frags = 0
			local raidlead = {}
			local info_text=""
			for k,v in pairs(ref_table) do
				if ref_table[k]["trigger-type"] == "Loot" then num_frags = num_frags+1 end
				if ref_table[k]["trigger-type"] == "Bosskill" then num_bosses = num_bosses+1 end
				
				raidlead[ref_table[k]["raidlead"]]=1
			end
			info_text = info_text.. "Raidweek: "..id_separat[1] .."\n"
			info_text = info_text.. "Raidlead: "
			for k,v in pairs(raidlead) do info_text = info_text.. k .." " end
			info_text = info_text.."\n"
			info_text = info_text.. "Bosses killed: "..num_bosses .."\n"
			info_text = info_text.. "Fragments dropped: "..num_frags .."\n"
			info_text = info_text.. "\n"
			
			local Label = AceGUI:Create("Label")
			Label:SetText(info_text)
			selectTree:AddChild(Label)
			
			local Button = AceGUI:Create("Button")
			Button:SetText("Delete this Raidweek")
			selectTree:AddChild(Button)
		end
	end
	
	
	
	-- local Icon = AceGUI:Create("Icon")
	-- local MultiLineEditBox = AceGUI:Create("MultiLineEditBox")
	
	-- --container:AddChild(widget [, beforeWidget])
	-- selectTree:AddChild
	
	
	selectTree:RefreshTree();

end

function addon:formatRaidSummary(table_ref)
	
	return "tesrt\nsasdas"
end



function addon:TreeUpdate()
	local num_1, num_2
	local keys_1, keys_2
	local current_weekID_tbl, current_time_tbl, Menu_Sub
	local string_color
	
	local Menu = SI_MenuTable.Menu
	local selectTree = SI_MenuTable.selectTree
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
			if current_time_tbl.icon == addonTable.IconList[L["ITEMNAME_FragmentValanyr"]] then
				string_color = "FFff9933"	-- make fragments orange (legendary)
			elseif current_time_tbl.icon == addonTable.IconList[L["BOSSNAME_Algalon"]] then
				string_color = "FF3fc7eb"	-- make Algalon light-blue (mage)
			elseif current_time_tbl.icon == addonTable.IconList[L["BOSSNAME_YoggSaron"]] then
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
	
	-- self.db.global["MENU"] = Menu
	selectTree:RefreshTree();
	DPrint("called addon:TreeUpdate()")
	
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
	
	db_SI["2021 W42: 2343"] = {
		["2021-10-15 21:33:44"] = {
			["trigger-type"] = "Bosskill",
			["trigger-text"] = "XT-002 Dekonstruktor",
			["raidlead"] = "Sareiha",
			["ID"] = 2343,
			["timestamp"] = "2021-10-15 21:33:20",
			["icon"] = "Interface\\Icons\\spell_brokenheart",
			["raid"] = {
				["GROUP2"] = {
					"Ereanor (Offline)", -- [1]
				},
				["GROUP1"] = {
					"Sareiha", -- [1]
				},
				["GROUP6"] = {
					"asdfsdsd", -- [1]
					"Ereserrgrdanor (Offline)", -- [2]
				},
			},
		},
		["2021-10-15 21:33:20"] = {
			["trigger-type"] = "Loot",
			["trigger-text"] = "Fragment von Val'anyr: Wulpho",
			["raidlead"] = "Sareiha",
			["ID"] = 2343,
			["timestamp"] = "2021-10-15 21:33:20",
			["icon"] = "Interface\\Icons\\inv_ingot_titansteel_red",
			["raid"] = {
				["GROUP2"] = {
					"Ereanor (Offline)", -- [1]
				},
				["GROUP1"] = {
					"Sareiha", -- [1]
				},
				["GROUP6"] = {
					"asdfsdsd", -- [1]
					"Ereserrgrdanor (Offline)", -- [2]
				},
			},
		},
		["2021-10-15 21:33:55"] = {
			["trigger-type"] = "Bosskill",
			["trigger-text"] = "Hodir",
			["raidlead"] = "Sareiha",
			["ID"] = 2343,
			["timestamp"] = "2021-10-15 21:33:20",
			["icon"] = "Interface\\Icons\\inv_sigil_hodir",
			["raid"] = {
				["GROUP2"] = {
					"Ereanor (Offline)", -- [1]
				},
				["GROUP1"] = {
					"Sareiha", -- [1]
				},
				["GROUP6"] = {
					"asdfsdsd", -- [1]
					"Ereserrgrdanor (Offline)", -- [2]
				},
			},
		},
	}
end









function addon:CheckIfUlduRaid()
	DPrint("addon:CheckIfUlduRaid()")
	
	-- local instanceName, instanceType, difficultyIndex, difficultyName, maxNumberOfPlayers, ?, dynamicInstance = GetInstanceInfo()
	local instanceName, instanceType, _, _, maxPlayers = GetInstanceInfo()
	
	-- if (instanceName==L["ZONENAME_Ulduar"] or instanceName=="Der Sonnenbrunnen") and (maxPlayers==25 or maxPlayers>0) then --DEBUG ignore raid size for now (at least >0)
	if ( (instanceName==L["ZONENAME_Ulduar"]) and (maxPlayers==25) ) or (debug_allInstances and maxPlayers > 0) then
		addon:setUlduRaid(true)
	else
		addon:setUlduRaid(false)
	end
end


function addon:setUlduRaid(new_state)
	if (not isUlduRaid) and (new_state) then -- set from 0 to 1
		isUlduRaid = new_state 
		DPrint("isUlduRaid", "|cff0077ff"..tostring(isUlduRaid) .."|r")
		
		addon:RegisterEvent("CHAT_MSG_LOOT");
		addon:RegisterEvent("CHAT_MSG_SYSTEM");
		addon:RegisterEvent("CHAT_MSG_MONSTER_YELL");
		-- addon:RegisterEvent("CHAT_MSG_MONSTER_SAY");
		addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	elseif (isUlduRaid) and (not new_state)  then -- set from 1 to 0
		isUlduRaid = new_state
		DPrint("isUlduRaid", "|cffffff00"..tostring(isUlduRaid) .."|r")
		
		addon:UnregisterEvent("CHAT_MSG_LOOT");
		addon:UnregisterEvent("CHAT_MSG_SYSTEM");
		addon:UnregisterEvent("CHAT_MSG_MONSTER_YELL");
		-- addon:UnregisterEvent("CHAT_MSG_MONSTER_SAY");
		addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	end
end

-- ********************************************************
-- ** Functions for Registered Events
-- ********************************************************

local INSTANCE_SAVED = getglobal("INSTANCE_SAVED") -- You are now saved to this instances.
function addon:CHAT_MSG_SYSTEM(event, msg)
    if isUlduRaid and tostring(msg) == INSTANCE_SAVED then
		DPrint("CHAT_MSG_SYSTEM - INSTANCE_SAVED in Uldu")
		addon:RegisterEvent("UPDATE_INSTANCE_INFO") -- Register to fetch the Raid ID
        RequestRaidInfo()
    end
end

function addon:UPDATE_INSTANCE_INFO()
    -- Fired when data from [RequestRaidInfo] is available. 
	DPrint("addon:UPDATE_INSTANCE_INFO")
	
	-- only try if we are in uldu raid and we have not grabbed lockout id yet
	if not LockoutID_key then 
	
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
				LockoutID_value = instanceID
				LockoutID_key = string.format("%d W%02d: %d", reset_date.year, reset_week, instanceID) -- tostring(reset_date.year)..","..tostring(reset_week)..","..tostring(instanceID)
				DPrint("LockoutID_key",LockoutID_key)
				
				addon:UnregisterEvent("UPDATE_INSTANCE_INFO") -- we have the LockoutID_key, we stop looking for the IDs
				addon:UnregisterEvent("CHAT_MSG_SYSTEM")
				break;
			end
		end -- for index=1,GetNumSavedInstances
		
	end -- if not LockoutID_key
end


function addon:CHAT_MSG_MONSTER_YELL(event, textMonster, nameMonster)
	DPrint("CHAT_MSG_MONSTER_YELL", nameMonster)
	
	-- isSubZoneBoss
	if addonTable.BossSubZoneList[nameMonster] then
		-- DPrint(nameMonster, "is a SubZoneBoss.")
		if addonTable.BossSubZoneList[nameMonster] == GetSubZoneText() then
			isSubZoneBoss = nameMonster
			-- DPrint(addonTable.BossSubZoneList[nameMonster], "is the correct SubZone. - SUCCESS")
		end
	else
		isSubZoneBoss = nil
	end
end

function addon:CHAT_MSG_MONSTER_SAY(event, textMonster, nameMonster)
	DPrint("CHAT_MSG_MONSTER_SAY", nameMonster)
	
	-- args = {...}
	-- local myPayload = ""
	-- for k, v in pairs(args) do
		-- myPayload = myPayload.."["..tostring(k).."]: "..tostring(v)..", "
	-- end
	-- DPrint(myPayload)
end


function addon:PLAYER_ENTERING_WORLD(...)
	DPrint("addon:PLAYER_ENTERING_WORLD")
	if not firstLogin then
		firstLogin = true -- check only once
		-- addon:CheckIfUlduRaid()
		-- self:CancelAllTimers()
		self:ScheduleTimer("CheckIfUlduRaid", 3) -- wait 3 secs after changing zones
		
		addon:RegisterEvent("UPDATE_INSTANCE_INFO") -- Register to fetch the Raid ID
        RequestRaidInfo()
		
		self:ScheduleTimer("UnregisterEvent", 2, "UPDATE_INSTANCE_INFO") -- unregister event after 2 secs so that we dont check the UPDATE_INSTANCE_INFO anymore until we get the instance id
	end
end


function addon:ZONE_CHANGED_NEW_AREA(...)
	DPrint("addon:ZONE_CHANGED_NEW_AREA")
	
	self:CancelAllTimers()
	self:ScheduleTimer("CheckIfUlduRaid", 3) -- wait 3 secs after changing zones
	
	-- if in raid, check if ulduar
	-- if (GetNumRaidMembers() > 0) then
		-- local zoneName = GetRealZoneText()
		-- local zoneId = GetCurrentMapAreaID()
		-- DPrint(zoneName,zoneId)
	-- end
end


function addon:RAID_ROSTER_UPDATE(...)
	DPrint("addon:RAID_ROSTER_UPDATE")
	
end


function addon:COMBAT_LOG_EVENT_UNFILTERED(eventname, ...)
    local _, combatEvent, _, _, _, destGUID, destName = ...;
    
    if (combatEvent == "UNIT_DIED" or combatEvent == "UNIT_DESTROYED") then
        local NPCID = addon:GetNPCID(destGUID);
        if (NPCID and BossIDList[NPCID]) then
			-- mark boss as killed
			DPrint(destName.." ("..tostring(NPCID)..") is dead", combatEvent); 
			addon:ExecuteScreenshot("Bosskill", destName, destName)
        end
    end
end


-------------------------------
--  loot tracking functions  --
-------------------------------
-- track loot based on chatmessage recognized by event CHAT_MSG_LOOT
function addon:CHAT_MSG_LOOT(eventname, chatmsg)
    -- patterns LOOT_ITEM / LOOT_ITEM_SELF are also valid for LOOT_ITEM_MULTIPLE / LOOT_ITEM_SELF_MULTIPLE - but not the other way around - try these first
	local player_received = false
	
    -- first try: somebody else recieved multiple loot (most parameters)
    local playerName, itemLink, itemCount = deformat(chatmsg, LOOT_ITEM_MULTIPLE);
	-- if playerName then DPrint("somebody else recieved multiple loot.") end
	
    -- next try: somebody else recieved single loot
    if (playerName == nil) then
        itemCount = 1;
        playerName, itemLink = deformat(chatmsg, LOOT_ITEM);
		-- if playerName then DPrint("somebody else recieved single loot.") end
    end
	
    -- if player == nil, then next try: player recieved multiple loot
    if (playerName == nil) then
        playerName = UnitName("player");
        itemLink, itemCount = deformat(chatmsg, LOOT_ITEM_SELF_MULTIPLE);
		if itemLink then 
			-- DPrint("player recieved multiple loot.") 
			player_received = true
		end
    end
	
    -- if itemLink == nil, then last try: player recieved single loot
    if (itemLink == nil) then
        itemCount = 1;
        itemLink = deformat(chatmsg, LOOT_ITEM_SELF);
		if itemLink then 
			-- DPrint("player recieved single loot.") 
			player_received = true
		end
    end
    -- if itemLink == nil, then there was neither a LOOT_ITEM, nor a LOOT_ITEM_SELF message
    if (itemLink == nil) then 
        -- DPrint("No valid lootevent recieved."); 
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
	
	-- IF we have a subzoneboss AND player received loot AND the loot indicates victory
	if isSubZoneBoss and player_received and ItemIDList_SubZoneBoss[itemId] then
		-- mark boss as killed
		DPrint(isSubZoneBoss, "is (presumably) defeated."); 
		addon:ExecuteScreenshot("Bosskill", isSubZoneBoss, isSubZoneBoss)
		
		isSubZoneBoss = nil -- reset subzoneboss tracking
	end
	
	-- IF the received item is on the list of screenshot items
	if (ItemIDList[itemId]) then
		DPrint(playerName.." received "..itemCount.."x "..itemLink..".")
		addon:ExecuteScreenshot("Loot", itemName, itemName..": "..playerName)
		
	end
end


function addon:ExecuteScreenshot(trigger_type, reason_raw, reason_detail)
	local t_now = date("*t", time())
	local time_stamp = string.format("%d-%02d-%02d %02d:%02d:%02d", t_now.year, t_now.month, t_now.day, t_now.hour, t_now.min, t_now.sec)
	-- self:CancelAllTimers()
	-- addon:PPrint(time_stamp.." "..reason_detail)
	self:ScheduleTimer("PPrint", 0.2, time_stamp.." "..reason_detail)
	addon:RWPrint(time_stamp.."\n"..reason_detail)
	self:ScheduleTimer(Screenshot, 0.5)
	
	addon:addEntrySI(time_stamp, trigger_type, reason_raw, reason_detail)
end

function addon:addEntrySI(time_stamp, trigger_type, reason_raw, reason_detail)
	if LockoutID_key then
		if not db_SI[LockoutID_key] then db_SI[LockoutID_key] = {} end
		db_SI[LockoutID_key][time_stamp] = {
			["icon"] = addonTable.IconList["Default"],
			["timestamp"] = time_stamp,
			["ID"] = LockoutID_value,
			["trigger-type"] = trigger_type,
			["trigger-text"] = reason_detail,
			["raid"] = {}
		}
		if addonTable.IconList[reason_raw] then
			db_SI[LockoutID_key][time_stamp]["icon"] = addonTable.IconList[reason_raw]
		end
		
		local name, rank, subgroup, online, isML
		for i = 1, getglobal("MAX_RAID_MEMBERS") do
			name, rank, subgroup, _, _, _, _, online = GetRaidRosterInfo(i)
			if name then
				-- print(',[i]:', i, ',[name]:', name, ',[rank]:', rank, ',[subgroup]:', subgroup, ',[level]:', level, ',[class]:', class, ',[fileName]:', fileName, ',[zone]:', zone, ',[online]:', online, ',[isDead]:', isDead, ',[role]:', role, ',[isML]:', isML)
				if not db_SI[LockoutID_key][time_stamp]["raid"]["GROUP"..subgroup] then db_SI[LockoutID_key][time_stamp]["raid"]["GROUP"..subgroup] = {} end
				if online then
					table.insert(db_SI[LockoutID_key][time_stamp]["raid"]["GROUP"..subgroup], name)
				else
					table.insert(db_SI[LockoutID_key][time_stamp]["raid"]["GROUP"..subgroup], name.." (Offline)")
				end
				if rank == 2 then
					db_SI[LockoutID_key][time_stamp]["raidlead"] = name
				end
			end
		end
		-- db_SI[LockoutID_key][time_stamp] = {
			-- -- ["icon"] = addonTable.IconList["Default"],
			-- -- ["ID"] = 512,
			-- -- ["timestamp"] = time_stamp,
			-- ["raidlead"] = "wulpho",
			-- -- ["reason"] = reason_detail,
			-- ["raid"] = {
				-- "asda",
				-- "assdda",
				-- "aswerwera",
				-- "asdfewda",
				-- "assdrerrrrrda",
			-- },
		-- }
	end -- if LockoutID_key
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
	-- ch_frame_3:AddMessage( tconcat(tmp," ",1,n) )
	-- ch_frame_6:AddMessage( tconcat(tmp," ",1,n) )
	DEFAULT_CHAT_FRAME:AddMessage( tconcat(tmp," ",1,n) )
end

function addon:RWPrint(...)
	local tmp={}
	local n=1
	tmp[n] = "|cff33ff99"..tostring( ADDON_NAME_SHORT ).."|r:"
	
	for i=1, select("#", ...) do
		n=n+1
		tmp[n] = tostring(select(i, ...))
	end
	
	-- DEFAULT_CHAT_FRAME:AddMessage( tconcat(tmp," ",1,n) )
	RaidNotice_AddMessage(RaidWarningFrame, table.concat(tmp," ",1,n), ChatTypeInfo["SAY"]);
end
