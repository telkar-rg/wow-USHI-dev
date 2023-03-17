UlduScreenHelperInformer = LibStub("AceAddon-3.0"):NewAddon("UlduScreenHelperInformer", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local addon = UlduScreenHelperInformer
local L = LibStub("AceLocale-3.0"):GetLocale("UlduScreenHelperInformer", true)
local deformat = 	LibStub("LibDeformat-3.0");
local AceConfig = 	LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB =		LibStub("AceDB-3.0")
local AceGUI = 		LibStub("AceGUI-3.0");

-- local tconcat, tostring, select = table.concat, tostring, select

local ADDON_NAME, addonTable = ...;
local defaults = 	addonTable.setting_defaults
local BossIDList = 	addonTable.BossIDList
local ItemIDList_Screenshot = 	addonTable.ItemIDList_Screenshot
local ItemIDList_SubZoneBoss = 	addonTable.ItemIDList_SubZoneBoss
local ColorList = 	addonTable.ColorList
local ADDON_NAME_LONG = 	addonTable.ADDON_NAME_LONG
local ADDON_NAME_SHORT = 	addonTable.ADDON_NAME_SHORT
local ADDON_VERSION = 		addonTable.ADDON_VERSION

-- local debug_flag = true
local debug_FreyaDefeat = false
-- local ch_frame_3 = getglobal("ChatFrame".."3")
-- local ch_frame_6 = getglobal("ChatFrame".."6")
local AssemblyOfIron = nil



local db_options, db_char, db_SI
local OptionsTable = {}
local OptionsTable_2 = {}
-- local Options_SI = {}
local SI_MenuTable = {}




local LockoutID_key = nil
local LockoutID_value = nil
local firstLogin
local isUlduRaid = false
local isSubZone = {
	BossName = nil,
	BossList = {},
	CombatTimer = nil,
	Timeout = nil,
	CombatFlag = nil,
}

addon.CHATFRAME_OUTPUT = DEFAULT_CHAT_FRAME

local function DPrint(...)
	-- DEFAULT_CHAT_FRAME:AddMessage( chatprefix..tostring(msg) )
	-- LibStub("AceLocale-3.0"):Print(ADDON_NAME_SHORT,DEFAULT_CHAT_FRAME,...)
	-- if debug_flag then
	if db_char.debug_msg then
		local tmp={}
		local n=1
		tmp[n] = "|c"..ColorList["COL_USHI"]..tostring( ADDON_NAME_SHORT ).."-debug".."|r:"
		
		for i=1, select("#", ...) do
			n=n+1
			tmp[n] = tostring(select(i, ...))
		end
		-- ch_frame_3:AddMessage( table.concat(tmp," ",1,n) )
		addon.CHATFRAME_OUTPUT:AddMessage( table.concat(tmp," ",1,n) )
	end
end

function addon:OnInitialize()
    -- Called when the addon is loaded
	addon:GetDB()
	-- addon:test_fill_db_si()
	
    -- Register the options table
	self:CreateOptionsTable()
	AceConfig:RegisterOptionsTable("USHI-Table-GENERAL", OptionsTable.general, "/ushi")
	
	-- Setup Blizzard option frames
	self.optionsFrames = {}
	-- self.optionsFrame = AceConfigDialog:AddToBlizOptions(MODNAME, nil, nil, "general")
	self.optionsFrames.general = AceConfigDialog:AddToBlizOptions("USHI-Table-GENERAL", ADDON_NAME_SHORT)
	
	self.optionsFrames.screen_info = addon:makeOptionsTree(ADDON_NAME_SHORT)
	-- self.optionsFrames.screen_info.refresh = addon:TreeUpdate; -- assign a refresh function
	InterfaceOptions_AddCategory(self.optionsFrames.screen_info, ADDON_NAME_SHORT);
	
    AceConfig:RegisterOptionsTable("USHI-Table-ABOUT", OptionsTable.about)
	self.optionsFrames.about = AceConfigDialog:AddToBlizOptions("USHI-Table-ABOUT","About", ADDON_NAME_SHORT)
	
	addon:TreeUpdate()
	
	addon:setAddonActive()
end

function addon:OnEnable()
    -- Called when the addon is enabled
	-- print(ADDON_NAME)
	
	
	-- Register slash commands
	addon:RegisterChatCommand("ushi", "OnSlashCommand")
	-- addon:CancelSubZoneBossWatching() -- we definetly want to reset this
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
    -- addon:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
end


function addon:setAddonActive()
	addon:PrintVersionState()
	
	if db_char.addon_active then
	-- IF ADDON ACTIVE
		addon:RegisterEvent("PLAYER_ENTERING_WORLD");
		-- addon:RegisterEvent("ZONE_CHANGED_NEW_AREA");
		
		self:ScheduleTimer("CheckIfUlduRaid", 1) -- wait 3 secs after changing zones
		
		addon:RegisterEvent("UPDATE_INSTANCE_INFO") -- Register to fetch the Raid ID
        RequestRaidInfo()
		
		self:ScheduleTimer("UnregisterEvent", 5, "UPDATE_INSTANCE_INFO") -- unregister event after 5 secs so that we dont check the UPDATE_INSTANCE_INFO anymore until we get the instance id
		
	else
	-- IF ADDON INACTIVE
		addon:UnregisterEvent("PLAYER_ENTERING_WORLD");
		-- addon:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
		
		addon:setUlduRaid(false)
		
		
	end
end

function addon:OnSlashCommand(input)
	-- DPrint("called the slash command!")
	-- addon:TreeUpdate()
	
	if input then input = strlower(input):trim() end
	
	-- Open About panel if there's no parameters or if we do /arl about
	if ( (not input) or (input and input == "") or (input == "o") or (input == "options") ) then
		DPrint("SLASH:","Screen Informer.")
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrames["general"]) 
	elseif ( (input == "i") or (input == "info") or (input == "informer") ) then 
		DPrint("SLASH:","Options.")
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrames["screen_info"]) 
	elseif (input == "test_db") then
		addon:test_fill_db_si()
		addon:TreeUpdate()
	elseif (input == "?" or input == "help" or input == "about") then
		DPrint("SLASH:","Help.")
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrames["about"]) 
		addon:print_help(L["Commands"]) 
		
	elseif (input=="add" or input=="man" or input=="manual") then
		
		if isUlduRaid and LockoutID_key then
			DPrint("SLASH:","Manual Entry!")
			addon:SaveTriggerEvent("Bosskill", "Manual Entry", "Manual Entry")
			
		else
			DPrint("SLASH:","Manual Entry (failed).")
		end
		
	else
		DPrint("SLASH:","unknown command.")
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrames["about"]) 
		addon:print_help(L["Unknown Command"]) 
	end
end


function addon:makeOptionsTree(parent)
	-- DPrint("called addon:makeOptionsTree(parent)")
	
	local bFrame, myGroup, selectTree,  Menu

	bFrame = AceGUI:Create("BlizOptionsGroup", "bFrame-Create");
	myGroup = AceGUI:Create("ScrollFrame", "myGroup-Create");
	selectTree = AceGUI:Create("TreeGroup");
	
	-- BLIZZ options frame
	bFrame:SetName(L["Informer Entries"], parent)
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
			Label:SetFullWidth(true)
			Label:SetText(ref_table["timestamp"].." ("..ref_table["ID"]..")\n"..ref_table["trigger-text"])
			
			InlineGroup_header:SetLayout("Flow")
			Icon:SetRelativeWidth(0.12)
			Label:SetRelativeWidth(0.88)
			InlineGroup_header:AddChild(Icon)
			InlineGroup_header:AddChild(Label)
			
			-- local checkbox = AceGUI:Create("CheckBox") -- DEBUG
			-- checkbox:SetLabel("test1")
			-- local spellId = 48441
			-- local spellName = GetSpellInfo(spellId) or "unknown"
			-- local spellLink = ("|cff71d5ff|Hspell:%d|h%s|h|r"):format(spellId, spellName)
			-- checkbox:SetDescription(spellLink)
			-- checkbox:SetCallback("OnEnter", function(self)
				-- GameTooltip:SetOwner(self.frame, "ANCHOR_TOPRIGHT")
				-- GameTooltip:SetHyperlink(spellLink)
				-- GameTooltip:Show()
			-- end)
			-- checkbox:SetCallback("OnLeave", function(self) 
				-- GameTooltip:Hide()
			-- end)
			-- InlineGroup_header:AddChild(checkbox)
			
			
			local MultiLineEditBox = AceGUI:Create("MultiLineEditBox")
			MultiLineEditBox:SetFullWidth(true)
			MultiLineEditBox:SetLabel(L["Mark and Copy"])
			MultiLineEditBox:SetNumLines(18)
			MultiLineEditBox:SetText(addon:formatRaidSummary(ref_table) )
			MultiLineEditBox:SetCallback("OnTextChanged", function() MultiLineEditBox:SetText(addon:formatRaidSummary(ref_table) ) end)
			selectTree:AddChild(MultiLineEditBox)
			
			local Button = AceGUI:Create("Button")
			Button:SetText(L["Delete Entry"])
			Button:SetCallback("OnClick", function() 
				-- remove this entry from tree and refresh
				db_SI[id_separat[1]][id_separat[2]]=nil
				selectTree:ReleaseChildren()
				addon:TreeUpdate()
			end)
			selectTree:AddChild(Button)
		else
			-- if there is only the top level
			local ref_table = db_SI[id_separat[1]];
			
			local Label = AceGUI:Create("Label")
			Label:SetFullWidth(true)
			Label:SetText(addon:formatRaidWeekSummary(ref_table, id_separat[1]))
			selectTree:AddChild(Label)
			
			
			
			local MultiLineEditBox = AceGUI:Create("MultiLineEditBox")
			MultiLineEditBox:SetFullWidth(true)
			MultiLineEditBox:SetLabel(L["Mark and Copy"])
			MultiLineEditBox:SetNumLines(18)
			MultiLineEditBox:SetText(addon:formatRaidWeekSummary_COPY(ref_table, id_separat[1]) )
			MultiLineEditBox:SetCallback("OnTextChanged", function() MultiLineEditBox:SetText(addon:formatRaidWeekSummary_COPY(ref_table, id_separat[1]) ) end)
			selectTree:AddChild(MultiLineEditBox)
			
			
			local Button = AceGUI:Create("Button")
			Button:SetText(L["Delete Raidweek"] )
			Button:SetCallback("OnClick", function() 
				-- remove this entry from tree and refresh
				db_SI[id_separat[1]]=nil
				selectTree:ReleaseChildren()
				addon:TreeUpdate()
			end)
			selectTree:AddChild(Button)
		end
	end
	
	
	selectTree:RefreshTree();
end

function addon:formatRaidSummary(table_ref)
	local txt = ""
	local keys = {}
	
	txt=txt.. "|c"..ColorList["YELLOW"]..table_ref["timestamp"] .."|r ("..table_ref["ID"] ..")\n"
	txt=txt.. "|c"..ColorList["BLUE_LIGHT"]..table_ref["trigger-type"] ..":|r "..table_ref["trigger-text"] .."\n"
	txt=txt.. "\n"
	txt=txt.. "|c"..ColorList["YELLOW"].. L["Raidlead"] ..":|r "..table_ref["raidlead"] .."\n"
	for k,v in pairs(table_ref["raid"]) do table.insert(keys, k) end
	table.sort(keys)
	for k,v in pairs(keys) do
		
		txt=txt.. "|c"..ColorList["BLUE_LIGHT"]..v..":|r\n"
		-- DPrint(k,v)
		for k2,v2 in pairs(table_ref["raid"][v]) do
			txt=txt.. v2.."\n"
			-- DPrint(k2,v2)
		end
	end
	return txt
end

function addon:formatRaidWeekSummary(ref_table, rw_str)
	local txt = ""
	local num_bosses = 0
	local num_frags = 0
	local raidlead = {}
	
	for k,v in pairs(ref_table) do
		if ref_table[k]["trigger-type"] == "Loot" then num_frags = num_frags+1 end
		if ref_table[k]["trigger-type"] == "Bosskill" then num_bosses = num_bosses+1 end
		
		raidlead[ref_table[k]["raidlead"]]=1
	end
	txt = txt.. "|c"..ColorList["YELLOW"]..L["Raidweek"]..":|r "..rw_str .."\n"
	
	txt = txt.. "|c"..ColorList["YELLOW"]..L["Raidlead"]..":|r "
	for k,v in pairs(raidlead) do txt = txt.. k .." " end
	txt = txt.."\n"
	
	txt = txt.. "|c"..ColorList["YELLOW"]..L["Bosskills"]..":|r "..num_bosses .."\n"
	txt = txt.. "|c"..ColorList["YELLOW"]..L["Fragments"]..":|r "..num_frags .."\n"
	-- txt = txt.. "\n"
	return txt
end

function addon:formatRaidWeekSummary_COPY(ref_table, rw_str)
	local key, entry, txt_temp, kGrp, vGrp, nameChar
	local t_teilnehmer, t_others
	local txt = ""
	local t_entry_keys = {}
	
	for k,v in pairs(ref_table) do table.insert(t_entry_keys, k) end	-- put all table keys in for sorting
	table.sort(t_entry_keys)	-- sort key table
	
	txt_temp = string.sub(t_entry_keys[1], 1, 10) 	-- fetch the date from first key
	txt_temp = "|c"..ColorList["YELLOW"] .. txt_temp .. " - " .. string.sub(rw_str, 6) .. "|r" 	-- get calendar week and id
	
	txt = txt .. txt_temp
	txt = txt .. "\n"
	
	for _,key in ipairs(t_entry_keys) do
		-- print(v)
		entry = ref_table[key]
		
		if entry["trigger-type"] == "Bosskill" then
			txt_temp = "\n\n"
			txt_temp = txt_temp .. "|c"..ColorList["BLUE_LIGHT"] ..  entry["trigger-text"] .. "|r" .. " - " .. entry["timestamp"] .. "\n"
			
			t_teilnehmer = {}
			t_others = {}
			for kGrp, vGrp in pairs(entry["raid"]) do 	-- go through every grp of the raid
				for _, nameChar in ipairs(vGrp) do 	-- go through every memeber of each grp
					if string.find(nameChar, "%(") then 	-- if a name contains a "(" then its an t_others person
						table.insert(t_others, nameChar)
					else
						table.insert(t_teilnehmer, nameChar)
					end
				end
			end
			table.sort(t_teilnehmer)
			table.sort(t_others)
			
			txt_temp = txt_temp .. "Teilnehmer(" .. "|c"..ColorList["YELLOW"] .. tostring(#t_teilnehmer) .."|r" .. "):\n"
			txt_temp = txt_temp .. "|c"..ColorList["GRAY"].. table.concat(t_teilnehmer, ", ", 1, #t_teilnehmer) .."|r".. "\n"
			
			if (#t_others > 0) then
				txt_temp = txt_temp .. "Other:\n"
				txt_temp = txt_temp .. "|c"..ColorList["GRAY"].. table.concat(t_others, ", ", 1, #t_others) .."|r".. "\n"
			end
			
			txt = txt .. txt_temp
	
		else
			txt_temp = "\n"
			txt_temp = txt_temp .. entry["trigger-type"] .. " - " .. entry["timestamp"] .. "\n"
			txt_temp = txt_temp .. "|c"..ColorList["GRAY"].. "- " .. entry["trigger-text"] .."|r".. "\n"
			
		
			txt = txt .. txt_temp
		end
	end

	return txt.."\n"
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
			elseif current_time_tbl.icon == addonTable.IconList[L["ITEMNAME_MimironsHead"]] then
				string_color = "FFb048f8"	-- make epic loot purple (epic)
			elseif current_time_tbl.icon == addonTable.IconList[L["BOSSNAME_Algalon"]] then
				string_color = "FF3fc7eb"	-- make Algalon light-blue (mage)
			elseif current_time_tbl.icon == addonTable.IconList[L["BOSSNAME_YoggSaron"]] then
				string_color = "FF3fc7eb"	-- make Yogg light-blue (mage)
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
	
	local db_SI_len = 0
	for _,_ in pairs(db_SI) do db_SI_len=db_SI_len+1 end
	-- DPrint("db_SI_len", db_SI_len)
	selectTree:ReleaseChildren()
	if db_SI_len==0 then
		-- we have no saved raid weeks
		local Label = AceGUI:Create("Label")
		Label:SetText(L["DESC_noSavedRaids"])
		selectTree:AddChild(Label)
	end
	
	-- self.db.global["MENU"] = Menu
	selectTree:RefreshTree();
	-- DPrint("called addon:TreeUpdate()")
	
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
	
	if db_char.addon_active == nil then
		db_char.addon_active = defaults.addon_active end
	if db_char.outputEnable == nil then
		db_char.outputEnable = defaults.outputEnable end
	if db_char.chooseCreateScreenOn == nil then
		db_char.chooseCreateScreenOn = defaults.chooseCreateScreenOn end
	if db_char.chooseCreateEntryOn == nil then
		db_char.chooseCreateEntryOn = defaults.chooseCreateEntryOn end
	if db_char.useChatFrame == nil then
		db_char.useChatFrame = defaults.useChatFrame end
		
	if db_options.screen_trigger == nil then
		db_options.screen_trigger = {
			[L["BOSSNAME_FlameLeviathan"]] = defaults.screen_trigger[L["BOSSNAME_FlameLeviathan"]],
			[L["BOSSNAME_Ignis"]] = 		defaults.screen_trigger[L["BOSSNAME_Ignis"]],
			[L["BOSSNAME_Razorscale"]] = 	defaults.screen_trigger[L["BOSSNAME_Razorscale"]],
			[L["BOSSNAME_XT002"]] = 		defaults.screen_trigger[L["BOSSNAME_XT002"]],
			[L["BOSSNAME_AssemblyIron"]] =  defaults.screen_trigger[L["BOSSNAME_AssemblyIron"]],
			[L["BOSSNAME_Kologarn"]] = 		defaults.screen_trigger[L["BOSSNAME_Kologarn"]],
			[L["BOSSNAME_Algalon"]] = 		defaults.screen_trigger[L["BOSSNAME_Algalon"]],
			[L["BOSSNAME_Auriaya"]] = 		defaults.screen_trigger[L["BOSSNAME_Auriaya"]],
			[L["BOSSNAME_Freya"]] = 		defaults.screen_trigger[L["BOSSNAME_Freya"]],
			[L["BOSSNAME_Thorim"]] = 		defaults.screen_trigger[L["BOSSNAME_Thorim"]],
			[L["BOSSNAME_Hodir"]] = 		defaults.screen_trigger[L["BOSSNAME_Hodir"]],
			[L["BOSSNAME_Mimiron"]] = 		defaults.screen_trigger[L["BOSSNAME_Mimiron"]],
			[L["BOSSNAME_GeneralVezax"]] =  defaults.screen_trigger[L["BOSSNAME_GeneralVezax"]],
			[L["BOSSNAME_YoggSaron"]] = 	defaults.screen_trigger[L["BOSSNAME_YoggSaron"]],
			[L["ITEMNAME_FragmentValanyr"]] = defaults.screen_trigger[L["ITEMNAME_FragmentValanyr"]],
			[L["ITEMNAME_MimironsHead"]] = 	defaults.screen_trigger[L["ITEMNAME_MimironsHead"]],
			} 
	end
	
	
	if (db_char.useChatFrame <= 0) then 
		db_char.useChatFrame = 0
		addon.CHATFRAME_OUTPUT = DEFAULT_CHAT_FRAME 
	else 
		addon.CHATFRAME_OUTPUT = getglobal("ChatFrame"..db_char.useChatFrame) 
	end
end

function addon:CreateOptionsTable()
	
	
	OptionsTable.general = {
		order = 1,
		type = 'group',
		name = ADDON_NAME_LONG,
		args = {
			description_about = {
				name =  L["DESC_OPTION_label_about"].."\n",
				type = "description",
				order = 1
			},
			
			header_saveToChar = {
				order = 5,
				type = "header",
				name = L["DESC_OPTION_header_saveToChar"],
			},
			addon_enable = {
				name = L["Enable Addon"],
				desc = L["DESC_OPTION_enable_addon"],
				type = "toggle",
				set = function(info,val) 
					db_char.addon_active = val 
					-- if v then addon:Enable() else addon:Disable() end
					
					addon:setAddonActive()
				end,
				get = function(info) return db_char.addon_active end,
				order = 10
			},
			slider_chatFrameSelect = {
				name = function()
					if (db_char.useChatFrame <= 0) then 
						return L["DESC_OPTION_slider_useChatDEFAULT"]
					else
						return L["DESC_OPTION_slider_useChatFrame"]..db_char.useChatFrame.." ("..addon.CHATFRAME_OUTPUT.name..")"
					end
				end,
				desc = L["DESC_OPTION_slider_desc"],
				type = "range",
				min = 0,
				max = 10,
				bigStep = 1,
				get = function(info) return db_char.useChatFrame end,
				set = function(info, val) 
					if not (math.floor(val)==db_char.useChatFrame) then
						db_char.useChatFrame = math.floor(val) 
					
						if (db_char.useChatFrame <= 0) then 
							db_char.useChatFrame = 0
							addon.CHATFRAME_OUTPUT = DEFAULT_CHAT_FRAME 
							addon:PPrint(L["DESC_OPTION_slider_hereIs_frame"]..'"'..L["DESC_OPTION_slider_useChatDEFAULT"]..'"')
						else 
							addon.CHATFRAME_OUTPUT = getglobal("ChatFrame"..db_char.useChatFrame) 
							addon:PPrint(L["DESC_OPTION_slider_hereIs_frame"]..'"'..L["DESC_OPTION_slider_useChatFrame"]..db_char.useChatFrame.." ("..addon.CHATFRAME_OUTPUT.name..")"..'"')
						end
					end;
				end,
				disabled = function() return (not db_char.addon_active) end,
				order = 15
			},
			drop_outputEnable = {
				name = L["Display Timestamp and Trigger"],
				desc = L["DESC_OPTION_drop_outputEnable"],
				type = "select",
				values = {
					[1] = L["DESC_OPTION_dd_disabled"],
					[2] = L["DESC_OPTION_dd_inChat"],
					[3] = L["DESC_OPTION_dd_onScreen"],
					[4] = L["DESC_OPTION_dd_Chat&Screen"],
				},
				get = function(info) return db_char.outputEnable end,
				set = function(info, val) db_char.outputEnable=val  end,
				disabled = function() return not db_char.addon_active end,
				order = 20
			},
			
			description_spacer = {
				name =  "",
				type = "description",
				order = 22
			},
			drop_chooseCreateScreenOn = {
				name = L["Create Screenshots for"],
				desc = L["DESC_OPTION_drop_chooseCreateScreenOn"],
				type = "select",
				values = {
					[1] = L["DESC_OPTION_dd_never"],
					[2] = L["DESC_OPTION_dd_selectedTrigger"],
					[3] = L["DESC_OPTION_dd_everyTrigger"],
				},
				get = function(info) return db_char.chooseCreateScreenOn end,
				set = function(info, val) db_char.chooseCreateScreenOn=val end,
				disabled = function() return not db_char.addon_active end,
				order = 25
			},
			drop_chooseCreateEntryOn = {
				name = L["Create Informer Entries for"],
				desc = L["DESC_OPTION_drop_chooseCreateEntryOn"],
				type = "select",
				values = {
					[1] = L["DESC_OPTION_dd_never"],
					[2] = L["DESC_OPTION_dd_selectedTrigger"],
					[3] = L["DESC_OPTION_dd_everyTrigger"],
				},
				get = function(info) return db_char.chooseCreateEntryOn end,
				set = function(info, val) db_char.chooseCreateEntryOn=val  end,
				disabled = function() return not db_char.addon_active end,
				order = 30
			},
			
			debug_msg = {
				name = "Debug Messages",
				desc = "Show debug messages in chat",
				type = "toggle",
				set = function(info,val) db_char.debug_msg = val end,
				get = function(info) return db_char.debug_msg end,
				disabled = function() return (not db_char.addon_active) end,
				order = 40
			},
			
			displayheader_saveToGlobal = {
				order = 50,
				type = "header",
				name = L["DESC_OPTION_header_saveToGlobal"],
			},
			container_triggers = {
				order = 51,
				type = "group",
				name = L["Triggers"],
				inline = true,
				args = {
					trigger_boss_FlameLevi = {
						name = L["BOSSNAME_FlameLeviathan"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_FlameLeviathan"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_FlameLeviathan"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_FlameLeviathan"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_FlameLeviathan"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 55
					},
					trigger_boss_Ignis = {
						name = L["BOSSNAME_Ignis"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Ignis"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_Ignis"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_Ignis"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_Ignis"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 60
					},
					trigger_boss_Razorscale = {
						name = L["BOSSNAME_Razorscale"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Razorscale"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_Razorscale"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_Razorscale"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_Razorscale"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 70
					},
					trigger_boss_XT002 = {
						name = L["BOSSNAME_XT002"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_XT002"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_XT002"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_XT002"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_XT002"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 75
					},
					trigger_boss_AssemblyIron = {
						name = L["BOSSNAME_AssemblyIron"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_AssemblyIron"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_AssemblyIron"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_AssemblyIron"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_AssemblyIron"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 80
					},
					trigger_boss_Kologarn = {
						name = L["BOSSNAME_Kologarn"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Kologarn"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_Kologarn"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_Kologarn"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_Kologarn"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 85
					},
					trigger_boss_Algalon = {
						name = L["BOSSNAME_Algalon"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Algalon"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_Algalon"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_Algalon"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_Algalon"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 90
					},
					trigger_boss_Auriaya = {
						name = L["BOSSNAME_Auriaya"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Auriaya"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_Auriaya"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_Auriaya"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_Auriaya"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 95
					},
					trigger_boss_Freya = {
						name = L["BOSSNAME_Freya"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Freya"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_Freya"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_Freya"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_Freya"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 100
					},
					trigger_boss_Thorim = {
						name = L["BOSSNAME_Thorim"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Thorim"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_Thorim"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_Thorim"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_Thorim"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 105
					},
					trigger_boss_Hodir = {
						name = L["BOSSNAME_Hodir"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Hodir"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_Hodir"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_Hodir"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_Hodir"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 110
					},
					trigger_boss_Mimiron = {
						name = L["BOSSNAME_Mimiron"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_Mimiron"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_Mimiron"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_Mimiron"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_Mimiron"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 115
					},
					trigger_boss_Vezax = {
						name = L["BOSSNAME_GeneralVezax"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_GeneralVezax"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_GeneralVezax"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_GeneralVezax"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_GeneralVezax"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 120
					},
					trigger_boss_Yogg = {
						name = L["BOSSNAME_YoggSaron"],
						desc = L["DESC_OPTION_trigger_boss_prefix"]..L["BOSSNAME_YoggSaron"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["BOSSNAME_YoggSaron"]] = true 
							else
								db_options.screen_trigger[L["BOSSNAME_YoggSaron"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["BOSSNAME_YoggSaron"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 125
					},
					trigger_val_drop = {
						name = L["Fragment looting"],
						desc = L["DESC_OPTION_trigger_val_drop"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["ITEMNAME_FragmentValanyr"]] = true 
							else
								db_options.screen_trigger[L["ITEMNAME_FragmentValanyr"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["ITEMNAME_FragmentValanyr"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 130
					},
					trigger_mimi_drop = {
						name = L["Mimirons Head looting"],
						desc = L["DESC_OPTION_trigger_mimi_drop"],
						type = "toggle",
						set = function(info, val) 
							if val then 
								db_options.screen_trigger[L["ITEMNAME_MimironsHead"]] = true 
							else
								db_options.screen_trigger[L["ITEMNAME_MimironsHead"]] = nil 
							end
						end,
						get = function(info) 
							return db_options.screen_trigger[L["ITEMNAME_MimironsHead"]] 
						end,
						disabled = function() return not db_char.addon_active end,
						order = 135
					},
				}
			},
			
		},
	}
	
	
	OptionsTable.about = {
		order = 1,
		type = 'group',
		name = "About",
		args = {
			description_about = {
				name =  L["PANEL_ABOUT_text"],
				type = "description",
				order = 1
			},
			description_spacer = {
				name =  " ",
				type = "description",
				order = 2
			},
			
			header_chatCommands = {
				order = 5,
				type = "header",
				name = L["PANEL_ABOUT_header_chatCommands"],
			},
			description_chatCommands = {
				name =  (
					L["PANEL_ABOUT_chatCommand_1"].."\n\n"..
					L["PANEL_ABOUT_chatCommand_2"].."\n\n"..
					L["PANEL_ABOUT_chatCommand_3"]
				),
				type = "description",
				order = 10
			},
			
			header_spacer_2 = {
				order = 15,
				type = "header",
				name = "",
			},
			description_about_2 = {
				name =  L["PANEL_ABOUT_text_2"],
				type = "description",
				order = 20
			},
			
			
		},
	}
end

function addon:print_help(firstLine) 
	addon:PPrint(firstLine.."\n"..
		L["PANEL_ABOUT_chatCommand_1"].."\n"..
		L["PANEL_ABOUT_chatCommand_2"].."\n"..
		L["PANEL_ABOUT_chatCommand_3"]
	)
end


function addon:test_fill_db_si()
	local TestDBEntry = addonTable.TestDBEntry
	local key = TestDBEntry.key
	
	db_SI[key] = {
		[TestDBEntry[1].timestamp] = TestDBEntry[1],
		[TestDBEntry[2].timestamp] = TestDBEntry[2],
		[TestDBEntry[3].timestamp] = TestDBEntry[3],
	}
end









function addon:CheckIfUlduRaid()
	-- DPrint("addon:CheckIfUlduRaid()")
	
	-- local instanceName, instanceType, difficultyIndex, difficultyName, maxNumberOfPlayers, ?, dynamicInstance = GetInstanceInfo()
	local _, _, _, _, maxPlayers = GetInstanceInfo()
	local mapName = GetMapInfo()
	
	-- if (instanceName==L["ZONENAME_Ulduar"] or instanceName=="Der Sonnenbrunnen") and (maxPlayers==25 or maxPlayers>0) then --DEBUG ignore raid size for now (at least >0)
	if ( (mapName == "Ulduar") and (maxPlayers==25) )  then
		addon:setUlduRaid(true)
	else
		addon:setUlduRaid(false)
	end
end


function addon:setUlduRaid(new_state)
	if (not isUlduRaid) and (new_state) then -- set from 0 to 1
		isUlduRaid = new_state 
		DPrint("isUlduRaid", "|c"..ColorList["BLUE_LIGHT"]..tostring(isUlduRaid) .."|r")
		
		addon:RegisterEvent("CHAT_MSG_LOOT");
		addon:RegisterEvent("CHAT_MSG_SYSTEM");
		addon:RegisterEvent("CHAT_MSG_MONSTER_YELL");
		-- addon:RegisterEvent("CHAT_MSG_MONSTER_SAY");
		addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	elseif (isUlduRaid) and (not new_state)  then -- set from 1 to 0
		isUlduRaid = new_state
		DPrint("isUlduRaid", "|c"..ColorList["YELLOW"]..tostring(isUlduRaid) .."|r")
		
		addon:UnregisterEvent("CHAT_MSG_LOOT");
		addon:UnregisterEvent("CHAT_MSG_SYSTEM");
		addon:UnregisterEvent("CHAT_MSG_MONSTER_YELL");
		-- addon:UnregisterEvent("CHAT_MSG_MONSTER_SAY");
		addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		
		-- addon:CancelSubZoneBossWatching() -- we definetly want to reset this
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
			if locked  and (instanceName==L["ZONENAME_Ulduar"] ) and maxPlayers==25 then
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
		
		addonTable.RealZoneText = GetRealZoneText()
		addonTable.PlayerName = GetUnitName("player")
		
	end -- if not LockoutID_key
end


function addon:CHAT_MSG_MONSTER_YELL(event, msgMonster, nameMonster)
	-- DPrint("CHAT_MSG_MONSTER_YELL", nameMonster)
	
	local defeatTrue
	-- check if a defeatYell exists for this BOSS
	local defeatYell = addonTable.BossDefeatYellList[nameMonster]
	if defeatYell then -- if defeatYell: then check if the MSG is that defeatYell
		defeatTrue = msgMonster:lower():find( defeatYell:lower() )
		if defeatTrue then
			DPrint("Detected defeatYell for: "..nameMonster.." | "..msgMonster)
			addon:SaveTriggerEvent("Bosskill", nameMonster, nameMonster)
		end
	end
	
	
	-- -- isSubZone.BossName - only used for buggy freya
	-- if addonTable.BossSubZoneList[nameMonster] then
		-- if (addonTable.BossSubZoneList[nameMonster] == GetSubZoneText() ) then
			-- isSubZone.BossName = nameMonster
			
			-- if not isSubZone.BossList then isSubZone.BossList = {} end
			-- isSubZone.BossList[nameMonster] = true
			
			-- isSubZone.Timeout = 5	-- every yell is a reset, since we encountered them (timeout after 5 mins)
			
			-- if not isSubZone.CombatTimer then
				-- isSubZone.CombatFlag = false	-- reset combat flag
				-- isSubZone.CombatTimer = addon:ScheduleRepeatingTimer("CheckSubZoneBossCombat", 60) -- check if combat is ongoing every minute
			-- end
			
			-- DPrint("["..addonTable.BossSubZoneList[nameMonster].."]is the correct SubZone for ["..nameMonster.."]")
		-- end
	-- else
		-- -- isSubZone.BossName = nil
	-- end
end

-- function addon:CheckSubZoneBossCombat()
	-- if isSubZone.CombatFlag then		-- if we have seen boss in combatlog
		-- isSubZone.Timeout = 5
	-- else
		-- isSubZone.Timeout = isSubZone.Timeout - 1
	-- end
	-- isSubZone.CombatFlag = false	-- reset combat flag
	
	-- -- if the combat counter flag is at zero, reset it all
	-- if (not isSubZone.Timeout) or (isSubZone.Timeout <= 0) or (not isSubZone.BossName) then
		-- addon:CancelSubZoneBossWatching()
	-- end
-- end

-- function addon:CancelSubZoneBossWatching()
	-- DPrint("CancelSubZoneBossWatching()")
	
	-- isSubZone.Timeout = 0
	-- isSubZone.CombatFlag = false
	-- isSubZone.BossName = nil
	-- isSubZone.BossList = {}
	
	-- addon:CancelTimer(isSubZone.CombatTimer, true)	-- reset timer (even if no timer running)
	-- isSubZone.CombatTimer = nil
-- end



function addon:CHAT_MSG_MONSTER_SAY(event, msgMonster, nameMonster)
	-- DPrint("CHAT_MSG_MONSTER_SAY", nameMonster)
	
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
		
		addon:RegisterEvent("UPDATE_INSTANCE_INFO") -- Register to fetch the Raid ID
        RequestRaidInfo()
		
		self:ScheduleTimer("UnregisterEvent", 10, "UPDATE_INSTANCE_INFO") -- unregister event after 10 secs so that we dont check the UPDATE_INSTANCE_INFO anymore until we get the instance id
	end
	
	-- addon:CheckIfUlduRaid()
	-- self:CancelAllTimers()
	self:ScheduleTimer("CheckIfUlduRaid", 3) -- wait 3 secs after changing zones
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
	-- DPrint("addon:RAID_ROSTER_UPDATE")
	
end


function addon:COMBAT_LOG_EVENT_UNFILTERED(eventname, ...)
    -- local timestamp, combatEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...;
    local _, combatEvent, sourceGUID, sourceName, _, destGUID, destName, _, arg9 = ...
    
    if (combatEvent == "UNIT_DIED" or combatEvent == "UNIT_DESTROYED") then
        local NPCID = addon:GetNPCID(destGUID);
        if (NPCID and BossIDList[NPCID]) then
			-- mark boss as killed
			DPrint(destName.." ("..tostring(NPCID)..") is dead", combatEvent); 
			addon:SaveTriggerEvent("Bosskill", destName, destName)
			return
        end
		
		if AssemblyOfIron and AssemblyOfIron == destGUID then
			local bossNameRaw = L["BOSSNAME_AssemblyIron"]
			local bossNameDetail = L["BOSSNAME_AssemblyIron"] .. " (" .. destName .. ")"
			
			addon:SaveTriggerEvent("Bosskill", bossNameRaw, bossNameDetail)
			return
		end
    end
	-- 3/12 19:47:06.399  SPELL_AURA_APPLIED_DOSE,0xF13000809F000924,"Runenmeister Molgeim",0xa48,0xF13000809F000924,"Runenmeister Molgeim",0xa48,61920,"Superladung",0x8,BUFF,2
	-- 3/12 19:48:10.092  SPELL_AURA_REMOVED,0xF13000809F000924,"Runenmeister Molgeim",0x10a48,0xF13000809F000924,"Runenmeister Molgeim",0x10a48,61920,"Superladung",0x8,BUFF
	-- 3/12 19:48:10.235  UNIT_DIED,0x0000000000000000,nil,0x80000000,0xF13000809F000924,"Runenmeister Molgeim",0x10a48
	
	-- check for supercharge stacks (last of the three has it)
	if (combatEvent == "SPELL_AURA_APPLIED_DOSE" and arg9 == 61920) then
		AssemblyOfIron = sourceGUID 	-- save guid of the boss with 2 stacks
	end
	
	-- -- check for subzone boss combat flag
	-- if (isSubZone.Timeout) and (isSubZone.Timeout > 0) and (not isSubZone.CombatFlag) then
		-- if (isSubZone.BossList[sourceName]) then
			-- isSubZone.CombatFlag = true
			-- isSubZone.BossName = sourceName
		-- elseif (isSubZone.BossList[destName]) then
			-- isSubZone.CombatFlag = true
			-- isSubZone.BossName = destName
		-- end
		
		-- if isSubZone.CombatFlag then DPrint("Current SubZoneBoss: " .. isSubZone.BossName) end
	-- end
	
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
	
	
	-- -- IF we have a subzoneboss AND player received loot AND the loot indicates victory
	-- if isSubZone.BossName and player_received and ItemIDList_SubZoneBoss[itemId] then
		-- -- mark boss as killed
		-- local bossNameRaw = isSubZone.BossName
		-- local bossNameDetail = isSubZone.BossName
		
		-- DPrint(isSubZone.BossName, "is (presumably) defeated."); 
		
		-- -- check for iron coucil rename
		-- if addonTable.IronCouncilNames[isSubZone.BossName] then
			-- bossNameRaw = L["BOSSNAME_AssemblyIron"]
			-- bossNameDetail = L["BOSSNAME_AssemblyIron"] .. " (" .. isSubZone.BossName .. ")"
		-- end
		
		-- addon:SaveTriggerEvent("Bosskill", bossNameRaw, bossNameDetail)
		
		-- addon:CancelSubZoneBossWatching() -- reset subzoneboss tracking
	-- end
	
	
	-- IF the received item is on the list of screenshot items
	if (ItemIDList_Screenshot[itemId]) then
		DPrint(playerName.." received "..itemCount.."x "..itemLink..".")
		addon:SaveTriggerEvent("Loot", itemName, itemName..": "..playerName)
	end
end


function addon:SaveTriggerEvent(trigger_type, reason_raw, reason_detail)
	local t_now = date("*t", time())
	local time_stamp = string.format("%d-%02d-%02d %02d:%02d:%02d", t_now.year, t_now.month, t_now.day, t_now.hour, t_now.min, t_now.sec)
	local hasScreen = false
	local hasEntry = false
	

	
	-- Create Screenshot: IF everyTrigger OR selectTrigger AND is boss in selected list?
	if (db_char.chooseCreateScreenOn==3) or ( (db_char.chooseCreateScreenOn==2) and (db_options.screen_trigger[reason_raw]) ) then
		self:ScheduleTimer(Screenshot, 0.5)
		hasScreen = true
		-- DPrint("Create Screenshot","true","|","db_char.chooseCreateScreenOn",db_char.chooseCreateScreenOn,reason_raw)
	else
		-- DPrint("Create Screenshot","false","|","db_char.chooseCreateScreenOn",db_char.chooseCreateScreenOn,reason_raw)
	end
	
	-- Create Entry: IF everyTrigger OR selectTrigger AND is boss in selected list?
	if (db_char.chooseCreateEntryOn==3) or ( (db_char.chooseCreateEntryOn==2) and (db_options.screen_trigger[reason_raw]) ) then
		if LockoutID_key then
			addon:addEntrySI(time_stamp, trigger_type, reason_raw, reason_detail)
		else
			-- in case of FlameLevi we do not have an id yet
			print(addEntrySI_delayed)
			-- addon:addEntrySI_delayed(time_stamp, trigger_type, reason_raw, reason_detail)
			self:ScheduleTimer("addEntrySI_delayed", 0.5, {time_stamp, trigger_type, reason_raw, reason_detail})
		end
		hasEntry = true
		-- DPrint("Create Entry","true","|","db_char.chooseCreateEntryOn",db_char.chooseCreateEntryOn,reason_raw)
	else
		-- DPrint("Create Entry","false","|","db_char.chooseCreateEntryOn",db_char.chooseCreateEntryOn,reason_raw)
	end
	-- DPrint("hasScreen",hasScreen,",","hasEntry",hasEntry)
	-- DPrint("trigger_type",trigger_type, "reason_raw",reason_raw, "reason_detail",reason_detail)
	
	if (hasScreen) then
		-- chat output: IF chat OR chat&screen
		if (db_char.outputEnable==2) or (db_char.outputEnable==4) then 
			self:ScheduleTimer("PPrint", 0.2, time_stamp.." "..reason_detail)
			-- DPrint("chat output","true","|","db_char.outputEnable",db_char.outputEnable)
		else
			-- DPrint("chat output","false","|","db_char.outputEnable",db_char.outputEnable)
		end
		
		-- screen output: IF screen OR chat&screen
		if (db_char.outputEnable==3) or (db_char.outputEnable==4) then 
			addon:RWPrint(time_stamp.."\n"..reason_detail)
			-- DPrint("screen output","true","|","db_char.outputEnable",db_char.outputEnable)
		else
			-- DPrint("screen output","false","|","db_char.outputEnable",db_char.outputEnable)
		end
	end
	
	if (hasEntry and not hasScreen) then -- only output in chat if we dont make screenshots
		-- chat output: IF chat OR chat&screen
		if (db_char.outputEnable==2) or (db_char.outputEnable==4) then 
			self:ScheduleTimer("PPrint", 0.2, time_stamp.." "..reason_detail)
			-- DPrint("chat output","true","|","db_char.outputEnable",db_char.outputEnable)
		else
			-- DPrint("chat output","false","|","db_char.outputEnable",db_char.outputEnable)
		end
	end
end

function addon:addEntrySI_delayed(argTbl)
	addon:addEntrySI(argTbl[1], argTbl[2], argTbl[3], argTbl[4])
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
		
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML
		for i = 1, getglobal("MAX_RAID_MEMBERS") do
			name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
			if name then
				-- print(',[i]:', i, ',[name]:', name, ',[rank]:', rank, ',[subgroup]:', subgroup, ',[level]:', level, ',[class]:', class, ',[fileName]:', fileName, ',[zone]:', zone, ',[online]:', online, ',[isDead]:', isDead, ',[role]:', role, ',[isML]:', isML)
				
				if not db_SI[LockoutID_key][time_stamp]["raid"]["GROUP"..subgroup] then db_SI[LockoutID_key][time_stamp]["raid"]["GROUP"..subgroup] = {} end
				if online then	-- if player is online then
					if name == addonTable.PlayerName or zone == L["ZONENAME_Ulduar"] then	-- if it is "us", or the char is in the correct zone (ulduar), then add them directly
						table.insert(db_SI[LockoutID_key][time_stamp]["raid"]["GROUP"..subgroup], name)
					else
						table.insert(db_SI[LockoutID_key][time_stamp]["raid"]["GROUP"..subgroup], name.." (".. zone ..")")	-- else add them with zone annotation
					end
				else
					table.insert(db_SI[LockoutID_key][time_stamp]["raid"]["GROUP"..subgroup], name.." (Offline)")	-- else add them as offline
				end
				
				if rank == 2 then	-- raid lead
					db_SI[LockoutID_key][time_stamp]["raidlead"] = name
				end
			end
		end
		self:ScheduleTimer("TreeUpdate", 1)
	end -- if LockoutID_key
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




function addon:PPrint(...)
	-- DEFAULT_CHAT_FRAME:AddMessage( chatprefix..tostring(msg) )
	-- LibStub("AceLocale-3.0"):Print(ADDON_NAME_SHORT,DEFAULT_CHAT_FRAME,...)
	local tmp={}
	local n=1
	tmp[n] = "|c"..ColorList["COL_USHI"]..tostring( ADDON_NAME_SHORT ).."|r:"
	
	for i=1, select("#", ...) do
		n=n+1
		tmp[n] = tostring(select(i, ...))
	end
	-- ch_frame_3:AddMessage( table.concat(tmp," ",1,n) )
	-- ch_frame_6:AddMessage( table.concat(tmp," ",1,n) )
	addon.CHATFRAME_OUTPUT:AddMessage( table.concat(tmp," ",1,n) )
end

function addon:RWPrint(...)
	local tmp={}
	local n=1
	tmp[n] = "|c"..ColorList["COL_USHI"]..tostring( ADDON_NAME_SHORT ).."|r:"
	
	for i=1, select("#", ...) do
		n=n+1
		tmp[n] = tostring(select(i, ...))
	end
	
	-- DEFAULT_CHAT_FRAME:AddMessage( table.concat(tmp," ",1,n) )
	RaidNotice_AddMessage(RaidWarningFrame, table.concat(tmp," ",1,n), ChatTypeInfo["SAY"]);
end
