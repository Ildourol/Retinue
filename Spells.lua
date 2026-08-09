-- UnBot spell list.
--
-- Whisper "spells" and the bot answers with Hspell links, many per line. The
-- raw list runs to hundreds of entries, so they are sorted into groups by
-- keyword and shown as collapsible sections, same as the strategy editor.
--
-- Buff-type spells are what you actually want to cast on a bot, so those
-- groups come first and the rest can be hidden entirely.

local ROW_COUNT  = 16
local ROW_HEIGHT = 17

-- Order matters: the first keyword found decides the group.
local GROUPS = {
    { key = "aura",       label = "Auras",       buff = true },
    { key = "blessing",   label = "Blessings",   buff = true },
    { key = "shout",      label = "Shouts",      buff = true },
    { key = "aspect",     label = "Aspects",     buff = true },
    { key = "seal",       label = "Seals",       buff = true },
    { key = "armor",      label = "Armor",       buff = true },
    { key = "ward",       label = "Wards",       buff = true },
    { key = "totem",      label = "Totems",      buff = true },
    { key = "form",       label = "Forms",       buff = true },
    { key = "presence",   label = "Presence",    buff = true },
    { key = "intellect",  label = "Intellect",   buff = true },
    { key = "fortitude",  label = "Fortitude",   buff = true },
    { key = "spirit",     label = "Spirit",      buff = true },
    { key = "mark of",    label = "Mark",        buff = true },
    { key = "thorns",     label = "Thorns",      buff = true },
    { key = "strength",   label = "Strength",    buff = true },
    { key = "power word", label = "Power Word",  buff = true },
    { key = "gift of",    label = "Gifts",       buff = true },
}

--=========================================================================--
--  Grouping
--=========================================================================--

local function GroupFor(name)
    local lower = string.lower(name)
    for i = 1, table.getn(GROUPS) do
        if string.find(lower, GROUPS[i].key, 1, true) then
            return GROUPS[i].label, true
        end
    end
    return "Other", false
end

function UnBot:BuildSpellTree()
    local tree    = {}
    local buckets = {}
    local isBuff  = {}

    for i = 1, table.getn(self.spellList or {}) do
        local spell = self.spellList[i]
        local label, buff = GroupFor(spell.name)

        if buff or not self.spellBuffsOnly then
            if not buckets[label] then
                buckets[label] = {}
                isBuff[label]  = buff
            end
            table.insert(buckets[label], spell.name)
        end
    end

    -- keep the declared order, with Other last
    for i = 1, table.getn(GROUPS) do
        local label = GROUPS[i].label
        if buckets[label] then
            table.sort(buckets[label])
            table.insert(tree, { label = label, items = buckets[label], buff = true })
            buckets[label] = nil
        end
    end
    if buckets["Other"] then
        table.sort(buckets["Other"])
        table.insert(tree, { label = "Other", items = buckets["Other"], buff = false })
    end

    return tree
end

function UnBot:GetSpellRows()
    local rows = {}
    local tree = self.spellTree or {}

    for i = 1, table.getn(tree) do
        local node = tree[i]
        table.insert(rows, {
            header = true,
            label  = node.label,
            count  = table.getn(node.items),
            buff   = node.buff,
        })
        if self.expandedSpellGroups[node.label] then
            for j = 1, table.getn(node.items) do
                table.insert(rows, { header = false, name = node.items[j],
                                     buff = node.buff })
            end
        end
    end

    return rows
end

--=========================================================================--
--  Window
--=========================================================================--

function UnBot:ShowSpellWindow()
    local target = self:GetBotTarget()
    if not target then return end

    if not UnBotSpellFrame then self:CreateSpellFrame() end

    self.spellTarget          = target
    self.spellOffset          = 0
    self.spellList            = {}
    self.expandedSpellGroups  = self.expandedSpellGroups or {}
    if self.spellBuffsOnly == nil then self.spellBuffsOnly = true end
    self.spellTree            = self:BuildSpellTree()

    UnBotSpellFrame:Show()
    self:RefreshSpells()
    SendChatMessage("spells", "WHISPER", nil, target)
end

function UnBot:CreateSpellFrame()
    local f = CreateFrame("Frame", "UnBotSpellFrame", UIParent)
    f:SetWidth(360)
    f:SetHeight(ROW_COUNT * ROW_HEIGHT + 130)
    f:SetPoint("CENTER", UIParent, "CENTER", -260, 0)
    f:EnableMouseWheel(true)
    self:MakeDraggable(f)
    self:RestoreFramePosition(f)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetScript("OnMouseWheel", function() UnBot:ScrollSpells(-arg1) end)
    f:Hide()

    if UISpecialFrames then
        table.insert(UISpecialFrames, "UnBotSpellFrame")
    end

    local title = f:CreateFontString("UnBotSpellTitle", "OVERLAY")
    title:SetFont(UnBotFont, 14)
    title:SetPoint("TOP", f, "TOP", 0, -16)
    title:SetTextColor(1, 0.82, 0)
    f.title = title

    local close = CreateFrame("Button", "UnBotSpellClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    local filter = CreateFrame("Button", "UnBotSpellFilter", f, "UIPanelButtonTemplate")
    filter:SetWidth(150)
    filter:SetHeight(21)
    filter:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -40)
    filter:SetScript("OnClick", function()
        UnBot.spellBuffsOnly = not UnBot.spellBuffsOnly
        UnBot.spellOffset = 0
        UnBot.spellTree = UnBot:BuildSpellTree()
        UnBot:RefreshSpells()
    end)
    f.filter = filter

    local refresh = CreateFrame("Button", "UnBotSpellRefresh", f, "UIPanelButtonTemplate")
    refresh:SetWidth(150)
    refresh:SetHeight(21)
    refresh:SetPoint("TOPLEFT", f, "TOPLEFT", 190, -40)
    refresh:SetText("Refresh")
    refresh:SetScript("OnClick", function()
        if not UnBot.spellTarget then return end
        UnBot.spellList = {}
        UnBot.spellTree = UnBot:BuildSpellTree()
        UnBot:RefreshSpells()
        SendChatMessage("spells", "WHISPER", nil, UnBot.spellTarget)
    end)

    self:CreateSpellRows(f)

    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont(UnBotFont, 10)
    hint:SetPoint("BOTTOM", f, "BOTTOM", 0, 16)
    hint:SetTextColor(0.6, 0.6, 0.6)
    f.hint = hint
end

function UnBot:CreateSpellRows(parent)
    self.spellRows = {}

    for i = 1, ROW_COUNT do
        local row = CreateFrame("Button", "UnBotSpellRow"..i, parent)
        row:SetWidth(320)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 18, -68 - (i - 1) * ROW_HEIGHT)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        local text = row:CreateFontString(nil, "OVERLAY")
        text:SetFont(UnBotFont, 11)
        text:SetPoint("LEFT", row, "LEFT", 6, 0)
        row.text = text

        row:SetScript("OnClick", function()
            if this.groupLabel then
                UnBot.expandedSpellGroups[this.groupLabel] =
                    not UnBot.expandedSpellGroups[this.groupLabel]
                UnBot:RefreshSpells()
            elseif this.spellName then
                UnBot:CastSpell(this.spellName)
            end
        end)

        row:SetScript("OnEnter", function()
            if this.groupLabel then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine(this.groupLabel, 1, 0.82, 0)
                GameTooltip:AddLine("Click to open or close", 0.65, 0.55, 0)
                GameTooltip:Show()
            elseif this.spellName then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine(this.spellName, 1, 1, 1)
                GameTooltip:AddLine("Click: cast on whatever the bot has targeted",
                                    0.65, 0.55, 0)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:Hide()
        self.spellRows[i] = row
    end
end

-- "cast <spell>" only ever uses the bot's own current target: appending a name
-- makes it read the whole string as the spell ("I do not know the spell Mark of
-- the Wild Sigman"). Buffing a specific player therefore has to go through the
-- bot's buff strategies, not through single casts.
function UnBot:CastSpell(name)
    if not self.spellTarget then return end
    SendChatMessage("cast "..name, "WHISPER", nil, self.spellTarget)
    self:Message("cast "..name.." -> "..self.spellTarget)
end

--=========================================================================--
--  Receiving
--=========================================================================--

-- One whisper can carry many spell links.
function UnBot:ReceiveSpells(msg, sender)
    if not msg or not sender then return end
    if not UnBotSpellFrame or not UnBotSpellFrame:IsShown() then return end
    if sender ~= self.spellTarget then return end

    local added = 0
    local pos = 1
    while true do
        local s, e, id, name = string.find(msg, "Hspell:(%d+)[^|]*|h%[([^%]]+)%]", pos)
        if not s then break end
        table.insert(self.spellList, { id = tonumber(id), name = name })
        added = added + 1
        pos = e + 1
    end

    if added > 0 then
        self.spellTree = self:BuildSpellTree()
        self:RefreshSpells()
    end
end

function UnBot:InitSpellEvents()
    local f = CreateFrame("Frame", "UnBotSpellEvents")
    f:RegisterEvent("CHAT_MSG_WHISPER")
    f:SetScript("OnEvent", function()
        UnBot:ReceiveSpells(arg1, arg2)
    end)
end

--=========================================================================--
--  Refresh
--=========================================================================--

function UnBot:ScrollSpells(delta)
    local total = table.getn(self:GetSpellRows())
    local maxOffset = total - ROW_COUNT
    if maxOffset < 0 then maxOffset = 0 end

    self.spellOffset = self.spellOffset + delta
    if self.spellOffset < 0 then self.spellOffset = 0 end
    if self.spellOffset > maxOffset then self.spellOffset = maxOffset end
    self:RefreshSpells()
end

function UnBot:RefreshSpells()
    if not UnBotSpellFrame then return end
    local f = UnBotSpellFrame

    f.title:SetText((self.spellTarget or "?").."  -  spells")
    if self.spellBuffsOnly then
        f.filter:SetText("Buffs only")
    else
        f.filter:SetText("Everything")
    end

    local rows = self:GetSpellRows()

    for i = 1, ROW_COUNT do
        local row   = self.spellRows[i]
        local entry = rows[i + self.spellOffset]

        row.groupLabel = nil
        row.spellName  = nil

        if entry and entry.header then
            row.groupLabel = entry.label
            local mark = "+"
            if self.expandedSpellGroups[entry.label] then mark = "-" end
            row.text:SetText(mark.." "..entry.label.."  ("..entry.count..")")
            if entry.buff then
                row.text:SetTextColor(1, 0.82, 0)
            else
                row.text:SetTextColor(0.55, 0.75, 1)
            end
            row:Show()

        elseif entry then
            row.spellName = entry.name
            row.text:SetText("      "..entry.name)
            row.text:SetTextColor(0.9, 0.9, 0.9)
            row:Show()

        else
            row:Hide()
        end
    end

    local total = table.getn(self.spellList or {})
    if total == 0 then
        f.hint:SetText("Waiting for "..(self.spellTarget or "the bot").."...")
    else
        f.hint:SetText(total.." spells known    Click one to cast it")
    end
end
