-- Retinue - Item Catalog & Spawner for Turtle WoW 1.18.1 / Vanilla 1.12.1
-- Displays searchable, filterable catalog of all 26,542 items from tw_world / tortoise-db-viewer.
-- Clicking an item executes .additem <id> 1 onto the targeted companion bot or player.
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
    local lvlDef = LEVEL_FILTERS[self.catalogFilterLevel] or LEVEL_FILTERS[1]
    local qDef = QUALITY_FILTERS[self.catalogFilterQuality] or QUALITY_FILTERS[1]
    local slotDef = SLOT_CATEGORIES[self.catalogFilterSlot] or SLOT_CATEGORIES[1]
    local search = string.lower(self.catalogSearchText or "")

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
        local reqLvl = entry[2] or 0
        local quality = entry[3] or 0
        local invType = entry[4] or 0
        local name = entry[5] or ""

        local pass = true

        -- Level check
        if reqLvl < lvlDef.minLvl or reqLvl > lvlDef.maxLvl then
            pass = false
        end

        -- Quality check
        if pass and qDef.q ~= -1 and quality ~= qDef.q then
            pass = false
        end

        -- Slot check
        if pass and slotDef.types ~= nil then
            if not slotDef.types[invType] then
                pass = false
            end
        end

        -- Search text check (substring match)
        if pass and search ~= "" then
            local lowerName = string.lower(name)
            if not string.find(lowerName, search, 1, true) then
                pass = false
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
    -- Exact width and height: fits 11 columns x 6 rows perfectly with zero dead space
    local f = CreateFrame("Frame", "UnBotCatalogFrame", UIParent)
    f:SetWidth(484)
    f:SetHeight(516)
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

    -- Subtitle / Target info
    local subtitle = f:CreateFontString(nil, "OVERLAY")
    subtitle:SetFont(UnBotFont, 11)
    subtitle:SetPoint("TOP", f, "TOP", 0, -32)
    subtitle:SetTextColor(0.8, 0.8, 0.8)
    f.subtitle = subtitle

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
    self.catalogLevelButtons = {}
    self.catalogQualityButtons = {}
    self.catalogSlotButtons = {}

    -- Row 1: Level Filters (7 buttons, width 52, gap 4 across 388px)
    local lvlLabel = parent:CreateFontString(nil, "OVERLAY")
    lvlLabel:SetFont(UnBotFont, 11)
    lvlLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, -54)
    lvlLabel:SetTextColor(1, 0.82, 0)
    lvlLabel:SetText("Level:")

    local numLevels = table.getn(LEVEL_FILTERS)
    for i = 1, numLevels do
        local def = LEVEL_FILTERS[i]
        local btn = CreateFrame("Button", "UnBotCatLvlBtn"..i, parent, "UIPanelButtonTemplate")
        btn:SetWidth(52)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 70 + (i - 1) * 56, -50)
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

    -- Row 2: Quality Filters (7 buttons, width 52, gap 4 across 388px)
    local qLabel = parent:CreateFontString(nil, "OVERLAY")
    qLabel:SetFont(UnBotFont, 11)
    qLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, -78)
    qLabel:SetTextColor(1, 0.82, 0)
    qLabel:SetText("Rarity:")

    local numQualities = table.getn(QUALITY_FILTERS)
    for i = 1, numQualities do
        local def = QUALITY_FILTERS[i]
        local btn = CreateFrame("Button", "UnBotCatQBtn"..i, parent, "UIPanelButtonTemplate")
        btn:SetWidth(52)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 70 + (i - 1) * 56, -74)
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

    -- Row 3 & 4: Slot Filter Header & Dedicated Selectable Slot Grid (22 buttons in 2 rows of 11)
    local slotHeader = parent:CreateFontString(nil, "OVERLAY")
    slotHeader:SetFont(UnBotFont, 11)
    slotHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, -100)
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
        btn:SetWidth(36)
        btn:SetHeight(26)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 24 + (col - 1) * 40, -118 - (row - 1) * 28)
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
    searchLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, -182)
    searchLabel:SetTextColor(1, 0.82, 0)
    searchLabel:SetText("Search:")

    local search = CreateFrame("EditBox", "UnBotCatalogSearchBox", parent)
    search:SetWidth(150)
    search:SetHeight(20)
    search:SetPoint("TOPLEFT", parent, "TOPLEFT", 72, -178)
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
    stats:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -24, -182)
    stats:SetTextColor(1, 0.82, 0)
    stats:SetJustifyH("RIGHT")
    stats:SetText("26,542 items")
    self.catalogStatsLabel = stats

    self.catalogSearchBox = search
end

function UnBot:CreateCatalogSlots(parent)
    self.catalogSlots = {}

    local startX = 24
    local startY = -206

    for row = 1, ROWS do
        for col = 1, COLS do
            local index = (row - 1) * COLS + col
            local slot = CreateFrame("Button", "UnBotCatSlot"..index, parent)
            slot:SetWidth(SLOT_SIZE)
            slot:SetHeight(SLOT_SIZE)
            slot:SetPoint("TOPLEFT", parent, "TOPLEFT",
                          startX + (col - 1) * (SLOT_SIZE + SLOT_GAP),
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
                    UnBot:SpawnCatalogItem(this.entry)
                end
            end)

            slot:SetScript("OnEnter", function()
                if not this.entry then return end
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")

                local itemId = this.entry[1]
                local reqLevel = this.entry[2]
                local quality = this.entry[3]
                local name = this.entry[5] or "Unknown Item"

                if itemId then
                    GameTooltip:SetHyperlink("item:"..itemId..":0:0:0")
                end

                if GameTooltip:NumLines() == 0 then
                    local color = QUALITY_COLORS[quality] or {1, 1, 1}
                    GameTooltip:AddLine(name, color[1], color[2], color[3])
                end

                if reqLevel and reqLevel > 0 then
                    GameTooltip:AddLine("Req Level: "..reqLevel, 0.8, 0.8, 0.8)
                end

                local target = UnitName("target") or UnitName("player") or "Target"
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Click: .additem "..itemId.." 1 -> "..target, 0.2, 1.0, 0.2)
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
    prev:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 24, 18)
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
    nextBtn:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 18)
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
    pageLabel:SetPoint("BOTTOM", parent, "BOTTOM", 0, 22)
    pageLabel:SetTextColor(1, 0.82, 0)
    pageLabel:SetText("Page 1 / 1")
    self.catalogPageLabel = pageLabel
end

function UnBot:CreateCatalogIconUpdater(parent)
    -- Throttled background updater that refreshes missing textures as server packets arrive
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
        UnBotCatalogFrame.subtitle:SetText("Selected Target: |cff00ff00"..target.."|r  (click item to add)")
    else
        local me = UnitName("player") or "Self"
        UnBotCatalogFrame.subtitle:SetText("Target: |cffffcc00"..me.."|r (Self)  (click item to add)")
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
    local slotDef = SLOT_CATEGORIES[self.catalogFilterSlot] or SLOT_CATEGORIES[1]
    if self.catalogSlotStatusText then
        if self.catalogFilterSlot == 1 then
            self.catalogSlotStatusText:SetText("|cffffffffAll Slots|r")
        else
            self.catalogSlotStatusText:SetText("|cffffd100"..slotDef.label.."|r")
        end
    end

    local numSlots = table.getn(SLOT_CATEGORIES)
    for i = 1, numSlots do
        local btn = self.catalogSlotButtons[i]
        if btn then
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
--  Spawning Command Handler
--=========================================================================--

function UnBot:SpawnCatalogItem(entry)
    if not entry or not entry[1] then return end

    local itemId = entry[1]
    local name = entry[5] or ("Item ID "..itemId)
    local target = UnitName("target") or UnitName("player") or "Target"

    -- tortoise-wow's HandleAddItemCommand automatically detects target from GetSelectedPlayer()
    SendChatMessage(".additem "..itemId.." 1", "SAY")
    self:Message("Adding |cff00ff00"..name.."|r (ID: "..itemId..") -> "..target)
end
