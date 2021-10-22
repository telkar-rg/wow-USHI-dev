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
    [33515] = "Auriaya",
        -- Freya, Hodir, Mimiron and Thorim will need bossyells - they don't die
    [33271] = "General Vezax",
    [33288] = "Yogg-Saron",
        -- Algalon needs a bossyell - he doesn't die
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

