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

local ROW_COUNT  = 12
local ROW_HEIGHT = 22

--=========================================================================--
--  Data
--=========================================================================--

function UnBot:InitRoster()
    -- without a seed math.random returns the same sequence every session
    math.randomseed(time())

    if self.config.roster == nil then self.config.roster = {} end
    self.rosterFilter = "ALL"
    self.rosterOffset = 0
    self.rosterSelection = {}
    self:RecordCurrentCharacter()
    self:InitRosterEvents()
end

--=========================================================================--
--  Server roster
--
--  mangosbot answers ".bot list" (and volunteers it after ".bot add") with
--      Bot roster: -Andorian Druid, +Dezwo Warrior, ...
--  where "-" is logged out and "+" is logged in. Reading that line gives us
--  the whole account roster with classes, so nothing has to be typed in.
--=========================================================================--

local ROSTER_EVENTS = {
    "CHAT_MSG_SYSTEM", "CHAT_MSG_WHISPER", "CHAT_MSG_SAY", "CHAT_MSG_PARTY",
    "CHAT_MSG_YELL", "CHAT_MSG_RAID", "CHAT_MSG_MONSTER_WHISPER",
    "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_CHANNEL", "CHAT_MSG_EMOTE",
}

function UnBot:InitRosterEvents()
    local f = CreateFrame("Frame", "UnBotRosterEvents")
    for i = 1, table.getn(ROSTER_EVENTS) do
        f:RegisterEvent(ROSTER_EVENTS[i])
    end
    f:SetScript("OnEvent", function()
        if UnBot.debug and arg1 then
            DEFAULT_CHAT_FRAME:AddMessage("|cff888888[UnBot "..tostring(event).."] "
                                          ..tostring(arg1).."|r")
        end
        UnBot:ParseServerRoster(arg1)
    end)
end

-- Strip colour codes and texture escapes so patterns see plain text.
local function CleanChat(msg)
    msg = string.gsub(msg, "|c%x%x%x%x%x%x%x%x", "")
    msg = string.gsub(msg, "|r", "")
    msg = string.gsub(msg, "|H.-|h", "")
    msg = string.gsub(msg, "|h", "")
    return msg
end

function UnBot:RequestServerRoster()
    SendChatMessage(".bot list", "SAY")
end

function UnBot:ParseServerRoster(msg)
    if not msg then return end
    msg = CleanChat(msg)

    local _, _, list = string.find(msg, "[Bb]ot roster:%s*(.+)")
    if not list then return end

    local iter = string.gmatch or string.gfind
    local found = 0

    for entry in iter(list, "[^,]+") do
        -- each entry looks like " -Andorian Druid"
        local _, _, status, name, class = string.find(entry, "([%+%-]?)%s*(%a+)%s+(%a+)")
        if name and class then
            local record = self.config.roster[name] or {}
            record.class  = string.upper(class)
            record.online = (status == "+")
            record.level  = record.level or 0
            self.config.roster[name] = record
            found = found + 1
        end
    end

    if found > 0 then
        self:Message("Roster updated from server: "..found.." character(s)")
        self:RefreshRoster()
    end
end

-- Called on login so the roster grows by itself.
function UnBot:RecordCurrentCharacter()
    local name = UnitName("player")
    if not name then return end

    local locClass, token = UnitClass("player")
    if not token then token = string.upper(locClass or "") end

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

-- Names matching the active class filter, alphabetically.
function UnBot:GetFilteredRoster()
    local out = {}
    for name, data in pairs(self.config.roster) do
        if self.rosterFilter == "ALL" or data.class == self.rosterFilter then
            table.insert(out, name)
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
        self:RefreshRoster()
        self:RequestServerRoster()   -- pull the authoritative list
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
    title:SetPoint("TOP", f, "TOP", 0, -16)
    title:SetTextColor(1, 0.82, 0)
    title:SetText("Player roster")

    local close = CreateFrame("Button", "UnBotRosterClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    self:CreateClassFilters(f)
    self:CreateRosterRows(f)
    self:CreateBulkButtons(f)
end

-- ".bot add *" only covers characters already in your group, so loading a
-- whole roster means one command per name, spaced out by the chat queue.
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

    MakeButton("UnBotRosterFillGroup", "Fill group", 18, -312, 94, function()
        UnBot:FillWith(5)
    end, "Reconnects offline group bots, then fills free party slots from the selected class filter.")

    MakeButton("UnBotRosterFillRaid", "Fill raid", 116, -312, 94, function()
        UnBot:FillWith(40)
    end, "Reconnects offline group bots, then fills free raid slots from the selected class filter.")

    MakeButton("UnBotRosterUnloadAll", "Log out filtered", 214, -312, 94, function()
        UnBot:BulkBotCommand("remove")
    end, "Logs out every roster character matching the selected class filter, including scrolled-off rows.")

    MakeButton("UnBotRosterAddFriends", "Add friends", 312, -312, 94, function()
        UnBot:RunCommand(88)
    end, "Adds your current party or raid members to the friends list. This ignores the class filter.")

    MakeButton("UnBotRosterRemoveSelected", "Remove selected", 18, -342, 126, function()
        UnBot:RemoveSelectedFromGroup()
    end, "Removes checked bots from your current party or raid without logging them out.")

    MakeButton("UnBotRosterLogoutSelected", "Log out selected", 152, -342, 126, function()
        UnBot:LogoutSelectedBots()
    end, "Logs out the checked bots. Their roster status updates automatically.")

    MakeButton("UnBotRosterClearSelection", "Clear selection", 286, -342, 120, function()
        UnBot:ClearRosterSelection()
    end, "Clears every roster checkbox, including checked names hidden by the class filter.")
end

-- ".bot add" only logs the character in; joining the group is a separate
-- invite, and it has to wait until the bot is actually in the world.
-- Time between ".bot add" and the invite. The server reports the character as
-- logged in well before it can accept an invite, so this is generous and a
-- second pass mops up anyone who was still not ready.
local LOGIN_GRACE      = 4
local RETRY_GAP        = 3
local STATUS_SYNC_DELAY = 1

-- Ask for authoritative status shortly after queued add/remove commands. This
-- keeps an open roster current without making the user press Refresh.
function UnBot:QueueRosterStatusSync()
    self:QueueWait(STATUS_SYNC_DELAY)
    self:QueueAction(function() UnBot:RequestServerRoster() end)
end

-- UnitInParty/UnitInRaid take a unit id. On 1.12, passing a name that is not
-- a nearby unit raises "Unknown unit name" instead of returning nil, so group
-- membership has to be checked by walking the slots.
local function IsInGroup(name)
    if name == UnitName("player") then return true end

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

-- Vanilla exposes InviteByName; TBC and later renamed it to InviteUnit.
local function RemoveFromGroup(name)
    if type(UninviteByName) == "function" then
        UninviteByName(name)
        return true
    elseif type(UninviteUnit) == "function" then
        UninviteUnit(name)
        return true
    end
    return false
end

function UnBot:GetSelectedRosterNames()
    local names = {}
    for name, selected in pairs(self.rosterSelection or {}) do
        if selected and self.config.roster[name] and name ~= UnitName("player") then
            table.insert(names, name)
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
    local removed = 0
    for i = 1, table.getn(names) do
        if IsInGroup(names[i]) and RemoveFromGroup(names[i]) then
            removed = removed + 1
        end
    end
    self:ClearRosterSelection()
    if removed == 0 then
        self:Message("None of the selected bots are in your group")
    else
        self:Message("Removing "..removed.." selected bot(s) from the group")
    end
end

function UnBot:LogoutSelectedBots()
    local names = self:GetSelectedRosterNames()
    if table.getn(names) == 0 then
        self:Message("No bots selected")
        return
    end
    for i = 1, table.getn(names) do
        self:QueueChat(".bot remove "..names[i], "SAY")
    end
    self:QueueRosterStatusSync()
    self:ClearRosterSelection()
    self:Message("Logging out "..table.getn(names).." selected bot(s)")
end

local function SendInvite(name)
    if type(InviteByName) == "function" then
        InviteByName(name)
        return true
    elseif type(InviteUnit) == "function" then
        InviteUnit(name)
        return true
    end
    return false
end

function UnBot:InviteBot(name)
    if IsInGroup(name) then
        if self.debug then self:Message("skip "..name..": already grouped") end
        return
    end

    -- A party caps at five, so make room before the fifth invite.
    if GetNumPartyMembers() == 4 and GetNumRaidMembers() == 0 then
        ConvertToRaid()
    end

    if not SendInvite(name) then
        self:Message("This client exposes no invite function - invite "..name.." manually")
        return
    end
    if self.debug then
        self:Message("InviteByName("..name..")")
    end
end

function UnBot:LoginAndInvite(name)
    self:QueueChat(".bot add "..name, "SAY")
    self:QueueRosterStatusSync()
    self:QueueWait(LOGIN_GRACE - STATUS_SYNC_DELAY)
    self:QueueAction(function() UnBot:InviteBot(name) end)
    -- InviteBot bails out if they already joined, so a retry is harmless
    self:QueueWait(RETRY_GAP)
    self:QueueAction(function() UnBot:InviteBot(name) end)
end

-- How many bodies are in the group right now, counting yourself.
local function GroupSize()
    local raid = GetNumRaidMembers()
    if raid > 0 then return raid end
    return 1 + GetNumPartyMembers()
end

-- Log in and invite as many of the shown characters as will fit.
-- maxSize 5 fills a party, 40 fills a raid; the conversion to raid happens
-- automatically in InviteBot once the party is full.
function UnBot:FillWith(maxSize)
    local free = maxSize - GroupSize()
    local names = self:GetFilteredRoster()
    local me = UnitName("player")

    -- A logged-out bot can still occupy a party slot. Reconnect those bots
    -- regardless of free space, then use genuinely free slots for new bots.
    local reconnect = {}
    local offline = {}
    local fallback = {}
    for i = 1, table.getn(names) do
        local name = names[i]
        if name ~= me then
            local data = self.config.roster[name]
            local grouped = IsInGroup(name)
            if grouped and data and data.online == false then
                table.insert(reconnect, name)
            elseif not grouped then
                if data and data.online == false then
                    table.insert(offline, name)
                else
                    table.insert(fallback, name)
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
    Shuffle(offline)
    Shuffle(fallback)

    local pool = {}
    for i = 1, table.getn(offline) do table.insert(pool, offline[i]) end
    for i = 1, table.getn(fallback) do table.insert(pool, fallback[i]) end

    local picked = {}
    for i = 1, table.getn(pool) do
        if i > free then break end
        table.insert(picked, pool[i])
    end

    local targets = {}
    for i = 1, table.getn(reconnect) do table.insert(targets, reconnect[i]) end
    for i = 1, table.getn(picked) do table.insert(targets, picked[i]) end

    local count = table.getn(targets)
    if self.debug then
        self:Message("fill: "..free.." free, "..table.getn(reconnect)
                     .." reconnecting, "..table.getn(picked).." picked")
    end
    if count == 0 then
        if free <= 0 then
            self:Message("Group is already full")
        else
            self:Message("No characters left to add from this list")
        end
        return
    end

    for i = 1, count do
        self:QueueChat(".bot add "..targets[i], "SAY")
    end
    self:QueueRosterStatusSync()
    self:QueueWait(LOGIN_GRACE - STATUS_SYNC_DELAY)
    for i = 1, count do
        local name = targets[i]
        self:QueueAction(function() UnBot:InviteBot(name) end)
    end

    -- second pass for anyone who was not ready yet
    self:QueueWait(RETRY_GAP)
    for i = 1, count do
        local name = targets[i]
        self:QueueAction(function() UnBot:InviteBot(name) end)
    end

    local what = "party"
    if maxSize > 5 then what = "raid" end
    self:Message("Filling "..what.." with "..count.." bot(s), about "
                 ..string.format("%.0f", count * 1.2 + LOGIN_GRACE + RETRY_GAP).."s")
end

function UnBot:BulkBotCommand(subcommand)
    local names = self:GetFilteredRoster()
    local count = table.getn(names)
    if count == 0 then
        self:Message("No characters in this list")
        return
    end

    local me = UnitName("player")

    if subcommand == "add" then
        -- log everyone in first, then invite them once they are in the world
        local queued = 0
        for i = 1, count do
            if names[i] ~= me then
                self:QueueChat(".bot add "..names[i], "SAY")
                queued = queued + 1
            end
        end
        if queued == 0 then
            self:Message("Nothing to log in")
            return
        end
        self:QueueRosterStatusSync()
        self:QueueWait(LOGIN_GRACE - STATUS_SYNC_DELAY)
        for i = 1, count do
            if names[i] ~= me then
                local name = names[i]
                self:QueueAction(function() UnBot:InviteBot(name) end)
            end
        end
        self:Message("Logging in and inviting "..queued.." character(s), about "
                     ..string.format("%.0f", queued * 0.8 + LOGIN_GRACE).."s")
    else
        local queued = 0
        for i = 1, count do
            if names[i] ~= me then
                self:QueueChat(".bot remove "..names[i], "SAY")
                queued = queued + 1
            end
        end
        if queued > 0 then self:QueueRosterStatusSync() end
        self:Message("Logging out "..queued.." character(s), about "
                     ..string.format("%.0f", queued * 0.4).."s")
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
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 18, -42 - (i - 1) * 24)
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
end

function UnBot:CreateRosterRows(parent)
    self.rosterRows = {}

    for i = 1, ROW_COUNT do
        local row = CreateFrame("Button", "UnBotRosterRow"..i, parent)
        row:SetWidth(276)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 126, -42 - (i - 1) * ROW_HEIGHT)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        local check = CreateFrame("CheckButton", "UnBotRosterSelect"..i, row,
                                  "UICheckButtonTemplate")
        check:SetWidth(18)
        check:SetHeight(18)
        check:SetPoint("LEFT", row, "LEFT", 0, 0)
        check:SetScript("OnClick", function()
            local owner = this:GetParent()
            if not owner.charName or owner.charName == UnitName("player") then return end
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
            if not this.charName then return end
            if this.charName == UnitName("player") then
                UnBot:Message("That one is you - you are already in the world")
                return
            end
            if arg1 == "RightButton" then
                if IsShiftKeyDown() then
                    UnBot:RemoveRosterCharacter(this.charName)
                    UnBot:RefreshRoster()
                    return
                end
                UnBot:QueueChat(".bot remove "..this.charName, "SAY")
                UnBot:QueueRosterStatusSync()
                UnBot:Message("Logging out "..this.charName)
            elseif IsShiftKeyDown() then
                UnBot:QueueChat(".bot add "..this.charName, "SAY")
                UnBot:QueueRosterStatusSync()
                UnBot:Message("Logging in "..this.charName.." without inviting")
            else
                UnBot:LoginAndInvite(this.charName)
                UnBot:Message("Logging in and inviting "..this.charName)
            end
        end)

        row:SetScript("OnEnter", function()
            if not this.charName then return end
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:AddLine(this.charName, 1, 0.82, 0)
            GameTooltip:AddLine("Checkbox: select for bulk remove or logout", 0.65, 0.75, 1)
            GameTooltip:AddLine("Left-click: log in and invite", 0.65, 0.55, 0)
            GameTooltip:AddLine("Shift+left-click: log in only", 0.65, 0.55, 0)
            GameTooltip:AddLine("Right-click: log out", 0.65, 0.55, 0)
            GameTooltip:AddLine("Shift+right-click: drop from this list", 0.6, 0.6, 0.6)
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
    for i = 1, ROW_COUNT do
        local row = self.rosterRows[i]
        local name = names[i + self.rosterOffset]

        if name then
            local data = self.config.roster[name]
            local c = CLASS_COLOR[data.class] or {1, 1, 1}
            row.charName = name
            row.nameText:SetTextColor(c[1], c[2], c[3])

            if name == UnitName("player") then
                row.selectCheck:SetChecked(nil)
                row.selectCheck:Hide()
                row.nameText:SetText(name.."  (you)")
                row.levelText:SetText("in world")
                row.levelText:SetTextColor(0.4, 0.8, 1)
            else
                row.selectCheck:SetChecked(self.rosterSelection[name] and 1 or nil)
                row.selectCheck:Show()
                row.nameText:SetText(name)
                if data.online then
                    row.levelText:SetText("logged in")
                    row.levelText:SetTextColor(0.3, 1, 0.3)
                elseif data.online == false then
                    row.levelText:SetText("logged out")
                    row.levelText:SetTextColor(0.6, 0.6, 0.6)
                elseif data.level and data.level > 0 then
                    row.levelText:SetText("level "..data.level)
                    row.levelText:SetTextColor(0.7, 0.7, 0.7)
                else
                    row.levelText:SetText("")
                end
            end
            row:Show()
        else
            row.charName = nil
            row.selectCheck:SetChecked(nil)
            row.selectCheck:Hide()
            row:Hide()
        end
    end
end
