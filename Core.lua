-- UnBot Core - Vanilla 1.12
-- 1.12 rules that shaped this file:
--   * script handlers receive no arguments; use globals `this`, `event`, `arg1`
--   * no `#` (use table.getn), no `%` (use math.mod), no `...` varargs

-- The addon is called Warband; the internal UnBot* names are kept from its
-- origin so the saved variables (and your roster) survive the rename.
UnBot = {}
UnBot.addonName = "Warband"
UnBot.version = "1.0"
UnBot.groupButtons = {}
UnBot.subButtons = {}
UnBot.handlers = {}

function UnBot:Message(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00cccc"..msg.."|r")
end

function UnBot:Init()
    if self.inited then return end
    self.inited = true

    if UnBotConfig == nil then UnBotConfig = {} end
    self.config = UnBotConfig
    self.capturing = self.config.capturing

    self:RegisterSlashCommands()

    -- Data.lua and IconsFilename.lua carry every command table. If a file was
    -- added to the .toc but the client has not been restarted, they are absent.
    if UnBotGroupDefault == nil or UnBotExecuteCommand == nil
       or UnBotCommandIcon == nil then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cffff0000UnBot: command data missing. Restart the game client "..
            "completely - /reload does not pick up newly added files.|r")
        return
    end

    self:InitRoster()
    self:InitItemEvents()
    self:InitSpellEvents()
    self:InitUI()
    self:Message(self.addonName.." "..self.version.." loaded. Use /warband")
end

function UnBot:RegisterSlashCommands()
    SLASH_UNBOT1 = "/warband"
    SLASH_UNBOT2 = "/wb"
    SLASH_UNBOT3 = "/unbot"        -- old name, kept so muscle memory still works
    SlashCmdList["UNBOT"] = function(msg)
        msg = string.lower(msg or "")
        -- some clients hand over a leading space, which would make every
        -- comparison below miss
        msg = string.gsub(msg, "^%s+", "")
        msg = string.gsub(msg, "%s+$", "")

        -- split off a first word so "ask actions" works
        local _, _, verb, rest = string.find(msg, "^(%S*)%s*(.*)$")
        if verb == nil then verb = msg end
        if rest == nil then rest = "" end
        if verb == "ask" then
            UnBot:AskBotHelp(rest)
            return
        elseif verb == "invite" then
            UnBot:TestInvite(rest)
            return
        elseif verb == "checkapi" then
            UnBot:CheckAPI()
            return
        elseif verb == "iteminfo" then
            UnBot:DumpItemInfo(rest)
            return
        elseif verb == "fill" or verb == "fillraid" then
            if type(UnBot.FillWith) ~= "function" then
                UnBot:Message("FillWith is missing - Roster.lua did not load. "..
                              "Restart the client completely.")
                return
            end
            if verb == "fill" then UnBot:FillWith(5) else UnBot:FillWith(40) end
            return
        end

        if msg == "roster" or msg == "bots" then
            UnBot:ToggleRoster()
        elseif msg == "strategy" or msg == "strat" then
            UnBot:ShowStrategyWindow()
        elseif msg == "spells" then
            UnBot:ShowSpellWindow()
        elseif msg == "bags" then
            UnBot:ShowItemWindow("view")
        elseif msg == "capture" then
            UnBot:ToggleCapture()
        elseif msg == "capture clear" then
            UnBot.config.capture = {}
            UnBot:Message("Capture log cleared")
        elseif msg == "debug" then
            UnBot.debug = not UnBot.debug
            if UnBot.debug then
                UnBot:Message("Debug on - chat messages will be echoed with their event name")
            else
                UnBot:Message("Debug off")
            end
        elseif msg == "help" then
            UnBot:Message("/warband - show or hide the command bar")
            UnBot:Message("Everything else has a button on the bar; these are")
            UnBot:Message("just shortcuts for the same windows:")
            UnBot:Message("  roster, strategy, spells, bags, fill, fillraid")
            UnBot:Message("Diagnostics: capture, debug, checkapi, ask all")
        else
            UnBot:ToggleUI()
        end
    end

    SLASH_UNBOTCOM1 = "/unbotcom"
    SLASH_UNBOTCOM2 = "/ubc"
    SlashCmdList["UNBOTCOM"] = function(msg)
        local index = tonumber(msg)
        if index then UnBot:RunCommand(index) end
    end
end

function UnBot:ToggleUI()
    if not UnBotFrame then return end
    if UnBotFrame:IsShown() then
        self:CloseAll()
    else
        UnBotFrame:Show()
    end
end

function UnBot:CloseAll()
    self:HideAllSubFrames()
    if UnBotFrame then UnBotFrame:Hide() end
    self:Message(UnBotL.MSG.CLOSE_BAR)
end

--=========================================================================--
--  Window positions
--
--  Every window is draggable, so remember where it was put. Frames anchor to
--  UIParent on restore, which is what StartMoving leaves them attached to.
--=========================================================================--

function UnBot:SaveFramePosition(frame)
    if not frame or not frame:GetName() then return end

    local point, _, relPoint, x, y = frame:GetPoint()
    if not point then return end

    if self.config.positions == nil then self.config.positions = {} end
    self.config.positions[frame:GetName()] = {
        point = point, relPoint = relPoint, x = x, y = y,
    }
end

function UnBot:RestoreFramePosition(frame)
    if not frame or not self.config.positions then return false end

    local pos = self.config.positions[frame:GetName()]
    if not pos then return false end

    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
    return true
end

-- Wire dragging plus position saving onto a frame in one go.
function UnBot:MakeDraggable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() this:StartMoving() end)
    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        UnBot:SaveFramePosition(this)
    end)
end

--=========================================================================--
--  Command lookup helpers
--=========================================================================--

function UnBot:GetIconPath(commandId)
    return UnBotCommandIcon[commandId] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function UnBot:GetTitle(commandId)
    return UnBotL.TITLE[commandId] or ("Command "..tostring(commandId))
end

-- A command is usable if it either has chat text or a special handler.
function UnBot:IsCommandDefined(commandId)
    if self.handlers[commandId] then return true end
    local text = UnBotExecuteCommand[commandId]
    return text ~= nil and text ~= ""
end

-- Register a special handler that replaces plain chat sending.
function UnBot:RegisterHandler(commandId, func)
    self.handlers[commandId] = func
end

--=========================================================================--
--  Target validation
--=========================================================================--

function UnBot:GetGroupedTarget()
    local name = UnitName("target")
    if not name or name == "" then
        self:Message(UnBotL.MSG.NO_TARGET)
        return nil
    end
    if not UnitInParty("target") and not UnitInRaid("target") then
        self:Message(UnBotL.MSG.NOT_IN_PARTY)
        return nil
    end
    return name
end

function UnBot:GetBotTarget()
    local name = self:GetGroupedTarget()
    if not name then return nil end
    if not UnitIsPlayer("target") then
        self:Message(UnBotL.MSG.NEED_PLAYER_BOT)
        return nil
    end
    return name
end

--=========================================================================--
--  Execution
--=========================================================================--

function UnBot:RunCommand(commandId)
    if commandId == nil then return end

    local handler = self.handlers[commandId]
    if handler then
        handler(commandId)
        return
    end

    local text = UnBotExecuteCommand[commandId]
    if text == nil or text == "" then
        self:Message(string.format(UnBotL.MSG.CMD_EMPTY, tostring(commandId)))
        return
    end

    local cmdType = UnBotCommandType[commandId]
    if cmdType == nil then
        self:Message(string.format(UnBotL.MSG.CMD_NOT_FOUND, tostring(commandId)))
        return
    end

    if cmdType == 1 then
        SendChatMessage(text, "SAY")

    elseif cmdType == 2 then
        local target = self:GetGroupedTarget()
        if not target then return end
        SendChatMessage(text, "WHISPER", nil, target)

    elseif cmdType == 3 then
        local name = UnitName("target")
        if not name or name == "" then
            self:Message(UnBotL.MSG.NO_TARGET)
            return
        end
        SendChatMessage(text, "PARTY")

    elseif cmdType == 4 then
        SendChatMessage(text, "PARTY")

    else
        self:Message(string.format(UnBotL.MSG.CMD_NOT_FOUND, tostring(commandId)))
    end
end

--=========================================================================--
--  Diagnostics
--
--  Vanilla, Turtle and later clients disagree about which group functions
--  exist, so report what this client actually has rather than assuming.
--=========================================================================--

function UnBot:CheckAPI()
    local names = {
        "InviteByName", "InviteUnit", "UninviteByName", "UninviteUnit",
        "ConvertToRaid", "AddFriend", "DoReadyCheck", "GetNumPartyMembers",
        "GetNumRaidMembers",
    }
    self:Message("Group API on this client:")
    for i = 1, table.getn(names) do
        local n = names[i]
        if type(getglobal(n)) == "function" then
            DEFAULT_CHAT_FRAME:AddMessage("|cff44ff44  "..n.." yes|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444  "..n.." MISSING|r")
        end
    end
end

-- Show everything GetItemInfo hands back on this client. Stock 1.12 returns
-- eight values and no texture, but modified clients sometimes add fields.
function UnBot:DumpItemInfo(arg)
    local id = tonumber(arg) or 3777    -- Lesser Healing Potion
    self:Message("GetItemInfo("..id..") returns:")

    local v = { GetItemInfo(id) }
    local n = table.getn(v)
    if n == 0 then
        self:Message("  nothing - the client has not cached this item")
        return
    end

    for i = 1, n do
        DEFAULT_CHAT_FRAME:AddMessage("|cff888888  ["..i.."] "..type(v[i])
                                      .." = "..tostring(v[i]).."|r")
    end
end

-- Invite someone straight away, no bot login and no delay, to separate an
-- invite problem from a timing problem.
function UnBot:TestInvite(name)
    if name == nil or name == "" then
        name = UnitName("target")
    end
    if not name or name == "" then
        self:Message("Usage: /unbot invite <name>, or target someone")
        return
    end

    -- restore the capitalisation the server expects
    name = string.upper(string.sub(name, 1, 1))..string.sub(name, 2)

    if type(InviteByName) == "function" then
        self:Message("InviteByName(\""..name.."\")")
        InviteByName(name)
    elseif type(InviteUnit) == "function" then
        self:Message("InviteUnit(\""..name.."\")")
        InviteUnit(name)
    else
        self:Message("No invite function exists on this client")
    end
end

--=========================================================================--
--  Whisper capture
--
--  The bots document themselves: whisper "help", then "actions", "strategies"
--  and so on. Those replies are long, so record them into SavedVariables and
--  read the file afterwards instead of squinting at the chat frame.
--=========================================================================--

function UnBot:ToggleCapture()
    -- kept in SavedVariables so a /reload does not silently switch it off
    self.capturing = not self.capturing
    self.config.capturing = self.capturing
    if self.capturing then
        if self.config.capture == nil then self.config.capture = {} end
        self:Message("Capture ON. Whisper a bot: help, actions, strategies, "..
                     "triggers, values, chatfilters")
        self:Message("Then /reload and the log is written to SavedVariables")
    else
        self:Message("Capture OFF - "..table.getn(self.config.capture or {})
                     .." line(s) recorded")
    end
end

-- The help system answers only to its own hyperlinks, not to typed words:
--   |c0000FFFF|Hvalue:help:object:action|h[actions]|h|r
-- so build the link and whisper it for them.
local HELP_TOPICS = {
    strategies  = "strategy",
    actions     = "action",
    triggers    = "trigger",
    values      = "value",
    chatfilters = "chatfilter",
}

local HELP_CLASSES = {
    "warrior", "paladin", "hunter", "rogue", "priest",
    "shaman", "mage", "warlock", "druid",
}

-- Verified against the bot: a hand-built |Hvalue:...|h link does go through and
-- is answered, while the same path sent as plain text is ignored. So the full
-- link markup is required, not optional.
local function HelpLink(path, label)
    return "|c0000FFFF|H"..path.."|h["..label.."]|h|r"
end

function UnBot:AskBotHelp(topic)
    local target = UnitName("target")
    if not target or target == "" then
        self:Message(UnBotL.MSG.NO_TARGET)
        return
    end

    if topic == nil or topic == "" then
        SendChatMessage("help", "WHISPER", nil, target)
        return
    end

    -- second level: "ask list generic strategy" -> value:help:list:<name>
    local _, _, listName = string.find(topic, "^list%s+(.+)$")
    if listName then
        SendChatMessage(HelpLink("value:help:list:"..listName, listName),
                        "WHISPER", nil, target)
        self:Message("Asked "..target.." for the "..listName.." list")
        return
    end

    -- Everything at once. Each list is a dozen long whispers, so leave a wide
    -- gap - asking back to back gets most of the replies dropped.
    if topic == "all" then
        self:QueueChat(HelpLink("value:help:list:generic strategy", "general"),
                       "WHISPER", target)
        for i = 1, table.getn(HELP_CLASSES) do
            local c = HELP_CLASSES[i]
            self:QueueWait(3)
            self:QueueChat(HelpLink("value:help:list:"..c.." strategy", c),
                           "WHISPER", target)
        end
        self:Message("Asking "..target.." for all strategy lists - takes about "
                     ..(table.getn(HELP_CLASSES) * 3).."s, then /reload")
        return
    end

    -- first level: the five object categories
    local object = HELP_TOPICS[topic]
    if not object then
        self:Message("Try: all | actions | strategies | list generic strategy")
        return
    end

    SendChatMessage(HelpLink("value:help:object:"..object, topic),
                    "WHISPER", nil, target)
    self:Message("Asked "..target.." about "..topic)
end

-- Help replies list strategies as value:help:strategy:<name> links. Harvest
-- them so the strategy picker works off the server's real names instead of a
-- table baked into the addon. Class strategies are prefixed, e.g.
-- "warrior aoe fury pve".
function UnBot:ParseStrategyList(msg)
    if not msg then return end
    if not string.find(msg, "Hvalue:help:strategy:") then return end

    if self.config.strategies == nil then self.config.strategies = {} end

    local iter = string.gmatch or string.gfind
    local found = 0

    for name in iter(msg, "Hvalue:help:strategy:([^|]+)|h") do
        local class, short = "generic", name

        for i = 1, table.getn(HELP_CLASSES) do
            local c = HELP_CLASSES[i]
            local _, _, rest = string.find(name, "^"..c.."%s+(.+)$")
            if rest then
                class, short = c, rest
                break
            end
        end

        if self.config.strategies[class] == nil then
            self.config.strategies[class] = {}
        end
        if not self.config.strategies[class][short] then
            self.config.strategies[class][short] = name   -- full name to send
            found = found + 1
        end
    end

    if found > 0 then
        if self.debug then
            self:Message("Learned "..found.." strategy name(s)")
        end
        -- an open strategy window should show them straight away
        if self.RebuildStrategyTree then self:RebuildStrategyTree() end
    end
end

function UnBot:CaptureLine(sender, msg)
    if not self.capturing or not msg then return end
    if self.config.capture == nil then self.config.capture = {} end
    table.insert(self.config.capture, tostring(sender)..": "..msg)
end

local capture = CreateFrame("Frame", "UnBotCaptureFrame")
capture:RegisterEvent("CHAT_MSG_WHISPER")
capture:RegisterEvent("CHAT_MSG_SYSTEM")
capture:RegisterEvent("CHAT_MSG_WHISPER_INFORM")   -- what we sent, to verify it left
capture:SetScript("OnEvent", function()
    local who = arg2 or "system"
    if event == "CHAT_MSG_WHISPER_INFORM" then who = "-> "..who end
    UnBot:CaptureLine(who, arg1)

    -- learn strategy names whenever they appear, capture on or off
    if event == "CHAT_MSG_WHISPER" then
        UnBot:ParseStrategyList(arg1)
    end
end)

--=========================================================================--
--  Throttled chat queue
--
--  Firing twenty ".bot add" lines in one frame gets most of them dropped by
--  the client's chat throttle, so anything bulk goes through here instead.
--=========================================================================--

UnBot.queue = {}
UnBot.queueTimer = 0
UnBot.queueWait = 0
local QUEUE_DELAY = 0.4

function UnBot:QueueChat(text, channel, target)
    table.insert(self.queue, {
        text = text,
        channel = channel or "SAY",
        target = target,
    })
end

-- Run something later, in order, e.g. inviting a bot once it has logged in.
function UnBot:QueueAction(func)
    table.insert(self.queue, { action = func })
end

-- Hold the queue for a while before continuing.
function UnBot:QueueWait(seconds)
    table.insert(self.queue, { wait = seconds })
end

function UnBot:QueueSize()
    return table.getn(self.queue)
end

local pump = CreateFrame("Frame", "UnBotQueuePump")
pump:SetScript("OnUpdate", function()
    -- 1.12 passes the frame time as the global arg1, never as a parameter.
    local elapsed = arg1 or 0

    if UnBot.queueWait > 0 then
        UnBot.queueWait = UnBot.queueWait - elapsed
        return
    end

    if table.getn(UnBot.queue) == 0 then return end

    UnBot.queueTimer = UnBot.queueTimer + elapsed
    if UnBot.queueTimer < QUEUE_DELAY then return end
    UnBot.queueTimer = 0

    local item = table.remove(UnBot.queue, 1)
    if item.wait then
        if UnBot.debug then UnBot:Message("queue: wait "..item.wait.."s") end
        UnBot.queueWait = item.wait
    elseif item.action then
        if UnBot.debug then UnBot:Message("queue: action") end
        item.action()
    else
        if UnBot.debug then UnBot:Message("queue: say "..item.text) end
        SendChatMessage(item.text, item.channel, nil, item.target)
    end
end)

--=========================================================================--
--  Load
--=========================================================================--

local loader = CreateFrame("Frame", "UnBotLoader")
loader:RegisterEvent("VARIABLES_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    UnBot:Init()
end)
