-- Retinue - Bot Equipment Paperdoll & Bags Inspector
--
-- Supports both:
--   1. Modern TortoiseBots Protocol (TBM:INV_BEGIN, TBM:INV_EQ, TBM:INV_ITEM, TBM:INV_END)
--   2. Legacy whispers ('c', 'e <link>', 's <link>', 'u <link>', 'destroy <link>')
--
-- Features:
--   - Full 3D PlayerModel paperdoll view surrounded by 19 equipment slots
--   - Multi-tab UI: [Gear], [Bags], [Behaviour]
--   - Real-time durability status, upgrade indicators, and quality borders
--   - Non-intrusive item cache queries (scanTip:SetHyperlink)
--   - Contextual item action menu: Equip / Unequip / Give to me / Trade

Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue
local C = Retinue.C or {}

local PW = 340
local PH = 480
local SLOT_SIZE = 34
local STEP = 38
local BAG_COLS = 8
local BAG_ROWS = 7
local EQUIPPED_BAG = 255 -- INVENTORY_SLOT_BAG_0
local UNKNOWN_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local QUALITY_COLOR = {
    [0] = { 0.62, 0.62, 0.62 }, -- poor
    [1] = { 1.00, 1.00, 1.00 }, -- common
    [2] = { 0.12, 1.00, 0.00 }, -- uncommon
    [3] = { 0.00, 0.44, 0.87 }, -- rare
    [4] = { 0.64, 0.21, 0.93 }, -- epic
    [5] = { 1.00, 0.50, 0.00 }, -- legendary
}

local function NormalizeName(name)
    if not name then return "" end
    name = string.gsub(name, "%-.*$", "")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    if name == "" then return "" end
    return string.upper(string.sub(name, 1, 1)) .. string.lower(string.sub(name, 2))
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

--=========================================================================--
--  Item Icons & AtlasLoot Cache Fallback
--=========================================================================--

local iconIndex = nil

local function BuildIconIndex()
    iconIndex = {}
    if not AtlasLoot_Data then return end
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
    local _, _, _, _, _, _, _, _, tex = GetItemInfo(id)
    if type(tex) == "string" and tex ~= "" then return tex end
    if iconIndex == nil then BuildIconIndex() end
    return iconIndex and iconIndex[id] or nil
end

--=========================================================================--
--  Item Info, Tooltip Queries & Formatting
--=========================================================================--

local scanTip = nil
local uncachedAt = nil

local function requestItem(id)
    if not id or tonumber(id) == nil or tonumber(id) <= 0 then return end
    if not scanTip then
        scanTip = CreateFrame("GameTooltip", "UnBotScanTip", UIParent, "GameTooltipTemplate")
    end
    if scanTip.SetOwner and scanTip.SetHyperlink then
        scanTip:SetOwner(UIParent, "ANCHOR_NONE")
        scanTip:SetHyperlink("item:" .. id .. ":0:0:0")
    end
    uncachedAt = uncachedAt or ((GetTime and GetTime()) or 0)
end

local function itemInfo(id)
    if not id or not GetItemInfo then return nil end
    local name, link, quality, _, _, _, _, _, texture = GetItemInfo(id)
    if not texture then
        texture = UnBot:GetItemIcon(id)
    end
    return name, link, quality, texture
end

local function qualityColor(quality)
    if quality and GetItemQualityColor then
        local r, g, b, hex = GetItemQualityColor(quality)
        if r then return r, g, b, hex end
    end
    local c = QUALITY_COLOR[quality]
    if c then
        return c[1], c[2], c[3], "|cffffffff"
    end
    return 0.35, 0.35, 0.35, "|cffffffff"
end

local function chatLink(id)
    local name, link, quality = itemInfo(id)
    if not name then return nil end
    local _, _, _, hex = qualityColor(quality)
    local cleanLink = link or ("item:" .. id .. ":0:0:0")
    return (hex or "|cffffffff") .. "|H" .. cleanLink .. "|h[" .. name .. "]|h|r"
end

local function formatMoney(copper)
    copper = tonumber(copper) or 0
    local g = math.floor(copper / 10000)
    local s = math.floor(math.mod(copper, 10000) / 100)
    local c = math.mod(copper, 100)
    local text = ""
    if g > 0 then text = text .. "|cffffd700" .. g .. "g|r " end
    if g > 0 or s > 0 then text = text .. "|cffc7c7cf" .. s .. "s|r " end
    return text .. "|cffeda55f" .. c .. "c|r"
end
UnBot.FormatMoney = formatMoney

local function botUnit(name)
    name = NormalizeName(name)
    if not name or name == "" or not UnitName then return nil end

    if UnitExists("target") and NormalizeName(UnitName("target")) == name then
        return "target"
    end

    local party = (GetNumPartyMembers and GetNumPartyMembers()) or 0
    for i = 1, party do
        local u = "party" .. i
        if NormalizeName(UnitName(u)) == name then return u end
    end

    local raid = (GetNumRaidMembers and GetNumRaidMembers()) or 0
    if raid > 0 then
        for i = 1, raid do
            local u = "raid" .. i
            if NormalizeName(UnitName(u)) == name then return u end
        end
    end

    if UnBot.GetGroupUnit then
        local u = UnBot:GetGroupUnit(name)
        if u and UnitExists(u) and NormalizeName(UnitName(u)) == name then return u end
    end

    return nil
end

local function botClassId(name)
    local unit = botUnit(name)
    if unit and UnitClass then
        local className, classFile = UnitClass(unit)
        local ids = (C and C.CLASS_NAME_TO_ID) or {}
        local id = ids[classFile or ""] or ids[className or ""]
        if id then return id end
    end
    local roster = UnBot.config and UnBot.config.roster and UnBot.config.roster[name]
    if roster and roster.classId then return roster.classId end
    local claimed = UnBot.claimedState and UnBot.claimedState[name]
    if claimed and claimed.classId then return claimed.classId end
    return nil
end

--=========================================================================--
--  Protocol Parser: TBM:INV_* & TBM:BOTSTATE
--=========================================================================--

function UnBot:GetInventory(name)
    name = NormalizeName(name)
    if not name or not self.botInventories then return nil end
    return self.botInventories[name]
end

function UnBot:RequestBotInventory(name)
    name = NormalizeName(name)
    if not name or name == "" then return false end
    self:SendBotCommand("inv " .. name)
    SendChatMessage("c", "WHISPER", nil, name)
    return true
end

function UnBot:ParseBotInspectorMessage(msg)
    if not msg or string.sub(msg, 1, 4) ~= "TBM:" then return false end

    -- TBM:INV_BEGIN|<bot>|<copper>
    if string.sub(msg, 1, 14) == "TBM:INV_BEGIN|" then
        local raw = string.sub(msg, 15)
        local parts = splitProtocol(raw)
        local name = parts[1]
        local copper = tonumber(parts[2]) or 0
        if name and name ~= "" then
            name = NormalizeName(name)
            self.invReceiving = {
                name = name,
                money = copper,
                equipped = {},
                items = {},
            }
        else
            self.invReceiving = nil
        end
        return true
    end

    -- TBM:INV_EQ|<slot>|<itemId>|<durability>|<maxDurability>
    if string.sub(msg, 1, 11) == "TBM:INV_EQ|" then
        local raw = string.sub(msg, 12)
        local parts = splitProtocol(raw)
        if self.invReceiving and table.getn(parts) >= 4 then
            local slot = tonumber(parts[1])
            local id = tonumber(parts[2])
            local dur = tonumber(parts[3]) or 0
            local maxDur = tonumber(parts[4]) or 0
            if slot and id and id > 0 then
                self.invReceiving.equipped[slot] = {
                    id = id,
                    durability = dur,
                    maxDurability = maxDur,
                }
                requestItem(id)
            end
        end
        return true
    end

    -- TBM:INV_ITEM|<bag>|<slot>|<itemId>|<count>|<flags>
    if string.sub(msg, 1, 13) == "TBM:INV_ITEM|" then
        local raw = string.sub(msg, 14)
        local parts = splitProtocol(raw)
        if self.invReceiving and table.getn(parts) >= 4 then
            local bag = tonumber(parts[1])
            local slot = tonumber(parts[2])
            local id = tonumber(parts[3])
            local count = tonumber(parts[4]) or 1
            local flags = parts[5] or "-"
            if bag and slot and id and id > 0 then
                table.insert(self.invReceiving.items, {
                    bag = bag,
                    slot = slot,
                    id = id,
                    count = count,
                    equippable = string.find(flags, "e", 1, true) ~= nil,
                    upgrade = string.find(flags, "u", 1, true) ~= nil,
                    noTrade = string.find(flags, "b", 1, true) ~= nil,
                })
                requestItem(id)
            end
        end
        return true
    end

    -- TBM:INV_END|<bot>|<freeSlots>|<totalSlots>
    if string.sub(msg, 1, 12) == "TBM:INV_END|" then
        local raw = string.sub(msg, 13)
        local parts = splitProtocol(raw)
        local inv = self.invReceiving
        self.invReceiving = nil
        local name = parts[1] and NormalizeName(parts[1]) or nil
        if inv and name and (name == inv.name or string.lower(name) == string.lower(inv.name or "")) then
            inv.free = tonumber(parts[2]) or 0
            inv.total = tonumber(parts[3]) or 0
            inv.receivedAt = (GetTime and GetTime()) or 0

            self.botInventories = self.botInventories or {}
            self.botInventories[name] = inv

            if self.inspectorBot and NormalizeName(self.inspectorBot) == name then
                self:RefreshBotInspector()
            end
        end
        return true
    end

    -- TBM:BOTSTATE|<bot>|<movement>|<...behaviors...>
    if string.sub(msg, 1, 12) == "TBM:BOTSTATE|" then
        if self.ParseBotStateMessage and self:ParseBotStateMessage(msg) then
            return true
        end
        return true
    end

    return false
end

--=========================================================================--
--  Legacy Whisper Inventory Parsing
--=========================================================================--

local CONFIRMATIONS = {
    "destroyed", "equipped", "sold to", " sold", "using ", "vendored",
    "cannot", "can't", "not found", "no such",
}

local function IsConfirmation(msg)
    local lower = string.lower(msg)
    for i = 1, table.getn(CONFIRMATIONS) do
        if string.find(lower, CONFIRMATIONS[i], 1, true) then return true end
    end
    return false
end

local function ParseItemLink(msg)
    local _, _, id, name = string.find(msg, "Hitem:(%d+):[^|]*|h%[([^%]]+)%]")
    if not id then return nil end
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

function UnBot:ReceiveItemWhisper(msg, sender)
    if not msg or not sender then return end
    if not UnBotItemFrame or not UnBotItemFrame:IsShown() then return end
    if NormalizeName(sender) ~= NormalizeName(self.inspectorBot) then return end
    if IsConfirmation(msg) then return end

    local item = ParseItemLink(msg)
    if not item then return end

    self.itemMap = self.itemMap or {}
    local known = self.itemMap[item.name]
    if known then
        if (item.count or 1) > (known.count or 1) then
            known.count = item.count
        end
    else
        self.itemMap[item.name] = item
    end

    self:RefreshBotInspector()
end

--=========================================================================--
--  Event Registration
--=========================================================================--

function UnBot:InitItemEvents()
    if self.itemEventsFrame then return end
    local f = CreateFrame("Frame", "UnBotItemEventsFrame")
    f:RegisterEvent("CHAT_MSG_WHISPER")
    f:RegisterEvent("CHAT_MSG_SYSTEM")
    f:RegisterEvent("CHAT_MSG_ADDON")
    f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    f:SetScript("OnEvent", function()
        if event == "CHAT_MSG_ADDON" then
            if arg1 == "TBM" and arg2 then
                UnBot:ParseBotInspectorMessage(arg2)
            end
        elseif event == "CHAT_MSG_SYSTEM" and arg1 then
            if string.find(arg1, "^TBM:") then
                UnBot:ParseBotInspectorMessage(arg1)
            end
        elseif event == "CHAT_MSG_WHISPER" then
            UnBot:ReceiveItemWhisper(arg1, arg2)
        elseif event == "GET_ITEM_INFO_RECEIVED" then
            if UnBotItemFrame and UnBotItemFrame:IsShown() then
                UnBot:RefreshBotInspector()
            end
        end
    end)
    self.itemEventsFrame = f
end

--=========================================================================--
--  Action Context Menu (Equip / Unequip / Give to me)
--=========================================================================--

local function createContextMenu(parent)
    local menu = CreateFrame("Frame", "UnBotItemContextMenu", parent)
    menu:SetWidth(120)
    menu:SetHeight(58)
    menu:SetFrameStrata("TOOLTIP")
    menu:EnableMouse(true)
    menu:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    local first = CreateFrame("Button", "UnBotContextMenuFirst", menu, "UIPanelButtonTemplate")
    first:SetWidth(108)
    first:SetHeight(22)
    first:SetPoint("TOPLEFT", menu, "TOPLEFT", 6, -6)
    first:SetText("Equip")
    menu.first = first

    local second = CreateFrame("Button", "UnBotContextMenuSecond", menu, "UIPanelButtonTemplate")
    second:SetWidth(108)
    second:SetHeight(22)
    second:SetPoint("TOPLEFT", menu, "TOPLEFT", 6, -30)
    second:SetText("Give to me")
    menu.second = second

    function menu:Open(owner, entry)
        self.owner = owner
        self.entry = entry
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", owner, "BOTTOMRIGHT", -8, 8)

        if entry.equipped then
            self.first:SetText("Unequip")
            self.first:Enable()
            self.first.op = "unequip"
            self.second:Hide()
            self:SetHeight(34)
        else
            self.first:SetText("Equip")
            self.first.op = "equip"
            if entry.equippable then self.first:Enable() else self.first:Disable() end
            self.second:Show()
            if entry.noTrade then self.second:Disable() else self.second:Enable() end
            self:SetHeight(58)
        end
        self:Show()
    end

    first:SetScript("OnClick", function()
        local entry = menu.entry
        local bot = UnBot.inspectorBot
        menu:Hide()
        menu.owner = nil
        if entry and bot then
            UnBot:SendBotCommand("item " .. bot .. " " .. menu.first.op .. " " .. (entry.bag or EQUIPPED_BAG) .. " " .. (entry.slot or 0))
        end
    end)

    second:SetScript("OnClick", function()
        local entry = menu.entry
        local bot = UnBot.inspectorBot
        menu:Hide()
        menu.owner = nil
        if entry and bot then
            UnBot:SendBotCommand("item " .. bot .. " give " .. (entry.bag or 0) .. " " .. (entry.slot or 0))
        end
    end)

    menu:Hide()
    return menu
end

--=========================================================================--
--  Item Slot Button Constructor
--=========================================================================--

local function createSlotButton(parent, slotSize)
    slotSize = slotSize or SLOT_SIZE
    local b = CreateFrame("Button", nil, parent)
    b:SetWidth(slotSize)
    b:SetHeight(slotSize)
    b:EnableMouse(true)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local border = b:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints(b)
    border:SetTexture(0.25, 0.25, 0.25, 0.9)
    b.border = border

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    b.icon = icon

    local count = b:CreateFontString(nil, "OVERLAY")
    count:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    count:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    count:SetTextColor(1, 1, 1)
    b.count = count

    local badge = b:CreateFontString(nil, "OVERLAY")
    badge:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    badge:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -1)
    badge:SetText("|cff40ff40+|r")
    badge:Hide()
    b.badge = badge

    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

    b:SetScript("OnEnter", function()
        local entry = this.entry
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if entry and entry.id then
            GameTooltip:SetHyperlink("item:" .. entry.id .. ":0:0:0")
            if GameTooltip:NumLines() == 0 then
                GameTooltip:AddLine("item #" .. tostring(entry.id), 1, 1, 1)
            end
            if entry.maxDurability and entry.maxDurability > 0 then
                local pct = math.floor((entry.durability or 0) / entry.maxDurability * 100 + 0.5)
                local durColor = pct < 25 and "|cffff4030" or (pct < 60 and "|cffffd200" or "|cff80ff80")
                GameTooltip:AddLine(durColor .. "Durability " .. (entry.durability or 0) .. " / " .. entry.maxDurability .. " (" .. pct .. "%)|r")
            end
            if entry.upgrade then
                GameTooltip:AddLine("Upgrade for " .. (UnBot.inspectorBot or "this bot"), 0.25, 1, 0.25)
            end
            if entry.equipped then
                GameTooltip:AddLine("Click: unequip", 0.62, 0.60, 0.56)
            else
                local hint = entry.equippable and "Click: equip or give to you" or "Click: give to you"
                if entry.noTrade and entry.equippable then hint = "Click: equip (cannot be traded)" end
                if entry.noTrade and not entry.equippable then hint = "Soulbound - stays with the bot" end
                GameTooltip:AddLine(hint, 0.62, 0.60, 0.56)
            end
            GameTooltip:AddLine("Shift-click: link in chat", 0.62, 0.60, 0.56)
        else
            GameTooltip:SetText(this.slotLabel or "Empty")
            GameTooltip:AddLine("Nothing equipped", 0.62, 0.60, 0.56)
        end
        GameTooltip:Show()
    end)

    b:SetScript("OnLeave", function() GameTooltip:Hide() end)

    b:SetScript("OnClick", function()
        local entry = this.entry
        if not entry or not entry.id then return end
        if IsShiftKeyDown and IsShiftKeyDown() then
            local link = chatLink(entry.id)
            if link and ChatFrameEditBox and ChatFrameEditBox.IsVisible and ChatFrameEditBox:IsVisible() then
                ChatFrameEditBox:Insert(link)
            end
            return
        end
        if UnBotItemFrame and UnBotItemFrame.contextMenu then
            if UnBotItemFrame.contextMenu.owner == this and UnBotItemFrame.contextMenu:IsVisible() then
                UnBotItemFrame.contextMenu:Hide()
                UnBotItemFrame.contextMenu.owner = nil
                return
            end
            UnBotItemFrame.contextMenu:Open(this, entry)
        end
    end)

    return b
end

local function paintItemButton(b, entry, emptyTexture)
    b.entry = entry
    if entry and entry.id then
        local name, link, quality, texture = itemInfo(entry.id)
        if not texture then
            requestItem(entry.id)
            texture = UNKNOWN_ICON
        end
        b.icon:SetTexture(texture)
        b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        local r, g, bl = qualityColor(quality)
        if entry.maxDurability and entry.maxDurability > 0
            and (entry.durability or 0) / entry.maxDurability < 0.25 then
            r, g, bl = 1, 0.15, 0.1 -- nearly broken: red frame
        end
        b.border:SetTexture(r, g, bl, 0.95)
        if entry.count and entry.count > 1 then
            b.count:SetText(tostring(entry.count))
        else
            b.count:SetText("")
        end
        if entry.upgrade then
            b.badge:Show()
        else
            b.badge:Hide()
        end
        if b.icon.SetVertexColor then
            if entry.noTrade and not entry.equippable and not entry.equipped then
                b.icon:SetVertexColor(0.7, 0.7, 0.7)
            else
                b.icon:SetVertexColor(1, 1, 1)
            end
        end
    else
        b.icon:SetTexture(emptyTexture or "")
        b.icon:SetTexCoord(0, 1, 0, 1)
        if b.icon.SetVertexColor then b.icon:SetVertexColor(1, 1, 1) end
        b.border:SetTexture(0.12, 0.12, 0.12, 0.9)
        b.count:SetText("")
        b.badge:Hide()
    end
    b:Show()
end

--=========================================================================--
--  Main Inspector Frame Construction
--=========================================================================--

function UnBot:CreateItemFrame()
    if UnBotItemFrame then return end

    local f = CreateFrame("Frame", "UnBotItemFrame", UIParent)
    f:SetWidth(PW)
    f:SetHeight(PH)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, -20)
    f:EnableMouse(true)
    self:MakeDraggable(f)
    self:RestoreFramePosition(f)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    if UISpecialFrames then
        table.insert(UISpecialFrames, "UnBotItemFrame")
    end

    -- Header Labels
    local title = f:CreateFontString("UnBotItemFrameTitle", "OVERLAY")
    title:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 14)
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -14)
    title:SetTextColor(1, 0.82, 0)
    f.title = title

    local subTitle = f:CreateFontString("UnBotItemFrameSubTitle", "OVERLAY")
    subTitle:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
    subTitle:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -28)
    subTitle:SetTextColor(0.7, 0.7, 0.7)
    f.subTitle = subTitle

    local moneyText = f:CreateFontString("UnBotItemFrameMoney", "OVERLAY")
    moneyText:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
    moneyText:SetPoint("TOPRIGHT", f, "TOPRIGHT", -36, -16)
    moneyText:SetJustifyH("RIGHT")
    f.moneyText = moneyText

    local close = CreateFrame("Button", "UnBotItemClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -6)
    close:SetScript("OnClick", function()
        if f.contextMenu then f.contextMenu:Hide() end
        f:Hide()
    end)

    -- Tab Bar (Gear, Bags, Behaviour)
    -- Tab Bar (Gear, Bags)
    local tabGear = CreateFrame("Button", "UnBotItemTabGear", f, "UIPanelButtonTemplate")
    tabGear:SetWidth(150)
    tabGear:SetHeight(20)
    tabGear:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -44)
    tabGear:SetText("Gear")
    tabGear:SetScript("OnClick", function()
        UnBot.inspectorView = "gear"
        if f.contextMenu then f.contextMenu:Hide() end
        UnBot:RefreshBotInspector()
    end)
    f.tabGear = tabGear

    local tabBags = CreateFrame("Button", "UnBotItemTabBags", f, "UIPanelButtonTemplate")
    tabBags:SetWidth(150)
    tabBags:SetHeight(20)
    tabBags:SetPoint("TOPLEFT", tabGear, "TOPRIGHT", 8, 0)
    tabBags:SetText("Bags")
    tabBags:SetScript("OnClick", function()
        UnBot.inspectorView = "bags"
        if f.contextMenu then f.contextMenu:Hide() end
        UnBot:RefreshBotInspector()
    end)
    f.tabBags = tabBags

    -- View 1: Gear Paperdoll View
    self:CreateGearPaperdollView(f)

    -- View 2: Bags View
    self:CreateBagsView(f)

    -- Footer Actions: Trade, Refresh, Catalog, Hint
    local tradeBtn = CreateFrame("Button", "UnBotItemTradeBtn", f, "UIPanelButtonTemplate")
    tradeBtn:SetWidth(76)
    tradeBtn:SetHeight(22)
    tradeBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 26)
    tradeBtn:SetText("Trade")
    tradeBtn:SetScript("OnClick", function()
        if UnBot.inspectorBot then
            UnBot:SendBotCommand("item " .. UnBot.inspectorBot .. " trade")
        end
    end)
    tradeBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOP")
        GameTooltip:AddLine("Open Trade", 1, 0.82, 0)
        GameTooltip:AddLine("Opens a trade window with this bot.\nPut items or gold in and accept - the bot accepts on its own.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tradeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f.tradeBtn = tradeBtn

    local refreshBtn = CreateFrame("Button", "UnBotItemRefreshBtn", f, "UIPanelButtonTemplate")
    refreshBtn:SetWidth(76)
    refreshBtn:SetHeight(22)
    refreshBtn:SetPoint("LEFT", tradeBtn, "RIGHT", 6, 0)
    refreshBtn:SetText("Refresh")
    refreshBtn:SetScript("OnClick", function()
        if UnBot.inspectorBot then
            UnBot:RequestBotInventory(UnBot.inspectorBot)
        end
    end)
    f.refreshBtn = refreshBtn

    local catalogBtn = CreateFrame("Button", "UnBotItemOpenCatalogBtn", f, "UIPanelButtonTemplate")
    catalogBtn:SetWidth(76)
    catalogBtn:SetHeight(22)
    catalogBtn:SetPoint("LEFT", refreshBtn, "RIGHT", 6, 0)
    catalogBtn:SetText("Catalog")
    catalogBtn:SetScript("OnClick", function()
        if UnBot.ShowCatalogWindow then
            UnBot:ShowCatalogWindow()
        end
    end)
    catalogBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOP")
        GameTooltip:AddLine("Item Catalog & Spawner", 1, 0.82, 0)
        GameTooltip:AddLine("Browse all 23k+ items and spawn onto target", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    catalogBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f.catalogBtn = catalogBtn

    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 9)
    hint:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 10)
    hint:SetTextColor(0.6, 0.6, 0.6)
    hint:SetText("Click an item for options. Shift-click links it in chat.")
    f.hint = hint

    f.contextMenu = createContextMenu(f)

    -- Dynamic Throttle on Cache Refreshes
    f:SetScript("OnUpdate", function()
        if uncachedAt and ((GetTime and GetTime()) or 0) - uncachedAt > 0.8 then
            uncachedAt = nil
            if UnBotItemFrame:IsShown() and UnBot.RefreshBotInspector then
                UnBot:RefreshBotInspector()
            end
        end
    end)

    f:Hide()
end

--=========================================================================--
--  View 1: Gear Paperdoll (Model + 19 Equipment Slots)
--=========================================================================--

function UnBot:CreateGearPaperdollView(parent)
    local gear = CreateFrame("Frame", "UnBotGearView", parent)
    gear:SetAllPoints(parent)
    parent.gearView = gear

    -- 3D Model Frame surrounded by dark backdrop
    local modelBg = gear:CreateTexture(nil, "BACKGROUND")
    modelBg:SetPoint("TOPLEFT", parent, "TOPLEFT", 52, -74)
    modelBg:SetWidth(236)
    modelBg:SetHeight(262)
    modelBg:SetTexture(0, 0, 0, 0.75)
    gear.modelBg = modelBg

    local model = CreateFrame("PlayerModel", "UnBotPaperDollModel", gear)
    model:SetPoint("TOPLEFT", parent, "TOPLEFT", 52, -74)
    model:SetWidth(236)
    model:SetHeight(262)
    model:EnableMouse(true)
    model:EnableMouseWheel(true)
    model.modelScale = 0.35
    model.currentRotation = 0

    model:SetScript("OnMouseDown", function()
        if arg1 == "LeftButton" then
            this.isDragging = true
            this.lastCursorX = GetCursorPosition()
        end
    end)
    model:SetScript("OnMouseUp", function()
        if arg1 == "LeftButton" then
            this.isDragging = false
        end
    end)
    model:SetScript("OnUpdate", function()
        if this.isDragging then
            local curX = GetCursorPosition()
            local delta = (curX - (this.lastCursorX or curX)) * 0.015
            this.lastCursorX = curX
            this.currentRotation = (this.currentRotation or 0) + delta
            pcall(function() this:SetRotation(this.currentRotation) end)
        end
    end)
    model:SetScript("OnMouseWheel", function()
        this.modelScale = (this.modelScale or 0.35) + arg1 * 0.05
        if this.modelScale < 0.15 then this.modelScale = 0.15 end
        if this.modelScale > 1.20 then this.modelScale = 1.20 end
        pcall(function() this:SetModelScale(this.modelScale) end)
    end)
    gear.model = model

    local modelNotice = gear:CreateFontString(nil, "OVERLAY")
    modelNotice:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
    modelNotice:SetPoint("CENTER", modelBg, "CENTER", 0, 0)
    modelNotice:SetWidth(210)
    modelNotice:SetJustifyH("CENTER")
    modelNotice:SetTextColor(0.85, 0.85, 0.65)
    modelNotice:SetText("(3D model requires bot in visual range)\nEquipped gear & bags are fully accessible.")
    modelNotice:Hide()
    gear.modelNotice = modelNotice

    local durabilityText = gear:CreateFontString(nil, "OVERLAY")
    durabilityText:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
    durabilityText:SetPoint("TOP", modelBg, "BOTTOM", 0, -6)
    durabilityText:SetWidth(236)
    durabilityText:SetJustifyH("CENTER")
    durabilityText:SetTextColor(0.9, 0.9, 0.9)
    gear.durabilityText = durabilityText

    gear.slots = {}

    -- Left Column (8 slots)
    local leftDefs = (C and C.GEAR_LEFT) or {
        { slot = 0,  label = "Head",     empty = "Head" },
        { slot = 1,  label = "Neck",     empty = "Neck" },
        { slot = 2,  label = "Shoulder", empty = "Shoulder" },
        { slot = 14, label = "Back",     empty = "Chest" },
        { slot = 4,  label = "Chest",    empty = "Chest" },
        { slot = 3,  label = "Shirt",    empty = "Shirt" },
        { slot = 18, label = "Tabard",   empty = "Tabard" },
        { slot = 8,  label = "Wrist",    empty = "Wrists" },
    }
    for i = 1, table.getn(leftDefs) do
        local def = leftDefs[i]
        local b = createSlotButton(gear, SLOT_SIZE)
        b:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, -74 - (i - 1) * STEP)
        b.slotId = def.slot
        b.slotLabel = def.label
        b.emptyTexture = "Interface\\PaperDoll\\UI-PaperDoll-Slot-" .. def.empty
        gear.slots[def.slot] = b
    end

    -- Right Column (8 slots)
    local rightDefs = (C and C.GEAR_RIGHT) or {
        { slot = 9,  label = "Hands",    empty = "Hands" },
        { slot = 5,  label = "Waist",    empty = "Waist" },
        { slot = 6,  label = "Legs",     empty = "Legs" },
        { slot = 7,  label = "Feet",     empty = "Feet" },
        { slot = 10, label = "Ring",     empty = "Finger" },
        { slot = 11, label = "Ring",     empty = "Finger" },
        { slot = 12, label = "Trinket",  empty = "Trinket" },
        { slot = 13, label = "Trinket",  empty = "Trinket" },
    }
    for i = 1, table.getn(rightDefs) do
        local def = rightDefs[i]
        local b = createSlotButton(gear, SLOT_SIZE)
        b:SetPoint("TOPLEFT", parent, "TOPLEFT", PW - 14 - SLOT_SIZE, -74 - (i - 1) * STEP)
        b.slotId = def.slot
        b.slotLabel = def.label
        b.emptyTexture = "Interface\\PaperDoll\\UI-PaperDoll-Slot-" .. def.empty
        gear.slots[def.slot] = b
    end

    -- Bottom Row (3 slots: Main Hand, Off Hand, Ranged)
    local bottomDefs = (C and C.GEAR_BOTTOM) or {
        { slot = 15, label = "Main hand", empty = "MainHand" },
        { slot = 16, label = "Off hand",  empty = "SecondaryHand" },
        { slot = 17, label = "Ranged",    empty = "Ranged" },
    }
    local x0 = math.floor((PW - (3 * STEP - 4)) / 2)
    for i = 1, table.getn(bottomDefs) do
        local def = bottomDefs[i]
        local b = createSlotButton(gear, SLOT_SIZE)
        b:SetPoint("TOPLEFT", parent, "TOPLEFT", x0 + (i - 1) * STEP, -374)
        b.slotId = def.slot
        b.slotLabel = def.label
        b.emptyTexture = "Interface\\PaperDoll\\UI-PaperDoll-Slot-" .. def.empty
        gear.slots[def.slot] = b
    end
end

--=========================================================================--
--  View 2: Bags View (Paged 8x7 Grid)
--=========================================================================--

function UnBot:CreateBagsView(parent)
    local bags = CreateFrame("Frame", "UnBotBagsView", parent)
    bags:SetAllPoints(parent)
    parent.bagsView = bags

    local bagSummary = bags:CreateFontString(nil, "OVERLAY")
    bagSummary:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
    bagSummary:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -74)
    bagSummary:SetWidth(PW - 32)
    bagSummary:SetJustifyH("LEFT")
    bagSummary:SetTextColor(0.8, 0.8, 0.8)
    bags.bagSummary = bagSummary

    bags.slots = {}
    local x0 = math.floor((PW - (BAG_COLS * STEP - 4)) / 2)
    for r = 1, BAG_ROWS do
        for c = 1, BAG_COLS do
            local b = createSlotButton(bags, SLOT_SIZE)
            b:SetPoint("TOPLEFT", parent, "TOPLEFT", x0 + (c - 1) * STEP, -94 - (r - 1) * STEP)
            table.insert(bags.slots, b)
        end
    end

    local prev = CreateFrame("Button", "UnBotBagsPrevBtn", bags, "UIPanelButtonTemplate")
    prev:SetWidth(26)
    prev:SetHeight(20)
    prev:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -366)
    prev:SetText("<")
    prev:SetScript("OnClick", function()
        UnBot.bagPage = (UnBot.bagPage or 1) - 1
        if UnBotItemFrame.contextMenu then UnBotItemFrame.contextMenu:Hide() end
        UnBot:RefreshBotInspector()
    end)
    bags.prev = prev

    local pageText = bags:CreateFontString(nil, "OVERLAY")
    pageText:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 10)
    pageText:SetPoint("TOPLEFT", parent, "TOPLEFT", 44, -370)
    pageText:SetWidth(56)
    pageText:SetJustifyH("CENTER")
    pageText:SetTextColor(0.9, 0.9, 0.9)
    bags.pageText = pageText

    local nextBtn = CreateFrame("Button", "UnBotBagsNextBtn", bags, "UIPanelButtonTemplate")
    nextBtn:SetWidth(26)
    nextBtn:SetHeight(20)
    nextBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 102, -366)
    nextBtn:SetText(">")
    nextBtn:SetScript("OnClick", function()
        UnBot.bagPage = (UnBot.bagPage or 1) + 1
        if UnBotItemFrame.contextMenu then UnBotItemFrame.contextMenu:Hide() end
        UnBot:RefreshBotInspector()
    end)
    bags.nextBtn = nextBtn

    local legend = bags:CreateFontString(nil, "OVERLAY")
    legend:SetFont(UnBotFont or "Fonts\\FRIZQT__.TTF", 9)
    legend:SetPoint("TOPLEFT", parent, "TOPLEFT", 136, -370)
    legend:SetWidth(PW - 150)
    legend:SetJustifyH("RIGHT")
    legend:SetTextColor(0.6, 0.6, 0.6)
    legend:SetText("|cff40ff40+|r upgrade · grey = soulbound")
    bags.legend = legend

    bags:Hide()
end

--=========================================================================--
--  Refreshing & Drawing
--=========================================================================--

function UnBot:RefreshBotInspector()
    local f = UnBotItemFrame
    if not f or not f:IsShown() then return end

    local bot = self.inspectorBot
    if not bot or bot == "" then
        f.title:SetText("No Bot Selected")
        f.subTitle:SetText("Shift-click a bot in the Roster to inspect.")
        f.moneyText:SetText("")
        return
    end

    local inv = self:GetInventory(bot)
    local classId = botClassId(bot)
    local col = (self.GetClassColor and self:GetClassColor(classId)) or { 1, 0.82, 0 }

    f.title:SetText(bot)
    f.title:SetTextColor(col[1], col[2], col[3])

    local parts = {}
    local unit = botUnit(bot)
    local claimed = self.claimedState and self.claimedState[bot]
    if unit and UnitLevel then
        local lvl = UnitLevel(unit)
        if lvl and lvl > 0 then table.insert(parts, "Lvl " .. lvl) end
    elseif claimed and claimed.level then
        table.insert(parts, "Lvl " .. claimed.level)
    end
    if classId and self.GetClassName then
        table.insert(parts, self:GetClassName(classId))
    end
    if claimed then
        if claimed.gearLocked then
            table.insert(parts, "|cffffd200Gear Locked|r")
        else
            table.insert(parts, "|cff4ecb5aLeveling|r")
        end
    end
    f.subTitle:SetText(table.concat(parts, " · "))
    f.moneyText:SetText(inv and formatMoney(inv.money) or "")

    local bagItemCount = inv and table.getn(inv.items) or 0
    f.tabBags:SetText(bagItemCount > 0 and ("Bags (" .. bagItemCount .. ")") or "Bags")

    local view = self.inspectorView or "gear"
    f.gearView:Hide()
    f.bagsView:Hide()
    f.tabGear:Enable()
    f.tabBags:Enable()

    if view == "bags" then
        f.bagsView:Show()
        f.tabBags:Disable()
        self:RenderBagsView(inv)
    else
        f.gearView:Show()
        f.tabGear:Disable()
        self:RenderGearView(inv)
    end
end

function UnBot:RenderGearView(inv)
    local f = UnBotItemFrame
    local gear = f.gearView
    local equipped = inv and inv.equipped or {}
    local lowestDur = nil
    local upgradesInBags = 0

    -- Paint 19 Equipment Slots
    for slotId, btn in pairs(gear.slots) do
        local item = equipped[slotId]
        local entry = item and {
            id = item.id,
            bag = EQUIPPED_BAG,
            slot = slotId,
            equipped = true,
            durability = item.durability,
            maxDurability = item.maxDurability,
        } or nil
        paintItemButton(btn, entry, btn.emptyTexture)

        if item and item.maxDurability and item.maxDurability > 0 then
            local pct = (item.durability or 0) / item.maxDurability
            if not lowestDur or pct < lowestDur then
                lowestDur = pct
            end
        end
    end

    -- Count upgrades in bags
    if inv and inv.items then
        for i = 1, table.getn(inv.items) do
            if inv.items[i].upgrade then
                upgradesInBags = upgradesInBags + 1
            end
        end
    end

    -- Summary Durability Text
    local summary = inv and "" or "Loading inventory snapshot…"
    if lowestDur then
        local pct = math.floor(lowestDur * 100 + 0.5)
        local hex = pct < 25 and "|cffff4030" or (pct < 60 and "|cffffd200" or "|cff80ff80")
        summary = hex .. "Lowest durability: " .. pct .. "%|r"
    end
    if upgradesInBags > 0 then
        summary = summary .. (summary ~= "" and "\n" or "") .. "|cff40ff40" .. upgradesInBags .. " upgrade(s) in bags|r"
    end
    gear.durabilityText:SetText(summary)

    -- 3D Model Rendering with In-World Fallback
    local unit = botUnit(self.inspectorBot)
    if unit and UnitExists(unit) and gear.model.SetUnit then
        gear.model:ClearModel()
        gear.model:SetUnit(unit)
        -- Scaled down with NO SetCamera(0) so the full character body with gear is visible
        gear.model.modelScale = gear.model.modelScale or 0.35
        gear.model.currentRotation = gear.model.currentRotation or 0
        pcall(function() gear.model:SetModelScale(gear.model.modelScale) end)
        pcall(function() gear.model:SetRotation(gear.model.currentRotation) end)
        gear.model:Show()
        gear.modelBg:Show()
        gear.modelNotice:Hide()
    else
        gear.model:ClearModel()
        gear.model:Hide()
        gear.modelBg:Show()
        gear.modelNotice:Show()
    end
end

function UnBot:RenderBagsView(inv)
    local f = UnBotItemFrame
    local bags = f.bagsView
    local items = inv and inv.items or {}
    local perPage = BAG_COLS * BAG_ROWS
    local totalItems = table.getn(items)
    local totalPages = math.max(1, math.ceil(totalItems / perPage))

    self.bagPage = self.bagPage or 1
    if self.bagPage > totalPages then self.bagPage = totalPages end
    if self.bagPage < 1 then self.bagPage = 1 end

    for i = 1, table.getn(bags.slots) do
        local btn = bags.slots[i]
        local itemIndex = (self.bagPage - 1) * perPage + i
        local entry = items[itemIndex]
        if entry then
            paintItemButton(btn, entry, nil)
        else
            btn.entry = nil
            btn:Hide()
        end
    end

    if inv then
        bags.bagSummary:SetText(totalItems .. " items · " .. (inv.free or 0) .. " of " .. (inv.total or 0) .. " slots free")
    else
        bags.bagSummary:SetText("Loading items…")
    end

    bags.pageText:SetText(self.bagPage .. " / " .. totalPages)
    if self.bagPage > 1 then bags.prev:Enable() else bags.prev:Disable() end
    if self.bagPage < totalPages then bags.nextBtn:Enable() else bags.nextBtn:Disable() end
end

--=========================================================================--
--  Public Entry Points
--=========================================================================--

function UnBot:OpenBotInspector(name, view)
    if not name or name == "" then return false end
    name = NormalizeName(name)

    if self.TargetBot then
        self:TargetBot(name)
    end

    if not UnBotItemFrame then
        self:CreateItemFrame()
    end

    self.inspectorBot = name
    self.inspectorView = view or self.inspectorView or "gear"
    self.bagPage = 1

    UnBotItemFrame:ClearAllPoints()
    if UnBotFrame and UnBotFrame:IsVisible() then
        local right = UnBotFrame:GetRight()
        local screen = (GetScreenWidth and GetScreenWidth()) or 1024
        local scale = (UnBotFrame.GetScale and UnBotFrame:GetScale()) or 1
        local width = UnBotItemFrame:GetWidth()
        if right and (right + width + 4) * scale > screen then
            UnBotItemFrame:SetPoint("TOPRIGHT", UnBotFrame, "TOPLEFT", -4, 0)
        else
            UnBotItemFrame:SetPoint("TOPLEFT", UnBotFrame, "TOPRIGHT", 4, 0)
        end
    else
        UnBotItemFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -20)
    end

    UnBotItemFrame:Show()
    self:RefreshBotInspector()
    self:RequestBotInventory(name)
    return true
end

function UnBot:ShowBotInspector(name, view)
    return self:OpenBotInspector(name, view)
end

function UnBot:ShowItemWindow(mode, botName)
    local target = botName or (self.GetBotTarget and self:GetBotTarget()) or (UnitIsPlayer("target") and UnitName("target"))
    if not target then
        self:Message("Select a bot first, or Shift-click a bot in the Roster.")
        return
    end

    local view = "gear"
    if mode == "view" or mode == "use" or mode == "sell" or mode == "destroy" or mode == "bags" then
        view = "bags"
    elseif mode == "equip" or mode == "gear" then
        view = "gear"
    end

    self:OpenBotInspector(target, view)
end

-- Compatibility Stubs for legacy references
function UnBot:GetShownItems()
    return {}
end

function UnBot:RefreshItems()
    if self.RefreshBotInspector then self:RefreshBotInspector() end
end

function UnBot:ScrollItems(delta)
    self.bagPage = (self.bagPage or 1) + delta
    self:RefreshBotInspector()
end
