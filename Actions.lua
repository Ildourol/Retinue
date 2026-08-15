-- Warband command-group window.
--
-- The command bar is a directory of command groups.  Each primary button
-- opens one shared labelled window; clicking another group reuses that window
-- instead of leaving a collection of floating windows open.

local ACTION_BUTTON_WIDTH  = 150
local ACTION_BUTTON_HEIGHT = 24
local ACTION_MAX_COLS      = 3
local ACTION_COL_GAP       = 6
local ACTION_ROW_HEIGHT    = 26
local ACTION_ROW_COUNT     = 6
local ACTION_POOL_SIZE     = ACTION_MAX_COLS * ACTION_ROW_COUNT
local ACTION_SECTION_GAP   = 14
local ACTION_SECTION_MAX   = 5

StaticPopupDialogs["UNBOT_REMOVE_FAVORITE"] = {
    text = "Remove %s from favorites?",
    button1 = "Remove",
    button2 = "Cancel",
    OnAccept = function()
        if UnBot.pendingFavoriteRemoval then
            UnBot:RemoveFavorite(UnBot.pendingFavoriteRemoval)
            UnBot.pendingFavoriteRemoval = nil
        end
    end,
    OnCancel = function()
        UnBot.pendingFavoriteRemoval = nil
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

StaticPopupDialogs["UNBOT_CLEAR_FAVORITES"] = {
    text = "Clear all favorites?",
    button1 = "Clear all",
    button2 = "Cancel",
    OnAccept = function()
        UnBot:ClearFavorites()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

-- These match the intent-based command-to-group mapping in Data.lua.
local GROUP_TITLES = {
    [1]  = "Combat",
    [2]  = "Movement",
    [3]  = "Support",
    [4]  = "Inventory",
    [5]  = "Info & Status",
    [6]  = "Abilities",
    [7]  = "Party Management",
    [8]  = "Strategy",
    [9]  = "Formation",
    [10] = "Roster",
}

-- One unmistakable icon per group, instead of a single command's icon.
local GROUP_ICONS = {
    [1]  = "Interface\\Icons\\Ability_DualWield",
    [2]  = "Interface\\Icons\\Ability_Rogue_Sprint",
    [3]  = "Interface\\Icons\\Spell_Holy_Heal",
    [4]  = "Interface\\Icons\\INV_Misc_Bag_08",
    [5]  = "Interface\\Icons\\INV_Misc_Note_01",
    [6]  = "Interface\\Icons\\INV_Misc_Book_09",
    [7]  = "Interface\\Icons\\INV_Misc_Horn_02",
    [8]  = "Interface\\Icons\\Spell_Nature_Purge",
    [9]  = "Interface\\Icons\\INV_Weapon_Bow_02",
    [10] = "Interface\\Icons\\INV_Banner_02",
}

-- Short labels fit beside a 20px icon.  Hovering still shows the original
-- full command title, target type and server text.
local ACTION_LABELS = {
    [2] = "Init selected",       [3] = "Init party",
    [9] = "Reset party strategies", [10] = "Reset selected strategies",
    [13] = "Summon party",       [14] = "Summon selected",
    [15] = "Follow party",       [16] = "Follow selected",
    [17] = "Learn skills",       [18] = "Release party",
    [19] = "Release selected",   [20] = "Party quests",
    [21] = "Selected quests",    [22] = "Party status",
    [23] = "Selected status",    [24] = "Loot party",
    [25] = "Flee party",          [26] = "Tank flee",
    [27] = "DPS flee",            [28] = "Healer flee",
    [29] = "Melee flee",          [30] = "Ranged flee",
    [31] = "Flee selected",       [32] = "Attack target",
    [33] = "Tank attack",         [34] = "DPS attack",
    [35] = "Healer attack",        [36] = "Melee attack",
    [37] = "Ranged attack",       [38] = "Formation: arrow",
    [39] = "Formation: queue",    [40] = "Formation: near",
    [41] = "Formation: melee",    [42] = "Formation: line",
    [43] = "Formation: circle",   [44] = "Formation: chaos",
    [45] = "Formation: shield",   [46] = "View formation",
    [47] = "Hold party",           [54] = "Strategy",
    [62] = "Party combat strategies", [63] = "Selected combat strategies",
    [64] = "Inventory",            [65] = "Destroy item",
    [66] = "Equip item",           [67] = "Sell item",
    [68] = "Use item",             [69] = "Spells",
    [70] = "Stop combat",          [71] = "Disband party",
    [74] = "Player roster",        [76] = "Hold selected",
    [77] = "Refresh bot list",     [80] = "Ready check",
    [81] = "Drink",                [82] = "Log out party",
    [83] = "Log in party",         [85] = "Reset current state",
    [86] = "Remove selected",      [87] = "Add selected",
    [88] = "Add as friends",       [89] = "Grind party",
    [90] = "Buff party",           [91] = "Attack my target",
    [92] = "Pull my target",        [93] = "Equip upgrades",
    [94] = "Repair gear",          [95] = "Sell junk",
    [96] = "Talents",              [97] = "Trainer",
    [98] = "Resurrect",            [99] = "Eat",
    [100] = "Stop following",       [101] = "Give leader",
    [102] = "Roles",               [103] = "Use world object",
}

-- Counts follow UnBotCommandOrder. Each family starts on a fresh grid row.
local ACTION_SECTIONS = {
    [1] = { {"Attack & Pull", 8}, {"Stop & Flee", 7} },
    [2] = { {"Following", 3}, {"Position", 2} },
    [3] = { {"Preparation", 4}, {"Activities", 3}, {"Death", 3} },
    [4] = { {"Bags & equipment", 4}, {"Item actions", 4} },
    [5] = { {"Status", 2}, {"Combat strategies", 2}, {"Quests", 2} },
    [6] = { {"View", 2}, {"Training", 2} },
    [7] = { {"Selected bot", 2}, {"Party login", 2}, {"Gear", 2},
            {"Summoning", 2}, {"Group", 2} },
    [8] = { {"Editor", 1}, {"Current state", 1}, {"AI strategies", 2} },
    [9] = { {"Current formation", 1}, {"Set formation", 8} },
}

function UnBot:GetActionGroupTitle(groupIndex)
    if groupIndex == "favorites" then return "Favorites" end
    return GROUP_TITLES[groupIndex] or ("Command group "..tostring(groupIndex))
end

function UnBot:GetActionGroupIcon(groupIndex)
    return GROUP_ICONS[groupIndex] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function UnBot:ShowActionGroupTooltip(owner, groupIndex)
    GameTooltip:SetOwner(owner, "ANCHOR_TOPRIGHT")
    GameTooltip:AddLine(self:GetActionGroupTitle(groupIndex), 1, 0.82, 0)
    if groupIndex == 10 then
        GameTooltip:AddLine("Click to open the Player roster", 0.65, 0.55, 0)
    else
        GameTooltip:AddLine("Click to open this command window", 0.65, 0.55, 0)
    end

    if groupIndex ~= 10 and type(self.GetGroupCommands) == "function" then
        local count = table.getn(self:GetGroupCommands(groupIndex))
        GameTooltip:AddLine(count.." commands", 0.6, 1, 0.6)
    end
    GameTooltip:Show()
end

-- Kept as a compatibility alias for the first-slot experiment.
function UnBot:ToggleActions()
    self:ToggleActionGroup(1)
end

function UnBot:ToggleActionGroup(groupIndex)
    if not GROUP_TITLES[groupIndex] then return end

    -- The roster contains its own social controls, so an intermediary
    -- command window no longer adds anything.
    if groupIndex == 10 then
        if self.actionGroupFrame then self.actionGroupFrame:Hide() end
        self:ToggleRoster()
        return
    end

    if not self.actionGroupOffsets then self.actionGroupOffsets = {} end

    local sameGroup = self.actionWindowGroup == groupIndex
    self.actionWindowGroup = groupIndex

    if not self.actionGroupFrame then
        self:CreateActionGroupFrame()
    end

    if self.actionGroupFrame:IsShown() and sameGroup then
        self.actionGroupFrame:Hide()
    else
        self.actionGroupFrame:Show()
        self:RefreshActionGroup(groupIndex)
    end
end

function UnBot:ToggleFavoritesWindow()
    if not self.actionGroupOffsets then self.actionGroupOffsets = {} end

    local sameGroup = self.actionWindowGroup == "favorites"
    self.actionWindowGroup = "favorites"

    if not self.actionGroupFrame then
        self:CreateActionGroupFrame()
    end

    if self.actionGroupFrame:IsShown() and sameGroup then
        self.actionGroupFrame:Hide()
    else
        self.actionGroupFrame:Show()
        self:RefreshActionGroup("favorites")
    end
end

function UnBot:ConfirmRemoveFavorite(commandId)
    self.pendingFavoriteRemoval = commandId
    StaticPopup_Show("UNBOT_REMOVE_FAVORITE", self:GetTitle(commandId))
end

function UnBot:ConfirmClearFavorites()
    if table.getn(self:GetFavoriteCommands()) == 0 then return end
    StaticPopup_Show("UNBOT_CLEAR_FAVORITES")
end

function UnBot:CreateActionGroupFrame()
    local f = CreateFrame("Frame", "UnBotActionGroupFrame", UIParent)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:EnableMouseWheel(true)
    f.actionCols = ACTION_MAX_COLS
    self:MakeDraggable(f)
    self:RestoreFramePosition(f)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetScript("OnMouseWheel", function()
        if UnBot.actionWindowGroup then
            UnBot:ScrollActionGroup(UnBot.actionWindowGroup, -arg1)
        end
    end)
    f:Hide()

    if UISpecialFrames then
        table.insert(UISpecialFrames, "UnBotActionGroupFrame")
    end

    local title = f:CreateFontString("UnBotActionGroupTitle", "OVERLAY")
    title:SetFont(UnBotFont, 14)
    title:SetPoint("TOP", f, "TOP", 0, -16)
    title:SetTextColor(1, 0.82, 0)
    f.title = title

    f.sectionHeaders = {}
    for index = 1, ACTION_SECTION_MAX do
        local header = f:CreateFontString(nil, "OVERLAY")
        header:SetFont(UnBotFont, 9)
        header:SetHeight(10)
        header:SetJustifyH("LEFT")
        header:SetTextColor(0.75, 0.75, 0.75)
        header:Hide()
        f.sectionHeaders[index] = header
    end

    local close = CreateFrame("Button", "UnBotActionGroupClose", f,
                              "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    f.buttons = {}
    for index = 1, ACTION_POOL_SIZE do
        local button = CreateFrame("Button", "UnBotActionButton"..index, f)
        button:SetWidth(ACTION_BUTTON_WIDTH)
        button:SetHeight(ACTION_BUTTON_HEIGHT)
        button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight",
                                   "ADD")
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        local icon = button:CreateTexture("UnBotActionIcon"..index, "ARTWORK")
        icon:SetWidth(20)
        icon:SetHeight(20)
        icon:SetPoint("LEFT", button, "LEFT", 2, 0)
        button.icon = icon

        local label = button:CreateFontString("UnBotActionLabel"..index,
                                              "OVERLAY")
        label:SetFont(UnBotFont, 10)
        label:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        label:SetPoint("RIGHT", button, "RIGHT", -3, 0)
        label:SetJustifyH("LEFT")
        label:SetTextColor(0.9, 0.9, 0.9)
        button.label = label

        button:SetScript("OnClick", function()
            if not this.commandId then return end
            if arg1 == "RightButton" then
                UnBot:ToggleFavorite(this.commandId)
            else
                UnBot:RunCommand(this.commandId)
            end
        end)
        button:SetScript("OnEnter", function()
            if this.commandId then
                UnBot:ShowCommandTooltip(this, this.commandId, "action")
            end
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)

        button:Hide()
        f.buttons[index] = button
    end

    self.actionGroupFrame = f
end

function UnBot:GetActionGroupEntries(groupIndex)
    local ids = self:GetGroupCommands(groupIndex)
    if groupIndex == "favorites" then
        ids = self:GetFavoriteCommands()
    end
    local entries = {}

    for i = 1, table.getn(ids) do
        local commandId = ids[i]
        table.insert(entries, {
            id = commandId,
            label = ACTION_LABELS[commandId] or self:GetTitle(commandId),
        })
    end
    return entries
end

function UnBot:GetActionGroupSections(groupIndex)
    local entries = self:GetActionGroupEntries(groupIndex)
    local definitions = ACTION_SECTIONS[groupIndex]
    if not definitions then return { { title = nil, entries = entries } } end

    local sections = {}
    local entryIndex = 1
    for i = 1, table.getn(definitions) do
        local section = { title = definitions[i][1], entries = {} }
        for j = 1, definitions[i][2] do
            if entries[entryIndex] then
                table.insert(section.entries, entries[entryIndex])
                entryIndex = entryIndex + 1
            end
        end
        if table.getn(section.entries) > 0 then table.insert(sections, section) end
    end
    return sections
end

-- Pick the narrowest useful grid and account for each section starting a row.
function UnBot:GetActionGroupLayout(groupIndex)
    local entries = self:GetActionGroupEntries(groupIndex)
    local count = table.getn(entries)
    local columns = 1
    if count > 3 then columns = 2 end
    if count > 8 then columns = ACTION_MAX_COLS end

    local rows = 0
    local sections = self:GetActionGroupSections(groupIndex)
    for i = 1, table.getn(sections) do
        rows = rows + math.ceil(table.getn(sections[i].entries) / columns)
    end
    if rows < 1 then rows = 1 end

    local visibleRows = rows
    if visibleRows > ACTION_ROW_COUNT then visibleRows = ACTION_ROW_COUNT end
    local gaps = table.getn(sections) - 1
    if gaps < 0 then gaps = 0 end

    local width = 36 + columns * ACTION_BUTTON_WIDTH
                         + (columns - 1) * ACTION_COL_GAP
    local height = 64 + visibleRows * ACTION_ROW_HEIGHT
                      + gaps * ACTION_SECTION_GAP
    return columns, width, height
end

function UnBot:ScrollActionGroup(groupIndex, delta)
    -- Defined command groups fit in six section-aware rows. Favorites remain
    -- a flat list and retain wheel scrolling for arbitrarily long saved lists.
    if groupIndex ~= "favorites" then return end
    local entries = self:GetActionGroupEntries(groupIndex)
    local columns = self:GetActionGroupLayout(groupIndex)
    local rowTotal = math.ceil(table.getn(entries) / columns)
    local maxOffset = rowTotal - ACTION_ROW_COUNT
    if maxOffset < 0 then maxOffset = 0 end

    if not self.actionGroupOffsets then self.actionGroupOffsets = {} end
    self.actionGroupOffsets[groupIndex] =
        (self.actionGroupOffsets[groupIndex] or 0) + delta
    if self.actionGroupOffsets[groupIndex] < 0 then
        self.actionGroupOffsets[groupIndex] = 0
    end
    if self.actionGroupOffsets[groupIndex] > maxOffset then
        self.actionGroupOffsets[groupIndex] = maxOffset
    end
    self:RefreshActionGroup(groupIndex)
end

function UnBot:RefreshActionGroup(groupIndex)
    local f = self.actionGroupFrame
    if not f then return end

    local entries = self:GetActionGroupEntries(groupIndex)
    local sections = self:GetActionGroupSections(groupIndex)
    local columns, width, height = self:GetActionGroupLayout(groupIndex)
    local offset = 0
    if groupIndex == "favorites" and self.actionGroupOffsets then
        offset = self.actionGroupOffsets[groupIndex] or 0
    end

    f:SetWidth(width)
    f:SetHeight(height)
    f.actionCols = columns
    f.title:SetText(self:GetActionGroupTitle(groupIndex))

    for index = 1, ACTION_SECTION_MAX do f.sectionHeaders[index]:Hide() end
    for index = 1, ACTION_POOL_SIZE do
        f.buttons[index].commandId = nil
        f.buttons[index]:Hide()
    end

    if groupIndex == "favorites" then
        for row = 1, ACTION_ROW_COUNT do
            for col = 1, columns do
                local poolIndex = (row - 1) * ACTION_MAX_COLS + col
                local entryIndex = offset * columns + (row - 1) * columns + col
                local entry = entries[entryIndex]
                local button = f.buttons[poolIndex]
                button:ClearAllPoints()
                button:SetPoint("TOPLEFT", f, "TOPLEFT",
                                18 + (col - 1) * (ACTION_BUTTON_WIDTH + ACTION_COL_GAP),
                                -48 - (row - 1) * ACTION_ROW_HEIGHT)
                if entry then
                    button.commandId = entry.id
                    button.icon:SetTexture(self:GetIconPath(entry.id))
                    button.label:SetText(entry.label)
                    button:Show()
                end
            end
        end
        return
    end

    local physicalRow = 0
    for sectionIndex = 1, table.getn(sections) do
        local section = sections[sectionIndex]
        local gap = (sectionIndex - 1) * ACTION_SECTION_GAP
        local header = f.sectionHeaders[sectionIndex]
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", f, "TOPLEFT", 18,
                        -34 - physicalRow * ACTION_ROW_HEIGHT - gap)
        header:SetText(section.title)
        header:Show()

        for sectionEntry = 1, table.getn(section.entries) do
            local sectionRow = math.floor((sectionEntry - 1) / columns)
            local col = math.mod(sectionEntry - 1, columns) + 1
            local row = physicalRow + sectionRow + 1
            local poolIndex = (row - 1) * ACTION_MAX_COLS + col
            local entry = section.entries[sectionEntry]
            local button = f.buttons[poolIndex]
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", f, "TOPLEFT",
                            18 + (col - 1) * (ACTION_BUTTON_WIDTH + ACTION_COL_GAP),
                            -48 - (row - 1) * ACTION_ROW_HEIGHT - gap)
            button.commandId = entry.id
            button.icon:SetTexture(self:GetIconPath(entry.id))
            local label = entry.label
            if type(self.IsFavorite) == "function" and self:IsFavorite(entry.id) then
                label = "* "..label
            end
            button.label:SetText(label)
            button:Show()
        end
        physicalRow = physicalRow
                      + math.ceil(table.getn(section.entries) / columns)
    end
end

function UnBot:HideActionGroupWindows()
    if self.actionGroupFrame then self.actionGroupFrame:Hide() end
end

function UnBot:HideActions()
    self:HideActionGroupWindows()
end
