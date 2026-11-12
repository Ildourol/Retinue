-- Retinue Roster & Tactics Hub - Vanilla 1.12 / Turtle WoW 1.18.1
--
-- Features:
--   1. Account Alts Roster: SavedVariables + server .bot roster / .bot list
--   2. Bot Loot History Log: party bot loot, roll decisions, money, and items
--   3. Active Party Roster: live roles (Tank/Heal/DPS), CC mark badges, 1-click gear inspect
--   4. Raid Encounter Tactics: Tank face away, Douse runes, Turtle custom raid toggles, boss tactics
--   5. Crowd Control (CC) Manager: 8 raid marks exclusive assignment and tracking
--   6. Sequenced Roster Batch Queue: error-handled invites with automatic ConvertToRaid()

Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue

local CLASSES = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}

-- Ensure global CLASS_ICON_TCOORDS and CLASS_COLOR exist
CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS or (Retinue and Retinue.CLASS_ICON_TCOORDS) or {
    WARRIOR     = {0.0, 0.25, 0.0, 0.25},
    MAGE        = {0.25, 0.49609375, 0.0, 0.25},
    ROGUE       = {0.49609375, 0.7421875, 0.0, 0.25},
    DRUID       = {0.7421875, 0.98828125, 0.0, 0.25},
    HUNTER      = {0.0, 0.25, 0.25, 0.5},
    SHAMAN      = {0.25, 0.49609375, 0.25, 0.5},
    PRIEST      = {0.49609375, 0.7421875, 0.25, 0.5},
    WARLOCK     = {0.7421875, 0.98828125, 0.25, 0.5},
    PALADIN     = {0.0, 0.25, 0.5, 0.75},
    DEATHKNIGHT = {0.25, 0.5, 0.5, 0.75},
}

CLASS_COLOR = CLASS_COLOR or (Retinue and Retinue.CLASS_COLOR) or {
    WARRIOR     = {0.78, 0.61, 0.43, hex = "ffc79c6e"},
    PALADIN     = {0.96, 0.55, 0.73, hex = "fff58cba"},
    HUNTER      = {0.67, 0.83, 0.45, hex = "ffabd473"},
    ROGUE       = {1.00, 0.96, 0.41, hex = "fffff569"},
    PRIEST      = {1.00, 1.00, 1.00, hex = "ffffffff"},
    DEATHKNIGHT = {0.77, 0.12, 0.23, hex = "ffc41f3b"},
    SHAMAN      = {0.00, 0.44, 0.87, hex = "ff0070de"},
    MAGE        = {0.41, 0.80, 0.94, hex = "ff69ccf0"},
    WARLOCK     = {0.58, 0.51, 0.79, hex = "ff9482c9"},
    DRUID       = {1.00, 0.49, 0.04, hex = "ffff7d0a"},
}

local CLASS_ID_TO_TOKEN = {
    [1]  = "WARRIOR",
    [2]  = "PALADIN",
    [3]  = "HUNTER",
    [4]  = "ROGUE",
    [5]  = "PRIEST",
    [6]  = "DEATHKNIGHT",
    [7]  = "SHAMAN",
    [8]  = "MAGE",
    [9]  = "WARLOCK",
    [11] = "DRUID",
}

local _classAliases = {
    [1]  = "WARRIOR",     ["1"]  = "WARRIOR",     Warrior = "WARRIOR",     warrior = "WARRIOR",
    [2]  = "PALADIN",     ["2"]  = "PALADIN",     Paladin = "PALADIN",     paladin = "PALADIN",
    [3]  = "HUNTER",      ["3"]  = "HUNTER",      Hunter  = "HUNTER",      hunter  = "HUNTER",
    [4]  = "ROGUE",       ["4"]  = "ROGUE",       Rogue   = "ROGUE",       rogue   = "ROGUE",
    [5]  = "PRIEST",      ["5"]  = "PRIEST",      Priest  = "PRIEST",      priest  = "PRIEST",
    [6]  = "DEATHKNIGHT", ["6"]  = "DEATHKNIGHT", ["Death Knight"] = "DEATHKNIGHT", deathknight = "DEATHKNIGHT",
    [7]  = "SHAMAN",      ["7"]  = "SHAMAN",      Shaman  = "SHAMAN",      shaman  = "SHAMAN",
    [8]  = "MAGE",        ["8"]  = "MAGE",        Mage    = "MAGE",        mage    = "MAGE",
    [9]  = "WARLOCK",     ["9"]  = "WARLOCK",     Warlock = "WARLOCK",     warlock = "WARLOCK",
    [11] = "DRUID",       ["11"] = "DRUID",       Druid   = "DRUID",       druid   = "DRUID",
}
for alias, canonical in pairs(_classAliases) do
    if CLASS_ICON_TCOORDS[canonical] and not CLASS_ICON_TCOORDS[alias] then
        CLASS_ICON_TCOORDS[alias] = CLASS_ICON_TCOORDS[canonical]
    end
    if CLASS_COLOR[canonical] and not CLASS_COLOR[alias] then
        CLASS_COLOR[alias] = CLASS_COLOR[canonical]
    end
end

local ROW_COUNT  = 10
local ROW_HEIGHT = 22


--=========================================================================--
--  Helpers
--=========================================================================--

local function CleanChat(msg)
    if not msg then return "" end
    msg = string.gsub(msg, "|c%x%x%x%x%x%x%x%x", "")
    msg = string.gsub(msg, "|r", "")
    msg = string.gsub(msg, "|H.-|h", "")
    msg = string.gsub(msg, "|h", "")
    return msg
end

local function splitPipe(text)
    local out = {}
    local start = 1
    while true do
        local at = string.find(text, "|", start, true)
        if at then
            table.insert(out, string.sub(text, start, at - 1))
            start = at + 1
        else
            table.insert(out, string.sub(text, start))
            break
        end
    end
    return out
end

local function protocolFields(msg, prefix)
    if string.sub(msg, 1, string.len(prefix)) ~= prefix then return nil end
    return splitPipe(string.sub(msg, string.len(prefix) + 1))
end

local function IsValidCharacterName(name)
    if not name or type(name) ~= "string" then return false end
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    if name == "" or name == "-" or name == "nil" then return false end
    local lower = string.lower(name)
    if lower == "unknown" or lower == "unknown entity" or lower == "unknown being" then return false end
    if UNKNOWNOBJECT and string.lower(UNKNOWNOBJECT) == lower then return false end
    if UNKNOWNBEING and string.lower(UNKNOWNBEING) == lower then return false end
    if string.len(name) < 2 then return false end
    if string.find(name, "[^%a%d_]") then return false end
    return true
end
UnBot.IsValidCharacterName = IsValidCharacterName
setglobal("IsValidCharacterName", IsValidCharacterName)

function UnBot:SanitizeRoster()
    if not self.config or not self.config.roster then return end
    local me = UnitName("player")
    local myNameValid = IsValidCharacterName(me)
    local myLower = myNameValid and string.lower(me) or ""
    for name, data in pairs(self.config.roster) do
        if not IsValidCharacterName(name) then
            self.config.roster[name] = nil
        elseif data and data.self and myNameValid and string.lower(name) ~= myLower then
            data.self = nil
        end
    end
end

local function IsInGroup(selfOrName, maybeName)
    local name = maybeName or selfOrName
    if name == UnBot and maybeName == nil then name = nil end

    if not name or name == "" then
        local raid = GetNumRaidMembers()
        if raid and raid > 0 then return true end
        local party = GetNumPartyMembers()
        if party and party > 0 then return true end
        return false
    end

    if type(name) ~= "string" then return false end
    local lowerName = string.lower(name)
    local pName = UnitName("player")
    if pName and string.lower(pName) == lowerName then return true end

    local raid = GetNumRaidMembers()
    if raid and raid > 0 then
        for i = 1, raid do
            local rName = UnitName("raid"..i)
            if rName and string.lower(rName) == lowerName then return true end
        end
    else
        local party = GetNumPartyMembers()
        if party and party > 0 then
            for i = 1, party do
                local partName = UnitName("party"..i)
                if partName and string.lower(partName) == lowerName then return true end
            end
        end
    end
    return false
end
UnBot.IsInGroup = IsInGroup
setglobal("IsInGroup", IsInGroup)

local function NativeInvite(selfOrName, maybeName)
    local name = maybeName or selfOrName
    if name == UnBot and maybeName == nil then return false end
    if not name or name == "" or type(name) ~= "string" then return false end
    if type(InviteByName) == "function" then
        InviteByName(name)
        return true
    elseif type(InviteUnit) == "function" then
        InviteUnit(name)
        return true
    end
    if SlashCmdList and SlashCmdList["INVITE"] then
        SlashCmdList["INVITE"](name)
        return true
    end
    return false
end
UnBot.NativeInvite = NativeInvite
setglobal("NativeInvite", NativeInvite)

local function GetGroupUnit(name)
    if not name or type(name) ~= "string" then return nil end
    local lower = string.lower(name)
    local me = UnitName("player")
    if me and string.lower(me) == lower then return "player" end
    local raid = GetNumRaidMembers()
    if raid and raid > 0 then
        for i = 1, raid do
            local rName = UnitName("raid"..i)
            if rName and string.lower(rName) == lower then return "raid"..i end
        end
    else
        local party = GetNumPartyMembers()
        if party and party > 0 then
            for i = 1, party do
                local pName = UnitName("party"..i)
                if pName and string.lower(pName) == lower then return "party"..i end
            end
        end
    end
    return nil
end
UnBot.GetGroupUnit = GetGroupUnit

function UnBot:TargetBot(name)
    if not name or name == "" or type(name) ~= "string" then return false end
    local lower = string.lower(name)
    local me = UnitName("player")
    if me and string.lower(me) == lower then
        if TargetUnit then TargetUnit("player") end
        return true
    end

    local groupUnit = GetGroupUnit(name)
    if groupUnit and TargetUnit then
        TargetUnit(groupUnit)
        return true
    end

    if TargetByName then
        TargetByName(name, true)
        local cur = UnitName("target")
        if cur and string.lower(cur) == lower then return true end
        TargetByName(name)
        cur = UnitName("target")
        if cur and string.lower(cur) == lower then return true end
    end
    return false
end
UnBot.TargetBot = UnBot.TargetBot
setglobal("TargetBot", function(name) return UnBot:TargetBot(name) end)

function UnBot:InteractWithBot(name, button)
    if not name or name == "" or type(name) ~= "string" then return end
    button = button or "LeftButton"

    -- 1. Always attempt targeting the bot first (works across party, raid, and world render)
    self:TargetBot(name)

    -- 2. Shift-Click -> Open Remote Equipment & Bag Inspector
    if IsShiftKeyDown and IsShiftKeyDown() then
        if self.ShowItemWindow then
            self:ShowItemWindow("view", name)
        end
        return
    end

    -- 3. Right-Click -> Contextual Dismiss / Remove
    if button == "RightButton" then
        if IsInGroup(name) then
            self:UninviteBot(name)
        else
            local data = self.config and self.config.roster and self.config.roster[name]
            if data and data.altbot then
                self:SendBotCommand("remove " .. name)
                data.online = false
                data.grouped = false
                self:RefreshRoster()
            else
                self:RemoveRosterCharacter(name)
            end
        end
        return
    end

    -- 4. Left-Click -> Invite or Bring to Group
    if IsInGroup(name) then
        -- Already grouped, targeting is complete
        return
    end

    local data = self.config and self.config.roster and self.config.roster[name]
    local isAccountAlt = (data and data.altbot == true)
    local isClaimed = (self.claimedState and self.claimedState[name]) and true or false
    local isOnline = (data and data.online == true) or (isClaimed and self.claimedState[name].serverState ~= "offline")

    -- Only account alts can be spawned into the world via .bot add
    if isAccountAlt and not isOnline and not isClaimed then
        self:SendBotCommand("add " .. name)
        if data then data.online = true end
        self:RefreshRoster()
    end

    -- Invite to party/raid (NativeInvite works for ALL bots: account alts, claimed bots, wandering bots)
    self:InviteBot(name)
end

function UnBot:UninviteBot(name)
    if not name or not IsValidCharacterName(name) then return false end

    local unit = GetGroupUnit(name)
    if unit and type(UninviteUnit) == "function" then UninviteUnit(unit) end
    if type(UninviteByName) == "function" then UninviteByName(name) end
    if SlashCmdList and SlashCmdList["UNINVITE"] then SlashCmdList["UNINVITE"](name) end

    SendChatMessage("leave", "WHISPER", nil, name)
    self:SendBotCommand("uninvite " .. name)

    if self.config and self.config.roster and self.config.roster[name] then
        self.config.roster[name].grouped = false
    end
    return true
end

local function NativeUninvite(selfOrName, maybeName)
    local name = maybeName or selfOrName
    if name == UnBot and maybeName == nil then return false end
    if not name or name == "" or type(name) ~= "string" then return false end
    return UnBot:UninviteBot(name)
end
UnBot.NativeUninvite = NativeUninvite
setglobal("NativeUninvite", NativeUninvite)

local function GroupSize()
    local raid = GetNumRaidMembers()
    if raid and raid > 0 then return raid end
    return 1 + (GetNumPartyMembers() or 0)
end

--=========================================================================--
--  Init & State Storage
--=========================================================================--

UnBot.claimedState      = {}
UnBot.claimedBots       = {}
UnBot.claimedSelection  = {}
UnBot.ccAssignments     = {}
UnBot.activeRosterTab   = "account"
UnBot.raidCustomState   = "on"
UnBot.raidBotTactics    = {}

function UnBot:InitRoster()
    math.randomseed(time())
    if self.config.roster == nil then self.config.roster = {} end
    self:SanitizeRoster()
    self.rosterFilter = "ALL"
    self.rosterSearchQuery = nil
    self.rosterOffset = 0
    self.lootOffset = 0
    self.rosterSelection = {}
    self.activeRosterTab = (self.config and self.config.activeRosterTab) or "account"

    self:RecordCurrentCharacter()
    self:ScanGroupBots()
    self:InitRosterEvents()
end

local ROSTER_EVENTS = {
    "CHAT_MSG_SYSTEM", "CHAT_MSG_WHISPER", "CHAT_MSG_SAY", "CHAT_MSG_PARTY",
    "CHAT_MSG_YELL", "CHAT_MSG_RAID", "CHAT_MSG_ADDON",
    "PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE", "PLAYER_TARGET_CHANGED",
}

function UnBot:InitRosterEvents()
    local f = CreateFrame("Frame", "UnBotRosterEvents")
    for i = 1, table.getn(ROSTER_EVENTS) do
        f:RegisterEvent(ROSTER_EVENTS[i])
    end
    f:SetScript("OnEvent", function()
        if event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
            if UnBot.rosterBatch and UnBot.rosterBatch.action == "invite" then
                local currentName = UnBot.rosterBatch.names[UnBot.rosterBatch.index]
                if currentName and IsInGroup(currentName) then
                    UnBot.rosterBatch.index = UnBot.rosterBatch.index + 1
                    UnBot:ProcessNextBatchItem()
                end
            end
            if UnBot.pendingInvites then
                for pendingName, _ in pairs(UnBot.pendingInvites) do
                    if IsInGroup(pendingName) then
                        UnBot.pendingInvites[pendingName] = nil
                    end
                end
            end
            UnBot:ScanGroupBots()
            UnBot:RefreshActiveRosterView()
            return
        elseif event == "PLAYER_TARGET_CHANGED" then
            if UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") then
                UnBot:ScanGroupBots()
            end
            UnBot:RefreshActiveRosterView()
            return
        end

        if event == "CHAT_MSG_ADDON" then
            if arg1 == "TBM" and arg2 then
                UnBot:ParseServerRoster(arg2)
            end
        else
            UnBot:ParseServerRoster(arg1)
        end
    end)
end

function UnBot:ScanGroupBots()
    local found = 0
    local me = UnitName("player")
    local myLower = (me and IsValidCharacterName(me)) and string.lower(me) or ""
    local function CheckUnit(unit)
        if not UnitExists(unit) then return end
        local name = UnitName(unit)
        if not IsValidCharacterName(name) then return end
        if myLower ~= "" and string.lower(name) == myLower then return end
        local _, classToken = UnitClass(unit)
        local level = UnitLevel(unit)
        local entry = UnBot.config.roster[name] or {}
        entry.class = classToken or entry.class or "WARRIOR"
        entry.level = (level and level > 0) and level or entry.level or 0
        entry.online = true
        entry.grouped = IsInGroup(name)
        UnBot.config.roster[name] = entry
        found = found + 1
    end

    if UnitInRaid("player") then
        local n = GetNumRaidMembers()
        for i = 1, n do CheckUnit("raid"..i) end
    else
        local n = GetNumPartyMembers()
        for i = 1, n do CheckUnit("party"..i) end
    end

    if UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") then
        CheckUnit("target")
    end

    for rName, rData in pairs(UnBot.config.roster) do
        if rData and not rData.self then
            rData.grouped = IsInGroup(rName)
        end
    end
    return found
end

function UnBot:AddRosterCharacter(name, classToken, level)
    if not IsValidCharacterName(name) then return end
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    if not IsValidCharacterName(name) then return end
    name = string.upper(string.sub(name, 1, 1)) .. string.lower(string.sub(name, 2))
    if not IsValidCharacterName(name) then return end

    local entry = self.config.roster[name] or {}
    entry.class = classToken or entry.class or "WARRIOR"
    entry.level = (level and level > 0) and level or entry.level or 0
    entry.grouped = IsInGroup(name)
    if entry.grouped then
        entry.online = true
    elseif entry.online == nil then
        entry.online = false
    end
    self.config.roster[name] = entry
    self:Message("Added bot '"..name.."' ("..entry.class..") to player roster")
    self:RefreshRoster()
    return name
end

function UnBot:AddTargetToRoster()
    if not UnitExists("target") then
        self:Message("Select a friendly bot or character first to add them")
        return
    end
    if not UnitIsPlayer("target") then
        self:Message("Target must be a player or bot character")
        return
    end
    local name = UnitName("target")
    if not IsValidCharacterName(name) then
        self:Message("Target name is not available yet (resolving)")
        return
    end
    local me = UnitName("player")
    if me and string.lower(name) == string.lower(me) then
        self:Message("That is you - you are already in the roster")
        return
    end
    local _, classToken = UnitClass("target")
    local level = UnitLevel("target")
    local isFriend = UnitIsFriend("player", "target")
    self:AddRosterCharacter(name, classToken, level)
    if isFriend then
        self.config.roster[name].online = true
        self.config.roster[name].grouped = IsInGroup(name)
    end
    self:RefreshRoster()
end

function UnBot:RequestServerRoster(feedback)
    self:ScanGroupBots()
    self:SendBotCommand("roster")
    self:SendBotCommand("list")
    if feedback then
        self:Message("Syncing roster and claimed bots with server...")
    end
    self:RefreshActiveRosterView()
end

--=========================================================================--
--  Protocol Parser (TBM Protocol Streams)
--=========================================================================--

function UnBot:ParseServerRoster(msg)
    if not msg or msg == "" then return false end
    msg = CleanChat(msg)

    -- 1. TBM Claimed Bots Stream
    local fields = protocolFields(msg, "TBM:CLAIMED_BEGIN|")
    if fields then
        self.claimedReceiving = { expected = tonumber(fields[1]) or 0, rows = {} }
        return true
    end

    fields = protocolFields(msg, "TBM:CLAIMED|")
    if fields then
        if self.claimedReceiving and table.getn(fields) >= 8 then
            local guid = fields[1]
            local name = fields[2]
            local classId = tonumber(fields[3]) or 1
            local level = tonumber(fields[4]) or 1
            local serverState = fields[5]
            local group = (fields[6] == "1")
            local location = fields[7]
            local gearLocked = (fields[8] == "1")

            table.insert(self.claimedReceiving.rows, {
                guid = guid,
                name = name,
                classId = classId,
                className = CLASS_ID_TO_TOKEN[classId] or "WARRIOR",
                level = level,
                serverState = serverState,
                group = group,
                location = location,
                gearLocked = gearLocked,
            })
        end
        return true
    end

    if msg == "TBM:CLAIMED_END" then
        if self.claimedReceiving then
            self:CommitClaimedSnapshot(self.claimedReceiving.rows)
            self.claimedReceiving = nil
        end
        return true
    end

    -- 2. TBM CC Assignments Stream
    fields = protocolFields(msg, "TBM:CC_ASSIGN_BEGIN|")
    if fields then
        self.ccReceiving = { expected = tonumber(fields[1]) or 0, rows = {} }
        return true
    end

    fields = protocolFields(msg, "TBM:CC_ASSIGN|")
    if fields then
        if self.ccReceiving and table.getn(fields) >= 2 then
            local name = fields[1]
            local mark = string.lower(fields[2] or "")
            table.insert(self.ccReceiving.rows, { name = name, mark = mark })
        end
        return true
    end

    if msg == "TBM:CC_ASSIGN_END" then
        if self.ccReceiving then
            self:CommitCcSnapshot(self.ccReceiving.rows)
            self.ccReceiving = nil
        end
        return true
    end

    -- 3. TBM Roster Stream
    if string.find(msg, "^TBM:ROSTER_BEGIN") then
        self.tbmRosterCount = 0
        return true
    end

    if string.find(msg, "^TBM:ROSTER|") then
        local parts = splitPipe(string.sub(msg, 12))
        if table.getn(parts) >= 5 then
            local counter = parts[1]
            local name = parts[2]
            local classId = tonumber(parts[3]) or 1
            local state = parts[4]
            local grouped = parts[5]
            local location = parts[6] or ""
            local ccMark = parts[7]

            if name and IsValidCharacterName(name) then
                local record = self.config.roster[name] or {}
                record.class    = CLASS_ID_TO_TOKEN[classId] or record.class or "WARRIOR"
                record.online   = (state ~= "offline")
                record.level    = record.level or 0
                record.grouped  = (tonumber(grouped) == 1) or IsInGroup(name)
                record.location = location
                if ccMark and ccMark ~= "" and ccMark ~= "-" then
                    record.ccMark = string.lower(ccMark)
                    self.ccAssignments[name] = record.ccMark
                end
                self.config.roster[name] = record
                self.tbmRosterCount = (self.tbmRosterCount or 0) + 1
            end
        end
        return true
    end

    if string.find(msg, "^TBM:ROSTER_END") then
        self:RefreshActiveRosterView()
        return true
    end

    if string.find(msg, "^TBM:ALTBOTS|") then
        local _, _, alts = string.find(msg, "^TBM:ALTBOTS|(.*)")
        if alts and alts ~= "" then
            local iter = string.gmatch or string.gfind
            for altName in iter(alts, "[^,]+") do
                altName = string.gsub(altName, "^%s+", "")
                altName = string.gsub(altName, "%s+$", "")
                if IsValidCharacterName(altName) and self.config.roster[altName] then
                    self.config.roster[altName].altbot = true
                end
            end
        end
        return true
    end

    -- 4. Raid Tactics & Custom Status Responses
    if string.find(msg, "^Custom raid tactics are%s+(%S+)") then
        local _, _, st = string.find(msg, "^Custom raid tactics are%s+(%S+)")
        self.raidCustomState = string.lower(st or "on")
        if self.RefreshRaidView then self:RefreshRaidView() end
        return true
    end

    local _, _, botTacticName, tactics = string.find(msg, "^%[?([%a%d_]+)%]?%s+tactics:%s*(.*)")
    if botTacticName and tactics then
        self.raidBotTactics[botTacticName] = tactics
        if self.RefreshRaidView then self:RefreshRaidView() end
        return true
    end

    -- 5. Fallback Legacy .bot list response
    local _, _, botName, botWorldState = string.find(msg, "^([%a%d_]+):%s*([%a%s]+),%s*random")
    if botName and IsValidCharacterName(botName) then
        local inWorld = (botWorldState == "in world")
        local record = self.config.roster[botName] or {}
        record.online = (inWorld or botWorldState == "starting")
        record.class  = record.class or "WARRIOR"
        record.level  = record.level or 0
        record.grouped = IsInGroup(botName)
        self.config.roster[botName] = record
        self:RefreshActiveRosterView()
        return true
    end

    return false
end

function UnBot:CommitClaimedSnapshot(rows)
    self.claimedState = {}
    self.claimedBots = {}
    for i = 1, table.getn(rows) do
        local row = rows[i]
        self.claimedState[row.name] = row
        table.insert(self.claimedBots, row)
    end
    table.sort(self.claimedBots, function(a, b)
        if a.level ~= b.level then return a.level > b.level end
        return a.name < b.name
    end)
    self.claimedSnapshotReady = true
end

function UnBot:CommitCcSnapshot(rows)
    self.ccAssignments = {}
    for i = 1, table.getn(rows) do
        local row = rows[i]
        self.ccAssignments[row.name] = row.mark
        if self.config.roster and self.config.roster[row.name] then
            self.config.roster[row.name].ccMark = row.mark
        end
    end
    if self.RefreshCCView then self:RefreshCCView() end
    if self.RefreshPartyView then self:RefreshPartyView() end
end

--=========================================================================--
--  Bot Loot History Model
--=========================================================================--

local QUALITY_HEX = {
    [0] = "|cff9d9d9d", -- Poor
    [1] = "|cffffffff", -- Common
    [2] = "|cff1eff00", -- Uncommon
    [3] = "|cff0070dd", -- Rare
    [4] = "|cffa335ee", -- Epic
    [5] = "|cffff8000", -- Legendary
    [6] = "|cffe6cc80", -- Artifact
}

local QUALITY_NAMES = {
    [-1] = "Any Qual",
    [0]  = "Poor",
    [1]  = "Common",
    [2]  = "Uncommon",
    [3]  = "Rare",
    [4]  = "Epic",
    [5]  = "Legendary",
    [6]  = "Artifact",
}

local VOTE_LABEL = { need = "Need", greed = "Greed", disenchant = "Disenchant", pass = "Pass" }
local VOTE_COLOR = { need = "|cff00ff00", greed = "|cffffd200", disenchant = "|cffa335ee", pass = "|cff9d9d9d" }

function UnBot:GetLootQualityHex(q)
    return (q and QUALITY_HEX[q]) or "|cffffffff"
end

function UnBot:GetLootQualityName(q)
    return (q and QUALITY_NAMES[q]) or "Any Qual"
end

function UnBot:FormatCopper(copper)
    copper = tonumber(copper) or 0
    local g = math.floor(copper / 10000)
    local s = math.floor(math.mod(copper, 10000) / 100)
    local c = math.mod(copper, 100)
    local text = ""
    if g > 0 then text = text .. "|cffffd700" .. g .. "g|r " end
    if g > 0 or s > 0 then text = text .. "|cffc7c7cf" .. s .. "s|r " end
    return text .. "|cffeda55f" .. c .. "c|r"
end

function UnBot:GetLootHistory()
    if not self.config then return self.lootHistory or {} end
    if type(self.config.lootHistory) ~= "table" then
        self.config.lootHistory = {}
    end
    return self.config.lootHistory
end

function UnBot:ClearLootLog()
    if self.config then
        self.config.lootHistory = {}
    end
    self.lootHistory = {}
    self.lootOffset = 0
    if self.RefreshLootLogView then self:RefreshLootLogView() end
end

local function lootRowKey(row)
    return (row.ts or "") .. "|" .. (row.bot or "") .. "|" .. (row.event or "")
        .. "|" .. tostring(row.itemId or "") .. "|" .. (row.item or "")
end

function UnBot:MergeLootRows(newRows)
    local history = self:GetLootHistory()
    local seen = {}
    for i = 1, table.getn(history) do
        seen[lootRowKey(history[i])] = true
    end
    local added = 0
    for i = 1, table.getn(newRows) do
        local r = newRows[i]
        local k = lootRowKey(r)
        if not seen[k] then
            seen[k] = true
            table.insert(history, 1, r)
            added = added + 1
        end
    end
    while table.getn(history) > 2000 do
        table.remove(history)
    end
    return added
end

function UnBot:RequestLootLog(cursor)
    if cursor and cursor ~= "" then
        self:SendBotCommand("lootlog " .. cursor)
    else
        self:SendBotCommand("lootlog")
    end
end

function UnBot:GetFilteredLoot()
    local history = self:GetLootHistory()
    local botFilter = self.lootBotFilter and string.lower(string.gsub(string.gsub(self.lootBotFilter, "^%s+", ""), "%s+$", "")) or ""
    local itemFilter = self.lootItemFilter and string.lower(string.gsub(string.gsub(self.lootItemFilter, "^%s+", ""), "%s+$", "")) or ""
    local qualityFilter = self.lootQualityFilter or -1
    local typeFilter = self.lootTypeFilter or "all"

    local out = {}
    for i = 1, table.getn(history) do
        local r = history[i]
        local match = true
        if botFilter ~= "" and not string.find(string.lower(r.bot or ""), botFilter, 1, true) then
            match = false
        end
        if match and itemFilter ~= "" and not string.find(string.lower(r.item or ""), itemFilter, 1, true) then
            match = false
        end
        if match and qualityFilter >= 0 and (r.quality == nil or r.quality < qualityFilter) then
            match = false
        end
        if match and typeFilter ~= "all" then
            if typeFilter == "items" and (r.event ~= "StoreLootAction") then
                match = false
            elseif typeFilter == "rolls" and (r.event ~= "LootRoll") then
                match = false
            elseif typeFilter == "money" and (r.event ~= "LootMoney") then
                match = false
            end
        end
        if match then
            table.insert(out, r)
        end
    end
    return out
end

--=========================================================================--
--  Sequenced Roster Batch Queue
--=========================================================================--

function UnBot:QueueRosterBatch(action, names)
    if not names or table.getn(names) == 0 then return end
    self.rosterBatch = {
        action = action,
        names = names,
        index = 1,
        started = GetTime(),
        lastSend = 0,
    }
    self:ProcessNextBatchItem()
end

function UnBot:ProcessNextBatchItem()
    if not self.rosterBatch then return end
    local batch = self.rosterBatch
    if batch.index > table.getn(batch.names) then
        self.rosterBatch = nil
        return
    end

    local name = batch.names[batch.index]
    batch.lastSend = GetTime()

    if batch.action == "invite" then
        if IsInGroup(name) then
            batch.index = batch.index + 1
            self:ProcessNextBatchItem()
            return
        end
        if not UnitInRaid("player") and GetNumPartyMembers() >= 4 then
            if type(ConvertToRaid) == "function" then ConvertToRaid() end
        end
        self:InviteBot(name)
    elseif batch.action == "summon" then
        self:SendBotCommand("summon " .. name)
        batch.index = batch.index + 1
        self:ProcessNextBatchItem()
    elseif batch.action == "login" then
        self:SendBotCommand("add " .. name)
        batch.index = batch.index + 1
        self:ProcessNextBatchItem()
    end
end

--=========================================================================--
--  Roster & Tactics Hub UI Construction
--=========================================================================--

function UnBot:ToggleRoster()
    if not UnBotRosterFrame then self:CreateRosterFrame() end
    if UnBotRosterFrame:IsShown() then
        UnBotRosterFrame:Hide()
    else
        UnBotRosterFrame:Show()
        self:ScanGroupBots()
        self:RefreshActiveRosterView()
    end
end

function UnBot:CreateRosterFrame()
    local f = CreateFrame("Frame", "UnBotRosterFrame", UIParent)
    f:SetWidth(500)
    f:SetHeight(430)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:EnableMouseWheel(true)
    self:MakeDraggable(f)
    self:RestoreFramePosition(f)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:Hide()

    if UISpecialFrames then table.insert(UISpecialFrames, "UnBotRosterFrame") end

    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont(UnBotFont, 14)
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -14)
    title:SetTextColor(1, 0.82, 0)
    title:SetText("Retinue Roster & Tactics")
    f.title = title

    local close = CreateFrame("Button", "UnBotRosterClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    self:CreateRosterTabs(f)
    self:CreateAccountView(f)
    self:CreatePartyView(f)
    self:CreateRaidView(f)
    self:CreateRolesView(f)
    self:CreateCCView(f)
    self:CreateLootLogView(f)

    local initialTab = (IsInGroup() and "party") or (self.config.activeRosterTab or "account")
    self:SelectRosterTab(initialTab)
end

function UnBot:CreateRosterTabs(parent)
    local tabBar = CreateFrame("Frame", "UnBotRosterTabBar", parent)
    tabBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, -36)
    tabBar:SetWidth(472)
    tabBar:SetHeight(22)

    self.rosterTabButtons = {}
    local tabDefs = {
        { id = "account", label = "Account",  offset = 0 },
        { id = "party",   label = "Party",    offset = 79 },
        { id = "raid",    label = "Raid",     offset = 158 },
        { id = "roles",   label = "Roles",    offset = 237 },
        { id = "cc",      label = "CC Marks", offset = 316 },
        { id = "lootlog", label = "Loot Log", offset = 395 },
    }

    for i = 1, table.getn(tabDefs) do
        local def = tabDefs[i]
        local btn = CreateFrame("Button", "UnBotRosterTab_" .. def.id, tabBar, "UIPanelButtonTemplate")
        btn:SetWidth(76)
        btn:SetHeight(20)
        btn:SetPoint("LEFT", tabBar, "LEFT", def.offset, 0)
        btn:SetText(def.label)
        btn.tabId = def.id
        btn:SetScript("OnClick", function()
            UnBot:SelectRosterTab(this.tabId)
        end)
        self.rosterTabButtons[def.id] = btn
    end
end

function UnBot:SelectRosterTab(tabId)
    self.activeRosterTab = tabId
    if self.config then self.config.activeRosterTab = tabId end

    for id, btn in pairs(self.rosterTabButtons or {}) do
        if id == tabId then
            btn:LockHighlight()
        else
            btn:UnlockHighlight()
        end
    end

    if self.accountView then self.accountView:Hide() end
    if self.partyView then self.partyView:Hide() end
    if self.raidView then self.raidView:Hide() end
    if self.rolesView then self.rolesView:Hide() end
    if self.ccView then self.ccView:Hide() end
    if self.lootLogView then self.lootLogView:Hide() end

    if tabId == "account" and self.accountView then
        self.accountView:Show()
        self:RefreshRoster()
    elseif tabId == "party" and self.partyView then
        self.partyView:Show()
        self:RefreshPartyView()
    elseif tabId == "raid" and self.raidView then
        self.raidView:Show()
        self:RefreshRaidView()
    elseif tabId == "roles" and self.rolesView then
        self.rolesView:Show()
        self:RefreshRolesView()
    elseif tabId == "cc" and self.ccView then
        self.ccView:Show()
        self:RefreshCCView()
    elseif tabId == "lootlog" and self.lootLogView then
        self.lootLogView:Show()
        self:RefreshLootLogView()
    end
end

function UnBot:RefreshActiveRosterView()
    if not UnBotRosterFrame or not UnBotRosterFrame:IsShown() then return end
    local tab = self.activeRosterTab or "account"
    if tab == "account" then self:RefreshRoster()
    elseif tab == "party" then self:RefreshPartyView()
    elseif tab == "raid" then self:RefreshRaidView()
    elseif tab == "roles" then self:RefreshRolesView()
    elseif tab == "cc" then self:RefreshCCView()
    elseif tab == "lootlog" then self:RefreshLootLogView() end
end

--=========================================================================--
--  Reusable ScrollBar Component
--=========================================================================--

local function CreateScrollBar(parent, name, x, y, width, height, onScroll)
    local frame = CreateFrame("Frame", name .. "Container", parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    frame:SetWidth(width)
    frame:SetHeight(height)

    local upBtn = CreateFrame("Button", name .. "Up", frame, "UIPanelButtonTemplate")
    upBtn:SetWidth(width)
    upBtn:SetHeight(16)
    upBtn:SetPoint("TOP", frame, "TOP", 0, 0)
    upBtn:SetText("^")
    upBtn:SetScript("OnClick", function()
        if onScroll then onScroll(-1) end
    end)
    frame.upBtn = upBtn

    local downBtn = CreateFrame("Button", name .. "Down", frame, "UIPanelButtonTemplate")
    downBtn:SetWidth(width)
    downBtn:SetHeight(16)
    downBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)
    downBtn:SetText("v")
    downBtn:SetScript("OnClick", function()
        if onScroll then onScroll(1) end
    end)
    frame.downBtn = downBtn

    local slider = CreateFrame("Slider", name .. "Slider", frame)
    slider:SetWidth(width - 4)
    slider:SetPoint("TOP", upBtn, "BOTTOM", 0, -2)
    slider:SetPoint("BOTTOM", downBtn, "TOP", 0, 2)
    slider:SetOrientation("VERTICAL")
    slider:SetMinMaxValues(0, 0)
    slider:SetValueStep(1)
    slider:SetValue(0)
    slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    slider:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    slider:SetBackdropColor(0.1, 0.1, 0.1, 0.6)

    slider:SetScript("OnValueChanged", function()
        local val = math.floor(this:GetValue() + 0.5)
        if frame.currentValue ~= val then
            frame.currentValue = val
            if frame.onValueChanged then frame.onValueChanged(val) end
        end
    end)
    frame.slider = slider

    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function()
        if onScroll then onScroll(-arg1) end
    end)
    slider:EnableMouseWheel(true)
    slider:SetScript("OnMouseWheel", function()
        if onScroll then onScroll(-arg1) end
    end)

    function frame:Update(current, maxVal)
        if maxVal < 0 then maxVal = 0 end
        if current < 0 then current = 0 end
        if current > maxVal then current = maxVal end
        self.slider:SetMinMaxValues(0, maxVal)
        self.currentValue = current
        self.slider:SetValue(current)
        if maxVal > 0 then
            self.slider:Show()
            self.upBtn:Enable()
            self.downBtn:Enable()
        else
            self.slider:Hide()
            self.upBtn:Disable()
            self.downBtn:Disable()
        end
    end

    return frame
end

--=========================================================================--
--  Tab 1: Account View (Existing Retinue Roster)
--=========================================================================--

function UnBot:CreateAccountView(parent)
    local v = CreateFrame("Frame", "UnBotAccountView", parent)
    v:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -60)
    v:SetWidth(476)
    v:SetHeight(356)
    self.accountView = v

    self:CreateRosterSearchBar(v)
    self:CreateClassFilters(v)
    self:CreateRosterRows(v)
    self:CreateBulkButtons(v)

    local scrollbar = CreateScrollBar(v, "UnBotAccountScroll", 456, -30, 16, 220, function(delta)
        UnBot:ScrollRoster(delta)
    end)
    scrollbar.onValueChanged = function(val)
        UnBot.rosterOffset = val
        UnBot:RefreshRoster()
    end
    v.scrollBar = scrollbar

    v:EnableMouseWheel(true)
    v:SetScript("OnMouseWheel", function()
        UnBot:ScrollRoster(-arg1)
    end)
end

function UnBot:CreateRosterSearchBar(parent)
    local search = CreateFrame("EditBox", "UnBotRosterSearch", parent)
    search:SetWidth(238)
    search:SetHeight(22)
    search:SetPoint("TOPLEFT", parent, "TOPLEFT", 232, -4)
    search:SetAutoFocus(false)
    search:SetFontObject(GameFontHighlightSmall)
    search:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    search:SetBackdropColor(0, 0, 0, 0.8)
    search:SetTextInsets(6, 20, 0, 0)

    local placeholder = search:CreateFontString(nil, "OVERLAY")
    placeholder:SetFont(UnBotFont, 11)
    placeholder:SetPoint("LEFT", search, "LEFT", 8, 0)
    placeholder:SetTextColor(0.5, 0.5, 0.5)
    placeholder:SetText("Search bots by name...")
    self.rosterSearchPlaceholder = placeholder

    local clearBtn = CreateFrame("Button", "UnBotRosterSearchClear", search)
    clearBtn:SetWidth(16); clearBtn:SetHeight(16)
    clearBtn:SetPoint("RIGHT", search, "RIGHT", -4, 0)
    clearBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    clearBtn:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight")
    clearBtn:SetScript("OnClick", function()
        search:SetText("")
        search:ClearFocus()
    end)

    search:SetScript("OnTextChanged", function()
        local text = this:GetText() or ""
        text = string.gsub(string.gsub(text, "^%s+", ""), "%s+$", "")
        if text == "" then
            UnBot.rosterSearchQuery = nil
            if UnBot.rosterSearchPlaceholder then UnBot.rosterSearchPlaceholder:Show() end
        else
            UnBot.rosterSearchQuery = string.lower(text)
            if UnBot.rosterSearchPlaceholder then UnBot.rosterSearchPlaceholder:Hide() end
        end
        UnBot.rosterOffset = 0
        UnBot:RefreshRoster()
    end)
    self.rosterSearchBox = search
end

function UnBot:CreateClassFilters(parent)
    self.classButtons = {}
    local ALL = "ALL"
    local allBtn = CreateFrame("Button", "UnBotClassFilterALL", parent)
    allBtn:SetWidth(18); allBtn:SetHeight(18)
    allBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -6)
    local allText = allBtn:CreateFontString(nil, "OVERLAY")
    allText:SetFont(UnBotFont, 9)
    allText:SetPoint("CENTER", allBtn, "CENTER", 0, 0)
    allText:SetText("ALL")
    allText:SetTextColor(1, 0.82, 0)
    allBtn.text = allText
    local allSel = allBtn:CreateTexture(nil, "BACKGROUND")
    allSel:SetAllPoints(allBtn)
    allSel:SetTexture(1, 0.82, 0, 0.3)
    allBtn.selected = allSel
    allBtn:SetScript("OnClick", function()
        UnBot.rosterFilter = "ALL"
        UnBot.rosterOffset = 0
        UnBot:RefreshRoster()
    end)
    allBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOP")
        GameTooltip:AddLine("Filter: All Classes", 1, 0.82, 0)
        GameTooltip:AddLine("Click to view all bots across every class.", 0.8, 0.8, 0.8, 1)
        GameTooltip:Show()
    end)
    allBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.classButtons[ALL] = allBtn

    for idx = 1, table.getn(CLASSES) do
        local class = CLASSES[idx]
        local btn = CreateFrame("Button", "UnBotClassFilter"..class, parent)
        btn:SetWidth(18); btn:SetHeight(18)
        btn:SetPoint("LEFT", self.classButtons[idx == 1 and ALL or CLASSES[idx - 1]], "RIGHT", 4, 0)
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(btn)
        local coords = (self.GetClassCoords and self:GetClassCoords(class)) or (CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class])
        if coords then
            icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
            icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        else
            local c = (self.GetClassColor and self:GetClassColor(class)) or {0.8, 0.8, 0.8}
            icon:SetTexture(c[1], c[2], c[3], 0.8)
        end
        local sel = btn:CreateTexture(nil, "BACKGROUND")
        sel:SetAllPoints(btn)
        sel:SetTexture(1, 0.82, 0, 0.3)
        sel:Hide()
        btn.selected = sel
        btn.class = class
        btn:SetScript("OnClick", function()
            UnBot.rosterFilter = this.class
            UnBot.rosterOffset = 0
            UnBot:RefreshRoster()
        end)
        btn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_TOP")
            local cName = (UnBot.GetClassName and UnBot:GetClassName(this.class)) or this.class
            local c = (UnBot.GetClassColor and UnBot:GetClassColor(this.class)) or {1, 0.82, 0}
            GameTooltip:AddLine("Filter: " .. cName, c[1], c[2], c[3])
            GameTooltip:AddLine("Click to filter roster to " .. cName .. " bots.", 0.8, 0.8, 0.8, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        self.classButtons[class] = btn
    end
end

function UnBot:CreateRosterRows(parent)
    self.rosterRows = {}
    for i = 1, ROW_COUNT do
        local row = CreateFrame("Button", "UnBotRosterRow"..i, parent)
        row:SetWidth(446); row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -30 - (i - 1) * ROW_HEIGHT)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function()
            UnBot:ScrollRoster(-arg1)
        end)

        -- Class Accent Bar (TortoiseBotsManager parity)
        local accent = row:CreateTexture(nil, "ARTWORK")
        accent:SetWidth(3); accent:SetHeight(ROW_HEIGHT - 4)
        accent:SetPoint("LEFT", row, "LEFT", 0, 0)
        row.accent = accent

        local check = CreateFrame("CheckButton", "UnBotRosterSelect"..i, row, "UICheckButtonTemplate")
        check:SetWidth(18); check:SetHeight(18)
        check:SetPoint("LEFT", row, "LEFT", 4, 0)
        check:EnableMouseWheel(true)
        check:SetScript("OnMouseWheel", function()
            UnBot:ScrollRoster(-arg1)
        end)
        check:SetScript("OnClick", function()
            local r = this:GetParent()
            if r.charName then
                UnBot.rosterSelection[r.charName] = this:GetChecked() and true or nil
            end
        end)
        row.selectCheck = check

        -- Class Icon (16x16 CharacterCreate-Classes UV icon)
        local classIcon = row:CreateTexture(nil, "ARTWORK")
        classIcon:SetWidth(16); classIcon:SetHeight(16)
        classIcon:SetPoint("LEFT", check, "RIGHT", 2, 0)
        row.classIcon = classIcon

        local nameText = row:CreateFontString(nil, "OVERLAY")
        nameText:SetFont(UnBotFont, 11)
        nameText:SetPoint("LEFT", classIcon, "RIGHT", 4, 0)
        nameText:SetWidth(175); nameText:SetJustifyH("LEFT")
        row.nameText = nameText

        local levelText = row:CreateFontString(nil, "OVERLAY")
        levelText:SetFont(UnBotFont, 10)
        levelText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
        levelText:SetWidth(140); levelText:SetJustifyH("RIGHT")
        row.levelText = levelText

        row:SetScript("OnClick", function()
            if this.isAddButton and this.charName then
                UnBot:AddRosterCharacter(this.charName)
                if UnBot.rosterSearchBox then UnBot.rosterSearchBox:SetText("") end
                return
            end
            if not this.charName then return end
            UnBot:InteractWithBot(this.charName, arg1)
        end)

        row:SetScript("OnEnter", function()
            if not this.charName then return end
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText(this.charName)
            local data = UnBot.config.roster[this.charName] or {}
            if data and data.class then
                local c = (UnBot.GetClassColor and UnBot:GetClassColor(data.class)) or {1, 1, 1}
                local cName = (UnBot.GetClassName and UnBot:GetClassName(data.class)) or data.class or "Warrior"
                GameTooltip:AddLine(cName .. (data.level and (" Lvl " .. data.level) or ""), c[1], c[2], c[3])
            end
            if IsInGroup(this.charName) then
                GameTooltip:AddLine("Status: In party/raid", 0.2, 0.9, 0.9)
            elseif data.online then
                GameTooltip:AddLine("Status: Online in world", 0.3, 1.0, 0.3)
            else
                GameTooltip:AddLine("Status: Offline", 0.6, 0.6, 0.6)
            end
            GameTooltip:AddLine("Click: target & invite | Shift-click: bags | Right-click: remove", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        self.rosterRows[i] = row
    end
end

function UnBot:CreateBulkButtons(parent)
    local function MakeBtn(name, label, x, y, width, handler, tip)
        local btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
        btn:SetWidth(width); btn:SetHeight(22)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        btn:SetText(label)
        btn:SetScript("OnClick", handler)
        btn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_TOP")
            GameTooltip:AddLine(label, 1, 0.82, 0)
            GameTooltip:AddLine(tip, 0.8, 0.8, 0.8, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return btn
    end

    MakeBtn("UnBotRosterFillGroup", "Fill group", 8, -266, 88, function() UnBot:FillWith(5) end, "Invites online/offline roster alts to fill a 5-man party.")
    MakeBtn("UnBotRosterFillRaid",  "Fill raid", 102, -266, 88, function() UnBot:FillWith(40) end, "Converts to raid and fills up to 40 slots.")
    MakeBtn("UnBotRosterUnloadAll", "Logout flt", 196, -266, 88, function() UnBot:BulkBotCommand("remove") end, "Logs out filtered characters.")
    MakeBtn("UnBotRosterAddFriends", "Add friends", 290, -266, 88, function() UnBot:RunCommand(88) end, "Adds current group to friends list.")
    MakeBtn("UnBotRosterSyncBtn", "Sync", 384, -266, 80, function() UnBot:RequestServerRoster(true) end, "Syncs roster with server.")

    MakeBtn("UnBotRosterRemoveSelected", "Uninvite", 8, -294, 88, function() UnBot:RemoveSelectedFromGroup() end, "Uninvites checked bots.")
    MakeBtn("UnBotRosterLogoutSelected", "Log out", 102, -294, 88, function() UnBot:LogoutSelectedBots() end, "Logs out checked bots.")
    MakeBtn("UnBotRosterDropSelected",   "Delete", 196, -294, 88, function() UnBot:DeleteSelectedRoster() end, "Drops checked bots from roster.")
    MakeBtn("UnBotRosterClearSelection", "Clear", 290, -294, 88, function() UnBot:ClearRosterSelection() end, "Clears selection.")
end

--=========================================================================--
--  Tab 6: Loot Log View (Bot Loot & Roll History)
--=========================================================================--

function UnBot:CreateLootLogView(parent)
    local v = CreateFrame("Frame", "UnBotLootLogView", parent)
    v:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -60)
    v:SetWidth(476); v:SetHeight(356)
    self.lootLogView = v

    -- Filters Bar
    local botSearch = CreateFrame("EditBox", "UnBotLootBotSearch", v, "InputBoxTemplate")
    botSearch:SetWidth(80); botSearch:SetHeight(20)
    botSearch:SetPoint("TOPLEFT", v, "TOPLEFT", 6, -4)
    botSearch:SetAutoFocus(false)
    botSearch:SetScript("OnTextChanged", function()
        UnBot.lootBotFilter = this:GetText() or ""
        UnBot.lootOffset = 0
        UnBot:RefreshLootLogView()
    end)
    v.botSearch = botSearch

    local itemSearch = CreateFrame("EditBox", "UnBotLootItemSearch", v, "InputBoxTemplate")
    itemSearch:SetWidth(95); itemSearch:SetHeight(20)
    itemSearch:SetPoint("LEFT", botSearch, "RIGHT", 6, 0)
    itemSearch:SetAutoFocus(false)
    itemSearch:SetScript("OnTextChanged", function()
        UnBot.lootItemFilter = this:GetText() or ""
        UnBot.lootOffset = 0
        UnBot:RefreshLootLogView()
    end)
    v.itemSearch = itemSearch

    local typeBtn = CreateFrame("Button", "UnBotLootTypeBtn", v, "UIPanelButtonTemplate")
    typeBtn:SetWidth(56); typeBtn:SetHeight(20)
    typeBtn:SetPoint("LEFT", itemSearch, "RIGHT", 4, 0)
    typeBtn:SetText("All")
    typeBtn:SetScript("OnClick", function()
        local cur = UnBot.lootTypeFilter or "all"
        local nextType = "all"
        if cur == "all" then nextType = "items"
        elseif cur == "items" then nextType = "rolls"
        elseif cur == "rolls" then nextType = "money"
        else nextType = "all" end
        UnBot.lootTypeFilter = nextType
        this:SetText(string.upper(string.sub(nextType, 1, 1)) .. string.sub(nextType, 2))
        UnBot.lootOffset = 0
        UnBot:RefreshLootLogView()
    end)
    v.typeBtn = typeBtn

    local qualBtn = CreateFrame("Button", "UnBotLootQualBtn", v, "UIPanelButtonTemplate")
    qualBtn:SetWidth(82); qualBtn:SetHeight(20)
    qualBtn:SetPoint("LEFT", typeBtn, "RIGHT", 4, 0)
    qualBtn:SetText("Any Qual")
    qualBtn:SetScript("OnClick", function()
        local cur = UnBot.lootQualityFilter or -1
        cur = cur + 1
        if cur > 4 then cur = -1 end
        UnBot.lootQualityFilter = cur
        if cur < 0 then
            this:SetText("Any Qual")
        else
            this:SetText(UnBot:GetLootQualityName(cur))
        end
        UnBot.lootOffset = 0
        UnBot:RefreshLootLogView()
    end)
    v.qualBtn = qualBtn

    local syncBtn = CreateFrame("Button", "UnBotLootSyncBtn", v, "UIPanelButtonTemplate")
    syncBtn:SetWidth(50); syncBtn:SetHeight(20)
    syncBtn:SetPoint("LEFT", qualBtn, "RIGHT", 4, 0)
    syncBtn:SetText("Sync")
    syncBtn:SetScript("OnClick", function()
        UnBot:RequestLootLog()
    end)

    local clearBtn = CreateFrame("Button", "UnBotLootClearBtn", v, "UIPanelButtonTemplate")
    clearBtn:SetWidth(50); clearBtn:SetHeight(20)
    clearBtn:SetPoint("LEFT", syncBtn, "RIGHT", 4, 0)
    clearBtn:SetText("Clear")
    clearBtn:SetScript("OnClick", function()
        UnBot:ClearLootLog()
    end)

    -- Column Headers
    local headers = {
        { text = "Time", x = 6, width = 50 },
        { text = "Bot", x = 58, width = 72 },
        { text = "Loot / Event / Roll", x = 132, width = 210 },
        { text = "Source", x = 344, width = 100 },
    }
    for i = 1, table.getn(headers) do
        local h = headers[i]
        local fs = v:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", v, "TOPLEFT", h.x, -28)
        fs:SetWidth(h.width); fs:SetJustifyH("LEFT")
        fs:SetText(h.text); fs:SetTextColor(0.6, 0.6, 0.6)
    end

    -- Rows: 11 rows of height 22
    local LOOT_ROWS = 11
    local ROW_H = 22
    v.rows = {}
    for i = 1, LOOT_ROWS do
        local row = CreateFrame("Button", "UnBotLootRow" .. i, v)
        row:SetWidth(444); row:SetHeight(ROW_H - 2)
        row:SetPoint("TOPLEFT", v, "TOPLEFT", 4, -46 - (i - 1) * ROW_H)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function()
            UnBot:ScrollLootLog(-arg1)
        end)

        local timeText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        timeText:SetPoint("LEFT", row, "LEFT", 2, 0); timeText:SetWidth(50); timeText:SetJustifyH("LEFT")
        row.timeText = timeText

        local botText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        botText:SetPoint("LEFT", row, "LEFT", 54, 0); botText:SetWidth(72); botText:SetJustifyH("LEFT")
        row.botText = botText

        local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        itemText:SetPoint("LEFT", row, "LEFT", 128, 0); itemText:SetWidth(210); itemText:SetJustifyH("LEFT")
        row.itemText = itemText

        local sourceText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        sourceText:SetPoint("LEFT", row, "LEFT", 340, 0); sourceText:SetWidth(100); sourceText:SetJustifyH("LEFT")
        row.sourceText = sourceText

        row:SetScript("OnEnter", function()
            local r = this.lootEntry
            if not r then return end
            if r.itemId and tonumber(r.itemId) and r.event ~= "LootMoney" then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink("item:" .. r.itemId .. ":0:0:0")
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:SetScript("OnClick", function()
            local r = this.lootEntry
            if not r then return end
            if IsShiftKeyDown and IsShiftKeyDown() and r.itemId and tonumber(r.itemId) and ChatFrameEditBox and ChatFrameEditBox:IsShown() then
                ChatFrameEditBox:Insert(UnBot:GetLootQualityHex(r.quality) .. "|Hitem:" .. r.itemId .. ":0:0:0|h[" .. (r.item or ("item:" .. r.itemId)) .. "]|h|r")
            end
        end)

        v.rows[i] = row
    end

    local scrollbar = CreateScrollBar(v, "UnBotLootScroll", 454, -46, 16, 238, function(delta)
        UnBot:ScrollLootLog(delta)
    end)
    scrollbar.onValueChanged = function(val)
        UnBot.lootOffset = val
        UnBot:RefreshLootLogView()
    end
    v.scrollBar = scrollbar

    v:EnableMouseWheel(true)
    v:SetScript("OnMouseWheel", function()
        UnBot:ScrollLootLog(-arg1)
    end)

    local emptyMsg = v:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    emptyMsg:SetPoint("CENTER", v, "CENTER", 0, 0)
    emptyMsg:SetWidth(420); emptyMsg:SetJustifyH("CENTER")
    emptyMsg:SetText("|cffd8a657No Loot History Logged|r\n\nParty bots log looted items, coins, and roll decisions here.\nClick [ Sync ] to retrieve server loot records.")
    v.emptyMsg = emptyMsg

    local countLabel = v:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countLabel:SetPoint("BOTTOMLEFT", v, "BOTTOMLEFT", 10, 10)
    countLabel:SetTextColor(0.7, 0.7, 0.7)
    v.countLabel = countLabel
end

function UnBot:RefreshLootLogView()
    if not self.lootLogView or not self.lootLogView:IsShown() then return end
    local list = self:GetFilteredLoot()
    local total = table.getn(list)
    local maxOffset = total - 11
    if maxOffset < 0 then maxOffset = 0 end

    self.lootOffset = self.lootOffset or 0
    if self.lootOffset > maxOffset then self.lootOffset = maxOffset end
    if self.lootOffset < 0 then self.lootOffset = 0 end

    if self.lootLogView.scrollBar then
        self.lootLogView.scrollBar:Update(self.lootOffset, maxOffset)
    end

    if total == 0 then
        self.lootLogView.emptyMsg:Show()
    else
        self.lootLogView.emptyMsg:Hide()
    end

    self.lootLogView.countLabel:SetText("Entries: " .. total)

    for i = 1, 11 do
        local row = self.lootLogView.rows[i]
        local r = list[i + self.lootOffset]
        if r then
            row.lootEntry = r
            local _, _, tail = string.find(r.ts or "", "(%d%d:%d%d:%d%d)%s*$")
            row.timeText:SetText(tail or r.ts or "")
            row.botText:SetText(r.bot or "")
            local c = (self.GetClassColor and self:GetClassColor(r.bot)) or {1, 0.82, 0}
            row.botText:SetTextColor(c[1], c[2], c[3])

            if r.event == "LootMoney" then
                row.itemText:SetText(self:FormatCopper(r.copper))
            elseif r.event == "LootRoll" then
                local vote = VOTE_LABEL[r.vote] or r.vote or "?"
                local vCol = VOTE_COLOR[r.vote] or "|cffffffff"
                local reasonStr = r.reason and (" (" .. r.reason .. ")") or ""
                row.itemText:SetText(vCol .. "[" .. vote .. "]|r " .. self:GetLootQualityHex(r.quality) .. (r.item or "?") .. "|r" .. reasonStr)
            else
                row.itemText:SetText(self:GetLootQualityHex(r.quality) .. "[" .. (r.item or ("item #" .. tostring(r.itemId or "?"))) .. "]|r")
            end

            local src = r.source or ""
            if src ~= "" then
                row.sourceText:SetText((r.sourceType or "other") .. ": " .. src)
            else
                row.sourceText:SetText(r.sourceType or "")
            end
            row:Show()
        else
            row.lootEntry = nil
            row:Hide()
        end
    end
end

function UnBot:ScrollLootLog(delta)
    local list = self:GetFilteredLoot()
    local total = table.getn(list)
    local maxOffset = total - 11
    if maxOffset < 0 then maxOffset = 0 end

    self.lootOffset = (self.lootOffset or 0) + delta
    if self.lootOffset < 0 then self.lootOffset = 0 end
    if self.lootOffset > maxOffset then self.lootOffset = maxOffset end
    self:RefreshLootLogView()
end

function UnBot:ShowLootLog()
    if not UnBotRosterFrame then self:CreateRosterFrame() end
    if not UnBotRosterFrame:IsShown() then
        UnBotRosterFrame:Show()
    end
    self:SelectRosterTab("lootlog")
    self:RequestLootLog()
end

--=========================================================================--
--  Tab 3: Party View (Active Roles & CC Marks)
--=========================================================================--

function UnBot:CreatePartyView(parent)
    local v = CreateFrame("Frame", "UnBotPartyView", parent)
    v:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -60)
    v:SetWidth(476); v:SetHeight(356)
    self.partyView = v

    local title = v:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", v, "TOPLEFT", 6, 0)
    title:SetText("|cffd8a657Active Party Roles|r")

    local subtitle = v:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("LEFT", title, "RIGHT", 8, 0)
    subtitle:SetText("|cff888888(role buttons · bag = gear & bags · click a row to target)|r")

    v.rows = {}
    for i = 1, 5 do
        local row = CreateFrame("Button", "UnBotPartyRow"..i, v)
        row:SetWidth(464); row:SetHeight(52)
        row:SetPoint("TOPLEFT", v, "TOPLEFT", 6, -20 - (i - 1) * 56)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")

        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameText:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -8); nameText:SetWidth(130); nameText:SetJustifyH("LEFT")
        row.nameText = nameText

        local descText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        descText:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 8, 8); descText:SetWidth(260); descText:SetJustifyH("LEFT")
        descText:SetTextColor(0.6, 0.6, 0.6)
        row.descText = descText

        -- CC Mark Texture Icon
        local ccIcon = row:CreateTexture(nil, "ARTWORK")
        ccIcon:SetWidth(20); ccIcon:SetHeight(20)
        ccIcon:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -8, 6)
        ccIcon:Hide()
        row.ccIcon = ccIcon

        local ccLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        ccLabel:SetPoint("RIGHT", ccIcon, "LEFT", -4, 0)
        ccLabel:SetText("CC:")
        ccLabel:SetTextColor(0.6, 0.6, 0.6)
        ccLabel:Hide()
        row.ccLabel = ccLabel

        local bagBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        bagBtn:SetWidth(22); bagBtn:SetHeight(20)
        bagBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, -6)
        bagBtn:SetText("B")
        bagBtn:SetScript("OnClick", function()
            local p = this:GetParent()
            if p.partyName then UnBot:ShowItemWindow("view", p.partyName) end
        end)
        row.bagBtn = bagBtn

        local btnBoost = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnBoost:SetWidth(26); btnBoost:SetHeight(20)
        btnBoost:SetPoint("RIGHT", bagBtn, "LEFT", -4, 0)
        btnBoost:SetText("+B")
        btnBoost:SetScript("OnClick", function()
            local p = this:GetParent()
            local name = p.partyName
            if not name or name == "" then return end
            if UnBot.boostTarget == name then
                SendChatMessage("boost target -" .. name, "PARTY")
                UnBot.boostTarget = nil
                UnBot:Message("Cleared boost target priority on " .. name)
            else
                SendChatMessage("boost target +" .. name, "PARTY")
                UnBot.boostTarget = name
                UnBot:Message("Set boost target priority on " .. name)
            end
            UnBot:RefreshPartyView()
        end)
        btnBoost:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText("Boost Target Priority", 1, 1, 1)
            GameTooltip:AddLine("Orders buffers/casters to prioritize Power Infusion, Bloodlust, and combat buffs on " .. (this:GetParent().partyName or "this member") .. ".", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Click to toggle.", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        btnBoost:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row.btnBoost = btnBoost

        local btnHeal = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnHeal:SetWidth(26); btnHeal:SetHeight(20)
        btnHeal:SetPoint("RIGHT", btnBoost, "LEFT", -4, 0)
        btnHeal:SetText("+H")
        btnHeal:SetScript("OnClick", function()
            local p = this:GetParent()
            local name = p.partyName
            if not name or name == "" then return end
            if UnBot.focusHealTarget == name then
                SendChatMessage("focus heal -" .. name, "PARTY")
                UnBot.focusHealTarget = nil
                UnBot:Message("Cleared focus heal priority on " .. name)
            else
                SendChatMessage("focus heal +" .. name, "PARTY")
                UnBot.focusHealTarget = name
                UnBot:Message("Set focus heal priority on " .. name)
            end
            UnBot:RefreshPartyView()
        end)
        btnHeal:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText("Focus Heal Priority", 1, 1, 1)
            GameTooltip:AddLine("Orders party healers to prioritize healing " .. (this:GetParent().partyName or "this member") .. ".", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Click to toggle.", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        btnHeal:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row.btnHeal = btnHeal

        local btnTalents = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnTalents:SetWidth(26); btnTalents:SetHeight(20)
        btnTalents:SetPoint("RIGHT", btnHeal, "LEFT", -4, 0)
        btnTalents:SetText("+T")
        btnTalents:SetScript("OnClick", function()
            local p = this:GetParent()
            local name = p.partyName
            if not name or name == "" or p.partyUnit == "player" then return end
            SendChatMessage("talents auto", "WHISPER", nil, name)
            UnBot:Message("Ordered " .. name .. " to auto-allocate talents for designated role")
        end)
        btnTalents:SetScript("OnEnter", function()
            local p = this:GetParent()
            local name = p.partyName or "this bot"
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText("Auto-Align Talents (+T)", 1, 1, 1)
            GameTooltip:AddLine("Orders " .. name .. " to automatically allocate its talent points", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("into the talent tree matching its active role.", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Click to apply.", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        btnTalents:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row.btnTalents = btnTalents

        row.roleButtons = {}
        for b = 1, 4 do
            local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btn:SetWidth(68); btn:SetHeight(20)
            btn:SetPoint("LEFT", row, "LEFT", 146 + (b - 1) * 70, 6)
            row.roleButtons[b] = btn
        end

        row:SetScript("OnClick", function()
            if not this.partyName or this.partyName == "" then return end
            if this.partyUnit == "player" then
                if TargetUnit then TargetUnit("player") end
                return
            end
            UnBot:InteractWithBot(this.partyName, arg1)
        end)

        row:SetScript("OnEnter", function()
            if not this.partyName then return end
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText(this.partyName)
            if this.partyUnit and this.partyUnit ~= "player" then
                local _, cls = UnitClass(this.partyUnit)
                local lvl = UnitLevel(this.partyUnit)
                local c = (UnBot.GetClassColor and UnBot:GetClassColor(cls)) or {1, 1, 1}
                local cName = (UnBot.GetClassName and UnBot:GetClassName(cls)) or cls or "Warrior"
                GameTooltip:AddLine("Level " .. (lvl or 0) .. " " .. cName, c[1], c[2], c[3])
                GameTooltip:AddLine("Click: target | Shift-click: bags | Right-click: uninvite", 0.7, 0.7, 0.7)
            else
                GameTooltip:AddLine("Master (Party Leader)", 1, 0.82, 0)
            end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        v.rows[i] = row
    end
end

function UnBot:RefreshPartyView()
    if not self.partyView or not self.partyView:IsShown() then return end

    local units = { "player", "party1", "party2", "party3", "party4" }
    for i = 1, 5 do
        local row = self.partyView.rows[i]
        local unit = units[i]
        if UnitExists(unit) then
            local name = UnitName(unit)
            local _, classToken = UnitClass(unit)
            classToken = classToken or "WARRIOR"
            local c = (self.GetClassColor and self:GetClassColor(classToken)) or {1, 1, 1}
            row.partyUnit = unit
            row.partyName = name

            if unit == "player" then
                local extra = ""
                if UnBot.focusHealTarget == name then extra = extra .. "  |cff00ff00[Heal Focus]|r" end
                if UnBot.boostTarget == name then extra = extra .. "  |cffffaa00[Boost Target]|r" end
                row.nameText:SetText(name .. "  |cffd8a657(Master)|r")
                row.nameText:SetTextColor(c[1], c[2], c[3])
                row.descText:SetText("Set your combat role:" .. extra)
                row.bagBtn:Hide()
                row.ccIcon:Hide(); row.ccLabel:Hide()
                if row.btnTalents then row.btnTalents:Hide() end
                if row.btnHeal then row.btnHeal:Hide() end
                if row.btnBoost then row.btnBoost:Hide() end

                local roles = (Retinue and Retinue.Roles and Retinue.Roles.PLAYER_ROLES) or { {id="tank", label="Tank"}, {id="heal", label="Healer"}, {id="dps", label="DPS"} }
                local currentRole = (Retinue and Retinue.Roles and Retinue.Roles.GetPlayerRole and Retinue.Roles.GetPlayerRole(classToken)) or "dps"
                local roleWidth = 68
                local roleStep = roleWidth + 2
                for b = 1, 4 do
                    local btn = row.roleButtons[b]
                    local r = roles[b]
                    btn:ClearAllPoints()
                    btn:SetWidth(roleWidth)
                    btn:SetPoint("LEFT", row, "LEFT", 146 + (b - 1) * roleStep, 6)
                    if r then
                        local isSelected = (currentRole == r.id)
                        local shown = r.label
                        if isSelected then
                            btn:SetText("|cffffffff" .. shown .. "|r")
                            btn:LockHighlight()
                        else
                            btn:SetText("|cff9a978f" .. shown .. "|r")
                            btn:UnlockHighlight()
                        end
                        btn.roleDef = r
                        btn:SetScript("OnClick", function()
                            if Retinue and Retinue.Roles and Retinue.Roles.SetPlayerRole then
                                Retinue.Roles.SetPlayerRole(this.roleDef)
                            end
                            UnBot:RefreshPartyView()
                        end)
                        btn:SetScript("OnEnter", function()
                            if this.roleDef then
                                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                GameTooltip:AddLine("Master Role: " .. this.roleDef.label, 1, 0.82, 0)
                                GameTooltip:AddLine("Informs companion bots of your active role.", 0.8, 0.8, 0.8)
                                GameTooltip:Show()
                            end
                        end)
                        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                        btn:Show()
                    else
                        btn:Hide()
                    end
                end
            else
                local extra = ""
                if UnBot.focusHealTarget == name then extra = extra .. "  |cff00ff00[Heal Focus]|r" end
                if UnBot.boostTarget == name then extra = extra .. "  |cffffaa00[Boost Target]|r" end
                row.nameText:SetText(name)
                row.nameText:SetTextColor(c[1], c[2], c[3])
                row.descText:SetText("Bot companion" .. extra)
                row.bagBtn:Show()
                if row.btnTalents then row.btnTalents:Show() end

                -- CC Mark display
                local mark = self.ccAssignments[name]
                if mark and Retinue and Retinue.C and Retinue.C.CC_MARK_ICONS and Retinue.C.CC_MARK_ICONS[mark] then
                    local iconIndex = Retinue.C.CC_MARK_ICONS[mark]
                    row.ccIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
                    local left = math.mod(iconIndex - 1, 4) * 0.25
                    local top = math.floor((iconIndex - 1) / 4) * 0.25
                    row.ccIcon:SetTexCoord(left, left + 0.25, top, top + 0.25)
                    row.ccIcon:Show(); row.ccLabel:Show()
                else
                    row.ccIcon:Hide(); row.ccLabel:Hide()
                end

                local classRoles = (Retinue and Retinue.Roles and Retinue.Roles.GetClassRoles and Retinue.Roles.GetClassRoles(classToken)) or {}
                local currentRole = (Retinue and Retinue.Roles and Retinue.Roles.GetBotRole and Retinue.Roles.GetBotRole(name, classToken)) or "dps"
                local roleCount = table.getn(classRoles)
                local roleWidth = roleCount >= 4 and 52 or 68
                local roleStep = roleWidth + 2

                for b = 1, 4 do
                    local btn = row.roleButtons[b]
                    local r = classRoles[b]
                    btn:ClearAllPoints()
                    btn:SetWidth(roleWidth)
                    btn:SetPoint("LEFT", row, "LEFT", 146 + (b - 1) * roleStep, 6)
                    if r then
                        local isSelected = (currentRole == r.id)
                        local shown = (Retinue and Retinue.Roles and Retinue.Roles.ShortLabel and Retinue.Roles.ShortLabel(r.label)) or r.label
                        if isSelected then
                            btn:SetText("|cffffffff" .. shown .. "|r")
                            btn:LockHighlight()
                        else
                            btn:SetText("|cff9a978f" .. shown .. "|r")
                            btn:UnlockHighlight()
                        end
                        btn.botName = name
                        btn.roleDef = r
                        btn.classToken = classToken
                        btn:SetScript("OnClick", function()
                            if Retinue and Retinue.Roles and Retinue.Roles.SetBotRole then
                                Retinue.Roles.SetBotRole(this.botName, this.roleDef, this.classToken)
                            end
                            UnBot:RefreshPartyView()
                        end)
                        btn:SetScript("OnEnter", function()
                            if this.roleDef then
                                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                GameTooltip:AddLine(this.botName .. " - " .. this.roleDef.label, 1, 0.82, 0)
                                if this.roleDef.strat and this.roleDef.strat ~= "" then
                                    GameTooltip:AddLine("Strategies: " .. this.roleDef.strat, 0.3, 1, 0.3)
                                end
                                GameTooltip:AddLine("Click to switch " .. this.botName .. " to this combat role.", 0.8, 0.8, 0.8)
                                GameTooltip:Show()
                            end
                        end)
                        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                        btn:Show()
                    else
                        btn:Hide()
                    end
                end
            end
            if row.btnHeal and unit ~= "player" then
                if UnBot.focusHealTarget == name then
                    row.btnHeal:LockHighlight()
                    row.btnHeal:SetText("|cff00ff00+H|r")
                else
                    row.btnHeal:UnlockHighlight()
                    row.btnHeal:SetText("+H")
                end
                row.btnHeal:Show()
            end
            if row.btnBoost and unit ~= "player" then
                if UnBot.boostTarget == name then
                    row.btnBoost:LockHighlight()
                    row.btnBoost:SetText("|cffffaa00+B|r")
                else
                    row.btnBoost:UnlockHighlight()
                    row.btnBoost:SetText("+B")
                end
                row.btnBoost:Show()
            end
            row:Show()
        else
            row.partyUnit = nil; row.partyName = nil
            if row.btnTalents then row.btnTalents:Hide() end
            if row.btnHeal then row.btnHeal:Hide() end
            if row.btnBoost then row.btnBoost:Hide() end
            row:Hide()
        end
    end
end

--=========================================================================--
--  Tab 4: Raid View (Encounter Helpers & Custom Tactics)
--=========================================================================--

function UnBot:CreateRaidView(parent)
    local v = CreateFrame("Frame", "UnBotRaidView", parent)
    v:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -60)
    v:SetWidth(476); v:SetHeight(356)
    self.raidView = v

    local intro = v:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", v, "TOPLEFT", 6, 0); intro:SetWidth(464); intro:SetJustifyH("LEFT")
    intro:SetText("Orders go to your bots in this raid. Target one of your bots to send an order to that bot only.")
    intro:SetTextColor(0.6, 0.6, 0.6)

    -- Card 1: Encounter Helpers
    local card1 = CreateFrame("Frame", nil, v)
    card1:SetPoint("TOPLEFT", v, "TOPLEFT", 6, -20); card1:SetWidth(464); card1:SetHeight(76)
    local c1Title = card1:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    c1Title:SetPoint("TOPLEFT", card1, "TOPLEFT", 0, 0); c1Title:SetText("|cffd8a657ENCOUNTER HELPERS|r")

    local btnTankFace = CreateFrame("Button", nil, card1, "UIPanelButtonTemplate")
    btnTankFace:SetWidth(180); btnTankFace:SetHeight(24); btnTankFace:SetPoint("TOPLEFT", card1, "TOPLEFT", 0, -16)
    btnTankFace:SetText("Tank face away")
    btnTankFace:SetScript("OnClick", function() UnBot:SendBotCommand("action raid tankface") end)

    local btnDouse = CreateFrame("Button", nil, card1, "UIPanelButtonTemplate")
    btnDouse:SetWidth(180); btnDouse:SetHeight(24); btnDouse:SetPoint("LEFT", btnTankFace, "RIGHT", 8, 0)
    btnDouse:SetText("Douse runes")
    btnDouse:SetScript("OnClick", function() UnBot:SendBotCommand("action raid douse") end)

    local c1Note = card1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    c1Note:SetPoint("TOPLEFT", card1, "TOPLEFT", 0, -48); c1Note:SetWidth(460); c1Note:SetJustifyH("LEFT")
    c1Note:SetText("Dragons: Tank turns boss away. Molten Core: Bots douse runes with Quintessence.")
    c1Note:SetTextColor(0.5, 0.5, 0.5)

    -- Card 2: Turtle Custom Raids
    local card2 = CreateFrame("Frame", nil, v)
    card2:SetPoint("TOPLEFT", card1, "BOTTOMLEFT", 0, -10); card2:SetWidth(464); card2:SetHeight(76)
    local c2Title = card2:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    c2Title:SetPoint("TOPLEFT", card2, "TOPLEFT", 0, 0); c2Title:SetText("|cffd8a657TURTLE CUSTOM RAIDS|r")

    local btnCustomToggle = CreateFrame("Button", nil, card2, "UIPanelButtonTemplate")
    btnCustomToggle:SetWidth(180); btnCustomToggle:SetHeight(24); btnCustomToggle:SetPoint("TOPLEFT", card2, "TOPLEFT", 0, -16)
    btnCustomToggle:SetText("Custom tactics: On")
    btnCustomToggle:SetScript("OnClick", function()
        if UnBot.raidCustomState == "on" then
            UnBot:SendBotCommand("action raid custom off")
            UnBot.raidCustomState = "off"
        else
            UnBot:SendBotCommand("action raid custom on")
            UnBot.raidCustomState = "on"
        end
        UnBot:RefreshRaidView()
    end)
    v.btnCustomToggle = btnCustomToggle

    local btnCustomCheck = CreateFrame("Button", nil, card2, "UIPanelButtonTemplate")
    btnCustomCheck:SetWidth(80); btnCustomCheck:SetHeight(24); btnCustomCheck:SetPoint("LEFT", btnCustomToggle, "RIGHT", 8, 0)
    btnCustomCheck:SetText("Check")
    btnCustomCheck:SetScript("OnClick", function() UnBot:SendBotCommand("action raid custom status") end)

    local c2Note = card2:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    c2Note:SetPoint("TOPLEFT", card2, "TOPLEFT", 0, -48); c2Note:SetWidth(460); c2Note:SetJustifyH("LEFT")
    c2Note:SetText("Scripted boss mechanics for Emerald Sanctum, Lower Karazhan, and Karazhan Crypt.")
    c2Note:SetTextColor(0.5, 0.5, 0.5)

    -- Card 3: Bot Raid Tactics
    local card3 = CreateFrame("Frame", nil, v)
    card3:SetPoint("TOPLEFT", card2, "BOTTOMLEFT", 0, -10); card3:SetWidth(464); card3:SetHeight(130)
    local c3Title = card3:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    c3Title:SetPoint("TOPLEFT", card3, "TOPLEFT", 0, 0); c3Title:SetText("|cffd8a657BOT RAID TACTICS|r")

    local btnCheckBots = CreateFrame("Button", nil, card3, "UIPanelButtonTemplate")
    btnCheckBots:SetWidth(110); btnCheckBots:SetHeight(22); btnCheckBots:SetPoint("TOPLEFT", card3, "TOPLEFT", 0, -16)
    btnCheckBots:SetText("Check bots")
    btnCheckBots:SetScript("OnClick", function()
        UnBot.raidBotTactics = {}
        UnBot:SendBotCommand("action raid status")
    end)

    local tacticsList = card3:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tacticsList:SetPoint("TOPLEFT", card3, "TOPLEFT", 0, -44); tacticsList:SetWidth(460); tacticsList:SetJustifyH("LEFT")
    tacticsList:SetText("Click 'Check bots' to list loaded boss tactics for every bot in this raid.")
    tacticsList:SetTextColor(0.7, 0.7, 0.7)
    v.tacticsList = tacticsList
end

function UnBot:RefreshRaidView()
    if not self.raidView or not self.raidView:IsShown() then return end
    if self.raidView.btnCustomToggle then
        self.raidView.btnCustomToggle:SetText("Custom tactics: " .. string.upper(self.raidCustomState or "ON"))
    end

    local text = ""
    for name, t in pairs(self.raidBotTactics or {}) do
        text = text .. "|cffd8a657" .. name .. ":|r " .. t .. "\n"
    end
    if text ~= "" and self.raidView.tacticsList then
        self.raidView.tacticsList:SetText(text)
    end
end

--=========================================================================--
--  Tab 5: Roles View (Combat Strategy Presets & Batch Roles)
--=========================================================================--

function UnBot:GetNumGroupMembersOfClass(classToken)
    if not classToken then return 0 end
    local count = 0
    local upperToken = string.upper(classToken)
    local raid = GetNumRaidMembers()
    if raid > 0 then
        for i = 1, raid do
            local unit = "raid" .. i
            if UnitExists(unit) and not UnitIsUnit(unit, "player") then
                local _, token = UnitClass(unit)
                if token and string.upper(token) == upperToken then
                    count = count + 1
                end
            end
        end
    else
        local party = GetNumPartyMembers()
        for i = 1, party do
            local unit = "party" .. i
            if UnitExists(unit) and not UnitIsUnit(unit, "player") then
                local _, token = UnitClass(unit)
                if token and string.upper(token) == upperToken then
                    count = count + 1
                end
            end
        end
    end
    return count
end

function UnBot:CreateRolesView(parent)
    local v = CreateFrame("Frame", "UnBotRolesView", parent)
    v:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -60)
    v:SetWidth(476); v:SetHeight(356)
    self.rolesView = v

    -- Card 1: Target Bot Role Strategy & Talents
    local targetCard = CreateFrame("Frame", nil, v)
    targetCard:SetPoint("TOPLEFT", v, "TOPLEFT", 6, 0)
    targetCard:SetWidth(464); targetCard:SetHeight(72)
    v.targetCard = targetCard

    local tcTitle = targetCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tcTitle:SetPoint("TOPLEFT", targetCard, "TOPLEFT", 0, 0)
    tcTitle:SetText("|cffd8a657TARGET BOT COMBAT STRATEGY & TALENTS|r")

    local tcSelected = targetCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tcSelected:SetPoint("TOPLEFT", targetCard, "TOPLEFT", 0, -16)
    tcSelected:SetWidth(236); tcSelected:SetJustifyH("LEFT")
    tcSelected:SetText("|cffaaaaaaSelect a grouped bot to inspect or toggle its role.|r")
    v.targetText = tcSelected

    local tcStatus = targetCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tcStatus:SetPoint("TOPLEFT", targetCard, "TOPLEFT", 0, -32)
    tcStatus:SetWidth(236); tcStatus:SetJustifyH("LEFT")
    tcStatus:SetText("Current combat strategy: |cff777777unavailable|r")
    v.statusText = tcStatus

    local tcHint = targetCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tcHint:SetPoint("TOPLEFT", targetCard, "TOPLEFT", 0, -48)
    tcHint:SetWidth(236); tcHint:SetJustifyH("LEFT")
    tcHint:SetText("|cff777777Applies combat strategy profile directly to targeted bot.|r")

    -- Target bot spec buttons (up to 4 specs)
    v.targetSpecButtons = {}
    for b = 1, 4 do
        local btn = CreateFrame("Button", "UnBotRolesViewTargetSpec"..b, targetCard, "UIPanelButtonTemplate")
        btn:SetWidth(52); btn:SetHeight(22)
        btn:SetPoint("TOPLEFT", targetCard, "TOPLEFT", 240 + (b - 1) * 55, -8)
        btn:Hide()
        btn:SetScript("OnClick", function()
            if this.specDef and UnBot.ApplySelectedRole then
                UnBot:ApplySelectedRole(this.specDef)
            end
        end)
        btn:SetScript("OnEnter", function()
            if this.specDef then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Set role to " .. this.specDef.label, 1, 0.82, 0)
                if this.specDef.strat and this.specDef.strat ~= "" then
                    GameTooltip:AddLine("Strategies: " .. this.specDef.strat, 0.3, 1, 0.3)
                end
                GameTooltip:AddLine("Click to switch targeted bot to this combat role.", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        v.targetSpecButtons[b] = btn
    end
    v.btnPrimary = v.targetSpecButtons[1]
    v.btnSecondary = v.targetSpecButtons[2]

    -- Target bot action buttons below specs
    local btnAlignTalents = CreateFrame("Button", "UnBotRolesViewAlignTalents", targetCard, "UIPanelButtonTemplate")
    btnAlignTalents:SetWidth(98); btnAlignTalents:SetHeight(20)
    btnAlignTalents:SetPoint("TOPLEFT", targetCard, "TOPLEFT", 240, -36)
    btnAlignTalents:SetText("Align Talents")
    btnAlignTalents:Disable()
    btnAlignTalents:SetScript("OnClick", function()
        local name = v.targetName
        if not name or name == "" then return end
        SendChatMessage("talents auto", "WHISPER", nil, name)
        UnBot:Message("Ordered " .. name .. " to auto-allocate talents for designated role")
    end)
    btnAlignTalents:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Auto-Align Talents", 1, 0.82, 0)
        GameTooltip:AddLine("Orders this bot to automatically allocate its talent points", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("into the talent tree matching its active role.", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Click to apply.", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    btnAlignTalents:SetScript("OnLeave", function() GameTooltip:Hide() end)
    v.btnAlignTalents = btnAlignTalents

    local btnResetTalents = CreateFrame("Button", "UnBotRolesViewResetTalents", targetCard, "UIPanelButtonTemplate")
    btnResetTalents:SetWidth(56); btnResetTalents:SetHeight(20)
    btnResetTalents:SetPoint("LEFT", btnAlignTalents, "RIGHT", 4, 0)
    btnResetTalents:SetText("Reset Tal")
    btnResetTalents:Disable()
    btnResetTalents:SetScript("OnClick", function()
        local name = v.targetName
        if not name or name == "" then return end
        SendChatMessage("talents reset", "WHISPER", nil, name)
        UnBot:Message("Ordered " .. name .. " to reset talents")
    end)
    btnResetTalents:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Reset Talents", 1, 0.82, 0)
        GameTooltip:AddLine("Wipes all talent points for this bot.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    btnResetTalents:SetScript("OnLeave", function() GameTooltip:Hide() end)
    v.btnResetTalents = btnResetTalents

    local btnRefresh = CreateFrame("Button", "UnBotRolesViewRefresh", targetCard, "UIPanelButtonTemplate")
    btnRefresh:SetWidth(56); btnRefresh:SetHeight(20)
    btnRefresh:SetPoint("LEFT", btnResetTalents, "RIGHT", 4, 0)
    btnRefresh:SetText("Check")
    btnRefresh:SetScript("OnClick", function()
        if UnBot.RefreshRoleTarget then
            UnBot:RefreshRoleTarget(true)
        end
        UnBot:RefreshRolesView()
    end)
    btnRefresh:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText("Check Role & Strategies", 1, 0.82, 0)
        GameTooltip:AddLine("Queries the targeted bot for its active combat strategies.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    btnRefresh:SetScript("OnLeave", function() GameTooltip:Hide() end)
    v.btnRefresh = btnRefresh

    -- Card 2: Mass Class Strategy Presets (All Grouped Bots)
    local massCard = CreateFrame("Frame", nil, v)
    massCard:SetPoint("TOPLEFT", targetCard, "BOTTOMLEFT", 0, -6)
    massCard:SetWidth(464); massCard:SetHeight(276)
    v.massCard = massCard

    local mcTitle = massCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mcTitle:SetPoint("TOPLEFT", massCard, "TOPLEFT", 0, 0)
    mcTitle:SetText("|cffd8a657MASS CLASS COMBAT STRATEGIES (ALL GROUPED BOTS)|r")

    local mcSubtitle = massCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    mcSubtitle:SetPoint("TOPLEFT", massCard, "TOPLEFT", 0, -16)
    mcSubtitle:SetWidth(464); mcSubtitle:SetJustifyH("LEFT")
    mcSubtitle:SetText("|cff888888Click a spec to apply to all bots of that class across your party or raid.|r")

    local roleOrder = (Retinue and Retinue.ROLE_ORDER) or (self.ROLE_ORDER) or {
        "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
        "SHAMAN", "MAGE", "WARLOCK", "DRUID",
    }

    v.classRows = {}
    local totalClasses = table.getn(roleOrder)
    for i = 1, totalClasses do
        local classToken = roleOrder[i]
        local isLeft = (i <= 5)
        local colX = isLeft and 0 or 236
        local rowIndex = isLeft and (i - 1) or (i - 6)
        local rowY = -34 - (rowIndex * 48)

        local rowFrame = CreateFrame("Frame", nil, massCard)
        rowFrame:SetWidth(228); rowFrame:SetHeight(44)
        rowFrame:SetPoint("TOPLEFT", massCard, "TOPLEFT", colX, rowY)
        rowFrame.classToken = classToken

        -- Clickable header row with highlight
        local header = CreateFrame("Button", nil, rowFrame)
        header:SetWidth(228); header:SetHeight(18)
        header:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 0, 0)
        header:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        header:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        header.classToken = classToken

        local icon = header:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(16); icon:SetHeight(16)
        icon:SetPoint("LEFT", header, "LEFT", 2, 0)
        local coords = (self.GetClassCoords and self:GetClassCoords(classToken)) or (CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken])
        if coords then
            icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
            icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        end

        local nameText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameText:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        local className = (self.GetClassName and self:GetClassName(classToken))
                       or (string.upper(string.sub(classToken, 1, 1)) .. string.lower(string.sub(classToken, 2)))
        nameText:SetText(className)
        local c = (self.GetClassColor and self:GetClassColor(classToken)) or { 1, 1, 1 }
        nameText:SetTextColor(c[1], c[2], c[3])

        local countText = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        countText:SetPoint("LEFT", nameText, "RIGHT", 6, 0)
        countText:SetText("|cff666666(0 in group)|r")
        rowFrame.countText = countText

        local classRoles = (Retinue and Retinue.Roles and Retinue.Roles.GetClassRoles and Retinue.Roles.GetClassRoles(classToken)) or {}
        local roleCount = table.getn(classRoles)

        header:SetScript("OnClick", function()
            local roles = (Retinue and Retinue.Roles and Retinue.Roles.GetClassRoles and Retinue.Roles.GetClassRoles(this.classToken)) or {}
            if table.getn(roles) > 0 then
                local pick = (arg1 == "RightButton" and roles[2]) or roles[1]
                if UnBot.ApplyRoleSpec then
                    UnBot:ApplyRoleSpec(this.classToken, pick)
                end
            end
        end)

        header:SetScript("OnEnter", function()
            local roles = (Retinue and Retinue.Roles and Retinue.Roles.GetClassRoles and Retinue.Roles.GetClassRoles(this.classToken)) or {}
            if table.getn(roles) == 0 then return end
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:AddLine(className, 1, 0.82, 0)
            for rIdx = 1, table.getn(roles) do
                local r = roles[rIdx]
                GameTooltip:AddLine(r.label .. ": " .. (r.strat or ""), 0.8, 0.8, 0.8)
            end
            GameTooltip:AddLine("Click individual spec buttons below to apply to all " .. string.lower(this.classToken) .. " bots.", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        header:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Multi-spec buttons for this class
        rowFrame.specButtons = {}
        local btnWidth = (roleCount >= 4 and 54) or math.floor((228 - (roleCount - 1) * 3) / (roleCount > 0 and roleCount or 1))
        for s = 1, roleCount do
            local spec = classRoles[s]
            local btn = CreateFrame("Button", nil, rowFrame, "UIPanelButtonTemplate")
            btn:SetWidth(btnWidth); btn:SetHeight(20)
            btn:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", (s - 1) * (btnWidth + 3), -20)
            local short = (Retinue and Retinue.Roles and Retinue.Roles.ShortLabel and Retinue.Roles.ShortLabel(spec.label)) or spec.label
            btn:SetText(short)
            btn.classToken = classToken
            btn.specDef = spec
            btn:SetScript("OnClick", function()
                if UnBot.ApplyRoleSpec then
                    UnBot:ApplyRoleSpec(this.classToken, this.specDef)
                end
            end)
            btn:SetScript("OnEnter", function()
                if not this.specDef then return end
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Apply " .. this.specDef.label .. " to all " .. className .. " bots", 1, 0.82, 0)
                if this.specDef.strat and this.specDef.strat ~= "" then
                    GameTooltip:AddLine("Strategies: " .. this.specDef.strat, 0.3, 1, 0.3)
                end
                GameTooltip:AddLine("Click to apply to all grouped bots of this class.", 0.6, 0.6, 0.6)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            rowFrame.specButtons[s] = btn
        end

        v.classRows[i] = rowFrame
    end
end

function UnBot:RefreshRolesView()
    if not self.rolesView or not self.rolesView:IsShown() then return end
    local v = self.rolesView

    -- 1. Refresh Target Bot
    local name, classToken
    if self.GetSelectedRoleTarget then
        name, classToken = self:GetSelectedRoleTarget()
    end

    if not name or not classToken then
        v.targetName = nil
        v.targetText:SetText("|cffaaaaaaSelect a grouped bot to inspect or toggle its role.|r")
        v.statusText:SetText("Current combat strategy: |cff777777unavailable|r")
        if v.targetSpecButtons then
            for b = 1, 4 do
                v.targetSpecButtons[b]:Hide()
            end
        end
        if v.btnAlignTalents then v.btnAlignTalents:Disable() end
        if v.btnResetTalents then v.btnResetTalents:Disable() end
    else
        local classRoles = (Retinue and Retinue.Roles and Retinue.Roles.GetClassRoles and Retinue.Roles.GetClassRoles(classToken)) or {}
        local currentId, currentRole = nil, nil
        if Retinue and Retinue.Roles and Retinue.Roles.GetBotRole then
            currentId, currentRole = Retinue.Roles.GetBotRole(name, classToken)
        end
        local label = (currentRole and currentRole.label) or (self.GetBotRoleLabel and self:GetBotRoleLabel(name, classToken)) or "Default"
        local c = (self.GetClassColor and self:GetClassColor(classToken)) or { 1, 1, 1, hex = "ffffffff" }
        local hex = c.hex or "ffffffff"
        local className = (self.GetClassName and self:GetClassName(classToken)) or classToken

        v.targetName = name
        v.targetText:SetText("Selected: |c" .. hex .. name .. "|r (" .. className .. ")")
        v.statusText:SetText("Current combat strategy: |cffffffff" .. label .. "|r")

        local roleCount = table.getn(classRoles)
        local btnWidth = (roleCount >= 4 and 52) or 68
        for b = 1, 4 do
            local btn = v.targetSpecButtons[b]
            local spec = classRoles[b]
            if spec then
                btn:ClearAllPoints()
                btn:SetWidth(btnWidth)
                btn:SetPoint("TOPLEFT", v.targetCard, "TOPLEFT", 240 + (b - 1) * (btnWidth + 3), -8)
                local short = (Retinue and Retinue.Roles and Retinue.Roles.ShortLabel and Retinue.Roles.ShortLabel(spec.label)) or spec.label
                local isSelected = (currentId == spec.id)
                if isSelected then
                    btn:SetText("|cffffffff" .. short .. "|r")
                    btn:LockHighlight()
                else
                    btn:SetText("|cff9a978f" .. short .. "|r")
                    btn:UnlockHighlight()
                end
                btn.specDef = spec
                btn:Show()
            else
                btn:Hide()
            end
        end

        if v.btnAlignTalents then v.btnAlignTalents:Enable() end
        if v.btnResetTalents then v.btnResetTalents:Enable() end
    end

    -- 2. Refresh Class Bot Counts
    if v.classRows then
        local totalRows = table.getn(v.classRows)
        for i = 1, totalRows do
            local row = v.classRows[i]
            if row and row.classToken and row.countText then
                local count = self:GetNumGroupMembersOfClass(row.classToken)
                if count > 0 then
                    row.countText:SetText("|cff40a040(" .. count .. " in group)|r")
                else
                    row.countText:SetText("|cff666666(0 in group)|r")
                end
            end
        end
    end
end

--=========================================================================--
--  Tab 6: CC Marks View (Crowd Control Assignment)
--=========================================================================--

function UnBot:CreateCCView(parent)
    local v = CreateFrame("Frame", "UnBotCCView", parent)
    v:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -60)
    v:SetWidth(476); v:SetHeight(356)
    self.ccView = v

    local title = v:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", v, "TOPLEFT", 6, 0)
    title:SetText("|cffd8a657Crowd Control (CC) Assignment Manager|r")

    local clearAll = CreateFrame("Button", nil, v, "UIPanelButtonTemplate")
    clearAll:SetWidth(80); clearAll:SetHeight(20)
    clearAll:SetPoint("TOPRIGHT", v, "TOPRIGHT", -8, 2)
    clearAll:SetText("Clear all")
    clearAll:SetScript("OnClick", function()
        UnBot:SendBotCommand("cc clear")
        UnBot.ccAssignments = {}
        UnBot:RefreshCCView()
    end)

    v.rows = {}
    local marks = (Retinue and Retinue.C and Retinue.C.CC_MARKS) or {
        { id = "moon", label = "Moon", icon = 5 },
        { id = "circle", label = "Circle", icon = 2 },
        { id = "square", label = "Square", icon = 6 },
        { id = "cross", label = "Cross", icon = 7 },
        { id = "triangle", label = "Triangle", icon = 4 },
        { id = "diamond", label = "Diamond", icon = 3 },
        { id = "star", label = "Star", icon = 1 },
        { id = "skull", label = "Skull", icon = 8 },
    }

    for i = 1, table.getn(marks) do
        local m = marks[i]
        local row = CreateFrame("Frame", nil, v)
        row:SetWidth(464); row:SetHeight(32)
        row:SetPoint("TOPLEFT", v, "TOPLEFT", 6, -26 - (i - 1) * 36)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(20); icon:SetHeight(20)
        icon:SetPoint("LEFT", row, "LEFT", 4, 0)
        icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        local left = math.mod(m.icon - 1, 4) * 0.25
        local top = math.floor((m.icon - 1) / 4) * 0.25
        icon:SetTexCoord(left, left + 0.25, top, top + 0.25)
        row.icon = icon

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", icon, "RIGHT", 8, 0); label:SetWidth(80); label:SetJustifyH("LEFT")
        label:SetText(m.label)
        row.label = label

        local ownerBtn = CreateFrame("Button", nil, row)
        ownerBtn:SetPoint("LEFT", label, "RIGHT", 8, 0); ownerBtn:SetWidth(180); ownerBtn:SetHeight(20)
        local owner = ownerBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        owner:SetAllPoints(ownerBtn); owner:SetJustifyH("LEFT")
        owner:SetText("|cff888888(Unassigned)|r")
        row.owner = owner
        row.ownerBtn = ownerBtn
        ownerBtn:SetScript("OnClick", function()
            local r = this:GetParent()
            if r.assignedBot and r.assignedBot ~= "" then
                UnBot:TargetBot(r.assignedBot)
            end
        end)

        local nextBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        nextBtn:SetWidth(60); nextBtn:SetHeight(20)
        nextBtn:SetPoint("RIGHT", row, "RIGHT", -36, 0)
        nextBtn:SetText("Next")
        nextBtn.markId = m.id
        nextBtn:SetScript("OnClick", function()
            local nextBot = UnBot:FindNextAvailableCcBot(this.markId)
            if nextBot then
                UnBot:SendBotCommand("cc " .. this.markId .. " " .. nextBot)
                UnBot.ccAssignments[nextBot] = this.markId
                UnBot:RefreshCCView()
            else
                UnBot:Message("No eligible online bot available for CC")
            end
        end)
        row.nextBtn = nextBtn

        local clrBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        clrBtn:SetWidth(24); clrBtn:SetHeight(20)
        clrBtn:SetPoint("LEFT", nextBtn, "RIGHT", 4, 0)
        clrBtn:SetText("X")
        clrBtn.markId = m.id
        clrBtn:SetScript("OnClick", function()
            local currentOwner = UnBot:GetCcMarkOwner(this.markId)
            if currentOwner then
                UnBot:SendBotCommand("cc clear " .. currentOwner)
                UnBot.ccAssignments[currentOwner] = nil
                UnBot:RefreshCCView()
            end
        end)
        row.clrBtn = clrBtn

        v.rows[i] = row
    end
end

function UnBot:GetCcMarkOwner(markId)
    markId = string.lower(markId or "")
    for name, mark in pairs(self.ccAssignments or {}) do
        if mark == markId then return name end
    end
    return nil
end

function UnBot:FindNextAvailableCcBot(markId)
    local candidates = {}
    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local name = UnitName("raid"..i)
            if name and not UnitIsUnit("raid"..i, "player") then table.insert(candidates, name) end
        end
    else
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if name then table.insert(candidates, name) end
        end
    end
    for i = 1, table.getn(candidates) do
        local name = candidates[i]
        if not self.ccAssignments[name] then return name end
    end
    return candidates[1]
end

function UnBot:RefreshCCView()
    if not self.ccView or not self.ccView:IsShown() then return end
    local marks = (Retinue and Retinue.C and Retinue.C.CC_MARKS) or {}
    for i = 1, table.getn(marks) do
        local m = marks[i]
        local row = self.ccView.rows[i]
        if row then
            local owner = self:GetCcMarkOwner(m.id)
            row.assignedBot = owner
            if owner then
                local data = self.config and self.config.roster and self.config.roster[owner]
                local c = (self.GetClassColor and self:GetClassColor(data and data.class)) or {0.9, 0.9, 0.9}
                row.owner:SetText(owner); row.owner:SetTextColor(c[1], c[2], c[3])
            else
                row.owner:SetText("|cff888888(Unassigned)|r")
            end
        end
    end
end

--=========================================================================--
--  Account View Row Refresh & Helpers
--=========================================================================--

function UnBot:ScrollRoster(delta)
    local total = table.getn(self:GetFilteredRoster())
    local maxOffset = total - ROW_COUNT
    if maxOffset < 0 then maxOffset = 0 end

    self.rosterOffset = (self.rosterOffset or 0) + delta
    if self.rosterOffset < 0 then self.rosterOffset = 0 end
    if self.rosterOffset > maxOffset then self.rosterOffset = maxOffset end
    self:RefreshRoster()
end

function UnBot:GetFilteredRoster()
    self:SanitizeRoster()
    local out = {}
    local query = self.rosterSearchQuery
    for name, data in pairs(self.config.roster or {}) do
        if IsValidCharacterName(name) then
            local matchesClass = (self.rosterFilter == "ALL")
            if not matchesClass then
                local botToken = (self.GetClassToken and self:GetClassToken(data.class)) or string.upper(tostring(data.class or ""))
                local fltToken = (self.GetClassToken and self:GetClassToken(self.rosterFilter)) or string.upper(tostring(self.rosterFilter or ""))
                matchesClass = (botToken == fltToken)
            end
            local matchesSearch = true
            if query and query ~= "" then
                matchesSearch = string.find(string.lower(name), query, 1, true) ~= nil
            end
            if matchesClass and matchesSearch then
                table.insert(out, name)
            end
        else
            self.config.roster[name] = nil
        end
    end
    table.sort(out)
    return out
end

function UnBot:RefreshRoster()
    if not self.accountView or not self.accountView:IsShown() then return end

    for class, btn in pairs(self.classButtons or {}) do
        if class == self.rosterFilter then btn.selected:Show() else btn.selected:Hide() end
    end

    local names = self:GetFilteredRoster()
    local total = table.getn(names)
    local maxOffset = total - ROW_COUNT
    if maxOffset < 0 then maxOffset = 0 end
    self.rosterOffset = self.rosterOffset or 0
    if self.rosterOffset > maxOffset then self.rosterOffset = maxOffset end
    if self.rosterOffset < 0 then self.rosterOffset = 0 end

    if self.accountView and self.accountView.scrollBar then
        self.accountView.scrollBar:Update(self.rosterOffset, maxOffset)
    end

    local searchQ = self.rosterSearchQuery
    local showAddRow = (searchQ and searchQ ~= "" and IsValidCharacterName(searchQ) and table.getn(names) == 0)
    local me = UnitName("player")
    local myLower = (me and IsValidCharacterName(me)) and string.lower(me) or ""

    for i = 1, ROW_COUNT do
        local row = self.rosterRows[i]
        local name = names[i + self.rosterOffset]

        if name and IsValidCharacterName(name) then
            row.isAddButton = nil
            local data = self.config.roster[name] or {}
            local c = (self.GetClassColor and self:GetClassColor(data.class)) or {1, 1, 1}
            local grouped = IsInGroup(name)
            row.charName = name
            row.nameText:SetTextColor(c[1], c[2], c[3])
            if row.accent then
                row.accent:SetTexture(c[1], c[2], c[3], 0.95)
                row.accent:Show()
            end

            local coords = (self.GetClassCoords and self:GetClassCoords(data.class))
            if coords and row.classIcon then
                row.classIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
                row.classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
                row.classIcon:Show()
            elseif row.classIcon then
                row.classIcon:Hide()
            end

            local isMe = (myLower ~= "" and string.lower(name) == myLower)
            if isMe then
                row.selectCheck:SetChecked(nil); row.selectCheck:Hide()
                row.nameText:SetText(name.."  (you)")
                row.levelText:SetText("in world"); row.levelText:SetTextColor(0.4, 0.8, 1)
            else
                row.selectCheck:SetChecked(self.rosterSelection[name] and 1 or nil)
                row.selectCheck:Show()
                row.nameText:SetText(name)
                if grouped then
                    row.levelText:SetText("in group"); row.levelText:SetTextColor(0.2, 0.9, 0.9)
                elseif data.online then
                    row.levelText:SetText("online"); row.levelText:SetTextColor(0.3, 1, 0.3)
                elseif data.online == false then
                    row.levelText:SetText("offline"); row.levelText:SetTextColor(0.6, 0.6, 0.6)
                elseif data.level and data.level > 0 then
                    row.levelText:SetText("level "..data.level); row.levelText:SetTextColor(0.7, 0.7, 0.7)
                else
                    row.levelText:SetText("")
                end
            end
            row:Show()
        elseif showAddRow and i == 1 then
            local normName = string.upper(string.sub(searchQ, 1, 1)) .. string.lower(string.sub(searchQ, 2))
            row.charName = normName
            row.isAddButton = true
            row.selectCheck:SetChecked(nil); row.selectCheck:Hide()
            if row.accent then
                row.accent:SetTexture(0.3, 1.0, 0.3, 0.95)
                row.accent:Show()
            end
            if row.classIcon then row.classIcon:Hide() end
            row.nameText:SetTextColor(0.3, 1.0, 0.3)
            row.nameText:SetText("+ Add \""..normName.."\"")
            row.levelText:SetTextColor(0.7, 0.7, 0.7)
            row.levelText:SetText("(Click or Enter)")
            row:Show()
        else
            row.isAddButton = nil; row.charName = nil
            if row.accent then row.accent:Hide() end
            if row.classIcon then row.classIcon:Hide() end
            row.selectCheck:SetChecked(nil); row.selectCheck:Hide()
            row:Hide()
        end
    end
end

function UnBot:GetSelectedRosterNames()
    local names = {}
    local me = UnitName("player")
    local myLower = (me and IsValidCharacterName(me)) and string.lower(me) or ""
    for name, selected in pairs(self.rosterSelection or {}) do
        if selected and IsValidCharacterName(name) and self.config.roster[name] then
            if myLower == "" or string.lower(name) ~= myLower then
                table.insert(names, name)
            end
        end
    end
    table.sort(names)
    return names
end

function UnBot:ClearRosterSelection()
    self.rosterSelection = {}
    self:RefreshRoster()
end

function UnBot:RemoveSelectedFromGroup()
    local names = self:GetSelectedRosterNames()
    if table.getn(names) == 0 then
        self:Message("No bots selected (check boxes next to characters)")
        return
    end
    for i = 1, table.getn(names) do
        local name = names[i]
        if IsInGroup(name) then self:UninviteBot(name) else self.config.roster[name] = nil end
    end
    self:ClearRosterSelection()
    self:RefreshRoster()
    self:Message("Updated selection")
end

function UnBot:DeleteSelectedRoster()
    local names = self:GetSelectedRosterNames()
    if table.getn(names) == 0 then
        self:Message("No bots selected (check boxes next to characters)")
        return
    end
    for i = 1, table.getn(names) do
        local name = names[i]
        if IsInGroup(name) then self:UninviteBot(name) end
        self.config.roster[name] = nil
    end
    self:ClearRosterSelection()
    self:RefreshRoster()
    self:Message("Dropped selected bots from roster list")
end

function UnBot:LogoutSelectedBots()
    local names = self:GetSelectedRosterNames()
    if table.getn(names) == 0 then
        self:Message("No bots selected (check boxes next to characters)")
        return
    end
    for i = 1, table.getn(names) do
        local name = names[i]
        if IsInGroup(name) then self:UninviteBot(name) end
        self:SendBotCommand("remove " .. name)
        if self.config.roster[name] then
            self.config.roster[name].online = false
            self.config.roster[name].grouped = false
        end
    end
    self:ClearRosterSelection()
    self:RefreshRoster()
    self:Message("Logging out selected bot(s)")
end

function UnBot:InviteBot(name)
    if not name or name == "" then return end
    if IsInGroup(name) then return end

    if not UnitInRaid("player") and GetNumPartyMembers() >= 4 then
        if type(ConvertToRaid) == "function" then ConvertToRaid() end
    end

    -- Native group invite works for ALL bots (account alts, claimed bots, wandering bots)
    NativeInvite(name)

    -- Only dispatch .bot invite for verified account alts to avoid "same account only" server rejection
    local data = self.config and self.config.roster and self.config.roster[name]
    if data and data.altbot then
        self:SendBotCommand("invite " .. name)
    end
end

function UnBot:LoginAndInvite(name)
    return self:InteractWithBot(name, "LeftButton")
end

function UnBot:FillWith(maxSize)
    if maxSize > 5 and not UnitInRaid("player") and GetNumPartyMembers() > 0 then
        if type(ConvertToRaid) == "function" then ConvertToRaid() end
    end

    local free = maxSize - GroupSize()
    if free <= 0 then
        self:Message("Group is already full")
        return
    end

    local names = self:GetFilteredRoster()
    local me = UnitName("player")
    local myLower = (me and IsValidCharacterName(me)) and string.lower(me) or ""
    local toInvite = {}

    for i = 1, table.getn(names) do
        local name = names[i]
        if (myLower == "" or string.lower(name) ~= myLower) and not IsInGroup(name) then
            table.insert(toInvite, name)
            if table.getn(toInvite) >= free then break end
        end
    end

    if table.getn(toInvite) > 0 then
        self:QueueRosterBatch("invite", toInvite)
        self:Message("Filling group with " .. table.getn(toInvite) .. " character(s)")
    else
        self:Message("No eligible roster characters found to invite")
    end
end

function UnBot:BulkBotCommand(subcommand)
    local cmd = subcommand or "remove"
    local names = self:GetFilteredRoster()
    local count = table.getn(names)
    if count == 0 then
        self:Message("No characters in this list")
        return
    end

    local me = UnitName("player")
    local myLower = (me and IsValidCharacterName(me)) and string.lower(me) or ""
    local queued = 0
    for i = 1, count do
        local name = names[i]
        if myLower == "" or string.lower(name) ~= myLower then
            self:SendBotCommand(cmd .. " " .. name)
            queued = queued + 1
            if cmd == "remove" and self.config.roster[name] then
                self.config.roster[name].online = false
                self.config.roster[name].grouped = false
            end
        end
    end
    self:RefreshRoster()
    self:Message("Dispatched '" .. cmd .. "' for " .. queued .. " character(s)")
end

function UnBot:RecordCurrentCharacter()
    local name = UnitName("player")
    if not IsValidCharacterName(name) then return end
    local locClass, token = UnitClass("player")
    if not token then token = string.upper(locClass or "") end
    self:SanitizeRoster()
    local entry = self.config.roster[name] or {}
    entry.class = token
    entry.level = UnitLevel("player")
    entry.self  = true
    self.config.roster[name] = entry
end

function UnBot:RemoveRosterCharacter(name)
    if not name or not IsValidCharacterName(name) then return end
    if self.config.roster[name] then
        if IsInGroup(name) then self:UninviteBot(name) end
        self.config.roster[name] = nil
        if self.rosterSelection then self.rosterSelection[name] = nil end
        self:Message("Removed " .. name .. " from roster")
        self:RefreshRoster()
    end
end
