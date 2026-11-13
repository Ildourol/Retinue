-- UnBot Commands - special handlers.
-- Everything else is dispatched generically by UnBot:RunCommand from the
-- UnBotExecuteCommand / UnBotCommandType tables.

Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue

--=========================================================================--
--  Group iteration helpers
--=========================================================================--

-- Calls func(unitName) for every group member except the player.
local function ForEachGroupMember(func)
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    local me = UnitName("player")
    local myLower = (me and checkValid and checkValid(me)) and string.lower(me) or ""
    if UnitInRaid("player") then
        local n = GetNumRaidMembers()
        for i = 1, n do
            local name = UnitName("raid"..i)
            if name and (not checkValid or checkValid(name)) then
                if myLower == "" or string.lower(name) ~= myLower then
                    func(name)
                end
            end
        end
    else
        local n = GetNumPartyMembers()
        for i = 1, n do
            local name = UnitName("party"..i)
            if name and (not checkValid or checkValid(name)) then
                if myLower == "" or string.lower(name) ~= myLower then
                    func(name)
                end
            end
        end
    end
end

-- Uninvite helper utilizing Retinue's robust uninvite pipeline
local function KickFromGroup(name)
    if UnBot and UnBot.UninviteBot then
        UnBot:UninviteBot(name)
    else
        if type(UninviteByName) == "function" then
            UninviteByName(name)
        elseif type(UninviteUnit) == "function" then
            UninviteUnit(name)
        end
        SendChatMessage("leave", "WHISPER", nil, name)
    end
end

-- Resolves the designated tank bot in the party/raid
function UnBot:GetPartyTank()
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    local target = UnitName("target")
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        local _, classToken = UnitClass("target")
        local role = (Retinue and Retinue.Roles and Retinue.Roles.GetBotRole and Retinue.Roles.GetBotRole(target, classToken))
        if role == "tank" then return target end
    end
    if UnitInRaid("player") then
        local n = GetNumRaidMembers()
        for i = 1, n do
            local name = UnitName("raid"..i)
            if name and (not checkValid or checkValid(name)) and not UnitIsUnit("raid"..i, "player") then
                local _, classToken = UnitClass("raid"..i)
                local role = (Retinue and Retinue.Roles and Retinue.Roles.GetBotRole and Retinue.Roles.GetBotRole(name, classToken))
                if role == "tank" then return name end
            end
        end
    else
        local n = GetNumPartyMembers()
        for i = 1, n do
            local name = UnitName("party"..i)
            if name and (not checkValid or checkValid(name)) then
                local _, classToken = UnitClass("party"..i)
                local role = (Retinue and Retinue.Roles and Retinue.Roles.GetBotRole and Retinue.Roles.GetBotRole(name, classToken))
                if role == "tank" then return name end
            end
        end
    end
    -- Fallback: first Warrior in group
    local n = GetNumPartyMembers()
    for i = 1, n do
        local name = UnitName("party"..i)
        if name and (not checkValid or checkValid(name)) then
            local _, classToken = UnitClass("party"..i)
            if classToken == "WARRIOR" then return name end
        end
    end
    return nil
end

-- Resolves the designated healer bot in the party/raid
function UnBot:GetPartyHealer()
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    local target = UnitName("target")
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        local _, classToken = UnitClass("target")
        local role = (Retinue and Retinue.Roles and Retinue.Roles.GetBotRole and Retinue.Roles.GetBotRole(target, classToken))
        if role == "heal" then return target end
    end
    if UnitInRaid("player") then
        local n = GetNumRaidMembers()
        for i = 1, n do
            local name = UnitName("raid"..i)
            if name and (not checkValid or checkValid(name)) and not UnitIsUnit("raid"..i, "player") then
                local _, classToken = UnitClass("raid"..i)
                local role = (Retinue and Retinue.Roles and Retinue.Roles.GetBotRole and Retinue.Roles.GetBotRole(name, classToken))
                if role == "heal" then return name end
            end
        end
    else
        local n = GetNumPartyMembers()
        for i = 1, n do
            local name = UnitName("party"..i)
            if name and (not checkValid or checkValid(name)) then
                local _, classToken = UnitClass("party"..i)
                local role = (Retinue and Retinue.Roles and Retinue.Roles.GetBotRole and Retinue.Roles.GetBotRole(name, classToken))
                if role == "heal" then return name end
            end
        end
    end
    return nil
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
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if not name or name == "" or (checkValid and not checkValid(name)) then
        UnBot:Message(UnBotL.MSG.NO_TARGET)
        return
    end
    local raw = UnBotExecuteCommand[id] .. " " .. name
    if string.find(raw, "^%.bot%s+") then
        local sub = string.gsub(raw, "^%.bot%s+", "")
        UnBot:SendBotCommand(sub)
    else
        SendChatMessage(raw)
    end
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
        if UnBot.config and UnBot.config.roster and UnBot.config.roster[name] then
            UnBot.config.roster[name].online = false
            UnBot.config.roster[name].grouped = false
        end
        count = count + 1
    end)
    if count > 0 then
        UnBot:Message("Queued logout for "..count.." party bot(s)")
        if UnBot.RefreshRoster then UnBot:RefreshRoster() end
    else
        UnBot:Message("No group bots to log out")
    end
end)

-- [83] Cleanly log in offline roster bots
UnBot:RegisterHandler(83, function()
    local count = 0
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if UnBot.config and UnBot.config.roster then
        for name, data in pairs(UnBot.config.roster) do
            if (not checkValid or checkValid(name)) and not data.self and not data.online then
                UnBot:QueueChat(".bot add "..name, "SAY")
                data.online = true
                count = count + 1
            end
        end
    end
    if count > 0 then
        UnBot:Message("Queued login for "..count.." offline bot(s)")
        if UnBot.RefreshRoster then UnBot:RefreshRoster() end
    else
        UnBot:Message("No offline roster bots to log in")
    end
end)

-- [70] Tell the group to stop combat and clear queues
UnBot:RegisterHandler(70, function()
    UnBot:SendBotCommand("action stop")
    SendChatMessage("combatstop", "PARTY")
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
    UnBot:SendBotCommand("action ready")
    if DoReadyCheck then
        DoReadyCheck()
    end
end)

-- [81] Make bots drink
UnBot:RegisterHandler(81, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage("d drink", "WHISPER", nil, target)
    else
        SendChatMessage("d drink", "PARTY")
    end
    UnBot:SendBotCommand("action drink")
end)

-- [99] Make bots eat
UnBot:RegisterHandler(99, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage("d food", "WHISPER", nil, target)
    else
        SendChatMessage("d food", "PARTY")
    end
    UnBot:SendBotCommand("action eat")
end)

-- [103] Use nearby world object (chests, levers, herbs, ore)
UnBot:RegisterHandler(103, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage("d use go", "WHISPER", nil, target)
    else
        SendChatMessage("d use go", "PARTY")
    end
    UnBot:SendBotCommand("action loot")
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

-- [77] Manual roster sync with server (.bot roster / .bot list)
UnBot:RegisterHandler(77, function()
    UnBot:RequestServerRoster(true)
end)

-- [92] Tank pull with configurable DPS delay stepper
UnBot:RegisterHandler(92, function()
    local delay = (RetinueConfig and RetinueConfig.pullDelay) or 10
    if UnBot.HasServerCapability and UnBot:HasServerCapability("pull-seconds") then
        UnBot:SendBotCommand("action pull " .. delay .. " ranged")
    else
        UnBot:SendBotCommand("action pull 10 ranged")
    end
end)

-- [157] Tank pullback with configurable join delay stepper
UnBot:RegisterHandler(157, function()
    local delay = (RetinueConfig and RetinueConfig.pullbackDelay) or 3
    if UnBot.HasServerCapability and UnBot:HasServerCapability("pull-seconds") then
        UnBot:SendBotCommand("action pullback " .. delay .. " ranged")
    else
        UnBot:SendBotCommand("action pullback 5 ranged")
    end
end)

-- [170] Raid Tankface
UnBot:RegisterHandler(170, function()
    UnBot:SendBotCommand("action raid tankface")
end)

-- [171] Raid Douse runes
UnBot:RegisterHandler(171, function()
    UnBot:SendBotCommand("action raid douse")
end)

-- [172] Raid custom tactics toggle
UnBot:RegisterHandler(172, function()
    if UnBot.raidCustomState == "on" then
        UnBot:SendBotCommand("action raid custom off")
        UnBot.raidCustomState = "off"
    else
        UnBot:SendBotCommand("action raid custom on")
        UnBot.raidCustomState = "on"
    end
    if UnBot.RefreshRaidView then UnBot:RefreshRaidView() end
end)

-- [183] Raid custom off
UnBot:RegisterHandler(183, function()
    UnBot:SendBotCommand("action raid custom off")
    UnBot.raidCustomState = "off"
    if UnBot.RefreshRaidView then UnBot:RefreshRaidView() end
end)

-- [184] Raid custom status
UnBot:RegisterHandler(184, function()
    UnBot:SendBotCommand("action raid custom status")
end)

-- [185] Raid boss tactics check
UnBot:RegisterHandler(185, function()
    UnBot.raidBotTactics = {}
    UnBot:SendBotCommand("action raid status")
end)

-- [25] Party flee
UnBot:RegisterHandler(25, function()
    if UnBot.HasServerCapability and UnBot:HasServerCapability("flee") then
        UnBot:SendBotCommand("action flee")
    else
        SendChatMessage("flee", "PARTY")
    end
end)

-- [33] Tank attack: Direct the designated tank bot to pull/engage target first
UnBot:RegisterHandler(33, function()
    local tank = UnBot.GetPartyTank and UnBot:GetPartyTank()
    if tank then
        SendChatMessage("tank attack", "WHISPER", nil, tank)
        UnBot:Message("Ordered tank ("..tank..") to attack")
    else
        SendChatMessage("tank attack", "PARTY")
        UnBot:SendBotCommand("action attack")
    end
end)

-- [110] Spread toggle (staggers bot positioning)
UnBot:RegisterHandler(110, function()
    local state = UnBot.GetPartyConsensus and UnBot:GetPartyConsensus("spread")
    if state == "on" or UnBot.spreadActive then
        UnBot:SendBotCommand("behavior party spread off")
        UnBot.spreadActive = false
        UnBot:Message("Party spread behavior disabled")
    else
        UnBot:SendBotCommand("behavior party spread on")
        UnBot.spreadActive = true
        UnBot:Message("Party spread behavior enabled")
    end
    if UnBot.RefreshActionGroupGrid and UnBot.actionGroupFrame and UnBot.actionGroupFrame:IsShown() then
        UnBot:RefreshActionGroupGrid()
    end
end)

-- [158] End pull: Abort active tank pull hold and instruct party/tank to resume standard combat
UnBot:RegisterHandler(158, function()
    local tank = UnBot.GetPartyTank and UnBot:GetPartyTank()
    if tank then
        SendChatMessage("end pull", "WHISPER", nil, tank)
    end
    UnBot:SendBotCommand("action end pull")
    UnBot:Message("Aborted tank pull hold")
end)

-- [167] Totem party drop
UnBot:RegisterHandler(167, function()
    UnBot:SendBotCommand("totem party drop")
    UnBot:Message("Ordered Shaman bots to drop totems")
end)

-- [186] Max DPS: Direct DPS bots to burn cooldowns and ignore threat/mana caps
UnBot:RegisterHandler(186, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage("max dps", "WHISPER", nil, target)
        UnBot:Message("Sent Max DPS order to " .. target)
    else
        SendChatMessage("max dps", "PARTY")
        UnBot:Message("Sent Max DPS order to party")
    end
end)

-- [187] Sync Swing Timer: Tell bots to sync attack timing / wait for attack time
UnBot:RegisterHandler(187, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage("wait for attack time 1", "WHISPER", nil, target)
        UnBot:Message("Set attack wait time for " .. target .. " to 1s")
    else
        SendChatMessage("wait for attack time 1", "PARTY")
        UnBot:Message("Set attack wait time for party to 1s")
    end
end)

-- [188] Combat Range: Adjust bot combat distance
UnBot:RegisterHandler(188, function()
    local cRange = (RetinueConfig and RetinueConfig.combatRange) or 30
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage("range attack " .. cRange, "WHISPER", nil, target)
        UnBot:Message("Set combat range for " .. target .. " to " .. cRange .. "yd")
    else
        SendChatMessage("range attack " .. cRange, "PARTY")
        UnBot:Message("Set combat range for party to " .. cRange .. "yd")
    end
end)

-- [189] Pet: Passive
UnBot:RegisterHandler(189, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage("pet passive", "WHISPER", nil, target)
        UnBot:Message("Set pet of " .. target .. " to passive")
    else
        SendChatMessage("pet passive", "PARTY")
        UnBot:Message("Set party pets to passive")
    end
end)

-- [190] Pet: Defensive
UnBot:RegisterHandler(190, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage("pet defensive", "WHISPER", nil, target)
        UnBot:Message("Set pet of " .. target .. " to defensive")
    else
        SendChatMessage("pet defensive", "PARTY")
        UnBot:Message("Set party pets to defensive")
    end
end)

-- [191] Pet: Aggressive
UnBot:RegisterHandler(191, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        SendChatMessage("pet aggressive", "WHISPER", nil, target)
        UnBot:Message("Set pet of " .. target .. " to aggressive")
    else
        SendChatMessage("pet aggressive", "PARTY")
        UnBot:Message("Set party pets to aggressive")
    end
end)

-- [192] Pet: Auto Taunt / Autocast
UnBot:RegisterHandler(192, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        local _, classToken = UnitClass("target")
        local spell = (classToken == "WARLOCK" and "Torment") or "Growl"
        SendChatMessage("pet autocast " .. spell, "WHISPER", nil, target)
        UnBot:Message("Toggled pet taunt autocast (" .. spell .. ") on " .. target)
    else
        SendChatMessage("pet autocast Growl", "PARTY")
        SendChatMessage("pet autocast Torment", "PARTY")
        UnBot:Message("Toggled pet taunt autocast for party pets")
    end
end)

-- [193] Focus Heal Priority
UnBot:RegisterHandler(193, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if not target or target == "" or (checkValid and not checkValid(target)) then
        UnBot:Message("Select a friendly group member to set/toggle as focus heal priority")
        return
    end
    SendChatMessage("focus heal +" .. target, "PARTY")
    UnBot.focusHealTarget = target
    UnBot:Message("Requested focus heal priority on " .. target)
    if UnBot.RefreshPartyView and UnBot.partyView and UnBot.partyView:IsShown() then
        UnBot:RefreshPartyView()
    end
end)

-- [194] Boost Target Priority
UnBot:RegisterHandler(194, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if not target or target == "" or (checkValid and not checkValid(target)) then
        UnBot:Message("Select a group member to set/toggle as boost target priority")
        return
    end
    SendChatMessage("boost target +" .. target, "PARTY")
    UnBot.boostTarget = target
    UnBot:Message("Requested boost target priority on " .. target)
    if UnBot.RefreshPartyView and UnBot.partyView and UnBot.partyView:IsShown() then
        UnBot:RefreshPartyView()
    end
end)

-- [195] Shaman Totem Configuration
UnBot:RegisterHandler(195, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) then
        UnBot:SendBotCommand("totem " .. target)
    else
        UnBot:SendBotCommand("totem")
    end
end)

-- Resolves a Mage bot in party/raid
function UnBot:GetPartyMage()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        local _, classToken = UnitClass("target")
        if classToken == "MAGE" then return target end
    end
    if UnitInRaid("player") then
        local n = GetNumRaidMembers()
        for i = 1, n do
            local name = UnitName("raid"..i)
            if name and (not checkValid or checkValid(name)) and not UnitIsUnit("raid"..i, "player") then
                local _, classToken = UnitClass("raid"..i)
                if classToken == "MAGE" then return name end
            end
        end
    else
        local n = GetNumPartyMembers()
        for i = 1, n do
            local name = UnitName("party"..i)
            if name and (not checkValid or checkValid(name)) then
                local _, classToken = UnitClass("party"..i)
                if classToken == "MAGE" then return name end
            end
        end
    end
    return nil
end

-- Interactive Mage City Portal Conjuring Menu
function UnBot:OpenMagePortalMenu()
    local mage = self:GetPartyMage()
    if not mage then
        self:Message("No Mage bot found in party or raid")
        return
    end

    if not self.magePortalFrame then
        local pf = CreateFrame("Frame", "UnBotMagePortalFrame", UIParent)
        pf:SetWidth(240); pf:SetHeight(180)
        pf:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
        pf:EnableMouse(true)
        if self.MakeDraggable then self:MakeDraggable(pf) end
        pf:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        if UISpecialFrames then table.insert(UISpecialFrames, "UnBotMagePortalFrame") end

        local pTitle = pf:CreateFontString(nil, "OVERLAY")
        pTitle:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 12)
        pTitle:SetPoint("TOP", pf, "TOP", 0, -16)
        pTitle:SetTextColor(1, 0.82, 0)
        pTitle:SetText("Mage Portals")
        pf.pTitle = pTitle

        local pSub = pf:CreateFontString(nil, "OVERLAY")
        pSub:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 9)
        pSub:SetPoint("TOP", pTitle, "BOTTOM", 0, -4)
        pSub:SetTextColor(0.7, 0.7, 0.7)
        pSub:SetText("Select destination city:")
        pf.pSub = pSub

        local closeBtn = CreateFrame("Button", nil, pf, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", pf, "TOPRIGHT", -6, -6)

        local portals = {
            { name = "Stormwind", spell = 10059 },
            { name = "Ironforge", spell = 11416 },
            { name = "Darnassus", spell = 11419 },
            { name = "Orgrimmar", spell = 11417 },
            { name = "Undercity", spell = 11418 },
            { name = "Thunder Bluff", spell = 11420 },
        }

        pf.buttons = {}
        for idx = 1, table.getn(portals) do
            local p = portals[idx]
            local col = math.mod(idx - 1, 2) + 1
            local row = math.floor((idx - 1) / 2) + 1
            local b = CreateFrame("Button", nil, pf, "UIPanelButtonTemplate")
            b:SetWidth(100); b:SetHeight(24)
            b:SetPoint("TOPLEFT", pf, "TOPLEFT", 16 + (col - 1) * 106, -50 - (row - 1) * 28)
            b:SetText(p.name)
            b.spell = p.spell
            b.cityName = p.name
            b:SetScript("OnClick", function()
                local m = UnBot:GetPartyMage()
                if m then
                    UnBot:SendBotCommand("service " .. m .. " portal " .. this.spell)
                    UnBot:Message("Requested portal to " .. this.cityName .. " from " .. m)
                end
                pf:Hide()
            end)
            pf.buttons[idx] = b
        end
        self.magePortalFrame = pf
    end

    self.magePortalFrame.pTitle:SetText("Mage Portals (" .. mage .. ")")
    self.magePortalFrame:Show()
end

-- [196] Remote Bank & Mailbox Vault
UnBot:RegisterHandler(196, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    local bot = (target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player")) and target or nil
    if not bot then
        local n = GetNumPartyMembers()
        for i = 1, n do
            local name = UnitName("party"..i)
            if name and (not checkValid or checkValid(name)) then
                bot = name
                break
            end
        end
    end
    if not bot then
        UnBot:Message("Select a party bot to inspect bank & mailbox vault")
        return
    end
    UnBot:ShowItemWindow("vault", bot)
end)

-- [197] Equip Upgrades
UnBot:RegisterHandler(197, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        UnBot:SendBotCommand("command " .. target .. " d equip upgrades")
        UnBot:Message("Ordered " .. target .. " to equip bag upgrades")
    else
        SendChatMessage("d equip upgrades", "PARTY")
        UnBot:Message("Ordered party bots to equip bag upgrades")
    end
end)

-- [198] Toggle Roster
UnBot:RegisterHandler(198, function()
    UnBot:ToggleRoster()
end)

-- [199] Mage City Portals
UnBot:RegisterHandler(199, function()
    UnBot:OpenMagePortalMenu()
end)

-- [200] Follow Target
UnBot:RegisterHandler(200, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and target ~= "" and (not checkValid or checkValid(target)) then
        SendChatMessage("follow target", "PARTY")
        UnBot:Message("Ordered bots to follow target: " .. target)
    else
        UnBot:Message("Select a friendly target for bots to follow")
    end
end)

-- [201] Buff Target Priority
UnBot:RegisterHandler(201, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and target ~= "" and (not checkValid or checkValid(target)) then
        SendChatMessage("buff target", "PARTY")
        UnBot:Message("Ordered buffer bots to buff " .. target)
    else
        SendChatMessage("buff target", "PARTY")
        UnBot:Message("Ordered buffer bots to cast party buffs")
    end
end)

-- [202] Revive Target Priority
UnBot:RegisterHandler(202, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and target ~= "" and (not checkValid or checkValid(target)) then
        SendChatMessage("revive target", "PARTY")
        UnBot:Message("Ordered healers to resurrect " .. target)
    else
        SendChatMessage("revive target", "PARTY")
        UnBot:Message("Ordered healers to revive fallen group members")
    end
end)

-- [203] Self Resurrect
UnBot:RegisterHandler(203, function()
    SendChatMessage("self res", "PARTY")
    UnBot:Message("Ordered Shamans and Warlocks to self-resurrect")
end)

-- [204] Corpse Run
UnBot:RegisterHandler(204, function()
    SendChatMessage("corpse run", "PARTY")
    UnBot:Message("Ordered dead bots to release and corpse run")
end)

-- [205] Warn & Runaway
UnBot:RegisterHandler(205, function()
    SendChatMessage("runaway", "PARTY")
    UnBot:Message("Ordered party bots to runaway!")
end)

-- [206] Query Attackers
UnBot:RegisterHandler(206, function()
    SendChatMessage("attackers", "PARTY")
    UnBot:Message("Queried party bots for active attackers")
end)

-- [207] Downtime Errands (Own Alts)
UnBot:RegisterHandler(207, function()
    UnBot:SendBotCommand("downtime")
    UnBot:Message("Dispatched downtime errands for active alts (trainer, vendor, repair)")
end)

--=========================================================================--
--  Modal Input Dialogs (Save AI, Load AI, Spread Distance, Wait Attack Time)
--=========================================================================--

StaticPopupDialogs["UNBOT_SAVE_AI"] = {
    text = "Enter AI strategy preset name to save:",
    button1 = "Save",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 24,
    OnShow = function()
        local editBox = getglobal(this:GetName().."EditBox")
        if editBox then
            editBox:SetText("")
            editBox:SetFocus()
        end
    end,
    OnAccept = function()
        local editBox = getglobal(this:GetParent():GetName().."EditBox")
        local name = editBox and editBox:GetText()
        if name and name ~= "" then
            local target = UnitName("target")
            local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
            if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
                SendChatMessage("save ai " .. name, "WHISPER", nil, target)
                UnBot:Message("Saved AI preset '" .. name .. "' for " .. target)
            else
                SendChatMessage("save ai " .. name, "PARTY")
                UnBot:Message("Saved AI preset '" .. name .. "' for party bots")
            end
        end
    end,
    EditBoxOnEnterPressed = function()
        StaticPopupDialogs["UNBOT_SAVE_AI"].OnAccept()
        this:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function()
        this:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
}

StaticPopupDialogs["UNBOT_LOAD_AI"] = {
    text = "Enter AI strategy preset name to load:",
    button1 = "Load",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 24,
    OnShow = function()
        local editBox = getglobal(this:GetName().."EditBox")
        if editBox then
            editBox:SetText("")
            editBox:SetFocus()
        end
    end,
    OnAccept = function()
        local editBox = getglobal(this:GetParent():GetName().."EditBox")
        local name = editBox and editBox:GetText()
        if name and name ~= "" then
            local target = UnitName("target")
            local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
            if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
                SendChatMessage("load ai " .. name, "WHISPER", nil, target)
                UnBot:Message("Loaded AI preset '" .. name .. "' on " .. target)
            else
                SendChatMessage("load ai " .. name, "PARTY")
                UnBot:Message("Loaded AI preset '" .. name .. "' on party bots")
            end
        end
    end,
    EditBoxOnEnterPressed = function()
        StaticPopupDialogs["UNBOT_LOAD_AI"].OnAccept()
        this:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function()
        this:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
}

StaticPopupDialogs["UNBOT_SPREAD_DISTANCE"] = {
    text = "Enter combat spread distance in yards (default 10):",
    button1 = "Set",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 4,
    OnShow = function()
        local editBox = getglobal(this:GetName().."EditBox")
        if editBox then
            editBox:SetText("10")
            editBox:HighlightText()
            editBox:SetFocus()
        end
    end,
    OnAccept = function()
        local editBox = getglobal(this:GetParent():GetName().."EditBox")
        local val = editBox and editBox:GetText()
        if val and tonumber(val) then
            SendChatMessage("spread distance " .. val, "PARTY")
            UnBot:Message("Set party combat spread distance to " .. val .. " yards")
        end
    end,
    EditBoxOnEnterPressed = function()
        StaticPopupDialogs["UNBOT_SPREAD_DISTANCE"].OnAccept()
        this:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function()
        this:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
}

StaticPopupDialogs["UNBOT_WAIT_ATTACK_TIME"] = {
    text = "Enter wait for attack delay in seconds (default 3):",
    button1 = "Set",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 4,
    OnShow = function()
        local editBox = getglobal(this:GetName().."EditBox")
        if editBox then
            editBox:SetText("3")
            editBox:HighlightText()
            editBox:SetFocus()
        end
    end,
    OnAccept = function()
        local editBox = getglobal(this:GetParent():GetName().."EditBox")
        local val = editBox and editBox:GetText()
        if val and tonumber(val) then
            SendChatMessage("wait for attack time " .. val, "PARTY")
            UnBot:Message("Set DPS wait-for-attack delay to " .. val .. " seconds")
        end
    end,
    EditBoxOnEnterPressed = function()
        StaticPopupDialogs["UNBOT_WAIT_ATTACK_TIME"].OnAccept()
        this:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function()
        this:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
}

--=========================================================================--
--  Reset, Preset, Tactical & Upkeep Handlers (208 - 226)
--=========================================================================--

-- [208] Full AI Reset (strategies + DB store)
UnBot:RegisterHandler(208, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("reset ai", "WHISPER", nil, target)
        UnBot:Message("Full AI Reset ordered for " .. target)
    else
        SendChatMessage("reset ai", "PARTY")
        UnBot:Message("Full AI Reset ordered for party bots")
    end
end)

-- [209] Soft AI Reset (clear transient combat state, reload config)
UnBot:RegisterHandler(209, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("reset ai soft", "WHISPER", nil, target)
        UnBot:Message("Soft AI Reset ordered for " .. target)
    else
        SendChatMessage("reset ai soft", "PARTY")
        UnBot:Message("Soft AI Reset ordered for party bots")
    end
end)

-- [210] Reset AI Blackboard Values
UnBot:RegisterHandler(210, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("reset values", "WHISPER", nil, target)
        UnBot:Message("Blackboard memory values reset for " .. target)
    else
        SendChatMessage("reset values", "PARTY")
        UnBot:Message("Blackboard memory values reset for party bots")
    end
end)

-- [211] Reset Travel Target
UnBot:RegisterHandler(211, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("reset travel target", "WHISPER", nil, target)
        UnBot:Message("Travel pathing target reset for " .. target)
    else
        SendChatMessage("reset travel target", "PARTY")
        UnBot:Message("Travel pathing target reset for party bots")
    end
end)

-- [212] Reset Anchor Position to Follow
UnBot:RegisterHandler(212, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("position reset", "WHISPER", nil, target)
        UnBot:Message("Anchor and guard position reset to follow for " .. target)
    else
        SendChatMessage("position reset", "PARTY")
        UnBot:Message("Anchor and guard positions reset to follow for party bots")
    end
end)

-- [213] Reset Talents at Trainer
UnBot:RegisterHandler(213, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("talents reset", "WHISPER", nil, target)
        UnBot:Message("Reset talents at class trainer ordered for " .. target)
    else
        SendChatMessage("talents reset", "PARTY")
        UnBot:Message("Reset talents at class trainer ordered for party bots")
    end
end)

-- [214] Reset 5-man Dungeons
UnBot:RegisterHandler(214, function()
    SendChatMessage("reset instances", "PARTY")
    UnBot:Message("Ordered party bot leader to reset 5-man instances")
end)

-- [215] Reset Raid Lockouts
UnBot:RegisterHandler(215, function()
    SendChatMessage("reset raids", "PARTY")
    UnBot:Message("Ordered raid bot leader to reset raid lockouts")
end)

-- [216] List Saved AI Presets
UnBot:RegisterHandler(216, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("list ai", "WHISPER", nil, target)
        UnBot:Message("Queried saved AI presets for " .. target)
    else
        SendChatMessage("list ai", "PARTY")
        UnBot:Message("Queried saved AI presets for party bots")
    end
end)

-- [217] Save Named AI Preset
UnBot:RegisterHandler(217, function()
    StaticPopup_Show("UNBOT_SAVE_AI")
end)

-- [218] Load Named AI Preset
UnBot:RegisterHandler(218, function()
    StaticPopup_Show("UNBOT_LOAD_AI")
end)

-- [219] Attack Player's Target
UnBot:RegisterHandler(219, function()
    SendChatMessage("attack my target", "PARTY")
    UnBot:Message("Ordered party bots to attack player's target")
end)

-- [220] Attack RTI Marked Target
UnBot:RegisterHandler(220, function()
    SendChatMessage("attack rti target", "PARTY")
    UnBot:Message("Ordered party bots to attack active RTI mark target")
end)

-- [221] Set Combat Spread Distance
UnBot:RegisterHandler(221, function()
    StaticPopup_Show("UNBOT_SPREAD_DISTANCE")
end)

-- [222] Set DPS Wait-for-Attack Delay
UnBot:RegisterHandler(222, function()
    StaticPopup_Show("UNBOT_WAIT_ATTACK_TIME")
end)

-- [223] Report Hostile Attackers
UnBot:RegisterHandler(223, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("tell attackers", "WHISPER", nil, target)
        UnBot:Message("Queried active attackers for " .. target)
    else
        SendChatMessage("tell attackers", "PARTY")
        UnBot:Message("Queried active attackers for party bots")
    end
end)

-- [224] Report Target Status
UnBot:RegisterHandler(224, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("tell target", "WHISPER", nil, target)
        UnBot:Message("Queried target status from " .. target)
    else
        SendChatMessage("tell target", "PARTY")
        UnBot:Message("Queried target status from party bots")
    end
end)

-- [225] Clean Stale Quests from Quest Log
UnBot:RegisterHandler(225, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("clean quest log", "WHISPER", nil, target)
        UnBot:Message("Cleaned stale quests from quest log for " .. target)
    else
        SendChatMessage("clean quest log", "PARTY")
        UnBot:Message("Cleaned stale quests from quest log for party bots")
    end
end)

-- [226] Buy Back Last Sold Items at Vendor
UnBot:RegisterHandler(226, function()
    local target = UnitName("target")
    local checkValid = IsValidCharacterName or (UnBot and UnBot.IsValidCharacterName)
    if target and (not checkValid or checkValid(target)) and (UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player") then
        SendChatMessage("buy back", "WHISPER", nil, target)
        UnBot:Message("Ordered " .. target .. " to buy back last sold items at vendor")
    else
        SendChatMessage("buy back", "PARTY")
        UnBot:Message("Ordered party bots to buy back last sold items at vendor")
    end
end)

--=========================================================================--
--  Parity Action Helpers (Direct Cast, Items, Bank, Mail)
--=========================================================================--

function UnBot:CastBotSpell(botName, spellName)
    if not botName or not spellName or spellName == "" then return false end
    UnBot:SendBotCommand("command " .. botName .. " cast " .. spellName)
    UnBot:Message("Ordered " .. botName .. " to cast " .. spellName)
    return true
end

function UnBot:BotItemAction(botName, action, bag, slot)
    if not botName or not action or not bag or not slot then return false end
    UnBot:SendBotCommand("item " .. botName .. " " .. action .. " " .. bag .. " " .. slot)
    return true
end

function UnBot:BotMailTake(botName, index)
    if not botName or not index then return false end
    UnBot:SendBotCommand("command " .. botName .. " mail take " .. index)
    UnBot:Message("Ordered " .. botName .. " to take mail item #" .. index)
    return true
end

function UnBot:BotBankItem(botName, itemLink, deposit)
    if not botName or not itemLink then return false end
    local prefix = deposit and "" or "-"
    UnBot:SendBotCommand("command " .. botName .. " bank " .. prefix .. itemLink)
    UnBot:Message("Ordered " .. botName .. " to " .. (deposit and "deposit " or "withdraw ") .. itemLink)
    return true
end


