-- Retinue Strategy & Bot Behaviour Editor (Turtle WoW 1.18.1 / Lua 5.0)
--
-- Strategies are the bot's behaviour rules, in three sets:
--   co +name / co -name / co ~name   combat strategies
--   nc +name / nc -name / nc ~name   out of combat strategies
--   behavior <bot> <key> <on/off>    core behaviour options (loot, aoe, autocc, etc.)

Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue
local C = Retinue.C or {}

local ROW_COUNT  = 16
local ROW_HEIGHT = 17

local CLASS_TOKEN = {
    WARRIOR = "warrior", PALADIN = "paladin", HUNTER = "hunter",
    ROGUE   = "rogue",   PRIEST  = "priest",  SHAMAN = "shaman",
    MAGE    = "mage",    WARLOCK = "warlock", DRUID  = "druid",
}

local function NormalizeName(name)
    if not name then return "" end
    name = string.gsub(name, "%-.*$", "")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    if name == "" then return "" end
    return string.upper(string.sub(name, 1, 1)) .. string.lower(string.sub(name, 2))
end

local function CleanChat(msg)
    if not msg then return "" end
    msg = string.gsub(msg, "|c%x%x%x%x%x%x%x%x", "")
    msg = string.gsub(msg, "|r", "")
    msg = string.gsub(msg, "|H.-|h", "")
    msg = string.gsub(msg, "|h", "")
    return msg
end

local function splitProtocol(text)
    local parts = {}
    if not text then return parts end
    local start = 1
    while true do
        local pos = string.find(text, "|", start, true)
        if not pos then
            table.insert(parts, string.sub(text, start))
            break
        end
        table.insert(parts, string.sub(text, start, pos - 1))
        start = pos + 1
    end
    return parts
end

local function parseBotStateFields(text)
    local state = {}
    if not text then return state end
    local iter = string.gfind or string.gmatch
    for pair in iter(text, "[^,]+") do
        local _, _, key, value = string.find(pair, "^%s*([%w_]+)=(%S*)%s*$")
        if key and value then
            state[string.lower(key)] = string.lower(value)
        end
    end
    return state
end

--=========================================================================--
--  Behavior Definitions & Commands
--=========================================================================--

local BEHAVIOR_DEFS = {
    { key = "loot",     label = "Loot corpses",      tip = "Loot corpses after a fight.", strat = "loot", combat = false },
    { key = "aoe",      label = "AoE spells",        tip = "Use area-of-effect abilities (held back next to CC).", strat = "no aoe", combat = true, invert = true },
    { key = "autocc",   label = "Auto CC",           tip = "Crowd-control loose adds hitting the healer automatically.", strat = "auto cc", combat = true },
    { key = "savemana", label = "Save mana",         tip = "Stretch mana on long fights by pacing casts.", strat = "conserve mana", combat = true, mana = true },
    { key = "boost",    label = "Cooldowns",         tip = "Use major offensive cooldowns during boss fights.", strat = "boost", combat = true },
    { key = "threat",   label = "Watch threat",      tip = "Throttle damage when high on tank threat.", strat = "threat", combat = true },
    { key = "potions",  label = "Drink potions",     tip = "Use healing and mana potions when health or mana drops low.", strat = "potions", combat = true },
    { key = "spread",   label = "Spread out",        tip = "Spread apart in combat to avoid chained AoE damage.", strat = "spread", combat = true },
    { key = "mimic",    label = "Mimic consumables", tip = "Mimic player potion and food usage out of combat.", strat = "mimic consumables", combat = false },
}

--=========================================================================--
--  Role Presets
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
    ["WARRIOR"] = "WARRIOR", ["PALADIN"] = "PALADIN", ["HUNTER"]  = "HUNTER",
    ["ROGUE"]   = "ROGUE",   ["PRIEST"]  = "PRIEST",  ["SHAMAN"]  = "SHAMAN",
    ["MAGE"]    = "MAGE",    ["WARLOCK"] = "WARLOCK", ["DRUID"]   = "DRUID",
    ["KRIEGER"] = "WARRIOR", ["GUERRIER"] = "WARRIOR", ["ВОИН"] = "WARRIOR", ["战士"] = "WARRIOR", ["GUERRERO"] = "WARRIOR",
    ["ПАЛАДИН"] = "PALADIN", ["圣骑士"] = "PALADIN", ["PALADÍN"] = "PALADIN",
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
        local stratCmd = "strategy " .. table.concat(parts, ",") .. " " .. name
        if self.SendBotCommand then
            self:SendBotCommand(stratCmd)
        else
            self:QueueChat(".bot " .. stratCmd)
        end
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

--=========================================================================--
--  Strategy & Behaviour State Parsers
--=========================================================================--

function UnBot:ParseCombatStrategies(sender, msg)
    if not sender or not msg then return false end
    msg = CleanChat(msg)
    if string.find(msg, "[Nn]on[%s%-]*[Cc]ombat") then return false end
    local _, _, list = string.find(msg, "[Cc]ombat [Ss]trategies:%s*(.*)")
    if not list then
        _, _, list = string.find(msg, "^%s*[Ss]trategies:%s*(.*)")
    end
    if not list then return false end

    local cleanSender = string.gsub(sender, "%-.*$", "")
    local normSender = NormalizeName(cleanSender)
    local lowerSender = string.lower(cleanSender)

    if not self.botCombatStrategies then self.botCombatStrategies = {} end
    local record = { text = list, active = {} }
    local iter = string.gmatch or string.gfind
    for strategy in iter(list, "[^,]+") do
        local clean = string.gsub(strategy, "^%s+", "")
        clean = string.gsub(clean, "%s+$", "")
        if clean ~= "" and clean ~= "(none)" and clean ~= "none" then
            record.active[clean] = true
            local lower = string.lower(clean)
            record.active[lower] = true
            local base = string.gsub(lower, "%s+pve$", "")
            base = string.gsub(base, "%s+pvp$", "")
            base = string.gsub(base, "%s+raid$", "")
            if base ~= lower then
                record.active[base] = true
            end
        end
    end
    self.botCombatStrategies[normSender] = record
    self.botCombatStrategies[cleanSender] = record
    self.botCombatStrategies[lowerSender] = record
    self.botCombatStrategies[sender] = record

    -- Synchronize behavior state
    self.botStates = self.botStates or {}
    local st = self.botStates[normSender] or self.botStates[cleanSender] or self.botStates[lowerSender] or {}
    if record.active["no aoe"] then
        st["aoe"] = "off"
    else
        st["aoe"] = "on"
    end
    if record.active["auto cc"] or record.active["autocc"] then st["autocc"] = "on" else st["autocc"] = "off" end
    if record.active["conserve mana"] or record.active["savemana"] or record.active["save mana"] then st["savemana"] = "on" else st["savemana"] = "off" end
    if record.active["boost"] then st["boost"] = "on" else st["boost"] = "off" end
    if record.active["threat"] then st["threat"] = "on" else st["threat"] = "off" end
    if record.active["potions"] or record.active["potion"] then st["potions"] = "on" else st["potions"] = "off" end
    if record.active["spread"] then st["spread"] = "on" else st["spread"] = "off" end

    self.botStates[normSender] = st
    self.botStates[cleanSender] = st
    self.botStates[lowerSender] = st
    self.botStates[sender] = st

    if self.behaviorPendingCombat then
        self.behaviorPendingCombat[normSender] = nil
        self.behaviorPendingCombat[cleanSender] = nil
        self.behaviorPendingCombat[lowerSender] = nil
        self.behaviorPendingCombat[sender] = nil
    end

    if self.behaviorTimedOut then
        self.behaviorTimedOut[normSender] = nil
        self.behaviorTimedOut[cleanSender] = nil
        self.behaviorTimedOut[lowerSender] = nil
        self.behaviorTimedOut[sender] = nil
    end

    if UnBotRoleFrame and UnBotRoleFrame:IsShown() then self:RefreshRoleTarget(false) end
    if UnBotStrategyFrame and UnBotStrategyFrame:IsShown() then
        if self.RefreshBehaviorView and (self.strategyMode == "behavior" or (UnBotStrategyFrame.behaviorPanel and UnBotStrategyFrame.behaviorPanel:IsShown())) then
            self:RefreshBehaviorView()
        end
        self:RefreshStrategies()
    end
    return true
end

function UnBot:ParseNonCombatStrategies(sender, msg)
    if not sender or not msg then return false end
    msg = CleanChat(msg)
    local _, _, list = string.find(msg, "[Nn]on[%s%-]*[Cc]ombat%s+[Ss]trategies:%s*(.*)")
    if not list then
        _, _, list = string.find(msg, "[Nn]on[%s%-]*[Cc]ombat:%s*(.*)")
    end
    if not list then return false end

    local cleanSender = string.gsub(sender, "%-.*$", "")
    local normSender = NormalizeName(cleanSender)
    local lowerSender = string.lower(cleanSender)

    if not self.botNonCombatStrategies then self.botNonCombatStrategies = {} end
    local record = { text = list, active = {} }
    local iter = string.gmatch or string.gfind
    for strategy in iter(list, "[^,]+") do
        local clean = string.gsub(strategy, "^%s+", "")
        clean = string.gsub(clean, "%s+$", "")
        if clean ~= "" and clean ~= "(none)" and clean ~= "none" then
            record.active[clean] = true
            local lower = string.lower(clean)
            record.active[lower] = true
            local base = string.gsub(lower, "%s+pve$", "")
            base = string.gsub(base, "%s+pvp$", "")
            base = string.gsub(base, "%s+raid$", "")
            if base ~= lower then
                record.active[base] = true
            end
        end
    end
    self.botNonCombatStrategies[normSender] = record
    self.botNonCombatStrategies[cleanSender] = record
    self.botNonCombatStrategies[lowerSender] = record
    self.botNonCombatStrategies[sender] = record

    -- Synchronize behavior state
    self.botStates = self.botStates or {}
    local st = self.botStates[normSender] or self.botStates[cleanSender] or self.botStates[lowerSender] or {}
    if record.active["loot"] then st["loot"] = "on" else st["loot"] = "off" end
    if record.active["mimic consumables"] or record.active["mimic"] then st["mimic"] = "on" else st["mimic"] = "off" end

    self.botStates[normSender] = st
    self.botStates[cleanSender] = st
    self.botStates[lowerSender] = st
    self.botStates[sender] = st

    if self.behaviorPendingNonCombat then
        self.behaviorPendingNonCombat[normSender] = nil
        self.behaviorPendingNonCombat[cleanSender] = nil
        self.behaviorPendingNonCombat[lowerSender] = nil
        self.behaviorPendingNonCombat[sender] = nil
    end

    if self.behaviorTimedOut then
        self.behaviorTimedOut[normSender] = nil
        self.behaviorTimedOut[cleanSender] = nil
        self.behaviorTimedOut[lowerSender] = nil
        self.behaviorTimedOut[sender] = nil
    end

    if UnBotStrategyFrame and UnBotStrategyFrame:IsShown() then
        if self.RefreshBehaviorView and (self.strategyMode == "behavior" or (UnBotStrategyFrame.behaviorPanel and UnBotStrategyFrame.behaviorPanel:IsShown())) then
            self:RefreshBehaviorView()
        end
        self:RefreshStrategies()
    end
    return true
end

function UnBot:ParseBotStateMessage(msg)
    if not msg or string.sub(msg, 1, 12) ~= "TBM:BOTSTATE|" then return false end
    local raw = string.sub(msg, 13)
    local parts = splitProtocol(raw)
    local rawName = parts[1]
    if not rawName or rawName == "" then return false end
    local cleanName = string.gsub(rawName, "%-.*$", "")
    local normName = NormalizeName(cleanName)
    local lowerName = string.lower(cleanName)

    local state = {}
    if parts[2] then
        state = parseBotStateFields(parts[2])
    end
    for p = 3, table.getn(parts) do
        local sub = parseBotStateFields(parts[p])
        for k, v in pairs(sub) do
            state[k] = v
        end
    end
    for k, v in pairs(state) do
        if v == "1" or v == "true" or v == "on" then
            state[k] = "on"
        elseif v == "0" or v == "false" or v == "off" then
            state[k] = "off"
        end
    end

    self.botStates = self.botStates or {}
    local cur = self.botStates[normName] or self.botStates[cleanName] or self.botStates[lowerName] or {}
    for k, v in pairs(state) do
        cur[k] = v
    end
    self.botStates[normName] = cur
    self.botStates[cleanName] = cur
    self.botStates[lowerName] = cur
    self.botStates[rawName] = cur

    if self.behaviorPendingCombat then
        self.behaviorPendingCombat[normName] = nil
        self.behaviorPendingCombat[cleanName] = nil
        self.behaviorPendingCombat[lowerName] = nil
        self.behaviorPendingCombat[rawName] = nil
    end
    if self.behaviorPendingNonCombat then
        self.behaviorPendingNonCombat[normName] = nil
        self.behaviorPendingNonCombat[cleanName] = nil
        self.behaviorPendingNonCombat[lowerName] = nil
        self.behaviorPendingNonCombat[rawName] = nil
    end
    if self.behaviorTimedOut then
        self.behaviorTimedOut[normName] = nil
        self.behaviorTimedOut[cleanName] = nil
        self.behaviorTimedOut[lowerName] = nil
        self.behaviorTimedOut[rawName] = nil
    end

    if UnBotStrategyFrame and UnBotStrategyFrame:IsShown() then
        if self.RefreshBehaviorView and (self.strategyMode == "behavior" or (UnBotStrategyFrame.behaviorPanel and UnBotStrategyFrame.behaviorPanel:IsShown())) then
            self:RefreshBehaviorView()
        end
        if self.RefreshStrategies then self:RefreshStrategies() end
    end
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
--  Strategy Tree Construction
--=========================================================================--

local function SortedKeys(t)
    local out = {}
    for k in pairs(t) do table.insert(out, k) end
    table.sort(out)
    return out
end

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

function UnBot:BuildStrategyTree()
    self:InitDefaultStrategies()
    local tree  = {}
    local store = self.config.strategies

    local bot = self.strategyTarget or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target")) or "Bot"
    table.insert(tree, {
        category   = "★ Bot Behaviour (" .. bot .. ")",
        items      = { "Open Behaviour Options for " .. bot },
        class      = false,
        isBehavior = true,
    })

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
                isBehavior = false,
            })
        end
    end

    local class = CLASS_TOKEN[self.strategyClass or ""]
    if class then AddSections(store[class], true) end
    AddSections(store.generic, false)

    return tree
end

function UnBot:GetStrategyRows()
    local rows = {}
    local tree = self.strategyTree or {}

    for i = 1, table.getn(tree) do
        local node = tree[i]
        table.insert(rows, {
            header     = true,
            category   = node.category,
            count      = table.getn(node.items),
            class      = node.class,
            isBehavior = node.isBehavior,
        })
        if self.expandedSections[node.category] then
            for j = 1, table.getn(node.items) do
                table.insert(rows, {
                    header     = false,
                    name       = node.items[j],
                    class      = node.class,
                    isBehavior = node.isBehavior,
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
--  Behaviour Actions & Command Execution
--=========================================================================--

function UnBot:QueryBotBehavior(bot)
    if not bot then return end
    local cleanBot = string.gsub(bot, "%-.*$", "")
    local normBot = NormalizeName(cleanBot)
    if normBot == "" then return end

    if self.behaviorTimedOut then
        self.behaviorTimedOut[normBot] = nil
        self.behaviorTimedOut[cleanBot] = nil
        self.behaviorTimedOut[bot] = nil
    end

    self.behaviorPendingCombat = self.behaviorPendingCombat or {}
    self.behaviorPendingNonCombat = self.behaviorPendingNonCombat or {}
    self.behaviorPendingCombat[normBot] = true
    self.behaviorPendingNonCombat[normBot] = true

    if UnBotStrategyFrame and UnBotStrategyFrame.behaviorPanel then
        UnBotStrategyFrame.behaviorPanel.pendingTime = 0
    end

    -- 1. First ask for strategies via companion whispers so bot whispers back its combat & non-combat strategy lists
    SendChatMessage("co ?", "WHISPER", nil, normBot)
    SendChatMessage("nc ?", "WHISPER", nil, normBot)

    -- 2. Also dispatch canonical TortoiseBots roster query to get live TBM:BOTSTATE snapshot for party bots
    if self.SendBotCommand then
        self:SendBotCommand("roster")
    else
        SendChatMessage(".bot roster")
    end
end

function UnBot:ToggleBotBehavior(key)
    local bot = self.strategyTarget or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target"))
    if not bot then
        self:Message("Select a bot first to configure behaviour.")
        return
    end
    local cleanBot = string.gsub(bot, "%-.*$", "")
    bot = NormalizeName(cleanBot)
    local normBot = bot
    local lowerBot = string.lower(cleanBot)

    if self.behaviorTimedOut then
        self.behaviorTimedOut[normBot] = nil
        self.behaviorTimedOut[cleanBot] = nil
        self.behaviorTimedOut[bot] = nil
    end

    self.botStates = self.botStates or {}
    local st = self.botStates[normBot] or self.botStates[cleanBot] or self.botStates[lowerBot] or {}
    local combatRec = self.botCombatStrategies and (self.botCombatStrategies[normBot] or self.botCombatStrategies[cleanBot] or self.botCombatStrategies[lowerBot])
    local nonCombatRec = self.botNonCombatStrategies and (self.botNonCombatStrategies[normBot] or self.botNonCombatStrategies[cleanBot] or self.botNonCombatStrategies[lowerBot])

    local cur = st[key]
    if not cur then
        if key == "loot" and nonCombatRec and nonCombatRec.active then
            cur = nonCombatRec.active["loot"] and "on" or "off"
        elseif key == "mimic" and nonCombatRec and nonCombatRec.active then
            cur = (nonCombatRec.active["mimic consumables"] or nonCombatRec.active["mimic"]) and "on" or "off"
        elseif key == "aoe" and combatRec and combatRec.active then
            cur = combatRec.active["no aoe"] and "off" or "on"
        elseif key == "autocc" and combatRec and combatRec.active then
            cur = (combatRec.active["auto cc"] or combatRec.active["autocc"]) and "on" or "off"
        elseif key == "savemana" and combatRec and combatRec.active then
            cur = (combatRec.active["conserve mana"] or combatRec.active["savemana"]) and "on" or "off"
        elseif key == "threat" and combatRec and combatRec.active then
            cur = combatRec.active["threat"] and "on" or "off"
        elseif key == "boost" and combatRec and combatRec.active then
            cur = combatRec.active["boost"] and "on" or "off"
        elseif key == "potions" and combatRec and combatRec.active then
            cur = (combatRec.active["potions"] or combatRec.active["potion"]) and "on" or "off"
        elseif key == "spread" and combatRec and combatRec.active then
            cur = combatRec.active["spread"] and "on" or "off"
        else
            cur = "off"
        end
    end

    local nextState = (cur == "on") and "off" or "on"
    st[key] = nextState
    self.botStates[normBot] = st
    self.botStates[cleanBot] = st
    self.botStates[lowerBot] = st

    -- 1. Dispatch canonical TortoiseBots behavior command
    local botCmd = "behavior " .. bot .. " " .. key .. " " .. nextState
    if self.SendBotCommand then
        self:SendBotCommand(botCmd)
    else
        SendChatMessage(".bot " .. botCmd)
    end

    -- 2. Also dispatch direct strategy change via whisper for vMaNGOS bot compatibility
    local def = nil
    for i = 1, table.getn(BEHAVIOR_DEFS) do
        if BEHAVIOR_DEFS[i].key == key then def = BEHAVIOR_DEFS[i]; break end
    end
    if def and def.strat then
        local sign = (nextState == "on") and "+" or "-"
        if def.invert then
            sign = (nextState == "on") and "-" or "+"
        end
        local mode = def.combat and "co" or "nc"
        if UnitIsPlayer("target") or UnitInParty("target") or UnitInRaid("target") then
            SendChatMessage(mode .. " " .. sign .. def.strat, "WHISPER", nil, bot)
        elseif GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then
            SendChatMessage(mode .. " " .. sign .. def.strat, "PARTY")
        else
            SendChatMessage(mode .. " " .. sign .. def.strat, "SAY")
        end
    end

    -- 3. Ask for strategies after clicking so the bot whispers and updates the addon from the chat log
    self.behaviorPendingCombat = self.behaviorPendingCombat or {}
    self.behaviorPendingNonCombat = self.behaviorPendingNonCombat or {}
    if def and def.combat then
        self.behaviorPendingCombat[normBot] = true
        SendChatMessage("co ?", "WHISPER", nil, normBot)
    else
        self.behaviorPendingNonCombat[normBot] = true
        SendChatMessage("nc ?", "WHISPER", nil, normBot)
    end
    if UnBotStrategyFrame and UnBotStrategyFrame.behaviorPanel then
        UnBotStrategyFrame.behaviorPanel.pendingTime = 0
    end

    local statusColor = (nextState == "on") and "|cff40a040" or "|cffa04040"
    self:Message(bot .. " - " .. (def and def.label or key) .. ": " .. statusColor .. string.upper(nextState) .. "|r (Verifying from bot...)")
    self:RefreshBehaviorView()
    if self.RefreshStrategies then self:RefreshStrategies() end
end

--=========================================================================--
--  Strategy Window Public Access
--=========================================================================--

function UnBot:ShowStrategyWindow(mode, botName)
    local target = botName or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target"))
    if not target then
        self:Message("Select a bot first to view strategies & behaviour.")
        return
    end

    local classToken = GetUnitClassToken("target")
    if not classToken then classToken = string.upper(UnitClass("target") or "") end

    if not UnBotStrategyFrame then self:CreateStrategyFrame() end

    self.strategyTarget    = NormalizeName(target)
    self.strategyClass     = classToken
    self.strategyMode      = mode or self.strategyMode or "dual"
    self.strategyOffset    = 0
    self.expandedSections  = self.expandedSections or {}
    self.strategyTree      = self:BuildStrategyTree()

    -- Ask for strategies before displaying
    if self.strategyMode == "behavior" then
        self:QueryBotBehavior(self.strategyTarget)
    elseif self.strategyMode == "dual" then
        if self.strategyTarget then
            SendChatMessage("co ?", "WHISPER", nil, self.strategyTarget)
            SendChatMessage("nc ?", "WHISPER", nil, self.strategyTarget)
        end
    else
        if not self:HaveStrategiesFor(classToken) then
            local class = CLASS_TOKEN[classToken]
            if class then
                self:Message("Fetching "..class.." strategies from "..self.strategyTarget.."...")
                SendChatMessage("|c0000FFFF|Hvalue:help:list:"..class..
                                " strategy|h["..class.."]|h|r", "WHISPER", nil, self.strategyTarget)
            end
        end
        SendChatMessage(self.strategyMode, "WHISPER", nil, self.strategyTarget)
    end

    UnBotStrategyFrame:Show()
    self:RefreshStrategies()
end

function UnBot:RebuildStrategyTree()
    if not UnBotStrategyFrame or not UnBotStrategyFrame:IsShown() then return end
    self.strategyTree = self:BuildStrategyTree()
    self:RefreshStrategies()
end

--=========================================================================--
--  Role Bar
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
    title:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
    title:SetPoint("TOP", f, "TOP", 0, -8)
    title:SetTextColor(1, 0.82, 0)
    title:SetText("Roles")

    local close = CreateFrame("Button", "UnBotRoleClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() f:Hide() end)

    local targetText = f:CreateFontString(nil, "OVERLAY")
    targetText:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
    targetText:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -28)
    targetText:SetTextColor(1, 1, 1)
    f.targetText = targetText

    local statusText = f:CreateFontString(nil, "OVERLAY")
    statusText:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
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

    local refresh = CreateFrame("Button", "UnBotSelectedRoleRefresh", f, "UIPanelButtonTemplate")
    refresh:SetWidth(88)
    refresh:SetHeight(20)
    refresh:SetPoint("TOP", f, "TOP", 0, -92)
    refresh:SetText("Check role")
    refresh:SetScript("OnClick", function() UnBot:RefreshRoleTarget(true) end)

    local allLabel = f:CreateFontString(nil, "OVERLAY")
    allLabel:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 9)
    allLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -120)
    allLabel:SetTextColor(0.75, 0.75, 0.75)
    allLabel:SetText("APPLY TO ALL GROUPED CLASS BOTS")

    for i = 1, count do
        local class = ROLE_ORDER[i]

        local btn = CreateFrame("Button", "UnBotRole"..class, f)
        btn:SetWidth(192)
        btn:SetHeight(20)
        btn:SetPoint("TOP", f, "TOP", 0, -136 - (i - 1) * 22)
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        btn.class = class

        local text = btn:CreateFontString(nil, "OVERLAY")
        text:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
        text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        local c = (UnBot.GetClassColor and UnBot:GetClassColor(class))
               or (CLASS_COLOR and CLASS_COLOR[class])
               or {1, 1, 1}
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
            GameTooltip:AddLine("Applies to every "..string.lower(this.class).." in your group", 0.6, 0.6, 0.6)
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

--=========================================================================--
--  Dual-Column Strategy Hub Definitions & Data
--=========================================================================--

local CLASS_SPEC_STRATEGIES = {
    WARRIOR = {"protection", "arms", "fury", "tank", "dps"},
    PALADIN = {"holy", "protection", "retribution", "heal", "tank", "dps"},
    HUNTER  = {"marksmanship", "beast mastery", "survival", "dps"},
    ROGUE   = {"combat", "assassination", "subtlety", "stealth", "dps"},
    PRIEST  = {"holy", "discipline", "shadow", "heal", "dps"},
    SHAMAN  = {"restoration", "elemental", "enhancement", "heal", "dps"},
    MAGE    = {"frost", "fire", "arcane", "dps"},
    WARLOCK = {"affliction", "demonology", "destruction", "dps"},
    DRUID   = {"restoration", "feral", "balance", "bear", "cat", "caster", "heal", "tank", "dps"},
}

local COMBAT_BASE_STRATEGIES = {
    "threat", "conserve mana", "kite", "flee", "avoid aoe", "wait for attack",
    "pull back", "focus heal targets", "focus rti targets", "mark rti", "racials",
    "potions", "no aoe", "aoe fear", "spread", "boost", "auto cc", "focus",
    "close", "behind", "tank face", "preheal", "heal interrupt", "passive",
    "dungeon", "molten core", "blackwing lair", "onyxia's lair", "zul'gurub",
    "ruins of ahn'qiraj", "ahn'qiraj temple", "naxxramas", "emerald sanctum",
    "lower karazhan", "karazhan crypt"
}

local NON_COMBAT_BASE_STRATEGIES = {
    "loot", "gather", "roll", "food", "consumables", "emote", "grind",
    "wander", "avoid mobs", "mimic consumables", "maintenance", "wbuff", "sit",
    "rpg", "rpg quest", "rpg vendor", "rpg explore", "rpg maintenance",
    "rpg craft", "rpg player", "rpg guild", "rpg bg", "travel", "explore", "map"
}

function UnBot:GetDualStrategies(mode)
    local list = {}
    local seen = {}

    local function add(s)
        if not s or s == "" then return end
        local lower = string.lower(s)
        if not seen[lower] then
            seen[lower] = true
            table.insert(list, s)
        end
    end

    local bot = self.strategyTarget or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target"))
    local cleanBot = bot and NormalizeName(bot)

    if mode == "co" then
        local classToken = self.strategyClass
        if not classToken and bot then
            classToken = GetUnitClassToken("target") or string.upper(UnitClass("target") or "")
        end
        if classToken and CLASS_SPEC_STRATEGIES[classToken] then
            for i = 1, table.getn(CLASS_SPEC_STRATEGIES[classToken]) do
                add(CLASS_SPEC_STRATEGIES[classToken][i])
            end
        end
        for i = 1, table.getn(COMBAT_BASE_STRATEGIES) do
            add(COMBAT_BASE_STRATEGIES[i])
        end
        local rec = self.botCombatStrategies and (self.botCombatStrategies[cleanBot] or (bot and self.botCombatStrategies[bot]))
        if rec and rec.active then
            for s in pairs(rec.active) do
                add(s)
            end
        end
    else
        for i = 1, table.getn(NON_COMBAT_BASE_STRATEGIES) do
            add(NON_COMBAT_BASE_STRATEGIES[i])
        end
        local rec = self.botNonCombatStrategies and (self.botNonCombatStrategies[cleanBot] or (bot and self.botNonCombatStrategies[bot]))
        if rec and rec.active then
            for s in pairs(rec.active) do
                add(s)
            end
        end
    end

    return list
end

local function IsStrategyActive(rec, strat)
    if not rec or not rec.active or not strat then return false end
    local lower = string.lower(strat)
    if rec.active[strat] or rec.active[lower] then return true end
    if rec.active[lower .. " pve"] or rec.active[lower .. " pvp"] or rec.active[lower .. " raid"] then
        return true
    end
    return false
end

function UnBot:ToggleStrategyDual(stratName, mode)
    if not stratName or stratName == "" then return end
    local bot = self.strategyTarget or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target"))
    local cleanBot = bot and NormalizeName(bot) or nil

    local rec = (mode == "co" and self.botCombatStrategies or self.botNonCombatStrategies)
    local botRec = cleanBot and rec and (rec[cleanBot] or (bot and rec[bot]))
    local isActive = IsStrategyActive(botRec, stratName)

    local sign = isActive and "-" or "+"
    local nextState = isActive and "OFF" or "ON"

    -- 1. Optimistic state update
    if cleanBot then
        rec = rec or {}
        if mode == "co" then self.botCombatStrategies = rec else self.botNonCombatStrategies = rec end
        rec[cleanBot] = rec[cleanBot] or { text = "", active = {} }
        botRec = rec[cleanBot]
        local lower = string.lower(stratName)
        if isActive then
            botRec.active[stratName] = nil
            botRec.active[lower] = nil
            botRec.active[lower .. " pve"] = nil
            botRec.active[lower .. " pvp"] = nil
            botRec.active[lower .. " raid"] = nil
        else
            botRec.active[stratName] = true
            botRec.active[lower] = true
        end
    end

    -- 2. Dispatch canonical TortoiseBots command: .bot strategy <sign><stratName> [cleanBot]
    local stratLower = string.lower(stratName)
    local changeParts = { sign .. stratLower }
    if isActive and botRec and botRec.active then
        if botRec.active[stratLower .. " pve"] then
            table.insert(changeParts, "-" .. stratLower .. " pve")
        end
        if botRec.active[stratLower .. " pvp"] then
            table.insert(changeParts, "-" .. stratLower .. " pvp")
        end
        if botRec.active[stratLower .. " raid"] then
            table.insert(changeParts, "-" .. stratLower .. " raid")
        end
    end
    local botCmd = "strategy " .. table.concat(changeParts, ",") .. (cleanBot and (" " .. cleanBot) or "")
    if self.SendBotCommand then
        self:SendBotCommand(botCmd)
    else
        SendChatMessage(".bot " .. botCmd)
    end

    -- 3. Dual-dispatch via whisper / channel for compatibility & query updated strategies
    local cmdText = mode .. " " .. sign .. stratName
    if cleanBot and (UnitIsPlayer("target") or UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage(cmdText, "WHISPER", nil, cleanBot)
        SendChatMessage(mode .. " ?", "WHISPER", nil, cleanBot)
    elseif GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then
        SendChatMessage(cmdText, "PARTY")
        SendChatMessage(mode .. " ?", "PARTY")
    else
        SendChatMessage(cmdText, "SAY")
        SendChatMessage(mode .. " ?", "SAY")
    end

    local statusColor = (sign == "+") and "|cff40a040" or "|cffa04040"
    local botLabel = cleanBot or "Party"
    self:Message(botLabel .. " [" .. mode .. "] " .. stratName .. ": " .. statusColor .. nextState .. "|r")

    if UnBotStrategyFrame and UnBotStrategyFrame:IsShown() then
        self:RefreshStrategies()
    end
end

function UnBot:CreateDualStrategyPanel(parent)
    local dp = CreateFrame("Frame", "UnBotStrategyDualPanel", parent)
    dp:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, -66)
    dp:SetWidth(492)
    dp:SetHeight(ROW_COUNT * ROW_HEIGHT + 14)

    self.dualCombatOffset = 0
    self.dualNonCombatOffset = 0
    local VISIBLE_ROWS = 14

    -- Left Column: Combat Strategies (co)
    local leftCol = CreateFrame("Frame", "UnBotStrategyColLeft", dp)
    leftCol:SetPoint("TOPLEFT", dp, "TOPLEFT", 0, 0)
    leftCol:SetWidth(242)
    leftCol:SetHeight(VISIBLE_ROWS * ROW_HEIGHT + 28)
    dp.leftCol = leftCol

    local leftTitle = leftCol:CreateFontString(nil, "OVERLAY")
    leftTitle:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
    leftTitle:SetPoint("TOPLEFT", leftCol, "TOPLEFT", 4, 0)
    leftTitle:SetTextColor(1, 0.82, 0)
    leftTitle:SetText("Combat Strategies (co)")
    leftCol.title = leftTitle

    local leftUp = CreateFrame("Button", nil, leftCol, "UIPanelButtonTemplate")
    leftUp:SetWidth(20); leftUp:SetHeight(16)
    leftUp:SetPoint("TOPRIGHT", leftCol, "TOPRIGHT", -26, 2)
    leftUp:SetText("^")
    leftUp:SetScript("OnClick", function()
        UnBot.dualCombatOffset = (UnBot.dualCombatOffset or 0) - 1
        if UnBot.dualCombatOffset < 0 then UnBot.dualCombatOffset = 0 end
        UnBot:RefreshDualStrategyView()
    end)

    local leftDown = CreateFrame("Button", nil, leftCol, "UIPanelButtonTemplate")
    leftDown:SetWidth(20); leftDown:SetHeight(16)
    leftDown:SetPoint("TOPRIGHT", leftCol, "TOPRIGHT", -4, 2)
    leftDown:SetText("v")
    leftDown:SetScript("OnClick", function()
        local total = table.getn(UnBot:GetDualStrategies("co"))
        local maxOff = total - VISIBLE_ROWS
        if maxOff < 0 then maxOff = 0 end
        UnBot.dualCombatOffset = (UnBot.dualCombatOffset or 0) + 1
        if UnBot.dualCombatOffset > maxOff then UnBot.dualCombatOffset = maxOff end
        UnBot:RefreshDualStrategyView()
    end)

    leftCol:EnableMouseWheel(true)
    leftCol:SetScript("OnMouseWheel", function()
        local total = table.getn(UnBot:GetDualStrategies("co"))
        local maxOff = total - VISIBLE_ROWS
        if maxOff < 0 then maxOff = 0 end
        UnBot.dualCombatOffset = (UnBot.dualCombatOffset or 0) - arg1
        if UnBot.dualCombatOffset < 0 then UnBot.dualCombatOffset = 0 end
        if UnBot.dualCombatOffset > maxOff then UnBot.dualCombatOffset = maxOff end
        UnBot:RefreshDualStrategyView()
    end)

    leftCol.rows = {}
    for i = 1, VISIBLE_ROWS do
        local btn = CreateFrame("Button", "UnBotDualCombatRow" .. i, leftCol)
        btn:SetWidth(238)
        btn:SetHeight(ROW_HEIGHT)
        btn:SetPoint("TOPLEFT", leftCol, "TOPLEFT", 2, -20 - (i - 1) * ROW_HEIGHT)
        btn:RegisterForClicks("LeftButtonUp")
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(btn)
        bg:SetTexture(0.12, 0.12, 0.12, (math.mod(i, 2) == 0) and 0.4 or 0.2)
        btn.bg = bg

        local lamp = btn:CreateFontString(nil, "OVERLAY")
        lamp:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
        lamp:SetPoint("LEFT", btn, "LEFT", 4, 0)
        btn.lamp = lamp

        local nameText = btn:CreateFontString(nil, "OVERLAY")
        nameText:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
        nameText:SetPoint("LEFT", lamp, "RIGHT", 6, 0)
        nameText:SetPoint("RIGHT", btn, "RIGHT", -44, 0)
        nameText:SetJustifyH("LEFT")
        btn.nameText = nameText

        local badge = btn:CreateFontString(nil, "OVERLAY")
        badge:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 9)
        badge:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
        btn.badge = badge

        btn:SetScript("OnClick", function()
            if this.stratName then
                UnBot:ToggleStrategyDual(this.stratName, "co")
            end
        end)

        btn:SetScript("OnEnter", function()
            if not this.stratName then return end
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Combat Strategy: " .. this.stratName, 1, 0.82, 0)
            GameTooltip:AddLine("Click to toggle ON / OFF", 0.85, 0.85, 0.85)
            GameTooltip:AddLine("Sends 'co +" .. this.stratName .. "' or 'co -" .. this.stratName .. "'", 0.5, 0.7, 0.9)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        leftCol.rows[i] = btn
    end

    -- Right Column: Non-combat Strategies (nc)
    local rightCol = CreateFrame("Frame", "UnBotStrategyColRight", dp)
    rightCol:SetPoint("TOPLEFT", dp, "TOPLEFT", 248, 0)
    rightCol:SetWidth(242)
    rightCol:SetHeight(VISIBLE_ROWS * ROW_HEIGHT + 28)
    dp.rightCol = rightCol

    local rightTitle = rightCol:CreateFontString(nil, "OVERLAY")
    rightTitle:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
    rightTitle:SetPoint("TOPLEFT", rightCol, "TOPLEFT", 4, 0)
    rightTitle:SetTextColor(0.55, 0.75, 1)
    rightTitle:SetText("Non-combat Strategies (nc)")
    rightCol.title = rightTitle

    local rightUp = CreateFrame("Button", nil, rightCol, "UIPanelButtonTemplate")
    rightUp:SetWidth(20); rightUp:SetHeight(16)
    rightUp:SetPoint("TOPRIGHT", rightCol, "TOPRIGHT", -26, 2)
    rightUp:SetText("^")
    rightUp:SetScript("OnClick", function()
        UnBot.dualNonCombatOffset = (UnBot.dualNonCombatOffset or 0) - 1
        if UnBot.dualNonCombatOffset < 0 then UnBot.dualNonCombatOffset = 0 end
        UnBot:RefreshDualStrategyView()
    end)

    local rightDown = CreateFrame("Button", nil, rightCol, "UIPanelButtonTemplate")
    rightDown:SetWidth(20); rightDown:SetHeight(16)
    rightDown:SetPoint("TOPRIGHT", rightCol, "TOPRIGHT", -4, 2)
    rightDown:SetText("v")
    rightDown:SetScript("OnClick", function()
        local total = table.getn(UnBot:GetDualStrategies("nc"))
        local maxOff = total - VISIBLE_ROWS
        if maxOff < 0 then maxOff = 0 end
        UnBot.dualNonCombatOffset = (UnBot.dualNonCombatOffset or 0) + 1
        if UnBot.dualNonCombatOffset > maxOff then UnBot.dualNonCombatOffset = maxOff end
        UnBot:RefreshDualStrategyView()
    end)

    rightCol:EnableMouseWheel(true)
    rightCol:SetScript("OnMouseWheel", function()
        local total = table.getn(UnBot:GetDualStrategies("nc"))
        local maxOff = total - VISIBLE_ROWS
        if maxOff < 0 then maxOff = 0 end
        UnBot.dualNonCombatOffset = (UnBot.dualNonCombatOffset or 0) - arg1
        if UnBot.dualNonCombatOffset < 0 then UnBot.dualNonCombatOffset = 0 end
        if UnBot.dualNonCombatOffset > maxOff then UnBot.dualNonCombatOffset = maxOff end
        UnBot:RefreshDualStrategyView()
    end)

    rightCol.rows = {}
    for i = 1, VISIBLE_ROWS do
        local btn = CreateFrame("Button", "UnBotDualNonCombatRow" .. i, rightCol)
        btn:SetWidth(238)
        btn:SetHeight(ROW_HEIGHT)
        btn:SetPoint("TOPLEFT", rightCol, "TOPLEFT", 2, -20 - (i - 1) * ROW_HEIGHT)
        btn:RegisterForClicks("LeftButtonUp")
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(btn)
        bg:SetTexture(0.12, 0.12, 0.12, (math.mod(i, 2) == 0) and 0.4 or 0.2)
        btn.bg = bg

        local lamp = btn:CreateFontString(nil, "OVERLAY")
        lamp:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
        lamp:SetPoint("LEFT", btn, "LEFT", 4, 0)
        btn.lamp = lamp

        local nameText = btn:CreateFontString(nil, "OVERLAY")
        nameText:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
        nameText:SetPoint("LEFT", lamp, "RIGHT", 6, 0)
        nameText:SetPoint("RIGHT", btn, "RIGHT", -44, 0)
        nameText:SetJustifyH("LEFT")
        btn.nameText = nameText

        local badge = btn:CreateFontString(nil, "OVERLAY")
        badge:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 9)
        badge:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
        btn.badge = badge

        btn:SetScript("OnClick", function()
            if this.stratName then
                UnBot:ToggleStrategyDual(this.stratName, "nc")
            end
        end)

        btn:SetScript("OnEnter", function()
            if not this.stratName then return end
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Non-combat Strategy: " .. this.stratName, 0.55, 0.75, 1)
            GameTooltip:AddLine("Click to toggle ON / OFF", 0.85, 0.85, 0.85)
            GameTooltip:AddLine("Sends 'nc +" .. this.stratName .. "' or 'nc -" .. this.stratName .. "'", 0.5, 0.7, 0.9)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        rightCol.rows[i] = btn
    end

    dp:Hide()
    parent.dualPanel = dp
end

function UnBot:RefreshDualStrategyView()
    local f = UnBotStrategyFrame
    if not f or not f.dualPanel then return end
    local dp = f.dualPanel

    local bot = self.strategyTarget or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target")) or "?"
    local cleanBot = string.gsub(bot, "%-.*$", "")
    cleanBot = NormalizeName(cleanBot)

    -- Left Column: Combat Strategies
    local coRec = self.botCombatStrategies and (self.botCombatStrategies[cleanBot] or self.botCombatStrategies[bot])
    local coList = self:GetDualStrategies("co")
    local coOffset = self.dualCombatOffset or 0
    local VISIBLE_ROWS = 14

    for i = 1, VISIBLE_ROWS do
        local btn = dp.leftCol.rows[i]
        local strat = coList[i + coOffset]
        if strat then
            btn.stratName = strat
            local isActive = IsStrategyActive(coRec, strat)
            if isActive then
                btn.lamp:SetText("|cff40a040●|r")
                btn.nameText:SetText("|cffffffff" .. strat .. "|r")
                btn.badge:SetText("|cff40a040[ON]|r")
            else
                btn.lamp:SetText("|cffa04040○|r")
                btn.nameText:SetText("|cff888888" .. strat .. "|r")
                btn.badge:SetText("|cffa04040[OFF]|r")
            end
            btn:Show()
        else
            btn.stratName = nil
            btn:Hide()
        end
    end

    -- Right Column: Non-combat Strategies
    local ncRec = self.botNonCombatStrategies and (self.botNonCombatStrategies[cleanBot] or self.botNonCombatStrategies[bot])
    local ncList = self:GetDualStrategies("nc")
    local ncOffset = self.dualNonCombatOffset or 0

    for i = 1, VISIBLE_ROWS do
        local btn = dp.rightCol.rows[i]
        local strat = ncList[i + ncOffset]
        if strat then
            btn.stratName = strat
            local isActive = IsStrategyActive(ncRec, strat)
            if isActive then
                btn.lamp:SetText("|cff40a040●|r")
                btn.nameText:SetText("|cffffffff" .. strat .. "|r")
                btn.badge:SetText("|cff40a040[ON]|r")
            else
                btn.lamp:SetText("|cffa04040○|r")
                btn.nameText:SetText("|cff888888" .. strat .. "|r")
                btn.badge:SetText("|cffa04040[OFF]|r")
            end
            btn:Show()
        else
            btn.stratName = nil
            btn:Hide()
        end
    end
end

--=========================================================================--
--  Strategy & Behaviour UI Frame Construction
--=========================================================================--

function UnBot:CreateStrategyFrame()
    local f = CreateFrame("Frame", "UnBotStrategyFrame", UIParent)
    f:SetWidth(520)
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
    f:SetScript("OnMouseWheel", function()
        if UnBot.strategyMode == "co" or UnBot.strategyMode == "nc" then
            UnBot:ScrollStrategies(-arg1)
        end
    end)
    f:Hide()

    if UISpecialFrames then
        table.insert(UISpecialFrames, "UnBotStrategyFrame")
    end

    local title = f:CreateFontString("UnBotStrategyTitle", "OVERLAY")
    title:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 14)
    title:SetPoint("TOP", f, "TOP", 0, -16)
    title:SetTextColor(1, 0.82, 0)
    f.title = title

    local close = CreateFrame("Button", "UnBotStrategyClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    local function Tab(name, label, mode, x, width)
        local btn = CreateFrame("Button", name, f, "UIPanelButtonTemplate")
        btn:SetWidth(width)
        btn:SetHeight(21)
        btn:SetPoint("TOPLEFT", f, "TOPLEFT", x, -40)
        btn:SetText(label)
        btn.mode = mode
        btn:SetScript("OnClick", function()
            UnBot.strategyMode = this.mode
            UnBot.strategyOffset = 0
            UnBot:RefreshStrategies()
            if this.mode == "behavior" then
                if UnBot.strategyTarget then
                    UnBot:QueryBotBehavior(UnBot.strategyTarget)
                end
            elseif this.mode == "dual" then
                if UnBot.strategyTarget then
                    SendChatMessage("co ?", "WHISPER", nil, UnBot.strategyTarget)
                    SendChatMessage("nc ?", "WHISPER", nil, UnBot.strategyTarget)
                end
            elseif UnBot.strategyTarget then
                SendChatMessage(this.mode, "WHISPER", nil, UnBot.strategyTarget)
            end
        end)
        return btn
    end

    f.tabDual     = Tab("UnBotStrategyTabDual", "Strategies", "dual", 18, 236)
    f.tabBehavior = Tab("UnBotStrategyTabBeh", "Behaviour", "behavior", 266, 236)
    f.tabCombat   = Tab("UnBotStrategyTabCo", "Combat", "co", 134, 108); f.tabCombat:Hide()
    f.tabNon      = Tab("UnBotStrategyTabNc", "Non-combat", "nc", 246, 116); f.tabNon:Hide()

    self:CreateDualStrategyPanel(f)
    self:CreateStrategyRows(f)
    self:CreateBehaviorPanel(f)

    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
    hint:SetPoint("BOTTOM", f, "BOTTOM", 0, 16)
    hint:SetTextColor(0.6, 0.6, 0.6)
    f.hint = hint
end

function UnBot:CreateStrategyRows(parent)
    self.strategyRows = {}

    for i = 1, ROW_COUNT do
        local row = CreateFrame("Button", "UnBotStrategyRow"..i, parent)
        row:SetWidth(482)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 18, -68 - (i - 1) * ROW_HEIGHT)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        local text = row:CreateFontString(nil, "OVERLAY")
        text:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
        text:SetPoint("LEFT", row, "LEFT", 6, 0)
        row.text = text

        row:SetScript("OnClick", function()
            if this.isBehavior or (this.category and string.find(this.category, "★ Bot Behaviour")) then
                UnBot.strategyMode = "behavior"
                UnBot.strategyOffset = 0
                UnBot:RefreshStrategies()
                if UnBot.strategyTarget then
                    UnBot:QueryBotBehavior(UnBot.strategyTarget)
                end
                return
            end
            if this.category then
                UnBot.expandedSections[this.category] = not UnBot.expandedSections[this.category]
                UnBot:RefreshStrategies()
            elseif this.strategyName then
                local sign = "+"
                if arg1 == "RightButton" then sign = "-" end
                UnBot:SetStrategy(this.strategyName, sign)
            end
        end)

        row:SetScript("OnEnter", function()
            if this.isBehavior or (this.category and string.find(this.category, "★ Bot Behaviour")) then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Bot Behaviour Options", 1, 0.82, 0)
                GameTooltip:AddLine("Click to configure combat & survival habits", 0.3, 1, 0.3)
                GameTooltip:AddLine("Loot, AoE, Auto CC, Threat, Potions, Cooldowns...", 0.7, 0.7, 0.7)
                GameTooltip:Show()
            elseif this.category then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine(this.category, 1, 0.82, 0)
                GameTooltip:AddLine("Click to open or close", 0.65, 0.55, 0)
                GameTooltip:Show()
            elseif this.strategyName then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine(this.strategyName, 1, 1, 1)
                GameTooltip:AddLine(UnBot.strategyMode.." +"..this.strategyName, 0.3, 1, 0.3)
                GameTooltip:AddLine(UnBot.strategyMode.." -"..this.strategyName, 1, 0.4, 0.4)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:Hide()
        self.strategyRows[i] = row
    end
end

--=========================================================================--
--  Dedicated Behaviour Options Panel inside Strategy Window
--=========================================================================--

function UnBot:CreateBehaviorPanel(parent)
    local bp = CreateFrame("Frame", "UnBotStrategyBehaviorPanel", parent)
    bp:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, -66)
    bp:SetWidth(490)
    bp:SetHeight(294)

    local headerText = bp:CreateFontString(nil, "OVERLAY")
    headerText:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 12)
    headerText:SetPoint("TOPLEFT", bp, "TOPLEFT", 6, -2)
    headerText:SetTextColor(1, 0.82, 0)
    headerText:SetText("Bot Behaviour Options")
    bp.headerText = headerText

    local subText = bp:CreateFontString(nil, "OVERLAY")
    subText:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 9)
    subText:SetPoint("TOPLEFT", bp, "TOPLEFT", 6, -18)
    subText:SetTextColor(0.7, 0.7, 0.7)
    subText:SetText("Combat & Adventure Habits (Saved on Server)")
    bp.subText = subText

    bp.chips = {}
    for i = 1, table.getn(BEHAVIOR_DEFS) do
        local def = BEHAVIOR_DEFS[i]
        local chip = CreateFrame("Button", "UnBotBehaviorOpt" .. def.key, bp)
        chip:SetWidth(482)
        chip:SetHeight(24)
        chip:SetPoint("TOPLEFT", bp, "TOPLEFT", 4, -36 - (i - 1) * 26)
        chip:RegisterForClicks("LeftButtonUp")
        chip:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        local border = chip:CreateTexture(nil, "BACKGROUND")
        border:SetAllPoints(chip)
        border:SetTexture(0.18, 0.18, 0.18, 0.6)
        chip.border = border

        local lamp = chip:CreateTexture(nil, "OVERLAY")
        lamp:SetWidth(8)
        lamp:SetHeight(8)
        lamp:SetPoint("LEFT", chip, "LEFT", 6, 0)
        lamp:SetTexture(0.40, 0.40, 0.40, 1)
        chip.lamp = lamp

        local label = chip:CreateFontString(nil, "OVERLAY")
        label:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11)
        label:SetPoint("LEFT", lamp, "RIGHT", 8, 0)
        label:SetTextColor(1, 0.85, 0.4)
        label:SetText(def.label)
        chip.label = label

        local tipPreview = chip:CreateFontString(nil, "OVERLAY")
        tipPreview:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 8)
        tipPreview:SetPoint("LEFT", label, "RIGHT", 8, 0)
        tipPreview:SetTextColor(0.65, 0.65, 0.65)
        tipPreview:SetText(def.tip)
        chip.tipPreview = tipPreview

        local badge = chip:CreateFontString(nil, "OVERLAY")
        badge:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
        badge:SetPoint("RIGHT", chip, "RIGHT", -8, 0)
        badge:SetText("|cffa04040[ OFF ]|r")
        chip.badge = badge

        chip.key = def.key
        chip.def = def

        chip:SetScript("OnClick", function()
            UnBot:ToggleBotBehavior(this.key)
        end)

        chip:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:AddLine(this.def.label, 1, 0.82, 0)
            GameTooltip:AddLine(this.def.tip, 0.9, 0.9, 0.9, 1)
            GameTooltip:AddLine("Command: .bot behavior <bot> " .. this.key .. " on/off", 0.6, 0.6, 0.6)
            GameTooltip:AddLine("Click to toggle ON / OFF", 0.3, 1, 0.3)
            GameTooltip:Show()
        end)
        chip:SetScript("OnLeave", function() GameTooltip:Hide() end)

        bp.chips[def.key] = chip
    end

    -- Bottom Action Buttons
    local queryBtn = CreateFrame("Button", "UnBotBehaviorQueryBtn", bp, "UIPanelButtonTemplate")
    queryBtn:SetWidth(120)
    queryBtn:SetHeight(20)
    queryBtn:SetPoint("BOTTOMLEFT", bp, "BOTTOMLEFT", 6, 2)
    queryBtn:SetText("Query State")
    queryBtn:SetScript("OnClick", function()
        if UnBot.strategyTarget then
            if UnBot.behaviorTimedOut then
                UnBot.behaviorTimedOut[UnBot.strategyTarget] = nil
                local clean = string.gsub(UnBot.strategyTarget, "%-.*$", "")
                UnBot.behaviorTimedOut[clean] = nil
                UnBot.behaviorTimedOut[NormalizeName(clean)] = nil
            end
            UnBot:QueryBotBehavior(UnBot.strategyTarget)
            UnBot:Message("Querying behaviour for " .. UnBot.strategyTarget .. "...")
            UnBot:RefreshBehaviorView()
        end
    end)
    bp.queryBtn = queryBtn

    local backBtn = CreateFrame("Button", "UnBotBehaviorBackBtn", bp, "UIPanelButtonTemplate")
    backBtn:SetWidth(140)
    backBtn:SetHeight(20)
    backBtn:SetPoint("LEFT", queryBtn, "RIGHT", 10, 0)
    backBtn:SetText("Back to Strategies")
    backBtn:SetScript("OnClick", function()
        UnBot.strategyMode = "dual"
        UnBot:RefreshStrategies()
    end)
    bp.backBtn = backBtn

    local partyBtn = CreateFrame("Button", "UnBotBehaviorPartyBtn", bp, "UIPanelButtonTemplate")
    partyBtn:SetWidth(140)
    partyBtn:SetHeight(20)
    partyBtn:SetPoint("LEFT", backBtn, "RIGHT", 10, 0)
    partyBtn:SetText("Party Consensus")
    partyBtn:SetScript("OnClick", function()
        UnBot:SendBotCommand("action aoe status")
        UnBot:SendBotCommand("action autocc status")
        UnBot:SendBotCommand("action loot status")
    end)
    bp.partyBtn = partyBtn

    bp.pendingTime = 0
    bp:SetScript("OnUpdate", function()
        local dt = arg1 or 0.1
        local target = UnBot.strategyTarget
        local normTarget = target and NormalizeName(string.gsub(target, "%-.*$", "")) or nil
        if normTarget and ((UnBot.behaviorPendingCombat and UnBot.behaviorPendingCombat[normTarget])
           or (UnBot.behaviorPendingNonCombat and UnBot.behaviorPendingNonCombat[normTarget])) then
            bp.pendingTime = (bp.pendingTime or 0) + dt
            if bp.pendingTime > 4.5 then
                if UnBot.behaviorPendingCombat then
                    UnBot.behaviorPendingCombat[normTarget] = nil
                end
                if UnBot.behaviorPendingNonCombat then
                    UnBot.behaviorPendingNonCombat[normTarget] = nil
                end
                UnBot.behaviorTimedOut = UnBot.behaviorTimedOut or {}
                UnBot.behaviorTimedOut[normTarget] = true
                bp.pendingTime = 0
                UnBot:RefreshBehaviorView()
            end
        else
            bp.pendingTime = 0
        end
    end)

    bp:Hide()
    parent.behaviorPanel = bp
end

function UnBot:RefreshBehaviorView()
    if not UnBotStrategyFrame or not UnBotStrategyFrame.behaviorPanel then return end
    local bp = UnBotStrategyFrame.behaviorPanel
    local bot = self.strategyTarget or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target"))
    if not bot then
        bp.headerText:SetText("No Bot Selected")
        bp.subText:SetText("Select a bot in your party or raid.")
        return
    end
    local cleanBot = string.gsub(bot, "%-.*$", "")
    local normBot = NormalizeName(cleanBot)
    local lowerBot = string.lower(cleanBot)

    local classToken = GetUnitClassToken("target") or (self.strategyClass) or ""
    local isNoMana = (classToken == "WARRIOR" or classToken == "ROGUE")

    local col = (self.GetClassColor and self:GetClassColor(classToken)) or { 1, 0.82, 0 }
    bp.headerText:SetText(normBot .. " - Behaviour Options")
    bp.headerText:SetTextColor(col[1], col[2], col[3])

    local st = self.botStates and (self.botStates[normBot] or self.botStates[cleanBot] or self.botStates[lowerBot] or self.botStates[bot]) or {}
    local combatRec = self.botCombatStrategies and (self.botCombatStrategies[normBot] or self.botCombatStrategies[cleanBot] or self.botCombatStrategies[lowerBot] or self.botCombatStrategies[bot])
    local nonCombatRec = self.botNonCombatStrategies and (self.botNonCombatStrategies[normBot] or self.botNonCombatStrategies[cleanBot] or self.botNonCombatStrategies[lowerBot] or self.botNonCombatStrategies[bot])

    local combatPending = (self.behaviorPendingCombat and self.behaviorPendingCombat[normBot] == true)
    local nonCombatPending = (self.behaviorPendingNonCombat and self.behaviorPendingNonCombat[normBot] == true)
    local isTimedOut = (self.behaviorTimedOut and self.behaviorTimedOut[normBot] == true)

    -- If neither record has ever been received, not currently pending, and not timed out, automatically ask for strategies once
    if combatRec == nil and nonCombatRec == nil and not combatPending and not nonCombatPending and not isTimedOut then
        self:QueryBotBehavior(normBot)
        combatPending = true
        nonCombatPending = true
    end

    if combatPending or nonCombatPending then
        bp.subText:SetText("|cffffcc00Querying strategies... Reading chat log from " .. normBot .. "...|r")
    elseif isTimedOut then
        bp.subText:SetText("|cffff8888No whisper response from " .. normBot .. " (Click 'Query State' to retry)|r")
    else
        bp.subText:SetText("|cff40ff40Combat & Adventure Habits (Read from " .. normBot .. ")|r")
    end

    for i = 1, table.getn(BEHAVIOR_DEFS) do
        local def = BEHAVIOR_DEFS[i]
        local chip = bp.chips[def.key]
        if chip then
            if def.mana and isNoMana then
                chip:Hide()
            else
                chip:Show()
                local isPending = false
                if def.combat then
                    isPending = (combatPending == true)
                else
                    isPending = (nonCombatPending == true)
                end

                if isPending then
                    chip.badge:SetText("|cffffcc00[ Reading... ]|r")
                    chip.lamp:SetTexture(0.70, 0.60, 0.20, 1)
                    chip.border:SetTexture(0.25, 0.22, 0.12, 0.8)
                else
                    local val = st[def.key]
                    if not val then
                        if def.key == "loot" and nonCombatRec and nonCombatRec.active then
                            val = nonCombatRec.active["loot"] and "on" or "off"
                        elseif def.key == "mimic" and nonCombatRec and nonCombatRec.active then
                            val = (nonCombatRec.active["mimic consumables"] or nonCombatRec.active["mimic"]) and "on" or "off"
                        elseif def.key == "aoe" and combatRec and combatRec.active then
                            val = combatRec.active["no aoe"] and "off" or "on"
                        elseif def.key == "autocc" and combatRec and combatRec.active then
                            val = (combatRec.active["auto cc"] or combatRec.active["autocc"]) and "on" or "off"
                        elseif def.key == "savemana" and combatRec and combatRec.active then
                            val = (combatRec.active["conserve mana"] or combatRec.active["savemana"]) and "on" or "off"
                        elseif def.key == "threat" and combatRec and combatRec.active then
                            val = combatRec.active["threat"] and "on" or "off"
                        elseif def.key == "boost" and combatRec and combatRec.active then
                            val = combatRec.active["boost"] and "on" or "off"
                        elseif def.key == "potions" and combatRec and combatRec.active then
                            val = (combatRec.active["potions"] or combatRec.active["potion"]) and "on" or "off"
                        elseif def.key == "spread" and combatRec and combatRec.active then
                            val = combatRec.active["spread"] and "on" or "off"
                        else
                            val = "off"
                        end
                    end

                    if val == "on" then
                        chip.badge:SetText("|cff40ff40[ ON ]|r")
                        chip.lamp:SetTexture(0.30, 0.90, 0.45, 1)
                        chip.border:SetTexture(0.20, 0.45, 0.25, 0.8)
                    else
                        chip.badge:SetText("|cffa04040[ OFF ]|r")
                        chip.lamp:SetTexture(0.60, 0.25, 0.25, 1)
                        chip.border:SetTexture(0.25, 0.15, 0.15, 0.6)
                    end
                end
            end
        end
    end
end

--=========================================================================--
--  Refreshing & Strategy Scrolling
--=========================================================================--

function UnBot:SetStrategy(name, sign)
    local mode = (self.strategyMode == "nc") and "nc" or "co"
    local target = self.strategyTarget or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target"))
    local cleanBot = target and NormalizeName(target) or nil

    -- 1. Canonical TortoiseBots command: .bot strategy <sign><name> [cleanBot]
    local stratLower = string.lower(name)
    local botCmd = "strategy " .. sign .. stratLower .. (cleanBot and (" " .. cleanBot) or "")
    if self.SendBotCommand then
        self:SendBotCommand(botCmd)
    else
        SendChatMessage(".bot " .. botCmd)
    end

    -- 2. Dual-dispatch via whisper / channel
    local cmd = mode .. " " .. sign .. name
    if cleanBot and (UnitIsPlayer("target") or UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage(cmd, "WHISPER", nil, cleanBot)
        SendChatMessage("co ?", "WHISPER", nil, cleanBot)
        SendChatMessage("nc ?", "WHISPER", nil, cleanBot)
        self:Message(cmd .. " -> " .. cleanBot)
    elseif GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then
        SendChatMessage(cmd, "PARTY")
        SendChatMessage("co ?", "PARTY")
        SendChatMessage("nc ?", "PARTY")
        self:Message(cmd .. " -> PARTY")
    else
        SendChatMessage(cmd, "SAY")
        SendChatMessage("co ?", "SAY")
        SendChatMessage("nc ?", "SAY")
        self:Message(cmd)
    end
end

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
    if not UnBotStrategyFrame or not UnBotStrategyFrame:IsShown() then return end

    local f = UnBotStrategyFrame
    local bot = self.strategyTarget or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target")) or "?"

    if self.strategyMode == "dual" then
        if f.tabDual then f.tabDual:LockHighlight() end
        f.tabCombat:UnlockHighlight()
        f.tabNon:UnlockHighlight()
        f.tabBehavior:UnlockHighlight()
        f.title:SetText(bot .. "  -  Strategy Hub")
        f.hint:SetText("Click any strategy to toggle  |cff40a040● ON|r   |cffa04040○ OFF|r")

        for i = 1, ROW_COUNT do
            if self.strategyRows[i] then self.strategyRows[i]:Hide() end
        end
        if f.behaviorPanel then f.behaviorPanel:Hide() end
        if f.dualPanel then
            f.dualPanel:Show()
            self:RefreshDualStrategyView()
        end
        return
    end

    if self.strategyMode == "behavior" then
        if f.tabDual then f.tabDual:UnlockHighlight() end
        f.tabCombat:UnlockHighlight()
        f.tabNon:UnlockHighlight()
        f.tabBehavior:LockHighlight()
        f.title:SetText(bot .. "  -  Behaviour Options")
        f.hint:SetText("Click an option to toggle ON / OFF. Settings save to server.")

        for i = 1, ROW_COUNT do
            if self.strategyRows[i] then self.strategyRows[i]:Hide() end
        end
        if f.dualPanel then f.dualPanel:Hide() end
        if f.behaviorPanel then
            f.behaviorPanel:Show()
            self:RefreshBehaviorView()
        end
        return
    end

    if f.dualPanel then f.dualPanel:Hide() end
    if f.behaviorPanel then f.behaviorPanel:Hide() end

    local label = "Combat"
    if self.strategyMode == "nc" then label = "Non-combat" end
    f.title:SetText(bot .. "  -  " .. label .. " strategies")

    if f.tabDual then f.tabDual:UnlockHighlight() end
    f.tabBehavior:UnlockHighlight()
    if self.strategyMode == "co" then
        f.tabCombat:LockHighlight()
        f.tabNon:UnlockHighlight()
    else
        f.tabCombat:UnlockHighlight()
        f.tabNon:LockHighlight()
    end

    local rows = self:GetStrategyRows()
    local cleanSender = string.gsub(bot, "%-.*$", "")
    local rec = (self.strategyMode == "co" and self.botCombatStrategies or self.botNonCombatStrategies)
    local botRec = rec and (rec[cleanSender] or rec[bot])

    for i = 1, ROW_COUNT do
        local row = self.strategyRows[i]
        local entry = rows[i + self.strategyOffset]

        row.category     = nil
        row.strategyName = nil
        row.isBehavior   = nil

        if entry and entry.header then
            row.category   = entry.category
            row.isBehavior = entry.isBehavior
            local mark = "+"
            if self.expandedSections[entry.category] then mark = "-" end
            if entry.isBehavior then
                row.text:SetText("|cff00ffff" .. mark .. " " .. entry.category .. "|r")
            else
                row.text:SetText(mark .. " " .. entry.category .. "  (" .. entry.count .. ")")
                if entry.class then
                    row.text:SetTextColor(1, 0.82, 0)
                else
                    row.text:SetTextColor(0.55, 0.75, 1)
                end
            end
            row:Show()

        elseif entry then
            row.strategyName = entry.name
            row.isBehavior   = entry.isBehavior
            if entry.isBehavior then
                row.text:SetText("    |cff40ff40★|r " .. entry.name)
            else
                local isActive = botRec and botRec.active and (botRec.active[entry.name] or botRec.active[string.lower(entry.name)])
                if isActive then
                    row.text:SetText("    |cff40a040●|r " .. entry.name .. " |cff40a040[ON]|r")
                    row.text:SetTextColor(1, 1, 1)
                else
                    row.text:SetText("    |cffa04040○|r " .. entry.name .. " |cffa04040[OFF]|r")
                    if entry.class then
                        row.text:SetTextColor(0.85, 0.85, 0.85)
                    else
                        row.text:SetTextColor(0.65, 0.65, 0.65)
                    end
                end
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
