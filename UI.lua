-- UnBot UI - Vanilla 1.12
-- Script handlers use the globals `this` and `arg1`, never parameters.

local BUTTON_SIZE = 32
local BUTTON_GAP  = 3
local MAIN_CONTENT_LEFT = 10
local GROUP_BUTTON_Y = -49
local FAVORITE_BUTTON_Y = -8
local FAVORITE_LABEL_Y = -14
local FAVORITE_CONTROL_Y = -13
local FAVORITES_DIVIDER_Y = -43
local FAVORITES_START_X = MAIN_CONTENT_LEFT + 58
local FAVORITES_MAX_VISIBLE = 7
local MINIMAP_BUTTON_RADIUS = 80
local MINIMAP_CENTER_OFFSET = 70
local MINIMAP_DEFAULT_ANGLE = -35

--=========================================================================--
--  Build
--=========================================================================--

function UnBot:InitUI()
    self:CreateMainFrame()
    self:CreateMinimapButton()
    self:CreateGroupButtons()
    self:CreateSubMenus()
    self:RefreshAllGroupIcons()
    self:RefreshFavorites()
end

function UnBot:CreateMainFrame()
    local frame = CreateFrame("Frame", "UnBotFrame", UIParent)
    frame:SetWidth(11 * (BUTTON_SIZE + BUTTON_GAP) + 20)
    frame:SetHeight(BUTTON_SIZE * 2 + 26)
    frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 180)
    self:MakeDraggable(frame)
    self:RestoreFramePosition(frame)

    frame:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.7)
    self:CreateFavoritesBar(frame)
end

function UnBot:CreateMinimapButton()
    local button = CreateFrame("Button", "UnBotMinimapButton", Minimap)
    button:SetWidth(31)
    button:SetHeight(31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture(
        "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetWidth(20)
    background:SetHeight(20)
    background:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    button.background = background

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(17)
    icon:SetHeight(17)
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -6)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Horn_02")
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetWidth(53)
    border:SetHeight(53)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border = border

    local dragger = CreateFrame("Frame", nil, button)
    dragger:Hide()
    dragger:SetScript("OnUpdate", function()
        UnBot:UpdateMinimapButtonPosition(button)
    end)

    button:SetScript("OnClick", function()
        UnBot:ToggleUI()
        UnBot:UpdateMinimapTooltip(this)
    end)
    button:SetScript("OnDragStart", function()
        this:LockHighlight()
        dragger:Show()
    end)
    button:SetScript("OnDragStop", function()
        this:UnlockHighlight()
        dragger:Hide()
        UnBot:UpdateMinimapButtonPosition(this)
    end)
    button:SetScript("OnEnter", function()
        UnBot:UpdateMinimapTooltip(this)
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.minimapButton = button
    self:SetMinimapButtonPosition(button)
end

function UnBot:SetMinimapButtonPosition(button)
    if not button or not Minimap then return end
    local angle = self.config.minimapAngle or MINIMAP_DEFAULT_ANGLE
    local radians = math.rad(angle)
    local x = 52 - MINIMAP_BUTTON_RADIUS * math.cos(radians)
    local y = MINIMAP_BUTTON_RADIUS * math.sin(radians) - 52

    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", x, y)
end

function UnBot:UpdateMinimapButtonPosition(button)
    if not button or not Minimap then return end

    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetScale()
    local minimapLeft = Minimap:GetLeft()
    local minimapBottom = Minimap:GetBottom()
    local x = minimapLeft - cursorX / scale + MINIMAP_CENTER_OFFSET
    local y = cursorY / scale - minimapBottom - MINIMAP_CENTER_OFFSET
    if x == 0 and y == 0 then return end

    self.config.minimapAngle = math.deg(math.atan2(y, x))
    self:SetMinimapButtonPosition(button)
end

function UnBot:UpdateMinimapTooltip(button)
    if not button then return end
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:AddLine(self.addonName or "Warband", 1, 0.82, 0)
    if UnBotFrame and UnBotFrame:IsShown() then
        GameTooltip:AddLine(UnBotL.TT.MINIMAP_HIDE, 0.65, 0.55, 0)
    else
        GameTooltip:AddLine(UnBotL.TT.MINIMAP_SHOW, 0.65, 0.55, 0)
    end
    GameTooltip:Show()
end

function UnBot:CreateFavoritesBar(parent)
    self.favoriteButtons = {}

    local label = parent:CreateFontString("UnBotFavoritesLabel", "OVERLAY")
    label:SetFont(UnBotFont, 10)
    label:SetWidth(54)
    label:SetHeight(20)
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", MAIN_CONTENT_LEFT,
                   FAVORITE_LABEL_Y)
    label:SetJustifyV("MIDDLE")
    label:SetText("Favorites")
    label:SetTextColor(1, 0.82, 0)
    self.favoriteLabel = label

    local divider = parent:CreateTexture("UnBotFavoritesDivider", "BORDER")
    divider:SetTexture(0.65, 0.5, 0.15, 0.8)
    divider:SetPoint("TOPLEFT", parent, "TOPLEFT", MAIN_CONTENT_LEFT,
                     FAVORITES_DIVIDER_Y)
    divider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, FAVORITES_DIVIDER_Y)
    divider:SetHeight(1)
    self.favoriteDivider = divider

    for i = 1, FAVORITES_MAX_VISIBLE do
        local x = FAVORITES_START_X + (i - 1) * (BUTTON_SIZE + BUTTON_GAP)
        local button = self:CreateIconButton("UnBotFavoriteButton"..i,
                                             parent, x, FAVORITE_BUTTON_Y)
        button.favoriteIndex = i
        button:SetScript("OnClick", function()
            if not this.commandId then return end
            if arg1 == "RightButton" then
                UnBot:ToggleFavorite(this.commandId)
            else
                UnBot:RunCommand(this.commandId)
            end
        end)
        button:SetScript("OnEnter", function()
            if this.commandId then
                UnBot:ShowCommandTooltip(this, this.commandId, "favorite")
            end
        end)
        self.favoriteButtons[i] = button
    end

    local moreX = FAVORITES_START_X
                 + FAVORITES_MAX_VISIBLE * (BUTTON_SIZE + BUTTON_GAP)
    local more = CreateFrame("Button", "UnBotFavoriteMoreButton", parent,
                             "UIPanelButtonTemplate")
    more:SetWidth(BUTTON_SIZE)
    more:SetHeight(22)
    more:SetPoint("TOPLEFT", parent, "TOPLEFT", moreX, FAVORITE_CONTROL_Y)
    more:SetText("+0")
    more:SetScript("OnClick", function()
        if type(UnBot.ToggleFavoritesWindow) == "function" then
            UnBot:ToggleFavoritesWindow()
        end
    end)
    more:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine("More favorites", 1, 0.82, 0)
        GameTooltip:AddLine("Open the complete favorites list", 0.65, 0.55, 0)
        GameTooltip:Show()
    end)
    more:SetScript("OnLeave", function() GameTooltip:Hide() end)
    more:Hide()
    self.favoriteMore = more

    local clearX = FAVORITES_START_X
                   + (FAVORITES_MAX_VISIBLE + 1) * (BUTTON_SIZE + BUTTON_GAP)
    local clear = CreateFrame("Button", "UnBotFavoritesClearButton", parent,
                              "UIPanelButtonTemplate")
    clear:SetWidth(44)
    clear:SetHeight(22)
    clear:SetPoint("TOPLEFT", parent, "TOPLEFT", clearX, FAVORITE_CONTROL_Y)
    clear:SetText("Clear")
    clear:SetScript("OnClick", function()
        if type(UnBot.ConfirmClearFavorites) == "function" then
            UnBot:ConfirmClearFavorites()
        end
    end)
    clear:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine("Clear all favorites", 1, 0.82, 0)
        GameTooltip:AddLine("Confirmation required", 0.65, 0.55, 0)
        GameTooltip:Show()
    end)
    clear:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.favoriteClear = clear
end

function UnBot:CreateGroupButtons()
    for group = 1, 10 do
        local x = MAIN_CONTENT_LEFT
                 + (group - 1) * (BUTTON_SIZE + BUTTON_GAP)
        local btn = self:CreateIconButton("UnBotGroupButton"..group, UnBotFrame, x,
                                      GROUP_BUTTON_Y)

        btn.groupIndex = group
        btn.isGroupButton = true

        if type(self.GetActionGroupIcon) == "function" then
            btn.icon:SetTexture(self:GetActionGroupIcon(group))
        else
            -- A stale /reload may know about UI.lua but not the newly added
            -- Actions.lua. Keep the bar usable and give the user a clear hint.
            btn.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end

        btn:SetScript("OnClick", function()
            UnBot:ToggleSubMenu(this.groupIndex)
        end)
        btn:SetScript("OnEnter", function()
            if type(UnBot.ShowActionGroupTooltip) == "function" then
                UnBot:ShowActionGroupTooltip(this, this.groupIndex)
            else
                GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
                GameTooltip:AddLine("Bot command group", 1, 0.82, 0)
                GameTooltip:AddLine("Restart the client to load command windows",
                                    0.65, 0.55, 0)
                GameTooltip:Show()
            end
        end)

        self.groupButtons[group] = btn
    end

    -- Role shortcuts get a fixed slot of their own rather than hiding in a
    -- popup, since they are meant to be one click away.
    local roleX = MAIN_CONTENT_LEFT + 10 * (BUTTON_SIZE + BUTTON_GAP)
    local roles = self:CreateIconButton("UnBotRoleButton", UnBotFrame, roleX,
                                      GROUP_BUTTON_Y)
    roles.icon:SetTexture(self:GetIconPath(102))
    roles:SetScript("OnClick", function()
        UnBot:ToggleRoleBar()
    end)
    roles:SetScript("OnEnter", function()
        UnBot:ShowCommandTooltip(this, 102, "plain")
    end)

end

-- Shared button factory: icon fills the button, with pushed/highlight art.
function UnBot:CreateIconButton(name, parent, x, y)
    local btn = CreateFrame("Button", name, parent)
    btn:SetWidth(BUTTON_SIZE)
    btn:SetHeight(BUTTON_SIZE)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local icon = btn:CreateTexture(name.."Icon", "ARTWORK")
    icon:SetAllPoints(btn)
    btn.icon = icon

    btn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return btn
end

--=========================================================================--
--  Sub menus
--=========================================================================--

-- Every command that belongs to a group and is actually usable.
function UnBot:GetGroupCommands(groupIndex)
    local list = {}
    local seen = {}
    local preferred = UnBotCommandOrder and UnBotCommandOrder[groupIndex]

    if preferred then
        for index = 1, table.getn(preferred) do
            local id = preferred[index]
            if UnBotCommandToGroups[id] == groupIndex
            and self:IsCommandDefined(id) then
                table.insert(list, id)
                seen[id] = true
            end
        end
    end

    -- Keep future or newly enabled commands visible even if their preferred
    -- position has not been added to the ordering table yet.
    for id = 1, 103 do
        if UnBotCommandToGroups[id] == groupIndex
        and not seen[id]
        and self:IsCommandDefined(id) then
            table.insert(list, id)
        end
    end
    return list
end

function UnBot:IsFavorite(commandId)
    for i = 1, table.getn(self.config.favorites or {}) do
        if self.config.favorites[i] == commandId then return true end
    end
    return false
end

function UnBot:GetFavoriteCommands()
    local list = {}
    local favorites = self.config.favorites or {}
    for i = 1, table.getn(favorites) do
        if self:IsCommandDefined(favorites[i]) then
            table.insert(list, favorites[i])
        end
    end
    return list
end

function UnBot:AddFavorite(commandId)
    if not commandId then return end
    if self.config.favorites == nil then self.config.favorites = {} end
    if self:IsFavorite(commandId) then return end

    table.insert(self.config.favorites, commandId)
    self:Message("Added "..self:GetTitle(commandId).." to favorites")
    self:RefreshFavorites()
    if self.actionGroupFrame and self.actionWindowGroup then
        self:RefreshActionGroup(self.actionWindowGroup)
    end
end

function UnBot:RemoveFavorite(commandId)
    if not commandId or self.config.favorites == nil then return end

    for i = 1, table.getn(self.config.favorites) do
        if self.config.favorites[i] == commandId then
            table.remove(self.config.favorites, i)
            self:Message("Removed "..self:GetTitle(commandId)
                         .." from favorites")
            self:RefreshFavorites()
            if self.actionGroupFrame and self.actionWindowGroup then
                self:RefreshActionGroup(self.actionWindowGroup)
            end
            return
        end
    end
end

function UnBot:ToggleFavorite(commandId)
    if not commandId then return end
    if self:IsFavorite(commandId) then
        self:ConfirmRemoveFavorite(commandId)
    else
        self:AddFavorite(commandId)
    end
end

function UnBot:ClearFavorites()
    if self.config.favorites == nil then return end
    self.config.favorites = {}
    self:Message("Cleared all favorites")
    self:RefreshFavorites()
    if self.actionGroupFrame and self.actionWindowGroup then
        self:RefreshActionGroup(self.actionWindowGroup)
    end
end

function UnBot:RefreshFavorites()
    if not self.favoriteButtons then return end

    local favorites = self:GetFavoriteCommands()
    local count = table.getn(favorites)

    for i = 1, FAVORITES_MAX_VISIBLE do
        local button = self.favoriteButtons[i]
        local commandId = favorites[i]
        button.commandId = nil
        if commandId then
            button.commandId = commandId
            button.icon:SetTexture(self:GetIconPath(commandId))
            button:Show()
        else
            button:Hide()
        end
    end

    local hidden = count - FAVORITES_MAX_VISIBLE
    if hidden > 0 then
        self.favoriteMore:SetText("+"..hidden)
        self.favoriteMore:Show()
    else
        self.favoriteMore:Hide()
    end
end

function UnBot:CreateSubMenus()
    -- Group commands now open labelled, draggable windows from Actions.lua.
    -- Keep this hook because InitUI calls it and older callers may still use
    -- the old name, but do not build the icon-only popup menus anymore.
end

function UnBot:ToggleSubMenu(groupIndex)
    -- Preserve the old entry point while routing right-clicks to the new
    -- per-group window.  The fallback prevents a stale /reload from throwing
    -- if the newly added Actions.lua has not been loaded yet.
    if type(UnBot.ToggleActionGroup) == "function" then
        UnBot:ToggleActionGroup(groupIndex)
    else
        self:Message("Command windows are not loaded - restart the client completely")
    end
end

function UnBot:HideAllSubFrames()
    for group = 1, 10 do
        local btn = self.groupButtons[group]
        if btn and btn.menu then btn.menu:Hide() end
    end
end

-- Kept for older callers and saved-layout compatibility.  Primary group
-- buttons now always open their labelled window, so this no longer changes
-- the group icon or click behaviour.
function UnBot:AssignCommandToGroup(groupIndex, commandId)
    local btn = self.groupButtons[groupIndex]
    if not btn then return end

    self.config[groupIndex] = commandId
    self:Message(self:GetTitle(commandId).." -> legacy slot "..groupIndex)
end

function UnBot:RefreshAllGroupIcons()
    for group = 1, 10 do
        local btn = self.groupButtons[group]
        if btn and type(self.GetActionGroupIcon) == "function" then
            btn.icon:SetTexture(self:GetActionGroupIcon(group))
        end
    end
end

--=========================================================================--
--  Tooltip
--=========================================================================--

function UnBot:ShowCommandTooltip(owner, commandId, kind)
    GameTooltip:SetOwner(owner, "ANCHOR_TOPRIGHT")
    GameTooltip:AddLine(self:GetTitle(commandId), 1, 0.82, 0)

    local cmdType = UnBotCommandType[commandId]
    if cmdType and UnBotL.TARGET_TYPE[cmdType] then
        GameTooltip:AddDoubleLine(UnBotL.TT.TARGET_TYPE, UnBotL.TARGET_TYPE[cmdType],
                                  0, 0.6, 1, 1, 1, 1)
    end

    local help = UnBotL.HELP[commandId]
    if help then
        GameTooltip:AddLine(help, 0.6, 1, 0.6, 1)
    end

    local text = UnBotExecuteCommand[commandId]
    if text and text ~= "" then
        GameTooltip:AddDoubleLine(UnBotL.TT.CMD_SENT, text, 0, 0.85, 0.85, 0, 0.85, 0.85)
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(UnBotL.TT.LCLICK_RUN, 0.65, 0.55, 0)
    if kind == "group" then
        GameTooltip:AddLine(UnBotL.TT.RCLICK_GROUP, 0.65, 0.55, 0)
    elseif kind == "sub" then
        GameTooltip:AddLine(UnBotL.TT.RCLICK_APPLY, 0.65, 0.55, 0)
    elseif kind == "action" or kind == "favorite" then
        GameTooltip:AddLine(UnBotL.TT.RCLICK_FAVORITE, 0.65, 0.55, 0)
    end

    GameTooltip:AddDoubleLine(UnBotL.TT.CMD_ID, tostring(commandId), 0, 0.6, 1, 1, 1, 1)
    GameTooltip:Show()
end
