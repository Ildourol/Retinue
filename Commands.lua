-- UnBot Commands - special handlers.
-- Everything else is dispatched generically by UnBot:RunCommand from the
-- UnBotExecuteCommand / UnBotCommandType tables.

--=========================================================================--
--  Group iteration helpers
--=========================================================================--

-- Calls func(unitName) for every group member except the player.
local function ForEachGroupMember(func)
    if UnitInRaid("player") then
        local n = GetNumRaidMembers()
        for i = 1, n do
            local name = UnitName("raid"..i)
            if name and name ~= UnitName("player") then
                func(name)
            end
        end
    else
        local n = GetNumPartyMembers()
        for i = 1, n do
            local name = UnitName("party"..i)
            if name then
                func(name)
            end
        end
    end
end

-- Vanilla exposes UninviteByName; TBC and later renamed it to UninviteUnit.
local function KickFromGroup(name)
    if type(UninviteByName) == "function" then
        UninviteByName(name)
    elseif type(UninviteUnit) == "function" then
        UninviteUnit(name)
    end
end

--=========================================================================--
--  Handlers
--=========================================================================--

-- [0] Close every window and collapse the sub-menus.
UnBot:RegisterHandler(0, function()
    UnBot:CloseAll()
end)

-- mangosbot server commands take a character name. These send
-- ".bot <sub> <target>" for whoever you have selected.
-- mangosbot server commands take a character name. These send
-- ".bot <sub> <target>" for whoever you have selected.
local function ServerCommandOnTarget(id)
    local name = UnitName("target")
    if not name or name == "" then
        UnBot:Message(UnBotL.MSG.NO_TARGET)
        return
    end
    SendChatMessage(UnBotExecuteCommand[id].." "..name, "SAY")
end

UnBot:RegisterHandler(2,   ServerCommandOnTarget)   -- autogear bot
UnBot:RegisterHandler(86,  ServerCommandOnTarget)   -- log bot out
UnBot:RegisterHandler(87,  ServerCommandOnTarget)   -- log bot in
UnBot:RegisterHandler(169, ServerCommandOnTarget)   -- maintenance for bot

-- [3] Autogear all group bots
UnBot:RegisterHandler(3, function()
    local count = 0
    ForEachGroupMember(function(name)
        UnBot:QueueChat(".bot autogear "..name, "SAY")
        count = count + 1
    end)
    if count > 0 then
        UnBot:Message("Queued autogear for "..count.." party bot(s)")
    else
        UnBot:Message("No group bots to gear")
    end
end)

-- [82] Cleanly log out all group bots using queued per-bot commands
UnBot:RegisterHandler(82, function()
    local count = 0
    ForEachGroupMember(function(name)
        UnBot:QueueChat(".bot remove "..name, "SAY")
        count = count + 1
    end)
    if count > 0 then
        UnBot:Message("Queued logout for "..count.." party bot(s)")
        if UnBot.QueueRosterStatusSync then UnBot:QueueRosterStatusSync() end
    else
        UnBot:Message("No group bots to log out")
    end
end)

-- [83] Cleanly log in offline roster bots
UnBot:RegisterHandler(83, function()
    local count = 0
    if UnBot.config and UnBot.config.roster then
        for name, data in pairs(UnBot.config.roster) do
            if not data.self and not data.online then
                UnBot:QueueChat(".bot add "..name, "SAY")
                count = count + 1
            end
        end
    end
    if count > 0 then
        UnBot:Message("Queued login for "..count.." offline bot(s)")
        if UnBot.QueueRosterStatusSync then UnBot:QueueRosterStatusSync() end
    else
        UnBot:Message("No offline roster bots to log in")
    end
end)

-- [70] Tell the group to stop combat and clear queues
UnBot:RegisterHandler(70, function()
    SendChatMessage(".bot action stop", "SAY")
    UnBot:Message("Sent combat stop to party bots")
end)

-- [71] Send the party home, then disband every bot.
UnBot:RegisterHandler(71, function()
    SendChatMessage("nc +grind", "PARTY")
    SendChatMessage("stay", "PARTY")
    ForEachGroupMember(function(name)
        KickFromGroup(name)
    end)
    UnBot:Message("Disbanded party bots")
end)

-- [80] Server-side ready check
UnBot:RegisterHandler(80, function()
    SendChatMessage(".bot action ready", "SAY")
    if DoReadyCheck then
        DoReadyCheck()
    end
end)

-- [88] Add every group member to the friends list.
UnBot:RegisterHandler(88, function()
    local added = 0
    ForEachGroupMember(function(name)
        AddFriend(name)
        added = added + 1
    end)
    UnBot:Message("Added "..added.." group member(s) as friends")
end)

--=========================================================================--
--  Window commands
--=========================================================================--

-- [54] Strategy editor, driven by the names the bot reported itself.
UnBot:RegisterHandler(54, function() UnBot:ShowStrategyWindow() end)

-- [102] Per-class role shortcuts, applied to the whole group at once.
UnBot:RegisterHandler(102, function() UnBot:ToggleRoleBar() end)

-- Bags and spells: one window, opened on the matching tab.
UnBot:RegisterHandler(64, function() UnBot:ShowItemWindow("view")    end)
UnBot:RegisterHandler(65, function() UnBot:ShowItemWindow("destroy") end)
UnBot:RegisterHandler(66, function() UnBot:ShowItemWindow("equip")   end)
UnBot:RegisterHandler(67, function() UnBot:ShowItemWindow("sell")    end)
UnBot:RegisterHandler(68, function() UnBot:ShowItemWindow("use")     end)
UnBot:RegisterHandler(69, function() UnBot:ShowSpellWindow()         end)
-- [74] The account bot roster replaces the old "bring bots online" window.
UnBot:RegisterHandler(74, function()
    UnBot:ToggleRoster()
end)
