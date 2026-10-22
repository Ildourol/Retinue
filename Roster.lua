-- UnBot Roster - the list of your own account characters.
--
-- WoW gives an addon no way to enumerate the characters on an account, so the
-- roster is built up instead: every character that logs in records itself, and
-- anything else can be typed in by hand. SavedVariables are per account, so
-- the list fills itself in as you play.

local CLASSES = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}

local CLASS_COLOR = {
    WARRIOR = {0.78, 0.61, 0.43},
    PALADIN = {0.96, 0.55, 0.73},
    HUNTER  = {0.67, 0.83, 0.45},
    ROGUE   = {1.00, 0.96, 0.41},
    PRIEST  = {1.00, 1.00, 1.00},
    SHAMAN  = {0.14, 0.35, 1.00},
    MAGE    = {0.41, 0.80, 0.94},
    WARLOCK = {0.58, 0.51, 0.79},
    DRUID   = {1.00, 0.49, 0.04},
}

local ROW_COUNT  = 11
local ROW_HEIGHT = 22

-- Suppress raw TBM protocol system messages from polluting player's chat frame
local origChatFrame_OnEvent = ChatFrame_OnEvent
ChatFrame_OnEvent = function(event)
    if event == "CHAT_MSG_SYSTEM" and arg1 and string.find(arg1, "^TBM:") then
        return
    end
    if type(origChatFrame_OnEvent) == "function" then
        return origChatFrame_OnEvent(event)
    end
end

--=========================================================================--
--  Helpers
--=========================================================================--

-- Strip colour codes and texture escapes so patterns see plain text.
local function CleanChat(msg)
    msg = string.gsub(msg, "|c%x%x%x%x%x%x%x%x", "")
    msg = string.gsub(msg, "|r", "")
    msg = string.gsub(msg, "|H.-|h", "")
    msg = string.gsub(msg, "|h", "")
    return msg
end

local CLASS_ID_TO_TOKEN = {
    [1]  = "WARRIOR",
    [2]  = "PALADIN",
    [3]  = "HUNTER",
    [4]  = "ROGUE",
    [5]  = "PRIEST",
    [7]  = "SHAMAN",
    [8]  = "MAGE",
    [9]  = "WARLOCK",
    [11] = "DRUID",
}

-- Validates whether a character name is legitimate, filtering out "Unknown", "-", etc.
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
IsValidCharacterName = IsValidCharacterName

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

-- Checks whether a character name is currently in the player's party or raid.
-- If no name is passed, returns whether the player is currently in any group.
local function IsInGroup(selfOrName, maybeName)
    local name = maybeName or selfOrName
    if name == UnBot and maybeName == nil then
        name = nil
    end

    -- If no target name is given, return whether player is in any group (party or raid)
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
IsInGroup = IsInGroup

-- Helper to perform native client party invitation (CMSG_GROUP_INVITE)
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
    return false
end
UnBot.NativeInvite = NativeInvite
setglobal("NativeInvite", NativeInvite)
NativeInvite = NativeInvite

-- Helper to perform native client party uninvitation (CMSG_GROUP_UNINVITE)
local function NativeUninvite(selfOrName, maybeName)
    local name = maybeName or selfOrName
    if name == UnBot and maybeName == nil then return false end
    if not name or name == "" or type(name) ~= "string" then return false end
    if type(UninviteByName) == "function" then
        UninviteByName(name)
        return true
    elseif type(UninviteUnit) == "function" then
        UninviteUnit(name)
        return true
    end
    return false
end
UnBot.NativeUninvite = NativeUninvite
setglobal("NativeUninvite", NativeUninvite)
NativeUninvite = NativeUninvite

--=========================================================================--
--  Data
--=========================================================================--

function UnBot:InitRoster()
    -- without a seed math.random returns the same sequence every session
    math.randomseed(time())

    if self.config.roster == nil then self.config.roster = {} end
    self:SanitizeRoster()
    self.rosterFilter = "ALL"
    self.rosterSearchQuery = nil
    self.rosterOffset = 0
    self.rosterSelection = {}
    self:RecordCurrentCharacter()
    self:ScanGroupBots()
    self:InitRosterEvents()
end

--=========================================================================--
--  Server roster
--
--  TortoiseBots answers ".bot roster" with structured TBM lines:
--      TBM:ROSTER_BEGIN|<count>
--      TBM:ROSTER|<counter>|<name>|<classId>|<state>|<grouped>|<location>
--      TBM:ROSTER_END
--      TBM:ALTBOTS|<names>
--  Legacy mangosbot answers ".bot list" with:
--      Bot roster: -Andorian Druid, +Dezwo Warrior, ...
--=========================================================================--

local ROSTER_EVENTS = {
    "CHAT_MSG_SYSTEM", "CHAT_MSG_WHISPER", "CHAT_MSG_SAY", "CHAT_MSG_PARTY",
    "CHAT_MSG_YELL", "CHAT_MSG_RAID", "CHAT_MSG_MONSTER_WHISPER",
    "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_CHANNEL", "CHAT_MSG_EMOTE", "CHAT_MSG_ADDON",
    "PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE", "PLAYER_TARGET_CHANGED",
}

function UnBot:InitRosterEvents()
    local f = CreateFrame("Frame", "UnBotRosterEvents")
    for i = 1, table.getn(ROSTER_EVENTS) do
        f:RegisterEvent(ROSTER_EVENTS[i])
    end
    f:SetScript("OnEvent", function()
        if event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
            if UnBot.pendingInvites then
                for pendingName, _ in pairs(UnBot.pendingInvites) do
                    if IsInGroup(pendingName) then
                        UnBot.pendingInvites[pendingName] = nil
                    end
                end
            end
            UnBot:ScanGroupBots()
            UnBot:RefreshRoster()
            return
        elseif event == "PLAYER_TARGET_CHANGED" then
            if UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") then
                UnBot:ScanGroupBots()
                UnBot:RefreshRoster()
            end
            return
        end

        if UnBot.debug and arg1 then
            DEFAULT_CHAT_FRAME:AddMessage("|cff888888[UnBot "..tostring(event).."] "
                                          ..tostring(arg1).."|r")
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


-- Automatically scans current party, raid, and friendly target to register live bots
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

    return found
end

-- Adds a character to the roster with name normalization
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
    if entry.online == nil then entry.online = false end
    entry.grouped = IsInGroup(name)
    self.config.roster[name] = entry

    self:Message("Added bot '"..name.."' ("..entry.class..") to player roster")
    self:RefreshRoster()
    return name
end

-- Quick action: add current target to roster
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
    -- 1. Scan local party/raid and friendly target immediately
    self:ScanGroupBots()

    -- 2. Pull authoritative account alts via .bot roster (TBM protocol)
    SendChatMessage(".bot roster", "SAY")

    -- 3. Also pull online bot instances in world via .bot list
    SendChatMessage(".bot list", "SAY")

    if feedback then
        self:Message("Syncing roster with server and group...")
    end
    self:RefreshRoster()
end

function UnBot:ParseServerRoster(msg)
    if not msg then return end
    msg = CleanChat(msg)

    -- Protocol 1: Modern TortoiseBots TBM:ROSTER protocol
    if string.find(msg, "^TBM:ROSTER_BEGIN") then
        self.tbmRosterCount = 0
        return
    end

    if string.find(msg, "^TBM:ROSTER|") then
        -- Format: TBM:ROSTER|<guidCounter>|<name>|<classId>|<state>|<grouped>|<location>
        local _, _, counter, name, classId, state, grouped, location =
            string.find(msg, "^TBM:ROSTER|(%d+)|([^|]+)|(%d+)|([^|]+)|(%d+)|?(.*)")
        if name and classId and IsValidCharacterName(name) then
            local record = self.config.roster[name] or {}
            local cid = tonumber(classId) or 1
            record.class    = CLASS_ID_TO_TOKEN[cid] or record.class or "WARRIOR"
            record.online   = (state ~= "offline")
            record.level    = record.level or 0
            record.grouped  = (tonumber(grouped) == 1) or IsInGroup(name)
            record.location = location or ""
            self.config.roster[name] = record
            self.tbmRosterCount = (self.tbmRosterCount or 0) + 1

            if state == "online" and self.pendingInvites and self.pendingInvites[name] and not record.grouped then
                self:InviteBot(name)
            end
        end
        return
    end

    if string.find(msg, "^TBM:ROSTER_END") then
        self:RefreshRoster()
        return
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
        return
    end

    -- Protocol 2: TortoiseBots .bot list output
    -- Format: "<name>: in world, random <0|1>, AI <0|1>"
    local _, _, botName, botWorldState = string.find(msg, "^([%a%d_]+):%s*([%a%s]+),%s*random")
    if botName and IsValidCharacterName(botName) then
        local inWorld = (botWorldState == "in world")
        local record = self.config.roster[botName] or {}
        record.online = (inWorld or botWorldState == "starting")
        record.class  = record.class or "WARRIOR"
        record.level  = record.level or 0
        record.grouped = IsInGroup(botName)
        self.config.roster[botName] = record
        if inWorld and self.pendingInvites and self.pendingInvites[botName] and not record.grouped then
            self:InviteBot(botName)
        end
        self:RefreshRoster()
        return
    end

    -- Protocol 3: TortoiseBots .bot add feedback
    -- Format: "Bot <name> queued for login; it will follow <player>..."
    local _, _, addedBot = string.find(msg, "^Bot%s+([%a%d_]+)%s+queued for login")
    if addedBot and IsValidCharacterName(addedBot) then
        local record = self.config.roster[addedBot] or {}
        record.online = true
        record.class  = record.class or "WARRIOR"
        record.grouped = IsInGroup(addedBot)
        self.config.roster[addedBot] = record
        self:RefreshRoster()
        return
    end

    -- Protocol 4: Fallback for legacy .bot list responses
    local _, _, list = string.find(msg, "[Bb]ot roster:%s*(.+)")
    if list then
        local iter = string.gmatch or string.gfind
        local found = 0

        for entry in iter(list, "[^,]+") do
            -- each entry looks like " -Andorian Druid"
            local _, _, status, name, class = string.find(entry, "([%+%-]?)%s*([%a%d_]+)%s+([%a%d_]+)")
            if name and class and IsValidCharacterName(name) then
                local record = self.config.roster[name] or {}
                record.class  = string.upper(class)
                record.online = (status == "+")
                record.level  = record.level or 0
                record.grouped = IsInGroup(name)
                self.config.roster[name] = record
                found = found + 1
            end
        end

        if found > 0 then
            self:RefreshRoster()
        end
        return
    end
end

-- Called on login so the roster grows by itself.
function UnBot:RecordCurrentCharacter()
    local name = UnitName("player")
    if not IsValidCharacterName(name) then return end

    local locClass, token = UnitClass("player")
    if not token then token = string.upper(locClass or "") end

    self:SanitizeRoster()

    local entry = self.config.roster[name] or {}
    entry.class = token
    entry.level = UnitLevel("player")
    entry.self  = true            -- seen logged in, so definitely ours
    self.config.roster[name] = entry
end

function UnBot:RemoveRosterCharacter(name)
    if self.config.roster[name] then
        self.config.roster[name] = nil
        self:Message("Removed "..name.." from the roster")
    end
end

-- Names matching the active class filter and search query, alphabetically.
function UnBot:GetFilteredRoster()
    self:SanitizeRoster()
    local out = {}
    local query = self.rosterSearchQuery
    for name, data in pairs(self.config.roster) do
        if IsValidCharacterName(name) then
            local matchesClass = (self.rosterFilter == "ALL" or data.class == self.rosterFilter)
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

--=========================================================================--
--  Window
--=========================================================================--

function UnBot:ToggleRoster()
    if not UnBotRosterFrame then self:CreateRosterFrame() end
    if UnBotRosterFrame:IsShown() then
        UnBotRosterFrame:Hide()
    else
        UnBotRosterFrame:Show()
        self:ScanGroupBots()
        self:RefreshRoster()
    end
end

function UnBot:CreateRosterFrame()
    local f = CreateFrame("Frame", "UnBotRosterFrame", UIParent)
    f:SetWidth(430)
    f:SetHeight(400)
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
    f:SetScript("OnMouseWheel", function()
        UnBot:ScrollRoster(-arg1)
    end)
    f:Hide()

    -- Closing with Escape
    if UISpecialFrames then
        table.insert(UISpecialFrames, "UnBotRosterFrame")
    end

    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont(UnBotFont, 15)
    title:SetPoint("TOP", f, "TOP", 0, -14)
    title:SetTextColor(1, 0.82, 0)
    title:SetText("Player roster")

    local close = CreateFrame("Button", "UnBotRosterClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    self:CreateRosterSearchBar(f)
    self:CreateClassFilters(f)
    self:CreateRosterRows(f)
    self:CreateBulkButtons(f)
end

function UnBot:CreateRosterSearchBar(parent)
    local search = CreateFrame("EditBox", "UnBotRosterSearch", parent)
    search:SetWidth(276)
    search:SetHeight(22)
    search:SetPoint("TOPLEFT", parent, "TOPLEFT", 126, -38)
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
    clearBtn:SetWidth(16)
    clearBtn:SetHeight(16)
    clearBtn:SetPoint("RIGHT", search, "RIGHT", -4, 0)
    clearBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    clearBtn:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight")
    clearBtn:SetScript("OnClick", function()
        search:SetText("")
        search:ClearFocus()
    end)

    search:SetScript("OnTextChanged", function()
        local text = this:GetText() or ""
        text = string.gsub(text, "^%s+", "")
        text = string.gsub(text, "%s+$", "")
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

    search:SetScript("OnEscapePressed", function()
        this:SetText("")
        this:ClearFocus()
    end)
    search:SetScript("OnEnterPressed", function()
        local text = this:GetText() or ""
        text = string.gsub(text, "^%s+", "")
        text = string.gsub(text, "%s+$", "")
        if text ~= "" then
            local normName = string.upper(string.sub(text, 1, 1)) .. string.lower(string.sub(text, 2))
            if IsValidCharacterName(normName) and not UnBot.config.roster[normName] then
                UnBot:AddRosterCharacter(normName)
                this:SetText("")
            end
        end
        this:ClearFocus()
    end)

    self.rosterSearchBox = search
end

function UnBot:CreateBulkButtons(parent)
    local function MakeButton(name, label, x, y, width, handler, tooltip)
        local btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
        btn:SetWidth(width)
        btn:SetHeight(22)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        btn:SetText(label)
        btn:SetScript("OnClick", handler)
        btn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_TOP")
            GameTooltip:AddLine(label, 1, 0.82, 0)
            GameTooltip:AddLine(tooltip, 0.75, 0.75, 0.75, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return btn
    end

    -- Row 1: Group and raid filling & bulk management
    MakeButton("UnBotRosterFillGroup", "Fill group", 18, -324, 94, function()
        UnBot:FillWith(5)
    end, "Brings offline bots online and immediately invites filtered characters to fill remaining 5-man party slots.")

    MakeButton("UnBotRosterFillRaid", "Fill raid", 116, -324, 94, function()
        UnBot:FillWith(40)
    end, "Converts to raid if needed, bringing bots online and inviting filtered characters up to 40 slots.")

    MakeButton("UnBotRosterUnloadAll", "Log out filtered", 214, -324, 96, function()
        UnBot:BulkBotCommand("remove")
    end, "Logs out every roster character matching the active class and search filter.")

    MakeButton("UnBotRosterAddFriends", "Add friends", 314, -324, 96, function()
        UnBot:RunCommand(88)
    end, "Adds your current party or raid members to the friends list.")

    -- Row 2: Selected actions and quick refresh
    MakeButton("UnBotRosterRemoveSelected", "Remove selected", 18, -354, 118, function()
        UnBot:RemoveSelectedFromGroup()
    end, "Uninvites checked bots from your group via .bot uninvite without logging them out.")

    MakeButton("UnBotRosterLogoutSelected", "Log out selected", 140, -354, 118, function()
        UnBot:LogoutSelectedBots()
    end, "Logs out checked bots via .bot remove.")

    MakeButton("UnBotRosterClearSelection", "Clear select", 262, -354, 90, function()
        UnBot:ClearRosterSelection()
    end, "Clears all checked roster boxes.")

    MakeButton("UnBotRosterRefreshBtn", "Sync", 356, -354, 54, function()
        UnBot:RequestServerRoster()
    end, "Requests live roster and online status from the server via .bot roster.")
end

local LOGIN_GRACE       = 2.5

-- Automatic server roster sync has been disabled to prevent server and chat spam.
-- Roster synchronization with the server (.bot roster / .bot list) is now only
-- performed manually (via the "Sync" button in the roster window or '/wb sync').
function UnBot:QueueRosterStatusSync()
    self:ScanGroupBots()
    self:RefreshRoster()
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

-- Uninvites selected bots from group using modern TortoiseBots .bot uninvite and native uninvite
function UnBot:RemoveSelectedFromGroup()
    local names = self:GetSelectedRosterNames()
    if table.getn(names) == 0 then
        self:Message("No bots selected (check boxes next to characters)")
        return
    end

    local queued = 0
    for i = 1, table.getn(names) do
        local name = names[i]
        if IsInGroup(name) then
            NativeUninvite(name)
            self:QueueChat(".bot uninvite "..name, "SAY")
            if self.config.roster[name] then
                self.config.roster[name].grouped = false
            end
            queued = queued + 1
        end
    end
    self:ClearRosterSelection()
    self:ScanGroupBots()
    self:RefreshRoster()

    if queued == 0 then
        self:Message("None of the selected bots are in your current group")
    else
        self:Message("Uninviting "..queued.." selected bot(s) from group")
    end
end

function UnBot:LogoutSelectedBots()
    local names = self:GetSelectedRosterNames()
    if table.getn(names) == 0 then
        self:Message("No bots selected (check boxes next to characters)")
        return
    end
    for i = 1, table.getn(names) do
        local name = names[i]
        if IsInGroup(name) then
            NativeUninvite(name)
        end
        self:QueueChat(".bot remove "..name, "SAY")
        if self.config.roster[name] then
            self.config.roster[name].online = false
            self.config.roster[name].grouped = false
        end
    end
    self:ClearRosterSelection()
    self:RefreshRoster()
    self:Message("Logging out "..table.getn(names).." selected bot(s)")
end

UnBot.pendingInvites = UnBot.pendingInvites or {}

function UnBot:StartPendingInvite(name)
    if not name or name == "" then return end
    self.pendingInvites[name] = {
        startTime = GetTime(),
        attempts = 0,
        maxAttempts = 5,
        nextAttempt = GetTime() + 1.8,
    }
end

function UnBot:CheckPendingInvites()
    local now = GetTime()
    for name, info in pairs(self.pendingInvites or {}) do
        if IsInGroup(name) then
            self.pendingInvites[name] = nil
        elseif now >= info.nextAttempt then
            info.attempts = info.attempts + 1
            self:InviteBot(name)
            if info.attempts >= info.maxAttempts or (now - info.startTime) > 10.0 then
                self.pendingInvites[name] = nil
            else
                info.nextAttempt = now + 2.0
            end
        end
    end
end

-- Invites bot to group via native client API and TortoiseBots .bot invite command
-- Automatically accepts invitation in the bot AI and joins group/raid
function UnBot:InviteBot(name)
    if not name or name == "" then return end
    if IsInGroup(name) then
        if self.debug then self:Message("skip "..name..": already in group") end
        return
    end

    -- If party has 4 members (leader + 4 = 5 total), convert to raid before inviting 6th
    if not UnitInRaid("player") and GetNumPartyMembers() >= 4 then
        if type(ConvertToRaid) == "function" then
            ConvertToRaid()
        end
    end

    -- 1. Native WoW client invite packet (CMSG_GROUP_INVITE)
    NativeInvite(name)

    -- 2. Native TortoiseBots server command (.bot invite <name>)
    -- Frees stale group, converts full party to raid, and triggers immediate AI acceptance
    SendChatMessage(".bot invite "..name, "SAY")
end

function UnBot:LoginAndInvite(name)
    if not name or name == "" then return end
    if IsInGroup(name) then
        TargetByName(name)
        self:Message(name.." is already in your group (targeted)")
        return
    end

    local data = self.config.roster[name]
    local isOnline = data and data.online

    if isOnline then
        -- Bot is already in world, invite immediately
        self:InviteBot(name)
        -- Start monitoring in case of race condition or slow accept
        self:StartPendingInvite(name)
    else
        -- Bot is offline: bring online via .bot add and track pending invite
        self:QueueChat(".bot add "..name, "SAY")
        if data then
            data.online = true
        end
        self:StartPendingInvite(name)
        self:RefreshRoster()
    end
end

-- How many bodies are in the group right now, counting yourself.
local function GroupSize()
    local raid = GetNumRaidMembers()
    if raid > 0 then return raid end
    return 1 + GetNumPartyMembers()
end

-- Log in and invite as many of the shown characters as will fit.
function UnBot:FillWith(maxSize)
    -- If filling raid, convert party to raid first so 6+ members can be invited
    if maxSize > 5 and not UnitInRaid("player") and GetNumPartyMembers() > 0 then
        if type(ConvertToRaid) == "function" then
            ConvertToRaid()
        end
    end

    local free = maxSize - GroupSize()
    local names = self:GetFilteredRoster()
    local me = UnitName("player")
    local myLower = (me and IsValidCharacterName(me)) and string.lower(me) or ""

    local reconnect = {}
    local onlineNotInGroup = {}
    local offlineNotInGroup = {}

    for i = 1, table.getn(names) do
        local name = names[i]
        if myLower == "" or string.lower(name) ~= myLower then
            local data = self.config.roster[name]
            local grouped = IsInGroup(name)
            local isOnline = data and data.online

            if grouped and not isOnline then
                table.insert(reconnect, name)
            elseif not grouped then
                if isOnline then
                    table.insert(onlineNotInGroup, name)
                else
                    table.insert(offlineNotInGroup, name)
                end
            end
        end
    end

    local function Shuffle(pool)
        for i = table.getn(pool), 2, -1 do
            local j = math.random(i)
            pool[i], pool[j] = pool[j], pool[i]
        end
    end
    Shuffle(onlineNotInGroup)
    Shuffle(offlineNotInGroup)

    local candidates = {}
    for i = 1, table.getn(onlineNotInGroup) do table.insert(candidates, onlineNotInGroup[i]) end
    for i = 1, table.getn(offlineNotInGroup) do table.insert(candidates, offlineNotInGroup[i]) end

    local picked = {}
    for i = 1, table.getn(candidates) do
        if i > free then break end
        table.insert(picked, candidates[i])
    end

    local totalToAdd = table.getn(reconnect) + table.getn(picked)
    if totalToAdd == 0 then
        if free <= 0 then
            self:Message("Group is already full ("..GroupSize().."/"..maxSize..")")
        else
            self:Message("No matching characters available to fill group")
        end
        return
    end

    -- Reconnect offline group bots
    for i = 1, table.getn(reconnect) do
        self:QueueChat(".bot add "..reconnect[i], "SAY")
    end

    -- For picked bots: invite immediately if online, or add then invite if offline
    for i = 1, table.getn(picked) do
        local name = picked[i]
        local data = self.config.roster[name]
        if data and data.online then
            self:InviteBot(name)
        else
            self:LoginAndInvite(name)
        end
    end

    self:RefreshRoster()
    local what = maxSize > 5 and "raid" or "party"
    self:Message("Filling "..what..": "..table.getn(picked).." new, "..table.getn(reconnect).." reconnecting")
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
            self:QueueChat(".bot "..cmd.." "..name, "SAY")
            queued = queued + 1
            if cmd == "remove" and self.config.roster[name] then
                self.config.roster[name].online = false
                self.config.roster[name].grouped = false
            end
        end
    end
    if queued > 0 then
        self:RefreshRoster()
        self:Message("Dispatched '.bot "..cmd.."' for "..queued.." character(s)")
    else
        self:Message("Nothing to log out")
    end
end

function UnBot:CreateClassFilters(parent)
    self.classButtons = {}

    local entries = { "ALL" }
    for i = 1, table.getn(CLASSES) do
        table.insert(entries, CLASSES[i])
    end

    for i = 1, table.getn(entries) do
        local class = entries[i]
        local btn = CreateFrame("Button", "UnBotClassFilter"..class, parent)
        btn:SetWidth(96)
        btn:SetHeight(22)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 18, -38 - (i - 1) * 24)
        btn.class = class

        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(btn)
        bg:SetTexture(1, 1, 1, 0.12)
        bg:Hide()
        btn.selected = bg

        local text = btn:CreateFontString(nil, "OVERLAY")
        text:SetFont(UnBotFont, 12)
        text:SetPoint("LEFT", btn, "LEFT", 6, 0)
        if class == "ALL" then
            text:SetText("All classes")
            text:SetTextColor(1, 0.82, 0)
        else
            local c = CLASS_COLOR[class]
            text:SetText(string.upper(string.sub(class, 1, 1))..string.lower(string.sub(class, 2)))
            text:SetTextColor(c[1], c[2], c[3])
        end

        btn:SetScript("OnClick", function()
            UnBot.rosterFilter = this.class
            UnBot.rosterOffset = 0
            UnBot:RefreshRoster()
        end)

        self.classButtons[class] = btn
    end

    local addTargetBtn = CreateFrame("Button", "UnBotRosterAddTargetBtn", parent, "UIPanelButtonTemplate")
    addTargetBtn:SetWidth(96)
    addTargetBtn:SetHeight(22)
    addTargetBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 18, -282)
    addTargetBtn:SetText("+ Target")
    addTargetBtn:SetScript("OnClick", function()
        UnBot:AddTargetToRoster()
    end)
    addTargetBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:AddLine("+ Target", 1, 0.82, 0)
        GameTooltip:AddLine("Add your currently selected friendly player or bot directly to the roster.", 0.75, 0.75, 0.75, 1)
        GameTooltip:Show()
    end)
    addTargetBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function UnBot:CreateRosterRows(parent)
    self.rosterRows = {}

    for i = 1, ROW_COUNT do
        local row = CreateFrame("Button", "UnBotRosterRow"..i, parent)
        row:SetWidth(276)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 126, -66 - (i - 1) * ROW_HEIGHT)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        local check = CreateFrame("CheckButton", "UnBotRosterSelect"..i, row,
                                  "UICheckButtonTemplate")
        check:SetWidth(18)
        check:SetHeight(18)
        check:SetPoint("LEFT", row, "LEFT", 0, 0)
        check:SetScript("OnClick", function()
            local owner = this:GetParent()
            if not owner.charName or not IsValidCharacterName(owner.charName) then return end
            local me = UnitName("player")
            if me and string.lower(owner.charName) == string.lower(me) then return end
            UnBot.rosterSelection[owner.charName] = this:GetChecked() and true or nil
        end)
        row.selectCheck = check

        local name = row:CreateFontString(nil, "OVERLAY")
        name:SetFont(UnBotFont, 12)
        name:SetPoint("LEFT", row, "LEFT", 22, 0)
        row.nameText = name

        local level = row:CreateFontString(nil, "OVERLAY")
        level:SetFont(UnBotFont, 11)
        level:SetPoint("RIGHT", row, "RIGHT", -8, 0)
        level:SetTextColor(0.7, 0.7, 0.7)
        row.levelText = level

        row:SetScript("OnClick", function()
            if this.isAddButton and this.charName then
                if IsValidCharacterName(this.charName) then
                    UnBot:AddRosterCharacter(this.charName)
                    if UnBot.rosterSearchBox then
                        UnBot.rosterSearchBox:SetText("")
                    end
                    UnBot.rosterSearchQuery = nil
                    UnBot:RefreshRoster()
                end
                return
            end
            if not this.charName or not IsValidCharacterName(this.charName) then return end
            local me = UnitName("player")
            if me and string.lower(this.charName) == string.lower(me) then
                UnBot:Message("That one is you - you are already in the world")
                return
            end
            if arg1 == "RightButton" then
                if IsShiftKeyDown() then
                    UnBot:RemoveRosterCharacter(this.charName)
                    UnBot:RefreshRoster()
                    return
                end
                if IsInGroup(this.charName) then
                    NativeUninvite(this.charName)
                    UnBot:QueueChat(".bot uninvite "..this.charName, "SAY")
                    if UnBot.config.roster[this.charName] then
                        UnBot.config.roster[this.charName].grouped = false
                    end
                    UnBot:RefreshRoster()
                    UnBot:Message("Removing "..this.charName.." from group")
                else
                    UnBot:QueueChat(".bot remove "..this.charName, "SAY")
                    if UnBot.config.roster[this.charName] then
                        UnBot.config.roster[this.charName].online = false
                        UnBot.config.roster[this.charName].grouped = false
                    end
                    UnBot:RefreshRoster()
                    UnBot:Message("Logging out "..this.charName)
                end
            elseif IsShiftKeyDown() then
                UnBot:QueueChat(".bot add "..this.charName, "SAY")
                if UnBot.config.roster[this.charName] then
                    UnBot.config.roster[this.charName].online = true
                end
                UnBot:RefreshRoster()
                UnBot:Message("Logging in "..this.charName.." without inviting")
            else
                if IsInGroup(this.charName) then
                    TargetByName(this.charName)
                    UnBot:Message(this.charName.." is already in your group (targeted)")
                else
                    UnBot:LoginAndInvite(this.charName)
                    UnBot:Message("Inviting "..this.charName)
                end
            end
        end)

        row:SetScript("OnEnter", function()
            if this.isAddButton and this.charName then
                if not IsValidCharacterName(this.charName) then return end
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine("+ Add "..this.charName, 0.3, 1, 0.3)
                GameTooltip:AddLine("Click or press Enter to add '"..this.charName.."' to your roster.", 0.8, 0.8, 0.8, 1)
                GameTooltip:Show()
                return
            end
            if not this.charName or not IsValidCharacterName(this.charName) then return end
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:AddLine(this.charName, 1, 0.82, 0)
            local data = UnBot.config.roster[this.charName] or {}
            if data and data.class then
                local c = CLASS_COLOR[data.class] or {1, 1, 1}
                GameTooltip:AddLine(data.class, c[1], c[2], c[3])
            end
            GameTooltip:AddLine("Checkbox: select for bulk actions", 0.65, 0.75, 1)
            GameTooltip:AddLine("Left-click: invite / bring into party", 0.3, 1, 0.3)
            GameTooltip:AddLine("Right-click: remove from group / log out", 1, 0.5, 0.3)
            GameTooltip:AddLine("Shift+left-click: log in only (stay solo)", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Shift+right-click: drop from roster list", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:Hide()
        self.rosterRows[i] = row
    end
end

--=========================================================================--
--  Refresh
--=========================================================================--

function UnBot:ScrollRoster(delta)
    local total = table.getn(self:GetFilteredRoster())
    local maxOffset = total - ROW_COUNT
    if maxOffset < 0 then maxOffset = 0 end

    self.rosterOffset = self.rosterOffset + delta
    if self.rosterOffset < 0 then self.rosterOffset = 0 end
    if self.rosterOffset > maxOffset then self.rosterOffset = maxOffset end
    self:RefreshRoster()
end

function UnBot:RefreshRoster()
    if not UnBotRosterFrame then return end

    for class, btn in pairs(self.classButtons) do
        if class == self.rosterFilter then
            btn.selected:Show()
        else
            btn.selected:Hide()
        end
    end

    local names = self:GetFilteredRoster()
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
            local c = CLASS_COLOR[data.class] or {1, 1, 1}
            local grouped = IsInGroup(name)
            row.charName = name
            row.nameText:SetTextColor(c[1], c[2], c[3])

            local isMe = (myLower ~= "" and string.lower(name) == myLower)
            if isMe then
                row.selectCheck:SetChecked(nil)
                row.selectCheck:Hide()
                row.nameText:SetText(name.."  (you)")
                row.levelText:SetText("in world")
                row.levelText:SetTextColor(0.4, 0.8, 1)
            else
                row.selectCheck:SetChecked(self.rosterSelection[name] and 1 or nil)
                row.selectCheck:Show()
                row.nameText:SetText(name)
                if grouped then
                    row.levelText:SetText("in group")
                    row.levelText:SetTextColor(0.2, 0.9, 0.9)
                elseif data.online then
                    row.levelText:SetText("online")
                    row.levelText:SetTextColor(0.3, 1, 0.3)
                elseif data.online == false then
                    row.levelText:SetText("offline")
                    row.levelText:SetTextColor(0.6, 0.6, 0.6)
                elseif data.level and data.level > 0 then
                    row.levelText:SetText("level "..data.level)
                    row.levelText:SetTextColor(0.7, 0.7, 0.7)
                else
                    row.levelText:SetText("")
                end
            end
            row:Show()
        elseif showAddRow and i == 1 then
            local normName = string.upper(string.sub(searchQ, 1, 1)) .. string.lower(string.sub(searchQ, 2))
            row.charName = normName
            row.isAddButton = true
            row.selectCheck:SetChecked(nil)
            row.selectCheck:Hide()
            row.nameText:SetTextColor(0.3, 1.0, 0.3)
            row.nameText:SetText("+ Add \""..normName.."\"")
            row.levelText:SetTextColor(0.7, 0.7, 0.7)
            row.levelText:SetText("(Click or Enter)")
            row:Show()
        else
            row.isAddButton = nil
            row.charName = nil
            row.selectCheck:SetChecked(nil)
            row.selectCheck:Hide()
            row:Hide()
        end
    end
end
