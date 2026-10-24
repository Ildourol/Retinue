Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue

-- Retinue - Item Catalog & Spawner for Turtle WoW 1.18.1 / Vanilla 1.12.1
-- Displays searchable, filterable catalog of all 26,542 items from tw_world / tortoise-db-viewer.
-- Clicking an item executes .additem <id> <count> onto the targeted companion bot or player.
--
-- Features:
--   - Top Domain Category Switcher: All, Gear, Quest Items, Consumables, Recipes, Trade Goods, Misc
--   - 22 Selectable Equipment Slot Filters with authentic MPQ/DBC icons
--   - Level and Rarity filters
--   - Numeric ID search (#id or id) and instant substring name search
--   - Smart Spawning: Left-click (1x), Shift-click (5x stack), Alt-click (spawn by exact name)
--   - Server error interception: Auto name-fallback when an entry ID is unmigrated in server DB
--
-- Lua 5.0 Invariants strictly observed:
--   * script handlers use globals `this`, `arg1`
--   * no `#` (use table.getn or explicit counts)
--   * no `%` (use math.mod)
--   * no `string.match` (use string.find / string.gfind)
--   * editBox SetAutoFocus(false) mandatory

local COLS = 11
local ROWS = 6
local PAGE_SIZE = 66 -- COLS * ROWS (11 * 6)
local SLOT_SIZE = 36
local SLOT_GAP  = 4
local UNKNOWN_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local QUALITY_COLORS = {
    [0] = { 0.62, 0.62, 0.62 }, -- Poor (Grey)
    [1] = { 1.00, 1.00, 1.00 }, -- Common (White)
    [2] = { 0.12, 1.00, 0.00 }, -- Uncommon (Green)
    [3] = { 0.00, 0.44, 0.87 }, -- Rare (Blue)
    [4] = { 0.64, 0.21, 0.93 }, -- Epic (Purple)
    [5] = { 1.00, 0.50, 0.00 }, -- Legendary (Orange)
    [6] = { 0.90, 0.00, 0.00 }, -- Artifact (Red)
}

-- Domain Categories (Top Bar)
local DOMAIN_CATEGORIES = {
    { label = "All Items",    short = "All",     colorText = "|cffffffffAll|r",      domain = "all" },
    { label = "Gear & Armor", short = "Gear",    colorText = "|cff00ccffGear|r",     domain = "gear" },
    { label = "Quest Items",  short = "Quest",   colorText = "|cffffd100Quest|r",    domain = "quest" },
    { label = "Consumables",  short = "Consum",  colorText = "|cff1eff00Consum|r",   domain = "consum" },
    { label = "Recipes",      short = "Recipe",  colorText = "|cffa335eeRecipe|r",   domain = "recipe" },
    { label = "Trade & Mats", short = "Trade",   colorText = "|cffff8000Trade|r",    domain = "trade" },
    { label = "Misc / Vanity",short = "Misc",    colorText = "|cffe0e0e0Misc|r",     domain = "misc" },
}

-- Level Filters: label, minLvl, maxLvl
local LEVEL_FILTERS = {
    { label = "All",   minLvl = 0,  maxLvl = 100 },
    { label = "1-10",  minLvl = 0,  maxLvl = 10  },
    { label = "11-20", minLvl = 11, maxLvl = 20  },
    { label = "21-30", minLvl = 21, maxLvl = 30  },
    { label = "31-40", minLvl = 31, maxLvl = 40  },
    { label = "41-50", minLvl = 41, maxLvl = 50  },
    { label = "51-60", minLvl = 51, maxLvl = 60  },
}

-- Quality Filters: label, q (-1 = All), formatted label
local QUALITY_FILTERS = {
    { label = "All",    q = -1, colorText = "|cffffffffAll|r" },
    { label = "Poor",   q = 0,  colorText = "|cff9d9d9dPoor|r" },
    { label = "Common", q = 1,  colorText = "|cffffffffCommon|r" },
    { label = "Uncom",  q = 2,  colorText = "|cff1eff00Uncom|r" },
    { label = "Rare",   q = 3,  colorText = "|cff0070ddRare|r" },
    { label = "Epic",   q = 4,  colorText = "|cffa335eeEpic|r" },
    { label = "Leg.",   q = 5,  colorText = "|cffff8000Leg.|r" },
}

-- Slot Categories: 22 distinct selectable slot filters with authentic icons
local SLOT_CATEGORIES = {
    -- Row 1 (11 buttons)
    { label = "All Slots",           short = "All",      icon = "Interface\\Icons\\INV_Misc_EngGizmos_17",        types = nil },
    { label = "Head",                short = "Head",     icon = "Interface\\Icons\\INV_Helmet_03",                types = { [1] = true } },
    { label = "Neck",                short = "Neck",     icon = "Interface\\Icons\\INV_Jewelry_Necklace_22",      types = { [2] = true } },
    { label = "Shoulders",           short = "Shoulder", icon = "Interface\\Icons\\INV_Shoulder_02",              types = { [3] = true } },
    { label = "Back / Cloak",        short = "Back",     icon = "Interface\\Icons\\INV_Misc_Cape_20",             types = { [16] = true } },
    { label = "Chest & Robes",       short = "Chest",    icon = "Interface\\Icons\\INV_Chest_Cloth_17",           types = { [5] = true, [20] = true } },
    { label = "Shirt",               short = "Shirt",    icon = "Interface\\Icons\\INV_Shirt_Grey_01",            types = { [4] = true } },
    { label = "Tabard",              short = "Tabard",   icon = "Interface\\Icons\\INV_Shirt_GuildTabard_01",     types = { [19] = true } },
    { label = "Wrists / Bracers",    short = "Wrist",    icon = "Interface\\Icons\\INV_Bracer_07",                types = { [9] = true } },
    { label = "Hands / Gloves",      short = "Hands",    icon = "Interface\\Icons\\INV_Gauntlets_04",             types = { [10] = true } },
    { label = "Waist / Belt",        short = "Waist",    icon = "Interface\\Icons\\INV_Belt_03",                  types = { [6] = true } },
    -- Row 2 (11 buttons)
    { label = "Legs / Pants",        short = "Legs",     icon = "Interface\\Icons\\INV_Pants_03",                 types = { [7] = true } },
    { label = "Feet / Boots",        short = "Feet",     icon = "Interface\\Icons\\INV_Boots_01",                 types = { [8] = true } },
    { label = "Finger / Rings",      short = "Finger",   icon = "Interface\\Icons\\INV_Jewelry_Ring_19",          types = { [11] = true } },
    { label = "Trinkets",            short = "Trinket",  icon = "Interface\\Icons\\INV_Jewelry_Talisman_07",      types = { [12] = true } },
    { label = "1H / Main Hand",      short = "1H/Main",  icon = "Interface\\Icons\\INV_Sword_23",                 types = { [13] = true, [21] = true } },
    { label = "Two-Handed Weapons",  short = "2H",       icon = "Interface\\Icons\\INV_Axe_14",                   types = { [17] = true } },
    { label = "Shields & Off-Hands", short = "Off-Hand", icon = "Interface\\Icons\\INV_Shield_04",                types = { [14] = true, [22] = true, [23] = true } },
    { label = "Ranged / Bow / Wand", short = "Ranged",   icon = "Interface\\Icons\\INV_Weapon_Bow_05",            types = { [15] = true, [24] = true, [25] = true, [26] = true, [27] = true } },
    { label = "Relics (Idol/Libram)",short = "Relic",    icon = "Interface\\Icons\\INV_Relics_IdolOfRejuvenation",types = { [28] = true } },
    { label = "Bags & Containers",   short = "Bags",     icon = "Interface\\Icons\\INV_Misc_Bag_07_Black",        types = { [18] = true } },
    { label = "Consumables & Misc",  short = "Consum",   icon = "Interface\\Icons\\INV_Drink_18",                 types = { [0] = true } },
}

-- State variables
UnBot.catalogPage = 1
UnBot.catalogMaxPage = 1
UnBot.catalogFilterDomain = 1  -- Index into DOMAIN_CATEGORIES (1 = All)
UnBot.catalogFilterLevel = 1   -- Index into LEVEL_FILTERS (1 = All)
UnBot.catalogFilterQuality = 1 -- Index into QUALITY_FILTERS (1 = All)
UnBot.catalogFilterSlot = 1    -- Index into SLOT_CATEGORIES (1 = All)
UnBot.catalogSearchText = ""
UnBot.catalogFilteredItems = {}
UnBot.catalogFilteredCount = 0

-- Hidden scanning tooltip to preload WDB item caches without UI flicker
local scanTooltip = CreateFrame("GameTooltip", "UnBotCatalogScanTooltip", UIParent, "GameTooltipTemplate")
scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

--=========================================================================--
--  Item Type Formatter
--=========================================================================--

local function GetItemTypeDescription(cls, subcls, invType)
    if cls == 12 then return "Quest Item" end
    if cls == 0 then return "Consumable" end
    if cls == 9 then return "Recipe / Pattern" end
    if cls == 7 then return "Trade Goods" end
    if cls == 5 then return "Reagent" end
    if cls == 13 then return "Key" end
    if cls == 1 or invType == 18 then return "Container / Bag" end
    if cls == 15 and (subcls == 2 or subcls == 4) then return "Companion / Mount" end
    if cls == 15 then return "Miscellaneous" end
    if cls == 2 then return "Weapon" end
    if cls == 4 then return "Armor" end
    return "Item"
end

--=========================================================================--
--  Icon Resolver
--=========================================================================--

function UnBot:GetCatalogItemIcon(itemId, entry)
    -- Priority 1: Instant MPQ icon from tw_world + ItemDisplayInfo.dbc
    if entry and entry[6] and type(entry[6]) == "string" and entry[6] ~= "" then
        return "Interface\\Icons\\" .. entry[6]
    end

    -- Priority 2: Client WDB cache (9th return value in 1.12.1 / Turtle WoW)
    if itemId then
        local _, _, _, _, _, _, _, _, tex = GetItemInfo(itemId)
        if type(tex) == "string" and tex ~= "" then
            return tex
        end
    end

    -- Priority 3: Fallback via Retinue's AtlasLoot index if available
    if self.GetItemIcon and itemId then
        local icon = self:GetItemIcon(itemId)
        if icon then return icon end
    end

    return UNKNOWN_ICON
end

--=========================================================================--
--  Filter Engine
--=========================================================================--

function UnBot:ApplyCatalogFilters()
    local domDef = DOMAIN_CATEGORIES[self.catalogFilterDomain] or DOMAIN_CATEGORIES[1]
    local lvlDef = LEVEL_FILTERS[self.catalogFilterLevel] or LEVEL_FILTERS[1]
    local qDef = QUALITY_FILTERS[self.catalogFilterQuality] or QUALITY_FILTERS[1]
    local slotDef = SLOT_CATEGORIES[self.catalogFilterSlot] or SLOT_CATEGORIES[1]
    local search = string.lower(self.catalogSearchText or "")

    -- Parse numeric ID search if input is e.g. "11" or "#11"
    local searchNum = nil
    if search ~= "" then
        if string.sub(search, 1, 1) == "#" then
            searchNum = tonumber(string.sub(search, 2))
        else
            searchNum = tonumber(search)
        end
    end

    self.catalogFilteredItems = {}
    local filteredCount = 0

    if not RetinueItemCatalog then
        self.catalogFilteredCount = 0
        self.catalogMaxPage = 1
        self.catalogPage = 1
        return
    end

    local total = table.getn(RetinueItemCatalog)
    for i = 1, total do
        local entry = RetinueItemCatalog[i]
        local itemId = entry[1]
        local reqLvl = entry[2] or 0
        local quality = entry[3] or 0
        local invType = entry[4] or 0
        local name = entry[5] or ""
        local cls = entry[7] or 0
        local subcls = entry[8] or 0

        local pass = true

        -- Domain Category filter
        local d = domDef.domain
        if d == "gear" then
            if cls ~= 2 and cls ~= 4 and invType == 0 then
                pass = false
            end
        elseif d == "quest" then
            if cls ~= 12 then
                pass = false
            end
        elseif d == "consum" then
            if cls ~= 0 then
                pass = false
            end
        elseif d == "recipe" then
            if cls ~= 9 then
                pass = false
            end
        elseif d == "trade" then
            if cls ~= 7 and cls ~= 5 then
                pass = false
            end
        elseif d == "misc" then
            if cls ~= 15 and cls ~= 13 and cls ~= 1 and invType ~= 18 then
                pass = false
            end
        end

        -- Level check
        if pass and (reqLvl < lvlDef.minLvl or reqLvl > lvlDef.maxLvl) then
            pass = false
        end

        -- Quality check
        if pass and qDef.q ~= -1 and quality ~= qDef.q then
            pass = false
        end

        -- Slot check (applied only if domain allows gear slots)
        if pass and (d == "all" or d == "gear") and slotDef.types ~= nil then
            if not slotDef.types[invType] then
                pass = false
            end
        end

        -- Search filter: check exact ID or substring name match
        if pass and search ~= "" then
            if searchNum and itemId == searchNum then
                -- Direct match on ID
            else
                local lowerName = string.lower(name)
                if not string.find(lowerName, search, 1, true) then
                    pass = false
                end
            end
        end

        if pass then
            filteredCount = filteredCount + 1
            self.catalogFilteredItems[filteredCount] = entry
        end
    end

    self.catalogFilteredCount = filteredCount
    local maxP = math.ceil(filteredCount / PAGE_SIZE)
    if maxP < 1 then maxP = 1 end
    self.catalogMaxPage = maxP

    if self.catalogPage > self.catalogMaxPage then
        self.catalogPage = self.catalogMaxPage
    elseif self.catalogPage < 1 then
        self.catalogPage = 1
    end
end

--=========================================================================--
--  Window Creation & UI Components
--=========================================================================--

function UnBot:ShowCatalogWindow()
    if self.actionGroupFrame and self.actionGroupFrame:IsShown() then
        self.actionGroupFrame:Hide()
    end

    if not UnBotCatalogFrame then
        self:CreateCatalogFrame()
    end

    self:InitCatalogEvents()
    UnBotCatalogFrame:Show()
    self:ApplyCatalogFilters()
    self:RefreshCatalogDisplay()
end

function UnBot:ToggleCatalogWindow()
    if UnBotCatalogFrame and UnBotCatalogFrame:IsShown() then
        UnBotCatalogFrame:Hide()
    else
        self:ShowCatalogWindow()
    end
end

function UnBot:CreateCatalogFrame()
    -- Exact width and height: fits domain tabs, 11 columns x 6 rows perfectly
    local f = CreateFrame("Frame", "UnBotCatalogFrame", UIParent)
    f:SetWidth(496)
    f:SetHeight(568)
    f:SetPoint("CENTER", UIParent, "CENTER", 40, -10)
    f:EnableMouseWheel(true)
    self:MakeDraggable(f)
    self:RestoreFramePosition(f)

    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetScript("OnMouseWheel", function()
        UnBot:ScrollCatalog(-arg1)
    end)
    f:SetScript("OnShow", function()
        if UnBot.catalogButton then UnBot.catalogButton:LockHighlight() end
    end)
    f:SetScript("OnHide", function()
        if UnBot.catalogButton then UnBot.catalogButton:UnlockHighlight() end
    end)
    f:Hide()

    if UISpecialFrames then
        table.insert(UISpecialFrames, "UnBotCatalogFrame")
    end

    -- Header Title
    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont(UnBotFont, 15)
    title:SetPoint("TOP", f, "TOP", 0, -14)
    title:SetTextColor(1, 0.82, 0)
    title:SetText("Item Catalog & Spawner")
    f.title = title

    -- Subtitle / Target info (Clickable to toggle target)
    local subtitle = CreateFrame("Button", "UnBotCatalogTargetBtn", f)
    subtitle:SetWidth(360)
    subtitle:SetHeight(18)
    subtitle:SetPoint("TOP", f, "TOP", 0, -32)
    local subText = subtitle:CreateFontString(nil, "OVERLAY")
    subText:SetFont(UnBotFont, 11)
    subText:SetPoint("CENTER", subtitle, "CENTER", 0, 0)
    subText:SetTextColor(0.8, 0.8, 0.8)
    subtitle.text = subText
    subtitle:SetScript("OnClick", function()
        -- Toggle target between player and target if target exists
        if UnitExists("target") and not UnitIsUnit("player", "target") then
            ClearTarget()
        end
        UnBot:RefreshCatalogDisplay()
    end)
    f.subtitle = subText

    -- Close Button
    local close = CreateFrame("Button", "UnBotCatalogClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    self:CreateCatalogFilterBars(f)
    self:CreateCatalogSearchBar(f)
    self:CreateCatalogSlots(f)
    self:CreateCatalogPagination(f)
    self:CreateCatalogIconUpdater(f)
end

function UnBot:CreateCatalogFilterBars(parent)
    self.catalogDomainButtons = {}
    self.catalogLevelButtons = {}
    self.catalogQualityButtons = {}
    self.catalogSlotButtons = {}

    -- Row 1: Domain Category Switcher (7 buttons, width 60, gap 4 across 444px)
    local domLabel = parent:CreateFontString(nil, "OVERLAY")
    domLabel:SetFont(UnBotFont, 11)
    domLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -56)
    domLabel:SetTextColor(1, 0.82, 0)
    domLabel:SetText("Type:")

    local numDomains = table.getn(DOMAIN_CATEGORIES)
    for i = 1, numDomains do
        local def = DOMAIN_CATEGORIES[i]
        local btn = CreateFrame("Button", "UnBotCatDomBtn"..i, parent, "UIPanelButtonTemplate")
        btn:SetWidth(56)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 60 + (i - 1) * 60, -52)
        btn:SetText(def.colorText or def.label)
        btn.domainIndex = i
        btn:SetScript("OnClick", function()
            UnBot.catalogFilterDomain = this.domainIndex
            UnBot.catalogPage = 1
            UnBot:ApplyCatalogFilters()
            UnBot:RefreshCatalogDisplay()
        end)
        self.catalogDomainButtons[i] = btn
    end

    -- Row 2: Level Filters (7 buttons, width 54, gap 4 across 402px)
    local lvlLabel = parent:CreateFontString(nil, "OVERLAY")
    lvlLabel:SetFont(UnBotFont, 11)
    lvlLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -80)
    lvlLabel:SetTextColor(1, 0.82, 0)
    lvlLabel:SetText("Level:")

    local numLevels = table.getn(LEVEL_FILTERS)
    for i = 1, numLevels do
        local def = LEVEL_FILTERS[i]
        local btn = CreateFrame("Button", "UnBotCatLvlBtn"..i, parent, "UIPanelButtonTemplate")
        btn:SetWidth(54)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 60 + (i - 1) * 58, -76)
        btn:SetText(def.label)
        btn.filterIndex = i
        btn:SetScript("OnClick", function()
            UnBot.catalogFilterLevel = this.filterIndex
            UnBot.catalogPage = 1
            UnBot:ApplyCatalogFilters()
            UnBot:RefreshCatalogDisplay()
        end)
        self.catalogLevelButtons[i] = btn
    end

    -- Row 3: Quality / Rarity Filters (7 buttons)
    local qLabel = parent:CreateFontString(nil, "OVERLAY")
    qLabel:SetFont(UnBotFont, 11)
    qLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -104)
    qLabel:SetTextColor(1, 0.82, 0)
    qLabel:SetText("Rarity:")

    local numQualities = table.getn(QUALITY_FILTERS)
    for i = 1, numQualities do
        local def = QUALITY_FILTERS[i]
        local btn = CreateFrame("Button", "UnBotCatQBtn"..i, parent, "UIPanelButtonTemplate")
        btn:SetWidth(54)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 60 + (i - 1) * 58, -100)
        btn:SetText(def.colorText or def.label)
        btn.filterIndex = i
        btn:SetScript("OnClick", function()
            UnBot.catalogFilterQuality = this.filterIndex
            UnBot.catalogPage = 1
            UnBot:ApplyCatalogFilters()
            UnBot:RefreshCatalogDisplay()
        end)
        self.catalogQualityButtons[i] = btn
    end

    -- Row 4 & 5: Slot Filter Header & Dedicated Selectable Slot Grid (22 buttons in 2 rows of 11)
    local slotHeader = parent:CreateFontString(nil, "OVERLAY")
    slotHeader:SetFont(UnBotFont, 11)
    slotHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -126)
    slotHeader:SetTextColor(1, 0.82, 0)
    slotHeader:SetText("Slot:")

    local slotStatus = parent:CreateFontString(nil, "OVERLAY")
    slotStatus:SetFont(UnBotFont, 11)
    slotStatus:SetPoint("LEFT", slotHeader, "RIGHT", 8, 0)
    slotStatus:SetTextColor(1, 1, 1)
    slotStatus:SetText("All Slots")
    self.catalogSlotStatusText = slotStatus

    local numSlots = table.getn(SLOT_CATEGORIES)
    for i = 1, numSlots do
        local def = SLOT_CATEGORIES[i]
        local row = 1
        local col = i
        if i > 11 then
            row = 2
            col = i - 11
        end

        local btn = CreateFrame("Button", "UnBotCatSlotFilterBtn"..i, parent)
        btn:SetWidth(38)
        btn:SetHeight(26)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20 + (col - 1) * 42, -144 - (row - 1) * 28)
        btn:RegisterForClicks("LeftButtonUp")

        -- Border highlight for selection
        local border = btn:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, 2)
        border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, -2)
        border:SetTexture(1, 0.82, 0, 0.9)
        border:Hide()
        btn.border = border

        -- Inset icon
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(btn)
        icon:SetTexture(def.icon or UNKNOWN_ICON)
        btn.icon = icon

        btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
        btn.slotIndex = i
        btn.def = def

        btn:SetScript("OnClick", function()
            -- If clicking already active slot, toggle back to All Slots
            if UnBot.catalogFilterSlot == this.slotIndex then
                UnBot.catalogFilterSlot = 1
            else
                UnBot.catalogFilterSlot = this.slotIndex
            end
            UnBot.catalogPage = 1
            UnBot:ApplyCatalogFilters()
            UnBot:RefreshCatalogDisplay()
        end)

        btn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_TOP")
            GameTooltip:AddLine(this.def.label or "Slot", 1, 0.82, 0)
            GameTooltip:AddLine("Click to filter catalog to this slot", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        self.catalogSlotButtons[i] = btn
    end
end

function UnBot:CreateCatalogSearchBar(parent)
    local searchLabel = parent:CreateFontString(nil, "OVERLAY")
    searchLabel:SetFont(UnBotFont, 11)
    searchLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -206)
    searchLabel:SetTextColor(1, 0.82, 0)
    searchLabel:SetText("Search:")

    local search = CreateFrame("EditBox", "UnBotCatalogSearchBox", parent)
    search:SetWidth(170)
    search:SetHeight(20)
    search:SetPoint("TOPLEFT", parent, "TOPLEFT", 68, -202)
    search:SetAutoFocus(false)
    search:SetFontObject(GameFontHighlightSmall)
    search:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    search:SetBackdropColor(0, 0, 0, 0.8)
    search:SetTextInsets(6, 6, 0, 0)
    search:SetScript("OnTextChanged", function()
        local text = this:GetText() or ""
        UnBot.catalogSearchText = text
        UnBot.catalogPage = 1
        UnBot:ApplyCatalogFilters()
        UnBot:RefreshCatalogDisplay()
    end)
    search:SetScript("OnEscapePressed", function()
        this:SetText("")
        this:ClearFocus()
    end)
    search:SetScript("OnEnterPressed", function()
        this:ClearFocus()
    end)

    local clear = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    clear:SetWidth(48)
    clear:SetHeight(20)
    clear:SetPoint("LEFT", search, "RIGHT", 4, 0)
    clear:SetText("Reset")
    clear:SetScript("OnClick", function()
        search:SetText("")
        UnBot.catalogFilterDomain = 1
        UnBot.catalogFilterLevel = 1
        UnBot.catalogFilterQuality = 1
        UnBot.catalogFilterSlot = 1
        UnBot.catalogSearchText = ""
        UnBot.catalogPage = 1
        UnBot:ApplyCatalogFilters()
        UnBot:RefreshCatalogDisplay()
    end)

    local stats = parent:CreateFontString(nil, "OVERLAY")
    stats:SetFont(UnBotFont, 10)
    stats:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, -206)
    stats:SetTextColor(1, 0.82, 0)
    stats:SetJustifyH("RIGHT")
    stats:SetText("26,542 items")
    self.catalogStatsLabel = stats

    self.catalogSearchBox = search
end

function UnBot:CreateCatalogSlots(parent)
    self.catalogSlots = {}

    local startX = 20
    local startY = -230

    for row = 1, ROWS do
        for col = 1, COLS do
            local index = (row - 1) * COLS + col
            local slot = CreateFrame("Button", "UnBotCatSlot"..index, parent)
            slot:SetWidth(SLOT_SIZE)
            slot:SetHeight(SLOT_SIZE)
            slot:SetPoint("TOPLEFT", parent, "TOPLEFT",
                          startX + (col - 1) * (SLOT_SIZE + SLOT_GAP + 2),
                          startY - (row - 1) * (SLOT_SIZE + SLOT_GAP))
            slot:RegisterForClicks("LeftButtonUp")

            -- Quality border backdrop
            local border = slot:CreateTexture(nil, "BACKGROUND")
            border:SetPoint("TOPLEFT", slot, "TOPLEFT", -2, 2)
            border:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 2, -2)
            slot.border = border

            local icon = slot:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(slot)
            slot.icon = icon

            slot:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

            slot:SetScript("OnClick", function()
                if this.entry then
                    local count = 1
                    if IsShiftKeyDown() then
                        count = 5 -- stack spawn
                    end
                    local useName = IsAltKeyDown()
                    UnBot:SpawnCatalogItem(this.entry, count, useName)
                end
            end)

            slot:SetScript("OnEnter", function()
                if not this.entry then return end
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")

                local itemId = this.entry[1]
                local reqLevel = this.entry[2]
                local quality = this.entry[3]
                local invType = this.entry[4]
                local name = this.entry[5] or "Unknown Item"
                local cls = this.entry[7] or 0
                local subcls = this.entry[8] or 0

                if itemId then
                    GameTooltip:SetHyperlink("item:"..itemId..":0:0:0")
                end

                if GameTooltip:NumLines() == 0 then
                    local color = QUALITY_COLORS[quality] or {1, 1, 1}
                    GameTooltip:AddLine(name, color[1], color[2], color[3])
                end

                local typeDesc = GetItemTypeDescription(cls, subcls, invType)
                GameTooltip:AddLine("Type: |cffffffff"..typeDesc.."|r  (ID: "..itemId..")", 0.7, 0.7, 0.7)

                if reqLevel and reqLevel > 0 then
                    GameTooltip:AddLine("Req Level: "..reqLevel, 0.8, 0.8, 0.8)
                end

                local target = UnitName("target") or UnitName("player") or "Target"
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Left-Click: .additem "..itemId.." 1 -> "..target, 0.2, 1.0, 0.2)
                GameTooltip:AddLine("Shift-Click: .additem "..itemId.." 5 (Stack)", 0.4, 0.8, 1.0)
                GameTooltip:AddLine("Alt-Click: .additem \""..name.."\" 1 (Spawn by Name)", 1.0, 0.82, 0.0)
                GameTooltip:Show()
            end)

            slot:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            slot:Hide()
            self.catalogSlots[index] = slot
        end
    end
end

function UnBot:CreateCatalogPagination(parent)
    local prev = CreateFrame("Button", "UnBotCatPrevBtn", parent, "UIPanelButtonTemplate")
    prev:SetWidth(75)
    prev:SetHeight(22)
    prev:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 20, 16)
    prev:SetText("< Prev")
    prev:SetScript("OnClick", function()
        if UnBot.catalogPage > 1 then
            UnBot.catalogPage = UnBot.catalogPage - 1
            UnBot:RefreshCatalogDisplay()
        end
    end)
    self.catalogPrevBtn = prev

    local nextBtn = CreateFrame("Button", "UnBotCatNextBtn", parent, "UIPanelButtonTemplate")
    nextBtn:SetWidth(75)
    nextBtn:SetHeight(22)
    nextBtn:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 16)
    nextBtn:SetText("Next >")
    nextBtn:SetScript("OnClick", function()
        if UnBot.catalogPage < UnBot.catalogMaxPage then
            UnBot.catalogPage = UnBot.catalogPage + 1
            UnBot:RefreshCatalogDisplay()
        end
    end)
    self.catalogNextBtn = nextBtn

    local pageLabel = parent:CreateFontString(nil, "OVERLAY")
    pageLabel:SetFont(UnBotFont, 11)
    pageLabel:SetPoint("BOTTOM", parent, "BOTTOM", 0, 20)
    pageLabel:SetTextColor(1, 0.82, 0)
    pageLabel:SetText("Page 1 / 1")
    self.catalogPageLabel = pageLabel
end

function UnBot:CreateCatalogIconUpdater(parent)
    local updater = CreateFrame("Frame", "UnBotCatalogIconUpdater", parent)
    updater:Hide()
    updater.elapsed = 0
    updater:SetScript("OnUpdate", function()
        this.elapsed = this.elapsed + arg1
        if this.elapsed < 0.15 then return end
        this.elapsed = 0

        local hasPending = false
        for i = 1, PAGE_SIZE do
            local slot = UnBot.catalogSlots[i]
            if slot and slot:IsShown() and slot.needsIconUpdate and slot.itemId then
                local _, _, _, _, _, _, _, _, tex = GetItemInfo(slot.itemId)
                if type(tex) == "string" and tex ~= "" then
                    slot.icon:SetTexture(tex)
                    slot.needsIconUpdate = nil
                else
                    hasPending = true
                end
            end
        end

        if not hasPending then
            this:Hide()
        end
    end)
    self.catalogIconUpdater = updater
end

--=========================================================================--
--  Display Refresh & Rendering
--=========================================================================--

function UnBot:ScrollCatalog(delta)
    local nextPage = self.catalogPage + delta
    if nextPage < 1 then nextPage = 1 end
    if nextPage > self.catalogMaxPage then nextPage = self.catalogMaxPage end
    if nextPage ~= self.catalogPage then
        self.catalogPage = nextPage
        self:RefreshCatalogDisplay()
    end
end

function UnBot:RefreshCatalogDisplay()
    if not UnBotCatalogFrame or not UnBotCatalogFrame:IsShown() then return end

    -- Update target subtitle
    local target = UnitName("target")
    if target and target ~= "" then
        UnBotCatalogFrame.subtitle:SetText("Target: |cff00ff00"..target.."|r  (click to reset)")
    else
        local me = UnitName("player") or "Self"
        UnBotCatalogFrame.subtitle:SetText("Target: |cffffcc00"..me.."|r (Self)")
    end

    -- Update Domain Category buttons highlight
    local numDomains = table.getn(DOMAIN_CATEGORIES)
    for i = 1, numDomains do
        local btn = self.catalogDomainButtons[i]
        if btn then
            if i == self.catalogFilterDomain then
                btn:LockHighlight()
            else
                btn:UnlockHighlight()
            end
        end
    end

    -- Update Level buttons highlight
    local numLevels = table.getn(LEVEL_FILTERS)
    for i = 1, numLevels do
        local btn = self.catalogLevelButtons[i]
        if btn then
            if i == self.catalogFilterLevel then
                btn:LockHighlight()
            else
                btn:UnlockHighlight()
            end
        end
    end

    -- Update Quality buttons highlight
    local numQualities = table.getn(QUALITY_FILTERS)
    for i = 1, numQualities do
        local btn = self.catalogQualityButtons[i]
        if btn then
            if i == self.catalogFilterQuality then
                btn:LockHighlight()
            else
                btn:UnlockHighlight()
            end
        end
    end

    -- Update Slot buttons selection and status text
    local isNonGearDomain = (self.catalogFilterDomain > 2)
    local slotDef = SLOT_CATEGORIES[self.catalogFilterSlot] or SLOT_CATEGORIES[1]

    if self.catalogSlotStatusText then
        if isNonGearDomain then
            self.catalogSlotStatusText:SetText("|cff888888(Slot filters inactive for non-gear)|r")
        elseif self.catalogFilterSlot == 1 then
            self.catalogSlotStatusText:SetText("|cffffffffAll Slots|r")
        else
            self.catalogSlotStatusText:SetText("|cffffd100"..slotDef.label.."|r")
        end
    end

    local numSlots = table.getn(SLOT_CATEGORIES)
    for i = 1, numSlots do
        local btn = self.catalogSlotButtons[i]
        if btn then
            if isNonGearDomain then
                btn:UnlockHighlight()
                btn.border:Hide()
                if btn.icon.SetDesaturated then btn.icon:SetDesaturated(true) end
            else
                if i == self.catalogFilterSlot then
                    btn:LockHighlight()
                    btn.border:Show()
                    if btn.icon.SetDesaturated then btn.icon:SetDesaturated(false) end
                else
                    btn:UnlockHighlight()
                    btn.border:Hide()
                    if btn.icon.SetDesaturated then
                        btn.icon:SetDesaturated(self.catalogFilterSlot ~= 1)
                    end
                end
            end
        end
    end

    -- Update Statistics & Page label
    local fromIdx = 0
    local toIdx = 0
    if self.catalogFilteredCount > 0 then
        fromIdx = (self.catalogPage - 1) * PAGE_SIZE + 1
        toIdx = fromIdx + PAGE_SIZE - 1
        if toIdx > self.catalogFilteredCount then
            toIdx = self.catalogFilteredCount
        end
    end

    if self.catalogStatsLabel then
        self.catalogStatsLabel:SetText(fromIdx.."-"..toIdx.." / "..self.catalogFilteredCount.." items")
    end

    if self.catalogPageLabel then
        self.catalogPageLabel:SetText("Page "..self.catalogPage.." / "..self.catalogMaxPage)
    end

    if self.catalogPrevBtn then
        if self.catalogPage <= 1 then
            self.catalogPrevBtn:Disable()
        else
            self.catalogPrevBtn:Enable()
        end
    end

    if self.catalogNextBtn then
        if self.catalogPage >= self.catalogMaxPage then
            self.catalogNextBtn:Disable()
        else
            self.catalogNextBtn:Enable()
        end
    end

    -- Populate Slots with Automatic Icon Preloader
    local startIndex = (self.catalogPage - 1) * PAGE_SIZE + 1
    local hasPendingIcons = false

    for i = 1, PAGE_SIZE do
        local slot = self.catalogSlots[i]
        local dataIndex = startIndex + (i - 1)
        local entry = self.catalogFilteredItems[dataIndex]

        if slot then
            if entry then
                slot.entry = entry
                local itemId = entry[1]
                local quality = entry[3] or 1
                slot.itemId = itemId

                -- Quality border tint
                local color = QUALITY_COLORS[quality] or { 1, 1, 1 }
                slot.border:SetTexture(color[1], color[2], color[3], 0.9)

                -- Icon resolution (immediate authentic MPQ icon from entry[6])
                local texture = self:GetCatalogItemIcon(itemId, entry)
                slot.icon:SetTexture(texture)

                -- Automatically query scanning tooltip to prime WDB cache for tooltip stats
                scanTooltip:SetHyperlink("item:"..itemId..":0:0:0")

                -- If the texture is unknown fallback, schedule background resolution
                if texture == UNKNOWN_ICON then
                    slot.needsIconUpdate = true
                    hasPendingIcons = true
                else
                    slot.needsIconUpdate = nil
                end

                slot:Show()
            else
                slot.entry = nil
                slot.itemId = nil
                slot.needsIconUpdate = nil
                slot:Hide()
            end
        end
    end

    -- Trigger background updater if any visible slot is pending WDB item packet
    if hasPendingIcons and self.catalogIconUpdater then
        self.catalogIconUpdater:Show()
    end
end

--=========================================================================--
--  Spawning Command Handler & Error Interceptor
--=========================================================================--

function UnBot:InitCatalogEvents()
    if self.catalogEventFrame then return end

    local f = CreateFrame("Frame", "UnBotCatalogEventFrame")
    f:RegisterEvent("CHAT_MSG_SYSTEM")
    f:SetScript("OnEvent", function()
        if event == "CHAT_MSG_SYSTEM" and arg1 then
            if UnBot.lastSpawnedEntry and (GetTime() - (UnBot.lastSpawnedTime or 0) < 2.5) then
                local lowerMsg = string.lower(arg1)
                -- Catch server command error when an item ID is not in active database
                if string.find(lowerMsg, "not found", 1, true) or string.find(lowerMsg, "could not find", 1, true) or string.find(lowerMsg, "invalid", 1, true) then
                    local entry = UnBot.lastSpawnedEntry
                    local itemId = entry[1]
                    local name = entry[5] or ""
                    local count = UnBot.lastSpawnedCount or 1
                    UnBot.lastSpawnedEntry = nil -- prevent loop

                    UnBot:Message("|cffff3333[Retinue Spawner]|r Item ID "..itemId.." ("..name..") was not found in server DB.")
                    UnBot:Message("|cffffd100[Retinue]|r Attempting name fallback: .additem \""..name.."\" "..count.."...")
                    SendChatMessage(".additem \""..name.."\" "..count, "SAY")
                end
            end
        end
    end)
    self.catalogEventFrame = f
end

function UnBot:SpawnCatalogItem(entry, count, useNameFallback)
    if not entry or not entry[1] then return end

    local itemId = entry[1]
    local name = entry[5] or ("Item ID "..itemId)
    local target = UnitName("target") or UnitName("player") or "Target"
    count = count or 1

    -- Track for error fallback
    self.lastSpawnedEntry = entry
    self.lastSpawnedTime = GetTime()
    self.lastSpawnedCount = count

    if useNameFallback then
        SendChatMessage(".additem \""..name.."\" "..count, "SAY")
        self:Message("Spawning by name: |cff00ff00"..name.."|r x"..count.." -> "..target)
    else
        SendChatMessage(".additem "..itemId.." "..count, "SAY")
        self:Message("Adding |cff00ff00"..name.."|r (ID: "..itemId..") x"..count.." -> "..target)
    end
end
