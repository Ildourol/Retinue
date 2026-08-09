-- Warband - the bot's bags.
--
-- Protocol, as used by the 3.3.5 addon and unchanged in mangosbot:
--   whisper "c" -> the bot whispers back one item link per line
--   whisper "e <link>", "s <link>", "u <link>", "destroy <link>" to act
--
-- Shown as an icon grid. The item name and everything else lives in the
-- tooltip, which is built from the chat link the bot sent, so it is correct
-- even for items this client has never seen.

local COLS, ROWS = 8, 5
local SLOT_SIZE  = 36
local SLOT_GAP   = 4
local UNKNOWN_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

-- mode -> { title, command, filter }
-- command nil means the tab only lists; filter narrows to sensible types.
local MODES = {
    view    = { title = "Inventory", command = nil,        filter = nil },
    equip   = { title = "Equip",     command = "e ",       filter = "gear" },
    use     = { title = "Use",       command = "u ",       filter = "usable" },
    sell    = { title = "Sell",      command = "s ",       filter = nil },
    destroy = { title = "Destroy",   command = "destroy ", filter = nil },
}

local MODE_ORDER = { "view", "equip", "use", "sell", "destroy" }

-- Vanilla's GetItemInfo returns eight values and no texture:
--   name, link, quality, minLevel, type, subType, stackCount, equipLoc
-- It only answers for items the client has seen, so unknowns are let through.
local function ItemPassesFilter(id, filter)
    if not filter or not id then return true end

    local _, _, _, _, itemType, _, _, equipLoc = GetItemInfo(id)
    if not itemType then return true end

    if filter == "gear" then
        return itemType == "Weapon" or itemType == "Armor"
            or (equipLoc ~= nil and equipLoc ~= "")
    elseif filter == "usable" then
        -- Trade Goods deliberately excluded: dust and essences are reagents,
        -- not things a bot can use.
        return itemType == "Consumable"
    end
    return true
end

--=========================================================================--
--  Item icons
--
--  This client's GetItemInfo returns ten values, with the texture in slot 9:
--    1 name  2 link  3 quality  4 minLevel  5 type  6 subType
--    7 stackCount  8 equipLoc  9 texture  10 (numeric)
--  Stock 1.12 has only eight and no texture at all, so AtlasLoot's id -> icon
--  table is kept as a fallback for clients without it.
--=========================================================================--

local iconIndex = nil

local function BuildIconIndex()
    iconIndex = {}
    if not AtlasLoot_Data then return end

    -- AtlasLoot_Data[category][list] = { {id, "IconName", "=q4=Name", ...}, ... }
    for _, category in pairs(AtlasLoot_Data) do
        if type(category) == "table" then
            for _, list in pairs(category) do
                if type(list) == "table" then
                    for _, entry in pairs(list) do
                        if type(entry) == "table" then
                            local id   = tonumber(entry[1])
                            local icon = entry[2]
                            if id and id > 0 and type(icon) == "string" and icon ~= "" then
                                iconIndex[id] = "Interface\\Icons\\"..icon
                            end
                        end
                    end
                end
            end
        end
    end
end

function UnBot:GetItemIcon(id)
    if not id then return nil end

    -- slot 9 on this client; guard the type so a numeric field can never be
    -- handed to SetTexture, which would paint the button solid red
    local _, _, _, _, _, _, _, _, tex = GetItemInfo(id)
    if type(tex) == "string" and tex ~= "" then return tex end

    if iconIndex == nil then BuildIconIndex() end
    return iconIndex[id]
end

function UnBot:IconIndexSize()
    if iconIndex == nil then BuildIconIndex() end
    local n = 0
    for _ in pairs(iconIndex) do n = n + 1 end
    return n
end

local QUALITY_COLOR = {
    [0] = {0.62, 0.62, 0.62},   -- poor
    [1] = {1.00, 1.00, 1.00},   -- common
    [2] = {0.12, 1.00, 0.00},   -- uncommon
    [3] = {0.00, 0.44, 0.87},   -- rare
    [4] = {0.64, 0.21, 0.93},   -- epic
    [5] = {1.00, 0.50, 0.00},   -- legendary
}

-- Whispers that confirm an action rather than list inventory.
local CONFIRMATIONS = {
    "destroyed", "equipped", "sold to", " sold", "using ", "vendored",
    "cannot", "can't", "not found", "no such",
}

--=========================================================================--
--  Parsing
--=========================================================================--

local function IsConfirmation(msg)
    local lower = string.lower(msg)
    for i = 1, table.getn(CONFIRMATIONS) do
        if string.find(lower, CONFIRMATIONS[i], 1, true) then return true end
    end
    return false
end

-- "|cff...|Hitem:3777:0:0:0|h[Lesser Healing Potion]|h|r x3"
local function ParseItemLink(msg)
    local _, _, id, name = string.find(msg, "Hitem:(%d+):[^|]*|h%[([^%]]+)%]")
    if not id then return nil end

    -- keep the link exactly as sent; the bot expects it back verbatim
    local _, _, link = string.find(msg, "(|c%x+|Hitem:[^|]*|h%[[^%]]+%]|h|r)")
    if not link then
        local _, _, bare = string.find(msg, "(|Hitem:[^|]*|h%[[^%]]+%]|h)")
        link = bare
    end

    local count = 1
    local _, _, n = string.find(msg, "|h|r?%s*x%s*(%d+)")
    if n then count = tonumber(n) end

    return { id = tonumber(id), name = name, link = link, count = count }
end

--=========================================================================--
--  Window
--=========================================================================--

function UnBot:ShowItemWindow(mode)
    local target = self:GetBotTarget()
    if not target then return end

    if not UnBotItemFrame then self:CreateItemFrame() end

    self.itemMode   = mode or "view"
    self.itemTarget = target
    self.itemOffset = 0
    self.itemMap    = {}

    UnBotItemFrame:Show()
    self:RefreshItems()
    self:RequestItems()
end

function UnBot:RequestItems()
    if not self.itemTarget then return end
    self.itemMap    = {}
    self.itemOffset = 0
    self:RefreshItems()
    SendChatMessage("c", "WHISPER", nil, self.itemTarget)
end

function UnBot:CreateItemFrame()
    local f = CreateFrame("Frame", "UnBotItemFrame", UIParent)
    f:SetWidth(COLS * (SLOT_SIZE + SLOT_GAP) + 34)
    f:SetHeight(ROWS * (SLOT_SIZE + SLOT_GAP) + 140)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, -40)
    f:EnableMouseWheel(true)
    self:MakeDraggable(f)
    self:RestoreFramePosition(f)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetScript("OnMouseWheel", function() UnBot:ScrollItems(-arg1) end)
    f:Hide()

    if UISpecialFrames then
        table.insert(UISpecialFrames, "UnBotItemFrame")
    end

    local title = f:CreateFontString("UnBotItemFrameTitle", "OVERLAY")
    title:SetFont(UnBotFont, 14)
    title:SetPoint("TOP", f, "TOP", 0, -16)
    title:SetTextColor(1, 0.82, 0)
    f.title = title

    local close = CreateFrame("Button", "UnBotItemClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)

    self:CreateModeTabs(f)
    self:CreateItemSlots(f)

    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont(UnBotFont, 10)
    hint:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 20, 20)
    hint:SetTextColor(0.6, 0.6, 0.6)
    f.hint = hint

    local refresh = CreateFrame("Button", "UnBotItemRefresh", f, "UIPanelButtonTemplate")
    refresh:SetWidth(90)
    refresh:SetHeight(21)
    refresh:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 14)
    refresh:SetText("Refresh")
    refresh:SetScript("OnClick", function() UnBot:RequestItems() end)
end

function UnBot:CreateModeTabs(parent)
    self.modeTabs = {}

    for i = 1, table.getn(MODE_ORDER) do
        local mode = MODE_ORDER[i]
        local btn = CreateFrame("Button", "UnBotItemTab"..mode, parent, "UIPanelButtonTemplate")
        btn:SetWidth(64)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 16 + (i - 1) * 66, -38)
        btn:SetText(MODES[mode].title)
        btn.mode = mode
        btn:SetScript("OnClick", function()
            UnBot.itemMode   = this.mode
            UnBot.itemOffset = 0
            UnBot:RefreshItems()
        end)
        self.modeTabs[mode] = btn
    end
end

function UnBot:CreateItemSlots(parent)
    self.itemSlots = {}

    for row = 1, ROWS do
        for col = 1, COLS do
            local index = (row - 1) * COLS + col
            local slot = CreateFrame("Button", "UnBotItemSlot"..index, parent)
            slot:SetWidth(SLOT_SIZE)
            slot:SetHeight(SLOT_SIZE)
            slot:SetPoint("TOPLEFT", parent, "TOPLEFT",
                          16 + (col - 1) * (SLOT_SIZE + SLOT_GAP),
                          -66 - (row - 1) * (SLOT_SIZE + SLOT_GAP))
            slot:RegisterForClicks("LeftButtonUp")

            -- quality tint, sitting a couple of pixels behind the icon
            local border = slot:CreateTexture(nil, "BACKGROUND")
            border:SetPoint("TOPLEFT", slot, "TOPLEFT", -2, 2)
            border:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 2, -2)
            slot.border = border

            local icon = slot:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(slot)
            slot.icon = icon

            slot:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

            local count = slot:CreateFontString(nil, "OVERLAY")
            count:SetFont(UnBotFont, 11, "OUTLINE")
            count:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -2, 2)
            count:SetTextColor(1, 1, 1)
            slot.count = count

            slot:SetScript("OnClick", function()
                UnBot:UseItemEntry(this.entry)
            end)

            slot:SetScript("OnEnter", function()
                if not this.entry then return end
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")

                -- 1.12 wants the bare "item:id:0:0:0" form here; handing it the
                -- full |H...|h chat link produces an empty tooltip.
                if this.entry.id then
                    GameTooltip:SetHyperlink("item:"..this.entry.id..":0:0:0")
                end
                if GameTooltip:NumLines() == 0 then
                    GameTooltip:AddLine(this.entry.name, 1, 1, 1)
                end

                if this.entry.count and this.entry.count > 1 then
                    GameTooltip:AddLine("Stack of "..this.entry.count, 0.7, 0.7, 0.7)
                end
                if UnBot.debug then
                    GameTooltip:AddLine("id "..tostring(this.entry.id), 0.5, 0.5, 0.5)
                end

                local mode = MODES[UnBot.itemMode]
                GameTooltip:AddLine(" ")
                if mode and mode.command then
                    GameTooltip:AddLine("Click to "..mode.title, 0.2, 1, 0.2)
                else
                    GameTooltip:AddLine("Pick a tab above to act on this",
                                        0.6, 0.6, 0.6)
                end
                GameTooltip:Show()
            end)
            slot:SetScript("OnLeave", function() GameTooltip:Hide() end)

            slot:Hide()
            self.itemSlots[index] = slot
        end
    end
end

function UnBot:UseItemEntry(entry)
    if not entry then return end

    local mode = MODES[self.itemMode]
    if not mode or not mode.command then
        self:Message("This tab only lists - pick Equip, Use, Sell or Destroy")
        return
    end

    -- send back the exact link the bot gave us
    local payload = entry.link or entry.name
    SendChatMessage(mode.command..payload, "WHISPER", nil, self.itemTarget)
    self:Message(mode.title.." "..entry.name.." -> "..self.itemTarget)
end

--=========================================================================--
--  Receiving
--=========================================================================--

function UnBot:InitItemEvents()
    local f = CreateFrame("Frame", "UnBotItemEvents")
    f:RegisterEvent("CHAT_MSG_WHISPER")
    f:SetScript("OnEvent", function()
        UnBot:ReceiveItemWhisper(arg1, arg2)
    end)
end

function UnBot:ReceiveItemWhisper(msg, sender)
    if not msg or not sender then return end
    if not UnBotItemFrame or not UnBotItemFrame:IsShown() then return end
    if sender ~= self.itemTarget then return end
    if IsConfirmation(msg) then return end

    local item = ParseItemLink(msg)
    if not item then return end

    -- Keyed by name so an item can only ever exist once: the bot sends one
    -- line per bag slot, and replies to an earlier request keep arriving after
    -- the list was cleared, which otherwise stacked the whole inventory up two
    -- or three times over.
    if self.itemMap == nil then self.itemMap = {} end

    local known = self.itemMap[item.name]
    if known then
        -- same item again: keep the larger stack rather than adding, since a
        -- repeat of one reply must not inflate the count
        if (item.count or 1) > (known.count or 1) then
            known.count = item.count
        end
    else
        self.itemMap[item.name] = item
    end

    self:RefreshItems()
end

--=========================================================================--
--  Drawing
--=========================================================================--

function UnBot:GetShownItems()
    local mode  = MODES[self.itemMode] or MODES.view
    local shown = {}
    for _, entry in pairs(self.itemMap or {}) do
        if ItemPassesFilter(entry.id, mode.filter) then
            table.insert(shown, entry)
        end
    end

    -- The bot's replies do not arrive in a fixed order, so sort by name to
    -- keep the grid stable between refreshes and put identical items adjacent.
    table.sort(shown, function(a, b)
        if a.name == b.name then
            return (a.id or 0) < (b.id or 0)
        end
        return a.name < b.name
    end)

    return shown
end

function UnBot:ScrollItems(delta)
    local total = table.getn(self:GetShownItems())
    local maxOffset = total - (COLS * ROWS)
    if maxOffset < 0 then maxOffset = 0 end

    self.itemOffset = self.itemOffset + delta
    if self.itemOffset < 0 then self.itemOffset = 0 end
    if self.itemOffset > maxOffset then self.itemOffset = maxOffset end
    self:RefreshItems()
end

function UnBot:RefreshItems()
    if not UnBotItemFrame then return end

    local mode = MODES[self.itemMode] or MODES.view
    UnBotItemFrame.title:SetText((self.itemTarget or "?").."  -  "..mode.title)

    for name, btn in pairs(self.modeTabs) do
        if name == self.itemMode then
            btn:LockHighlight()
        else
            btn:UnlockHighlight()
        end
    end

    local shown = self:GetShownItems()

    for i = 1, COLS * ROWS do
        local slot  = self.itemSlots[i]
        local entry = shown[i + self.itemOffset]

        if entry then
            slot.entry = entry
            slot.icon:SetTexture(self:GetItemIcon(entry.id) or UNKNOWN_ICON)

            -- tint the frame behind the icon by item quality
            local quality
            if entry.id then
                local _, _, q = GetItemInfo(entry.id)
                quality = q
            end
            local c = QUALITY_COLOR[quality]
            if c and quality and quality > 1 then
                slot.border:SetTexture(c[1], c[2], c[3])
                slot.border:Show()
            else
                slot.border:Hide()
            end

            if entry.count and entry.count > 1 then
                slot.count:SetText(entry.count)
            else
                slot.count:SetText("")
            end
            slot:Show()
        else
            slot.entry = nil
            slot:Hide()
        end
    end

    local total = 0
    for _ in pairs(self.itemMap or {}) do total = total + 1 end
    local hidden = total - table.getn(shown)

    if total == 0 then
        UnBotItemFrame.hint:SetText("Waiting for "..(self.itemTarget or "the bot").."...")
    elseif hidden > 0 then
        UnBotItemFrame.hint:SetText(table.getn(shown).." shown, "..hidden.." filtered out")
    else
        UnBotItemFrame.hint:SetText(total.." items")
    end
end
