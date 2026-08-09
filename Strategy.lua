-- UnBot Strategy editor.
--
-- Strategies are the bot's behaviour rules, in two sets:
--   co +name / co -name / co ~name   combat
--   nc +name / nc -name / nc ~name   out of combat
--
-- Names are sent WITHOUT the class prefix: the strategy stored as
-- "warrior aoe fury pve" is toggled with "co ~aoe fury pve". The list is
-- learned from the bot's own help output (UnBot:ParseStrategyList), never
-- hardcoded, so it always matches the server.
--
-- A class has ~90 strategies and there are ~100 generic ones, so they are
-- grouped by their first word ("tank", "aoe", "buff"...) into collapsible
-- sections rather than one endless list.

local ROW_COUNT  = 16
local ROW_HEIGHT = 17

local CLASS_TOKEN = {
    WARRIOR = "warrior", PALADIN = "paladin", HUNTER = "hunter",
    ROGUE   = "rogue",   PRIEST  = "priest",  SHAMAN = "shaman",
    MAGE    = "mage",    WARLOCK = "warlock", DRUID  = "druid",
}

--=========================================================================--
--  Role presets
--
--  One button per class: left-click sets the primary role, right-click the
--  secondary. Each preset turns its own strategies on and the competing ones
--  off, and is applied to every bot of that class in the group at once.
--
--  Every name below was read back from this server's own strategy lists, so
--  they are the real ones rather than guesses.
--=========================================================================--

local ROLE_PRESETS = {
    WARRIOR = {
        primary   = { label = "Tank", on = {"protection"}, off = {"arms", "fury"} },
        secondary = { label = "DPS",  on = {"fury"}, off = {"protection"} },
    },
    PALADIN = {
        primary   = { label = "Heal", on = {"holy"}, off = {"protection", "retribution"} },
        secondary = { label = "Tank", on = {"protection"}, off = {"holy", "retribution"} },
    },
    HUNTER = {
        primary   = { label = "Marks", on = {"marksmanship"},
                      off = {"beast mastery", "survival"} },
        secondary = { label = "Beast", on = {"beast mastery"},
                      off = {"marksmanship", "survival"} },
    },
    ROGUE = {
        primary   = { label = "Combat",  on = {"combat"},
                      off = {"subtlety", "assassination"} },
        secondary = { label = "Subtle", on = {"subtlety"},
                      off = {"combat", "assassination"} },
    },
    PRIEST = {
        primary   = { label = "Heal",   on = {"holy"},   off = {"shadow"} },
        secondary = { label = "Shadow", on = {"shadow"}, off = {"holy", "discipline"} },
    },
    SHAMAN = {
        primary   = { label = "Heal", on = {"restoration"},
                      off = {"elemental", "enhancement"} },
        secondary = { label = "DPS",  on = {"enhancement"},
                      off = {"restoration", "elemental"} },
    },
    MAGE = {
        primary   = { label = "Frost", on = {"frost"}, off = {"fire", "arcane"} },
        secondary = { label = "Fire",  on = {"fire"},  off = {"frost", "arcane"} },
    },
    WARLOCK = {
        primary   = { label = "Destro", on = {"destruction"},
                      off = {"affliction", "demonology"} },
        secondary = { label = "Affli",  on = {"affliction"},
                      off = {"destruction", "demonology"} },
    },
    DRUID = {
        primary   = { label = "Heal", on = {"restoration"},
                      off = {"balance", "dps feral", "tank feral"} },
        secondary = { label = "Feral", on = {"dps feral"},
                      off = {"restoration", "balance"} },
    },
}

local CLASS_COLOR = {
    WARRIOR = {0.78, 0.61, 0.43}, PALADIN = {0.96, 0.55, 0.73},
    HUNTER  = {0.67, 0.83, 0.45}, ROGUE   = {1.00, 0.96, 0.41},
    PRIEST  = {1.00, 1.00, 1.00}, SHAMAN  = {0.14, 0.35, 1.00},
    MAGE    = {0.41, 0.80, 0.94}, WARLOCK = {0.58, 0.51, 0.79},
    DRUID   = {1.00, 0.49, 0.04},
}

local ROLE_ORDER = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}

-- Only send names the server actually reported for that class. If we have not
-- learned its list yet, send everything and let the bot sort it out.
local function KnownOnly(classToken, names)
    local class = CLASS_TOKEN[classToken]
    local store = UnBot.config and UnBot.config.strategies
    if not class or not store or not store[class] then return names end

    local out = {}
    for i = 1, table.getn(names) do
        if store[class][names[i]] then table.insert(out, names[i]) end
    end
    return out
end

local function ForEachGroupMemberOfClass(classToken, func)
    local raid = GetNumRaidMembers()
    if raid > 0 then
        for i = 1, raid do
            local _, token = UnitClass("raid"..i)
            if token == classToken then func(UnitName("raid"..i)) end
        end
    else
        for i = 1, GetNumPartyMembers() do
            local _, token = UnitClass("party"..i)
            if token == classToken then func(UnitName("party"..i)) end
        end
    end
end

function UnBot:ApplyRole(classToken, which)
    local preset = ROLE_PRESETS[classToken]
    if not preset then return end
    local role = preset[which]
    if not role then return end

    local on  = KnownOnly(classToken, role.on)
    local off = KnownOnly(classToken, role.off)

    local targets = 0
    ForEachGroupMemberOfClass(classToken, function(name)
        targets = targets + 1
        for i = 1, table.getn(off) do
            self:QueueChat("co -"..off[i], "WHISPER", name)
        end
        for i = 1, table.getn(on) do
            self:QueueChat("co +"..on[i], "WHISPER", name)
        end
    end)

    if targets == 0 then
        self:Message("No "..string.lower(classToken).." in your group")
    else
        self:Message(role.label.." -> "..targets.." "..string.lower(classToken).."(s)")
    end
end

--=========================================================================--
--  Tree
--=========================================================================--

local function SortedKeys(t)
    local out = {}
    for k in pairs(t) do table.insert(out, k) end
    table.sort(out)
    return out
end

-- Grouping by first word would scatter the raid and battleground strategies
-- into a dozen one-line sections ("naxxramas", "onyxia's", "molten"...), so
-- these are collected under one heading each instead.
local SPECIAL_GROUP = {
    ["dungeon"]           = "instance",
    ["karazhan"]          = "instance",
    ["magmadar"]          = "instance",
    ["molten core"]       = "instance",
    ["naxxramas"]         = "instance",
    ["netherspite"]       = "instance",
    ["onyxia"]            = "instance",
    ["onyxia's lair"]     = "instance",
    ["prince malchezaar"] = "instance",
    ["four horseman"]     = "instance",
    ["isle"]              = "instance",
    ["eye"]               = "instance",

    ["alterac"]      = "pvp",
    ["arathi"]       = "pvp",
    ["arena"]        = "pvp",
    ["battleground"] = "pvp",
    ["bg"]           = "pvp",
    ["warsong"]      = "pvp",
    ["duel"]         = "pvp",
    ["start duel"]   = "pvp",
    ["pvp"]          = "pvp",
    ["nowar"]        = "pvp",
}

-- { {category, items, class}, ... } - class sections first, then generic.
function UnBot:BuildStrategyTree()
    local tree  = {}
    local store = self.config.strategies
    if not store then return tree end

    local function AddSections(source, isClass)
        if not source then return end

        local buckets = {}
        for short in pairs(source) do
            local cat = SPECIAL_GROUP[short]
            if not cat then
                local _, _, first = string.find(short, "^(%S+)")
                cat = first or short
            end
            if not buckets[cat] then buckets[cat] = {} end
            table.insert(buckets[cat], short)
        end

        local names = SortedKeys(buckets)
        for i = 1, table.getn(names) do
            local cat = names[i]
            table.sort(buckets[cat])
            table.insert(tree, {
                category = cat,
                items    = buckets[cat],
                class    = isClass,
            })
        end
    end

    local class = CLASS_TOKEN[self.strategyClass or ""]
    if class then AddSections(store[class], true) end
    AddSections(store.generic, false)

    return tree
end

-- Flatten the tree into what is actually drawn, honouring collapsed sections.
function UnBot:GetStrategyRows()
    local rows = {}
    local tree = self.strategyTree or {}

    for i = 1, table.getn(tree) do
        local node = tree[i]
        table.insert(rows, {
            header   = true,
            category = node.category,
            count    = table.getn(node.items),
            class    = node.class,
        })
        if self.expandedSections[node.category] then
            for j = 1, table.getn(node.items) do
                table.insert(rows, {
                    header = false,
                    name   = node.items[j],
                    class  = node.class,
                })
            end
        end
    end

    return rows
end

function UnBot:HaveStrategiesFor(classToken)
    local class = CLASS_TOKEN[classToken or ""]
    if not class then return true end
    local store = self.config.strategies
    return store ~= nil and store[class] ~= nil
end

--=========================================================================--
--  Window
--=========================================================================--

function UnBot:ShowStrategyWindow()
    local target = self:GetBotTarget()
    if not target then return end

    local _, classToken = UnitClass("target")
    if not classToken then classToken = string.upper(UnitClass("target") or "") end

    if not UnBotStrategyFrame then self:CreateStrategyFrame() end

    self.strategyTarget    = target
    self.strategyClass     = classToken
    self.strategyMode      = self.strategyMode or "co"
    self.strategyOffset    = 0
    self.expandedSections  = self.expandedSections or {}
    self.strategyTree      = self:BuildStrategyTree()

    UnBotStrategyFrame:Show()
    self:RefreshStrategies()

    -- Fetch this class's list once, then ask which strategies are active.
    if not self:HaveStrategiesFor(classToken) then
        local class = CLASS_TOKEN[classToken]
        if class then
            self:Message("Fetching "..class.." strategies from "..target.."...")
            SendChatMessage("|c0000FFFF|Hvalue:help:list:"..class..
                            " strategy|h["..class.."]|h|r", "WHISPER", nil, target)
        end
    end
    SendChatMessage(self.strategyMode, "WHISPER", nil, target)
end

-- Called when new names arrive so an open window picks them up.
function UnBot:RebuildStrategyTree()
    if not UnBotStrategyFrame or not UnBotStrategyFrame:IsShown() then return end
    self.strategyTree = self:BuildStrategyTree()
    self:RefreshStrategies()
end

--=========================================================================--
--  Role bar
--=========================================================================--

function UnBot:ToggleRoleBar()
    if not UnBotRoleFrame then self:CreateRoleFrame() end
    if UnBotRoleFrame:IsShown() then
        UnBotRoleFrame:Hide()
    else
        UnBotRoleFrame:Show()
    end
end

function UnBot:CreateRoleFrame()
    local count = table.getn(ROLE_ORDER)
    local f = CreateFrame("Frame", "UnBotRoleFrame", UIParent)
    f:SetWidth(96)
    f:SetHeight(count * 22 + 44)
    f:SetPoint("LEFT", UIParent, "LEFT", 40, 0)
    self:MakeDraggable(f)
    self:RestoreFramePosition(f)
    f:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.8)
    f:Hide()

    if UISpecialFrames then
        table.insert(UISpecialFrames, "UnBotRoleFrame")
    end

    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont(UnBotFont, 11)
    title:SetPoint("TOP", f, "TOP", 0, -8)
    title:SetTextColor(1, 0.82, 0)
    title:SetText("Roles")

    for i = 1, count do
        local class = ROLE_ORDER[i]
        local preset = ROLE_PRESETS[class]

        local btn = CreateFrame("Button", "UnBotRole"..class, f)
        btn:SetWidth(84)
        btn:SetHeight(20)
        btn:SetPoint("TOP", f, "TOP", 0, -24 - (i - 1) * 22)
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        btn.class = class

        local text = btn:CreateFontString(nil, "OVERLAY")
        text:SetFont(UnBotFont, 11)
        text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        local c = CLASS_COLOR[class]
        text:SetTextColor(c[1], c[2], c[3])
        text:SetText(string.upper(string.sub(class, 1, 1))
                     ..string.lower(string.sub(class, 2)))

        btn:SetScript("OnClick", function()
            if arg1 == "RightButton" then
                UnBot:ApplyRole(this.class, "secondary")
            else
                UnBot:ApplyRole(this.class, "primary")
            end
        end)

        btn:SetScript("OnEnter", function()
            local p = ROLE_PRESETS[this.class]
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:AddLine(this.class, 1, 0.82, 0)
            GameTooltip:AddLine("Left-click: "..p.primary.label, 0.3, 1, 0.3)
            GameTooltip:AddLine("Right-click: "..p.secondary.label, 1, 0.6, 0.3)
            GameTooltip:AddLine("Applies to every "..string.lower(this.class)
                                .." in your group", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
end

function UnBot:CreateStrategyFrame()
    local f = CreateFrame("Frame", "UnBotStrategyFrame", UIParent)
    f:SetWidth(360)
    f:SetHeight(ROW_COUNT * ROW_HEIGHT + 130)
    f:SetPoint("CENTER", UIParent, "CENTER", 260, 0)
    f:EnableMouseWheel(true)
    self:MakeDraggable(f)
    self:RestoreFramePosition(f)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetScript("OnMouseWheel", function() UnBot:ScrollStrategies(-arg1) end)
    f:Hide()

    if UISpecialFrames then
        table.insert(UISpecialFrames, "UnBotStrategyFrame")
    end

    local title = f:CreateFontString("UnBotStrategyTitle", "OVERLAY")
    title:SetFont(UnBotFont, 14)
    title:SetPoint("TOP", f, "TOP", 0, -16)
    title:SetTextColor(1, 0.82, 0)
    f.title = title

    local close = CreateFrame("Button", "UnBotStrategyClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    local function Tab(name, label, mode, x)
        local btn = CreateFrame("Button", name, f, "UIPanelButtonTemplate")
        btn:SetWidth(150)
        btn:SetHeight(21)
        btn:SetPoint("TOPLEFT", f, "TOPLEFT", x, -40)
        btn:SetText(label)
        btn.mode = mode
        btn:SetScript("OnClick", function()
            UnBot.strategyMode = this.mode
            UnBot.strategyOffset = 0
            UnBot:RefreshStrategies()
            if UnBot.strategyTarget then
                SendChatMessage(this.mode, "WHISPER", nil, UnBot.strategyTarget)
            end
        end)
        return btn
    end

    f.tabCombat = Tab("UnBotStrategyTabCo", "Combat", "co", 18)
    f.tabNon    = Tab("UnBotStrategyTabNc", "Non-combat", "nc", 190)

    self:CreateStrategyRows(f)

    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont(UnBotFont, 10)
    hint:SetPoint("BOTTOM", f, "BOTTOM", 0, 16)
    hint:SetTextColor(0.6, 0.6, 0.6)
    f.hint = hint
end

function UnBot:CreateStrategyRows(parent)
    self.strategyRows = {}

    for i = 1, ROW_COUNT do
        local row = CreateFrame("Button", "UnBotStrategyRow"..i, parent)
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
            if this.category then
                -- header: fold the section open or shut
                UnBot.expandedSections[this.category] =
                    not UnBot.expandedSections[this.category]
                UnBot:RefreshStrategies()
            elseif this.strategyName then
                local sign = "+"
                if arg1 == "RightButton" then sign = "-" end
                UnBot:SetStrategy(this.strategyName, sign)
            end
        end)

        row:SetScript("OnEnter", function()
            if this.category then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine(this.category, 1, 0.82, 0)
                GameTooltip:AddLine("Click to open or close", 0.65, 0.55, 0)
                GameTooltip:Show()
            elseif this.strategyName then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine(this.strategyName, 1, 1, 1)
                GameTooltip:AddLine(UnBot.strategyMode.." +"..this.strategyName,
                                    0.3, 1, 0.3)
                GameTooltip:AddLine(UnBot.strategyMode.." -"..this.strategyName,
                                    1, 0.4, 0.4)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:Hide()
        self.strategyRows[i] = row
    end
end

function UnBot:SetStrategy(name, sign)
    if not self.strategyTarget then return end
    local cmd = self.strategyMode.." "..sign..name
    SendChatMessage(cmd, "WHISPER", nil, self.strategyTarget)
    self:Message(cmd.." -> "..self.strategyTarget)
end

--=========================================================================--
--  Refresh
--=========================================================================--

function UnBot:ScrollStrategies(delta)
    local total = table.getn(self:GetStrategyRows())
    local maxOffset = total - ROW_COUNT
    if maxOffset < 0 then maxOffset = 0 end

    self.strategyOffset = self.strategyOffset + delta
    if self.strategyOffset < 0 then self.strategyOffset = 0 end
    if self.strategyOffset > maxOffset then self.strategyOffset = maxOffset end
    self:RefreshStrategies()
end

function UnBot:RefreshStrategies()
    if not UnBotStrategyFrame then return end

    local f = UnBotStrategyFrame
    local label = "Combat"
    if self.strategyMode == "nc" then label = "Non-combat" end
    f.title:SetText((self.strategyTarget or "?").."  -  "..label.." strategies")

    if self.strategyMode == "co" then
        f.tabCombat:LockHighlight()
        f.tabNon:UnlockHighlight()
    else
        f.tabCombat:UnlockHighlight()
        f.tabNon:LockHighlight()
    end

    local rows = self:GetStrategyRows()

    for i = 1, ROW_COUNT do
        local row   = self.strategyRows[i]
        local entry = rows[i + self.strategyOffset]

        row.category     = nil
        row.strategyName = nil

        if entry and entry.header then
            row.category = entry.category
            local mark = "+"
            if self.expandedSections[entry.category] then mark = "-" end
            row.text:SetText(mark.." "..entry.category.."  ("..entry.count..")")
            if entry.class then
                row.text:SetTextColor(1, 0.82, 0)
            else
                row.text:SetTextColor(0.55, 0.75, 1)
            end
            row:Show()

        elseif entry then
            row.strategyName = entry.name
            row.text:SetText("      "..entry.name)
            if entry.class then
                row.text:SetTextColor(0.95, 0.95, 0.95)
            else
                row.text:SetTextColor(0.7, 0.7, 0.7)
            end
            row:Show()

        else
            row:Hide()
        end
    end

    local sections = table.getn(self.strategyTree or {})
    if sections == 0 then
        f.hint:SetText("Nothing known yet - use /unbot ask all")
    else
        f.hint:SetText("Click a group to open    Left-click: on    Right-click: off")
    end
end
