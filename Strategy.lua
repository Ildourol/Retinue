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

local CLASS_NORMALIZATION = {
    ["WARRIOR"] = "WARRIOR",
    ["PALADIN"] = "PALADIN",
    ["HUNTER"]  = "HUNTER",
    ["ROGUE"]   = "ROGUE",
    ["PRIEST"]  = "PRIEST",
    ["SHAMAN"]  = "SHAMAN",
    ["MAGE"]    = "MAGE",
    ["WARLOCK"] = "WARLOCK",
    ["DRUID"]   = "DRUID",
    -- Localized class names fallbacks:
    ["KRIEGER"] = "WARRIOR", ["GUERRIER"] = "WARRIOR", ["ВОИН"] = "WARRIOR", ["战士"] = "WARRIOR", ["GUERRERO"] = "WARRIOR",
    ["PALADIN"] = "PALADIN", ["ПАЛАДИН"] = "PALADIN", ["圣骑士"] = "PALADIN", ["PALADÍN"] = "PALADIN",
    ["JÄGER"] = "HUNTER", ["CHASSEUR"] = "HUNTER", ["ОХОТНИК"] = "HUNTER", ["猎人"] = "HUNTER", ["CAZADOR"] = "HUNTER",
    ["SCHURKE"] = "ROGUE", ["VOLEUR"] = "ROGUE", ["РАЗБОЙНИК"] = "ROGUE", ["盗贼"] = "ROGUE", ["PÍCARO"] = "ROGUE", ["PICARO"] = "ROGUE",
    ["PRIESTER"] = "PRIEST", ["PRÊTRE"] = "PRIEST", ["PRETRE"] = "PRIEST", ["ЖРЕЦ"] = "PRIEST", ["牧师"] = "PRIEST", ["SACERDOTE"] = "PRIEST",
    ["SCHAMANE"] = "SHAMAN", ["CHAMAN"] = "SHAMAN", ["ШАМАН"] = "SHAMAN", ["萨满祭司"] = "SHAMAN", ["CHAMÁN"] = "SHAMAN",
    ["MAGIER"] = "MAGE", ["МАГ"] = "MAGE", ["法师"] = "MAGE", ["MAGO"] = "MAGE",
    ["HEXENMEISTER"] = "WARLOCK", ["DÉMONISTE"] = "WARLOCK", ["DEMONISTE"] = "WARLOCK", ["ЧЕРНОКНИЖНИК"] = "WARLOCK", ["术士"] = "WARLOCK", ["BRUJO"] = "WARLOCK",
    ["DRUIDE"] = "DRUID", ["ДРУИД"] = "DRUID", ["德鲁伊"] = "DRUID", ["DRUIDA"] = "DRUID",
}

local function GetUnitClassToken(unit)
    if not UnitExists(unit) then return nil end
    local locClass, token = UnitClass(unit)
    if token and token ~= "" then
        local upper = string.upper(token)
        if ROLE_PRESETS[upper] then return upper end
    end
    if locClass and locClass ~= "" then
        local upper = string.upper(locClass)
        if ROLE_PRESETS[upper] then return upper end
        if CLASS_NORMALIZATION[upper] then return CLASS_NORMALIZATION[upper] end
    end
    return nil
end

local function IsGroupedName(name)
    if not name then return false end
    local raid = GetNumRaidMembers()
    if raid > 0 then
        for i = 1, raid do
            if UnitName("raid"..i) == name then return true end
        end
    else
        for i = 1, GetNumPartyMembers() do
            if UnitName("party"..i) == name then return true end
        end
    end
    return false
end

local function IsGroupedTarget()
    if not UnitExists("target") then return false end
    if UnitIsUnit("target", "player") then return false end
    if UnitInParty("target") or UnitInRaid("target") then return true end
    local name = UnitName("target")
    if name and IsGroupedName(name) then return true end
    return false
end

local function ForEachGroupMemberOfClass(classToken, func)
    local raid = GetNumRaidMembers()
    if raid > 0 then
        for i = 1, raid do
            local unit = "raid"..i
            if GetUnitClassToken(unit) == classToken then
                local name = UnitName(unit)
                if name and name ~= UnitName("player") then func(name) end
            end
        end
    else
        for i = 1, GetNumPartyMembers() do
            local unit = "party"..i
            if GetUnitClassToken(unit) == classToken then
                local name = UnitName(unit)
                if name and name ~= UnitName("player") then func(name) end
            end
        end
    end
end

function UnBot:QueueRoleForBot(name, classToken, which, queryAfter)
    local preset = ROLE_PRESETS[classToken]
    local role = preset and preset[which]
    if not role or not name then return false end

    -- Send source-verified strategy commands matching original Warband presets.
    -- vMaNGOS playerbots supports chained comma-separated syntax ("co -arms,-fury,+protection")
    -- which applies changes atomically without chat throttle queue delays.
    local off = role.off
    local on = role.on
    local parts = {}
    for i = 1, table.getn(off) do
        table.insert(parts, "-"..off[i])
    end
    for i = 1, table.getn(on) do
        table.insert(parts, "+"..on[i])
    end
    if table.getn(parts) > 0 then
        self:QueueChat("co "..table.concat(parts, ","), "WHISPER", name)
    end
    if queryAfter then
        self:QueueChat("co ?", "WHISPER", name)
    end
    return true
end

function UnBot:ApplyRole(classToken, which)
    local preset = ROLE_PRESETS[classToken]
    local role = preset and preset[which]
    if not role then return end

    local targets = 0
    ForEachGroupMemberOfClass(classToken, function(name)
        if self:QueueRoleForBot(name, classToken, which, true) then
            targets = targets + 1
        end
    end)

    if targets == 0 then
        self:Message("No "..string.lower(classToken).." in your group")
    else
        local className = string.upper(string.sub(classToken, 1, 1))
                          ..string.lower(string.sub(classToken, 2))
        self:Message(className.." - "..role.label.." applied to "..targets.." bot(s)")
        if UnBotRoleFrame and UnBotRoleFrame:IsShown() then
            self:RefreshRoleTarget(false)
        end
    end
end

function UnBot:GetSelectedRoleTarget()
    if not IsGroupedTarget() then return end
    local name = UnitName("target")
    local classToken = GetUnitClassToken("target")
    if not name or not classToken or not ROLE_PRESETS[classToken] then return end
    return name, classToken
end

function UnBot:ApplySelectedRole(which)
    local name, classToken = self:GetSelectedRoleTarget()
    if not name then
        self:Message("Select a supported bot in your party or raid")
        return
    end
    local role = ROLE_PRESETS[classToken][which]
    if self:QueueRoleForBot(name, classToken, which, true) then
        if UnBotRoleFrame then
            UnBotRoleFrame.statusText:SetText("Applying: "..role.label.."...")
        end
        self:Message(role.label.." combat strategy applied to "..name)
    end
end

function UnBot:ParseCombatStrategies(sender, msg)
    if not sender or not msg then return false end
    local _, _, list = string.find(msg, "[Cc]ombat [Ss]trategies:%s*(.*)")
    if not list then return false end

    local cleanSender = string.gsub(sender, "%-.*$", "")

    if not self.botCombatStrategies then self.botCombatStrategies = {} end
    local record = { text = list, active = {} }
    local iter = string.gmatch or string.gfind
    for strategy in iter(list, "[^,]+") do
        local clean = string.gsub(strategy, "^%s+", "")
        clean = string.gsub(clean, "%s+$", "")
        if clean ~= "" then
            record.active[clean] = true
            record.active[string.lower(clean)] = true
        end
    end
    self.botCombatStrategies[cleanSender] = record
    self.botCombatStrategies[sender] = record
    if UnBotRoleFrame and UnBotRoleFrame:IsShown() then self:RefreshRoleTarget(false) end
    if UnBotStrategyFrame and UnBotStrategyFrame:IsShown() then self:RefreshStrategies() end
    return true
end

function UnBot:ParseNonCombatStrategies(sender, msg)
    if not sender or not msg then return false end
    local _, _, list = string.find(msg, "[Nn]on%-[Cc]ombat [Ss]trategies:%s*(.*)")
    if not list then return false end

    local cleanSender = string.gsub(sender, "%-.*$", "")

    if not self.botNonCombatStrategies then self.botNonCombatStrategies = {} end
    local record = { text = list, active = {} }
    local iter = string.gmatch or string.gfind
    for strategy in iter(list, "[^,]+") do
        local clean = string.gsub(strategy, "^%s+", "")
        clean = string.gsub(clean, "%s+$", "")
        if clean ~= "" then
            record.active[clean] = true
            record.active[string.lower(clean)] = true
        end
    end
    self.botNonCombatStrategies[cleanSender] = record
    self.botNonCombatStrategies[sender] = record
    if UnBotStrategyFrame and UnBotStrategyFrame:IsShown() then self:RefreshStrategies() end
    return true
end

function UnBot:GetBotRoleLabel(name, classToken)
    if not name then return "Not checked" end
    local cleanName = string.gsub(name, "%-.*$", "")
    local record = self.botCombatStrategies and (self.botCombatStrategies[cleanName] or self.botCombatStrategies[name])
    local preset = ROLE_PRESETS[classToken]
    if not record or not preset then return "Not checked" end

    local matches = {}
    for _, which in ipairs({"primary", "secondary"}) do
        local role = preset[which]
        local matched = false
        for i = 1, table.getn(role.on) do
            local wanted = role.on[i]
            local lowerWanted = string.lower(wanted)
            for active in pairs(record.active) do
                local lowerActive = string.lower(active)
                if lowerActive == lowerWanted
                   or string.find(" "..lowerActive.." ", " "..lowerWanted.." ", 1, true) then
                    matched = true
                    break
                end
            end
            if matched then break end
        end
        if matched then table.insert(matches, role.label) end
    end
    if table.getn(matches) == 0 then return "Custom / unknown" end
    if table.getn(matches) > 1 then return "Mixed: "..table.concat(matches, ", ") end
    return matches[1]
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
    ["blackwing lair"]    = "instance",
    ["suppression room"]  = "instance",
    ["avoid specific creatures"] = "instance",
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

    ["kite"]                = "movement",
    ["runaway"]             = "movement",
    ["flee from adds"]      = "movement",
    ["avoid mobs"]          = "movement",
    ["avoid aoe"]           = "tactics",
    ["pull back"]           = "tactics",
    ["pull"]                = "tactics",
    ["wait for attack"]     = "tactics",
    ["mark rti"]            = "tactics",
    ["focus rti targets"]   = "tactics",
    ["focus heal targets"]  = "tactics",
    ["tank assist"]         = "tactics",
    ["dps assist"]          = "tactics",
    ["dps aoe"]             = "tactics",
    ["threat"]              = "tactics",
    ["passive"]             = "tactics",
    ["conserve mana"]       = "upkeep",
    ["potions"]             = "upkeep",
    ["food"]                = "upkeep",
    ["racials"]             = "tactics",
    ["cast time"]           = "tactics",

    ["rpg"]             = "rpg",
    ["rpg quest"]       = "rpg",
    ["rpg vendor"]      = "rpg",
    ["rpg explore"]     = "rpg",
    ["rpg maintenance"] = "rpg",
    ["rpg craft"]       = "rpg",
    ["rpg player"]      = "rpg",
    ["rpg bg"]          = "rpg",
}

local BASE_GENERIC_STRATEGIES = {
    "kite", "avoid aoe", "focus heal targets", "focus rti targets",
    "pull back", "tank assist", "dps assist", "dps aoe", "threat", "passive",
    "avoid mobs", "flee from adds", "conserve mana", "mark rti",
    "wait for attack", "racials", "potions", "food", "cast time",
    "rpg", "rpg quest", "rpg vendor", "rpg explore", "rpg maintenance",
    "rpg craft", "rpg player", "rpg bg"
}

function UnBot:InitDefaultStrategies()
    if self.config.strategies == nil then self.config.strategies = {} end
    if self.config.strategies.generic == nil then self.config.strategies.generic = {} end
    for i = 1, table.getn(BASE_GENERIC_STRATEGIES) do
        local strat = BASE_GENERIC_STRATEGIES[i]
        if not self.config.strategies.generic[strat] then
            self.config.strategies.generic[strat] = strat
        end
    end
end

-- { {category, items, class}, ... } - class sections first, then generic.
function UnBot:BuildStrategyTree()
    self:InitDefaultStrategies()
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

    local classToken = GetUnitClassToken("target")
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
        self:RefreshRoleTarget(false)
    end
end

function UnBot:RefreshRoleTarget(queryServer)
    if not UnBotRoleFrame then return end
    local name, classToken = self:GetSelectedRoleTarget()
    if not name then
        UnBotRoleFrame.targetName = nil
        UnBotRoleFrame.targetText:SetText("Select a grouped bot")
        UnBotRoleFrame.statusText:SetText("Current combat strategy: unavailable")
        UnBotRoleFrame.primaryButton:Disable()
        UnBotRoleFrame.secondaryButton:Disable()
        UnBotRoleFrame.primaryButton:SetText("Primary")
        UnBotRoleFrame.secondaryButton:SetText("Alternative")
        return
    end

    local preset = ROLE_PRESETS[classToken]
    local label = self:GetBotRoleLabel(name, classToken)
    UnBotRoleFrame.targetName = name
    UnBotRoleFrame.targetText:SetText("Selected: "..name)
    UnBotRoleFrame.statusText:SetText("Current combat strategy: "..label)
    UnBotRoleFrame.primaryButton:SetText(preset.primary.label)
    UnBotRoleFrame.secondaryButton:SetText(preset.secondary.label)
    UnBotRoleFrame.primaryButton:Enable()
    UnBotRoleFrame.secondaryButton:Enable()
    if queryServer or label == "Not checked" then
        self:QueueChat("co ?", "WHISPER", name)
    end
end

function UnBot:CreateRoleFrame()
    local count = table.getn(ROLE_ORDER)
    local f = CreateFrame("Frame", "UnBotRoleFrame", UIParent)
    f:SetWidth(220)
    f:SetHeight(count * 22 + 142)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
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

    local close = CreateFrame("Button", "UnBotRoleClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() f:Hide() end)

    local targetText = f:CreateFontString(nil, "OVERLAY")
    targetText:SetFont(UnBotFont, 11)
    targetText:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -28)
    targetText:SetTextColor(1, 1, 1)
    f.targetText = targetText

    local statusText = f:CreateFontString(nil, "OVERLAY")
    statusText:SetFont(UnBotFont, 10)
    statusText:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -46)
    statusText:SetTextColor(0.65, 0.8, 1)
    f.statusText = statusText

    local function TargetRoleButton(name, x, which)
        local btn = CreateFrame("Button", name, f, "UIPanelButtonTemplate")
        btn:SetWidth(88)
        btn:SetHeight(22)
        btn:SetPoint("TOPLEFT", f, "TOPLEFT", x, -66)
        btn.which = which
        btn:SetScript("OnClick", function() UnBot:ApplySelectedRole(this.which) end)
        return btn
    end
    f.primaryButton = TargetRoleButton("UnBotSelectedRolePrimary", 14, "primary")
    f.secondaryButton = TargetRoleButton("UnBotSelectedRoleSecondary", 118, "secondary")

    local refresh = CreateFrame("Button", "UnBotSelectedRoleRefresh", f,
                                "UIPanelButtonTemplate")
    refresh:SetWidth(88)
    refresh:SetHeight(20)
    refresh:SetPoint("TOP", f, "TOP", 0, -92)
    refresh:SetText("Check role")
    refresh:SetScript("OnClick", function() UnBot:RefreshRoleTarget(true) end)

    local allLabel = f:CreateFontString(nil, "OVERLAY")
    allLabel:SetFont(UnBotFont, 9)
    allLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -120)
    allLabel:SetTextColor(0.75, 0.75, 0.75)
    allLabel:SetText("APPLY TO ALL GROUPED CLASS BOTS")

    for i = 1, count do
        local class = ROLE_ORDER[i]
        local preset = ROLE_PRESETS[class]

        local btn = CreateFrame("Button", "UnBotRole"..class, f)
        btn:SetWidth(192)
        btn:SetHeight(20)
        btn:SetPoint("TOP", f, "TOP", 0, -136 - (i - 1) * 22)
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        btn.class = class

        local text = btn:CreateFontString(nil, "OVERLAY")
        text:SetFont(UnBotFont, 11)
        text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        local c = CLASS_COLOR[class]
        text:SetTextColor(c[1], c[2], c[3])
        local className = string.upper(string.sub(class, 1, 1))
                          ..string.lower(string.sub(class, 2))
        text:SetText(className)

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
            GameTooltip:AddLine("Changes combat strategies, not talents or gear", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    local events = CreateFrame("Frame", "UnBotRoleEvents")
    events:RegisterEvent("PLAYER_TARGET_CHANGED")
    events:RegisterEvent("PARTY_MEMBERS_CHANGED")
    events:RegisterEvent("RAID_ROSTER_UPDATE")
    events:SetScript("OnEvent", function()
        if UnBotRoleFrame and UnBotRoleFrame:IsShown() then
            UnBot:RefreshRoleTarget(false)
        end
    end)
    self:RefreshRoleTarget(false)
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
    SendChatMessage(self.strategyMode, "WHISPER", nil, self.strategyTarget)
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
