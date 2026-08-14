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
local COMBAT_ATTACK_COUNT  = 8
local COMBAT_SECTION_GAP   = 14

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
    [6]  = "Training & Abilities",
    [7]  = "Party Management",
    [8]  = "Strategy & AI",
    [9]  = "Formation",
    [10] = "Roster & Social",
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
    [9] = "Reset party AI",      [10] = "Reset selected AI",
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
    [62] = "Party AI status",     [63] = "Selected AI status",
    [64] = "Inventory",            [65] = "Destroy item",
    [66] = "Equip item",           [67] = "Sell item",
    [68] = "Use item",             [69] = "Spells",
    [70] = "Stop combat",          [71] = "Disband party",
    [74] = "Bot roster",           [76] = "Hold selected",
    [77] = "Refresh bot list",     [80] = "Ready check",
    [81] = "Eat / drink (alt)",    [82] = "Log out party",
    [83] = "Log in party",         [85] = "Reset party",
    [86] = "Remove selected",      [87] = "Add selected",
    [88] = "Add as friends",       [89] = "Grind party",
    [90] = "Buff party",           [91] = "Attack my target",
    [92] = "Pull my target",        [93] = "Equip upgrades",
    [94] = "Repair gear",          [95] = "Sell junk",
    [96] = "Talents",              [97] = "Trainer",
    [98] = "Resurrect",            [99] = "Eat / drink",
    [100] = "Stop following",       [101] = "Give leader",
    [102] = "Roles",               [103] = "Use world object",
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
    GameTooltip:AddLine("Click to open this command window", 0.65, 0.55, 0)

    if type(self.GetGroupCommands) == "function" then
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

    local combatHeader = f:CreateFontString(nil, "OVERLAY")
    combatHeader:SetFont(UnBotFont, 9)
    combatHeader:SetHeight(10)
    combatHeader:SetJustifyH("LEFT")
    combatHeader:SetTextColor(0.75, 0.75, 0.75)
    combatHeader:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -34)
    combatHeader:Hide()
    f.combatHeader = combatHeader

    local combatSectionLabel = f:CreateFontString(nil, "OVERLAY")
    combatSectionLabel:SetFont(UnBotFont, 9)
    combatSectionLabel:SetHeight(10)
    combatSectionLabel:SetJustifyH("LEFT")
    combatSectionLabel:SetTextColor(0.75, 0.75, 0.75)
    combatSectionLabel:Hide()
    f.combatSectionLabel = combatSectionLabel

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

-- Pick the narrowest useful grid for this group's command count.  Small groups
-- should not inherit a wide three-column frame or a tall six-row frame.
function UnBot:GetActionGroupLayout(groupIndex)
    local count = table.getn(self:GetActionGroupEntries(groupIndex))
    local columns = 1
    if count > 3 then columns = 2 end
    if count > 8 then columns = ACTION_MAX_COLS end

    local rows = math.ceil(count / columns)
    if rows < 1 then rows = 1 end

    local visibleRows = rows
    if visibleRows > ACTION_ROW_COUNT then
        visibleRows = ACTION_ROW_COUNT
    end

    local width = 36 + columns * ACTION_BUTTON_WIDTH
                         + (columns - 1) * ACTION_COL_GAP
    local height = 64 + visibleRows * ACTION_ROW_HEIGHT
    if groupIndex == 1 and count > COMBAT_ATTACK_COUNT then
        height = height + COMBAT_SECTION_GAP
    end
    return columns, width, height
end

function UnBot:ScrollActionGroup(groupIndex, delta)
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
    local columns, width, height = self:GetActionGroupLayout(groupIndex)
    local offset = 0
    if self.actionGroupOffsets then
        offset = self.actionGroupOffsets[groupIndex] or 0
    end

    f:SetWidth(width)
    f:SetHeight(height)
    f.actionCols = columns
    f.title:SetText(self:GetActionGroupTitle(groupIndex))

    local combatAttackRows
    local combatSlots
    if groupIndex == 1 and table.getn(entries) > COMBAT_ATTACK_COUNT then
        combatAttackRows = math.ceil(COMBAT_ATTACK_COUNT / columns)
        combatSlots = {}
        for entryIndex = 1, table.getn(entries) do
            local row
            local col
            if entryIndex <= COMBAT_ATTACK_COUNT then
                local slot = entryIndex - 1
                row = math.floor(slot / columns) + 1
                col = math.mod(slot, columns) + 1
            else
                local slot = entryIndex - COMBAT_ATTACK_COUNT - 1
                row = combatAttackRows + math.floor(slot / columns) + 1
                col = math.mod(slot, columns) + 1
            end
            combatSlots[(row - 1) * ACTION_MAX_COLS + col] = entries[entryIndex]
        end

        f.combatHeader:SetText("Attack & Pull")
        f.combatHeader:Show()

        local sectionY = -48 - combatAttackRows * ACTION_ROW_HEIGHT
                        - (COMBAT_SECTION_GAP / 2)
        f.combatSectionLabel:ClearAllPoints()
        f.combatSectionLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 18,
                                      sectionY + 5)
        f.combatSectionLabel:SetText("Stop & Flee")
        f.combatSectionLabel:Show()
    else
        f.combatHeader:Hide()
        f.combatSectionLabel:Hide()
    end

    for index = 1, ACTION_POOL_SIZE do
        local button = f.buttons[index]
        button.commandId = nil
        button:Hide()
    end

    for row = 1, ACTION_ROW_COUNT do
        for col = 1, columns do
            local poolIndex = (row - 1) * ACTION_MAX_COLS + col
            local entryIndex = offset * columns + (row - 1) * columns + col
            local entry
            if combatSlots then
                entry = combatSlots[poolIndex]
            else
                entry = entries[entryIndex]
            end
            local button = f.buttons[poolIndex]
            local rowGap = 0
            if combatAttackRows and row > combatAttackRows then
                rowGap = COMBAT_SECTION_GAP
            end

            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", f, "TOPLEFT",
                            18 + (col - 1) * (ACTION_BUTTON_WIDTH + ACTION_COL_GAP),
                            -48 - (row - 1) * ACTION_ROW_HEIGHT - rowGap)

            if entry then
                button.commandId = entry.id
                button.icon:SetTexture(self:GetIconPath(entry.id))
                local label = entry.label
                if type(self.IsFavorite) == "function"
                   and self:IsFavorite(entry.id) then
                    label = "* "..label
                end
                button.label:SetText(label)
                button:Show()
            else
                button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                button.label:SetText("")
            end
        end
    end
end

function UnBot:HideActionGroupWindows()
    if self.actionGroupFrame then self.actionGroupFrame:Hide() end
end

function UnBot:HideActions()
    self:HideActionGroupWindows()
end
