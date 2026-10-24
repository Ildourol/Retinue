Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue

-- Retinue Spell List & Smart Filter Hub (Turtle WoW 1.18.1 / Lua 5.0)
--
-- Whisper "spells" and the bot answers with Hspell links, many per line.
-- Spells are categorized into:
--   - 3 Talent Spec categories per class (e.g. Arms, Fury, Protection)
--   - Buff & Aura categories (Auras, Blessings, Shouts, Aspects, etc.)
--   - General (Racials, utility, common actions)
-- Opens Everything by default, with instant search text matching and smart filter chips.

local ROW_COUNT  = 16
local ROW_HEIGHT = 17

-- Buff & utility keyword groups (order matters: first match claims buff category)
local BUFF_GROUPS = {
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

local CLASS_TALENT_TREES = {
    WARRIOR = { "Arms", "Fury", "Protection" },
    PALADIN = { "Holy", "Protection", "Retribution" },
    HUNTER  = { "Beast Mastery", "Marksmanship", "Survival" },
    ROGUE   = { "Assassination", "Combat", "Subtlety" },
    PRIEST  = { "Discipline", "Holy", "Shadow" },
    SHAMAN  = { "Elemental", "Enhancement", "Restoration" },
    MAGE    = { "Arcane", "Fire", "Frost" },
    WARLOCK = { "Affliction", "Demonology", "Destruction" },
    DRUID   = { "Balance", "Feral", "Restoration" },
}

local CLASS_SPELL_MAP = {
    WARRIOR = {
        ["Arms"] = {
            "mortal strike", "rend", "charge", "thunder clap", "overpower",
            "sweeping strikes", "hamstring", "whirlwind", "intercept", "mocking blow",
            "retaliation", "deep wounds", "poleaxe", "mace specialization", "sword specialization"
        },
        ["Fury"] = {
            "bloodthirst", "slam", "cleave", "execute", "battle shout",
            "demoralizing shout", "berserker rage", "death wish", "flurry", "pummel",
            "piercing howl", "bloodrage", "recklessness", "rampage"
        },
        ["Protection"] = {
            "shield slam", "sunder armor", "shield block", "taunt", "revenge",
            "disarm", "shield bash", "last stand", "shield wall", "concussion blow",
            "defensive stance", "toughness"
        },
    },
    PALADIN = {
        ["Holy"] = {
            "holy light", "flash of light", "lay on hands", "holy shock", "cleanse",
            "purify", "holy wrath", "redemption", "exorcism", "seal of light",
            "seal of wisdom", "blessing of wisdom", "blessing of light", "greater blessing of wisdom",
            "greater blessing of light", "divine favor"
        },
        ["Protection"] = {
            "seal of justice", "blessing of protection", "blessing of freedom", "blessing of sacrifice",
            "blessing of sanctuary", "greater blessing of sanctuary", "righteous fury", "holy shield",
            "hammer of justice", "devotion aura", "fire resistance aura", "frost resistance aura",
            "shadow resistance aura", "redoubt"
        },
        ["Retribution"] = {
            "seal of the crusader", "seal of command", "judgement", "blessing of might",
            "blessing of kings", "greater blessing of might", "greater blessing of kings",
            "hammer of wrath", "retribution aura", "sanctity aura", "crusader strike",
            "holy strike", "repentance", "seal of righteousness"
        },
    },
    HUNTER = {
        ["Beast Mastery"] = {
            "bestial wrath", "mend pet", "intimidation", "eyes of the beast", "scare beast",
            "aspect of the monkey", "aspect of the hawk", "aspect of the cheetah", "aspect of the pack",
            "aspect of the beast", "call pet", "dismiss pet", "feed pet", "revive pet", "tame beast",
            "eagle eye"
        },
        ["Marksmanship"] = {
            "aimed shot", "arcane shot", "concussive shot", "multi-shot", "serpent sting",
            "scorpid sting", "viper sting", "trueshot aura", "flare", "hunter's mark",
            "volley", "distracting shot", "rapid fire", "auto shot", "aspect of the wild"
        },
        ["Survival"] = {
            "wing clip", "raptor strike", "mongoose bite", "disengage", "feign death",
            "counterattack", "freezing trap", "immolation trap", "frost trap", "explosive trap",
            "wyvern sting", "deterrence", "track"
        },
    },
    ROGUE = {
        ["Assassination"] = {
            "eviscerate", "slice and dice", "garrote", "rupture", "ambush",
            "kidney shot", "cheap shot", "expose armor", "cold blood", "vigor",
            "relentless strikes", "deadly poison", "instant poison", "wound poison"
        },
        ["Combat"] = {
            "sinister strike", "gouge", "backstab", "evasion", "sprint",
            "kick", "feint", "blade flurry", "adrenaline rush", "riposte"
        },
        ["Subtlety"] = {
            "stealth", "vanish", "blind", "sap", "distract",
            "pick pocket", "pick lock", "preparation", "ghostly strike", "hemorrhage",
            "premeditation", "safe fall", "crippling poison", "mind-numbing poison"
        },
    },
    PRIEST = {
        ["Discipline"] = {
            "power word: shield", "power word: fortitude", "inner fire", "mana burn", "inner focus",
            "power infusion", "divine spirit", "fear ward", "dispel magic", "levitate",
            "abolish disease", "cure disease", "shackle undead", "prayer of fortitude", "prayer of spirit"
        },
        ["Holy"] = {
            "lesser heal", "heal", "flash heal", "greater heal", "renew",
            "prayer of healing", "holy nova", "resurrection", "desperate prayer", "lightwell",
            "circle of healing", "holy fire", "smite", "spirit of redemption"
        },
        ["Shadow"] = {
            "shadow word: pain", "mind blast", "mind flay", "mind control", "mind soothe",
            "mind vision", "psychic scream", "fade", "shadowform", "silence",
            "vampiric embrace", "devouring plague", "shadow protection", "prayer of shadow protection"
        },
    },
    SHAMAN = {
        ["Elemental"] = {
            "lightning bolt", "chain lightning", "earth shock", "flame shock", "frost shock",
            "elemental mastery", "fire nova totem", "magma totem", "searing totem", "fire elemental totem"
        },
        ["Enhancement"] = {
            "rockbiter weapon", "windfury weapon", "flametongue weapon", "frostbrand weapon", "lightning shield",
            "stoneskin totem", "strength of earth totem", "windfury totem", "grace of air totem", "ghost wolf",
            "stormstrike", "elemental weapons"
        },
        ["Restoration"] = {
            "healing wave", "lesser healing wave", "chain heal", "healing stream totem", "mana spring totem",
            "tremor totem", "poison cleansing totem", "disease cleansing totem", "mana tide totem", "nature's swiftness",
            "ancestral spirit", "purge"
        },
    },
    MAGE = {
        ["Arcane"] = {
            "arcane missiles", "arcane explosion", "arcane intellect", "arcane brilliance", "arcane power",
            "evocation", "blink", "counterspell", "polymorph", "slow fall",
            "dampen magic", "amplify magic", "mana shield", "conjure water", "conjure food",
            "conjure mana", "portal", "teleport", "presence of mind"
        },
        ["Fire"] = {
            "fireball", "fire blast", "scorch", "pyroblast", "flamestrike",
            "blast wave", "combustion", "molten armor", "fire ward"
        },
        ["Frost"] = {
            "frostbolt", "frost nova", "blizzard", "ice armor", "frost armor",
            "cone of cold", "ice barrier", "ice block", "cold snap", "frost ward"
        },
    },
    WARLOCK = {
        ["Affliction"] = {
            "corruption", "curse of agony", "curse of weakness", "curse of recklessness", "curse of elements",
            "curse of shadow", "curse of the elements", "curse of doom", "curse of tongues", "drain soul",
            "drain life", "drain mana", "life tap", "fear", "howl of terror",
            "death coil", "siphon life", "dark pact", "amplify curse"
        },
        ["Demonology"] = {
            "summon imp", "summon voidwalker", "summon succubus", "summon felhunter", "summon infernal",
            "summon doomguard", "health funnel", "demonic sacrifice", "soul link", "sense demons",
            "banish", "enslave demon", "create healthstone", "create soulstone", "create firestone",
            "create spellstone", "eye of kilrogg", "demon skin", "demon armor", "shadow protection"
        },
        ["Destruction"] = {
            "shadow bolt", "immolate", "conflagrate", "searing pain", "rain of fire",
            "hellfire", "soul fire", "shadowburn", "shadow ward"
        },
    },
    DRUID = {
        ["Balance"] = {
            "wrath", "moonfire", "starfire", "hurricane", "entangling roots",
            "nature's grasp", "omen of clarity", "moonkin form", "soothe animal", "hibernate",
            "thorns", "barkskin", "teleport: moonglade", "faerie fire"
        },
        ["Feral"] = {
            "claw", "rake", "rip", "shred", "bite",
            "ferocious bite", "ravage", "pounce", "tiger's fury", "dash",
            "track humanoids", "prowl", "cower", "maul", "swipe",
            "growl", "demoralizing roar", "enrage", "frenzied regeneration", "bash",
            "feral charge", "faerie fire (feral)", "bear form", "dire bear form", "cat form",
            "travel form", "aquatic form"
        },
        ["Restoration"] = {
            "healing touch", "regrowth", "rejuvenation", "tranquility", "swiftmend",
            "innervate", "nature's swiftness", "mark of the wild", "gift of the wild", "rebirth",
            "abolish poison", "cure poison", "remove curse"
        },
    },
}

--=========================================================================--
--  Grouping & Classification
--=========================================================================--

local function MatchSpellToSpec(spellLower, classToken)
    if classToken and CLASS_SPELL_MAP[classToken] then
        local specs = CLASS_SPELL_MAP[classToken]
        for specName, keywords in pairs(specs) do
            for k = 1, table.getn(keywords) do
                if string.find(spellLower, keywords[k], 1, true) then
                    return specName
                end
            end
        end
    end
    -- Fallback: check across all class specs
    for cToken, specs in pairs(CLASS_SPELL_MAP) do
        if cToken ~= classToken then
            for specName, keywords in pairs(specs) do
                for k = 1, table.getn(keywords) do
                    if string.find(spellLower, keywords[k], 1, true) then
                        return specName
                    end
                end
            end
        end
    end
    return nil
end

local function GroupFor(name, classToken)
    local lower = string.lower(name)

    -- 1. Check specific buff keyword groups
    for i = 1, table.getn(BUFF_GROUPS) do
        if string.find(lower, BUFF_GROUPS[i].key, 1, true) then
            return BUFF_GROUPS[i].label, true, "Buff"
        end
    end

    -- 2. Check class talent tree specs
    local spec = MatchSpellToSpec(lower, classToken)
    if spec then
        return spec, false, spec
    end

    -- 3. Default to General (never an ambiguous "Other")
    return "General", false, "General"
end

function UnBot:GetTargetClassToken()
    local target = self.spellTarget or (self.GetBotTarget and self:GetBotTarget())
    if not target then return nil end
    local clean = string.gsub(target, "%-.*$", "")

    if UnitExists("target") and UnitIsPlayer("target") then
        local tName = UnitName("target")
        if tName and (tName == target or string.gsub(tName, "%-.*$", "") == clean) then
            local _, ct = UnitClass("target")
            if ct then return string.upper(ct) end
        end
    end

    if self.config and self.config.roster and self.config.roster[clean] then
        local c = self.config.roster[clean].class
        if c then return string.upper(tostring(c)) end
    end
    if self.config and self.config.roster and self.config.roster[target] then
        local c = self.config.roster[target].class
        if c then return string.upper(tostring(c)) end
    end

    return nil
end

function UnBot:BuildSpellTree()
    local tree    = {}
    local buckets = {}
    local isBuff  = {}
    local categoryMap = {}

    local classToken = self:GetTargetClassToken()
    local filter = self.spellFilter or "ALL"
    local query = self.spellSearchQuery
    if query then query = string.lower(query) end

    local spellList = self.spellList or {}
    for i = 1, table.getn(spellList) do
        local spell = spellList[i]
        local label, buff, cat = GroupFor(spell.name, classToken)

        local passFilter = true
        if filter == "BUFFS" then
            passFilter = buff
        elseif filter == "GENERAL" then
            passFilter = (cat == "General" or label == "General")
        elseif filter ~= "ALL" then
            passFilter = (string.lower(cat) == string.lower(filter) or string.lower(label) == string.lower(filter))
        end

        local passQuery = true
        if query and query ~= "" then
            passQuery = (string.find(string.lower(spell.name), query, 1, true) ~= nil)
        end

        if passFilter and passQuery then
            if not buckets[label] then
                buckets[label] = {}
                isBuff[label]  = buff
                categoryMap[label] = cat
            end
            table.insert(buckets[label], spell.name)
        end
    end

    -- Order: Buff groups first
    for i = 1, table.getn(BUFF_GROUPS) do
        local label = BUFF_GROUPS[i].label
        if buckets[label] then
            table.sort(buckets[label])
            table.insert(tree, { label = label, items = buckets[label], buff = true, category = "Buff" })
            buckets[label] = nil
        end
    end

    -- Next: Class talent specs if known
    if classToken and CLASS_TALENT_TREES[classToken] then
        local specs = CLASS_TALENT_TREES[classToken]
        for s = 1, table.getn(specs) do
            local label = specs[s]
            if buckets[label] then
                table.sort(buckets[label])
                table.insert(tree, { label = label, items = buckets[label], buff = false, category = label })
                buckets[label] = nil
            end
        end
    end

    -- Next: Any remaining specs from other classes
    for cToken, specs in pairs(CLASS_TALENT_TREES) do
        for s = 1, table.getn(specs) do
            local label = specs[s]
            if buckets[label] then
                table.sort(buckets[label])
                table.insert(tree, { label = label, items = buckets[label], buff = false, category = label })
                buckets[label] = nil
            end
        end
    end

    -- Finally: General
    if buckets["General"] then
        table.sort(buckets["General"])
        table.insert(tree, { label = "General", items = buckets["General"], buff = false, category = "General" })
        buckets["General"] = nil
    end

    -- Fallback for any leftover bucket
    for label, items in pairs(buckets) do
        table.sort(items)
        table.insert(tree, { label = label, items = items, buff = isBuff[label] or false, category = categoryMap[label] or "General" })
    end

    -- Open all groups by default
    self.expandedSpellGroups = self.expandedSpellGroups or {}
    for i = 1, table.getn(tree) do
        local lbl = tree[i].label
        if self.expandedSpellGroups[lbl] == nil then
            self.expandedSpellGroups[lbl] = true
        end
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
                table.insert(rows, { header = false, name = node.items[j], buff = node.buff })
            end
        end
    end

    return rows
end

--=========================================================================--
--  Window & Smart Filter Construction
--=========================================================================--

function UnBot:ShowSpellWindow()
    local target = self:GetBotTarget()
    if not target then
        self:Message("Select a bot first to view known spells.")
        return
    end

    if not UnBotSpellFrame then self:CreateSpellFrame() end

    self.spellTarget          = target
    self.spellOffset          = 0
    self.spellList            = {}
    self.spellFilter          = "ALL"
    self.spellBuffsOnly       = false
    self.spellSearchQuery     = ""
    self.expandedSpellGroups  = {}
    self.spellTree            = self:BuildSpellTree()

    if UnBotSpellSearchEdit then
        UnBotSpellSearchEdit:SetText("")
    end

    UnBotSpellFrame:Show()
    self:UpdateFilterChips()
    self:RefreshSpells()
    SendChatMessage("spells", "WHISPER", nil, target)
end

function UnBot:CreateSpellFrame()
    local f = CreateFrame("Frame", "UnBotSpellFrame", UIParent)
    f:SetWidth(380)
    f:SetHeight(ROW_COUNT * ROW_HEIGHT + 140)
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
    title:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 13)
    title:SetPoint("TOP", f, "TOP", 0, -14)
    title:SetTextColor(1, 0.82, 0)
    f.title = title

    local close = CreateFrame("Button", "UnBotSpellClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    -- Row 1: Search Box + Expand/Collapse All + Refresh
    local search = CreateFrame("EditBox", "UnBotSpellSearchEdit", f, "InputBoxTemplate")
    search:SetWidth(140)
    search:SetHeight(20)
    search:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -37)
    search:SetAutoFocus(false)
    search:SetScript("OnTextChanged", function()
        local text = this:GetText() or ""
        text = string.gsub(text, "^%s+", "")
        text = string.gsub(text, "%s+$", "")
        UnBot.spellSearchQuery = text
        UnBot.spellOffset = 0
        UnBot.spellTree = UnBot:BuildSpellTree()
        UnBot:RefreshSpells()
    end)
    search:SetScript("OnEscapePressed", function()
        this:SetText("")
        this:ClearFocus()
    end)
    search:SetScript("OnEnterPressed", function()
        this:ClearFocus()
    end)
    f.search = search

    local toggleExpand = CreateFrame("Button", "UnBotSpellExpandToggle", f, "UIPanelButtonTemplate")
    toggleExpand:SetWidth(96)
    toggleExpand:SetHeight(21)
    toggleExpand:SetPoint("TOPLEFT", f, "TOPLEFT", 172, -36)
    toggleExpand:SetText("Collapse All")
    toggleExpand:SetScript("OnClick", function()
        local anyExpanded = false
        local tree = UnBot.spellTree or {}
        for i = 1, table.getn(tree) do
            if UnBot.expandedSpellGroups[tree[i].label] then
                anyExpanded = true
                break
            end
        end
        if anyExpanded then
            UnBot.expandedSpellGroups = {}
            this:SetText("Expand All")
        else
            for i = 1, table.getn(tree) do
                UnBot.expandedSpellGroups[tree[i].label] = true
            end
            this:SetText("Collapse All")
        end
        UnBot.spellOffset = 0
        UnBot:RefreshSpells()
    end)
    f.toggleExpand = toggleExpand

    local refresh = CreateFrame("Button", "UnBotSpellRefresh", f, "UIPanelButtonTemplate")
    refresh:SetWidth(90)
    refresh:SetHeight(21)
    refresh:SetPoint("TOPLEFT", f, "TOPLEFT", 274, -36)
    refresh:SetText("Refresh")
    refresh:SetScript("OnClick", function()
        if not UnBot.spellTarget then return end
        UnBot.spellList = {}
        UnBot.spellTree = UnBot:BuildSpellTree()
        UnBot:RefreshSpells()
        SendChatMessage("spells", "WHISPER", nil, UnBot.spellTarget)
    end)
    f.refresh = refresh

    -- Compatibility pointer for legacy tests/addons
    f.filter = toggleExpand

    -- Row 2: Smart Filter Chips ([All], [Spec 1], [Spec 2], [Spec 3], [Buffs], [General])
    local function Chip(name, label, mode, x, w, tip)
        local btn = CreateFrame("Button", name, f, "UIPanelButtonTemplate")
        btn:SetWidth(w)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", f, "TOPLEFT", x, -63)
        btn:SetText(label)
        btn.mode = mode
        btn.tip = tip
        btn:SetScript("OnClick", function()
            UnBot.spellFilter = this.mode
            UnBot.spellBuffsOnly = (this.mode == "BUFFS")
            UnBot.spellOffset = 0
            UnBot.spellTree = UnBot:BuildSpellTree()
            UnBot:UpdateFilterChips()
            UnBot:RefreshSpells()
        end)
        btn:SetScript("OnEnter", function()
            if this.tip then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine(this.tip, 1, 0.82, 0)
                GameTooltip:Show()
            end
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return btn
    end

    f.chips = {}
    f.chips.all     = Chip("UnBotSpellChipAll",     "All",   "ALL",     18,  46, "Show all known spells")
    f.chips.spec1   = Chip("UnBotSpellChipSpec1",   "Spec1", "SPEC1",   66,  60, "Filter by primary talent tree")
    f.chips.spec2   = Chip("UnBotSpellChipSpec2",   "Spec2", "SPEC2",   128, 60, "Filter by secondary talent tree")
    f.chips.spec3   = Chip("UnBotSpellChipSpec3",   "Spec3", "SPEC3",   190, 60, "Filter by tertiary talent tree")
    f.chips.buffs   = Chip("UnBotSpellChipBuffs",   "Buffs", "BUFFS",   252, 52, "Filter by Buffs & Auras only")
    f.chips.general = Chip("UnBotSpellChipGeneral", "Gen",   "GENERAL", 306, 56, "Filter by General & Racial abilities")

    self:CreateSpellRows(f)

    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
    hint:SetPoint("BOTTOM", f, "BOTTOM", 0, 14)
    hint:SetTextColor(0.6, 0.6, 0.6)
    f.hint = hint
end

function UnBot:UpdateFilterChips()
    local f = UnBotSpellFrame
    if not f or not f.chips then return end

    local classToken = self:GetTargetClassToken()
    local specs = (classToken and CLASS_TALENT_TREES[classToken]) or { "Spec 1", "Spec 2", "Spec 3" }

    f.chips.spec1:SetText(string.sub(specs[1], 1, 6))
    f.chips.spec1.mode = specs[1]
    f.chips.spec1.tip = "Filter spells: " .. specs[1]

    f.chips.spec2:SetText(string.sub(specs[2], 1, 6))
    f.chips.spec2.mode = specs[2]
    f.chips.spec2.tip = "Filter spells: " .. specs[2]

    f.chips.spec3:SetText(string.sub(specs[3], 1, 6))
    f.chips.spec3.mode = specs[3]
    f.chips.spec3.tip = "Filter spells: " .. specs[3]

    local active = self.spellFilter or "ALL"
    for k, chip in pairs(f.chips) do
        if chip.mode == active or (active == "ALL" and chip.mode == "ALL") then
            chip:LockHighlight()
        else
            chip:UnlockHighlight()
        end
    end
end

function UnBot:CreateSpellRows(parent)
    self.spellRows = {}

    for i = 1, ROW_COUNT do
        local row = CreateFrame("Button", "UnBotSpellRow"..i, parent)
        row:SetWidth(344)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 18, -88 - (i - 1) * ROW_HEIGHT)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        local text = row:CreateFontString(nil, "OVERLAY")
        text:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
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
                GameTooltip:AddLine("Click to expand or collapse", 0.65, 0.55, 0)
                GameTooltip:Show()
            elseif this.spellName then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine(this.spellName, 1, 1, 1)
                GameTooltip:AddLine("Click: cast on whatever the bot has targeted", 0.65, 0.55, 0)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:Hide()
        self.spellRows[i] = row
    end
end

function UnBot:CastSpell(name)
    if not self.spellTarget then return end
    SendChatMessage("cast "..name, "WHISPER", nil, self.spellTarget)
    self:Message("cast "..name.." -> "..self.spellTarget)
end

--=========================================================================--
--  Receiving & Parsing
--=========================================================================--

function UnBot:ReceiveSpells(msg, sender)
    if not msg or not sender then return end
    if not UnBotSpellFrame or not UnBotSpellFrame:IsShown() then return end
    local cleanSender = string.gsub(sender, "%-.*$", "")
    local cleanTarget = self.spellTarget and string.gsub(self.spellTarget, "%-.*$", "")
    if cleanSender ~= cleanTarget and sender ~= self.spellTarget then return end

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
        self:UpdateFilterChips()
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
--  Refresh & Scrolling
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

    local bot = self.spellTarget or "?"
    local filter = self.spellFilter or "ALL"
    f.title:SetText(bot .. "  -  Spells (" .. filter .. ")")

    self:UpdateFilterChips()

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
            row.text:SetText(mark .. " " .. entry.label .. "  (" .. entry.count .. ")")
            if entry.buff then
                row.text:SetTextColor(1, 0.82, 0)
            else
                row.text:SetTextColor(0.55, 0.75, 1)
            end
            row:Show()

        elseif entry then
            row.spellName = entry.name
            row.text:SetText("      " .. entry.name)
            row.text:SetTextColor(0.9, 0.9, 0.9)
            row:Show()

        else
            row:Hide()
        end
    end

    local total = table.getn(self.spellList or {})
    if total == 0 then
        f.hint:SetText("Waiting for " .. (self.spellTarget or "the bot") .. "...")
    else
        local showing = table.getn(rows)
        f.hint:SetText(total .. " spells known (" .. showing .. " rows visible)  Click spell to cast")
    end
end
