-- UnBot UI - Vanilla 1.12
-- Script handlers use the globals `this` and `arg1`, never parameters.

local BUTTON_SIZE = 32
local BUTTON_GAP  = 3

--=========================================================================--
--  Build
--=========================================================================--

function UnBot:InitUI()
    self:CreateMainFrame()
    self:CreateGroupButtons()
    self:CreateSubMenus()
    self:RefreshAllGroupIcons()
end

function UnBot:CreateMainFrame()
    local frame = CreateFrame("Frame", "UnBotFrame", UIParent)
    frame:SetWidth(12 * (BUTTON_SIZE + BUTTON_GAP) + 12)
    frame:SetHeight(BUTTON_SIZE + 10)
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
end

function UnBot:CreateGroupButtons()
    for group = 1, 10 do
        local x = 6 + (group - 1) * (BUTTON_SIZE + BUTTON_GAP)
        local btn = self:CreateIconButton("UnBotGroupButton"..group, UnBotFrame, x, -5)

        btn.groupIndex = group
        btn.commandId = self.config[group] or UnBotGroupDefault[group]
        btn.isGroupButton = true

        btn:SetScript("OnClick", function()
            if arg1 == "RightButton" then
                UnBot:ToggleSubMenu(this.groupIndex)
            else
                UnBot:RunCommand(this.commandId)
            end
        end)

        btn:SetScript("OnEnter", function()
            UnBot:ShowCommandTooltip(this, this.commandId, "group")
        end)

        self.groupButtons[group] = btn
    end

    -- Role shortcuts get a fixed slot of their own rather than hiding in a
    -- popup, since they are meant to be one click away.
    local roleX = 6 + 10 * (BUTTON_SIZE + BUTTON_GAP)
    local roles = self:CreateIconButton("UnBotRoleButton", UnBotFrame, roleX, -5)
    roles.icon:SetTexture(self:GetIconPath(102))
    roles:SetScript("OnClick", function()
        UnBot:ToggleRoleBar()
    end)
    roles:SetScript("OnEnter", function()
        UnBot:ShowCommandTooltip(this, 102, "plain")
    end)

    -- Close button on the far right: the game's own red X, so it reads as a
    -- close control rather than another command icon.
    local closeX = 6 + 11 * (BUTTON_SIZE + BUTTON_GAP)
    local close = CreateFrame("Button", "UnBotCloseButton", UnBotFrame, "UIPanelCloseButton")
    close:SetWidth(BUTTON_SIZE)
    close:SetHeight(BUTTON_SIZE)
    close:SetPoint("TOPLEFT", UnBotFrame, "TOPLEFT", closeX, -5)

    close:SetScript("OnClick", function()
        UnBot:CloseAll()
    end)
    close:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine(UnBotL.TITLE[0], 1, 0.82, 0)
        GameTooltip:AddLine(UnBotL.TT.LCLICK_RUN, 0.65, 0.55, 0)
        GameTooltip:Show()
    end)
    close:SetScript("OnLeave", function() GameTooltip:Hide() end)
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
    for id = 1, 103 do
        if UnBotCommandToGroups[id] == groupIndex and self:IsCommandDefined(id) then
            table.insert(list, id)
        end
    end
    return list
end

function UnBot:CreateSubMenus()
    for group = 1, 10 do
        local parent = self.groupButtons[group]
        local menu = CreateFrame("Frame", "UnBotSubFrame"..group, parent)
        menu:SetWidth(BUTTON_SIZE)
        menu:SetHeight(BUTTON_SIZE)
        menu:SetPoint("BOTTOM", parent, "TOP", 0, BUTTON_GAP)
        menu:Hide()

        local ids = self:GetGroupCommands(group)
        local count = table.getn(ids)

        for i = 1, count do
            local commandId = ids[i]
            local btn = self:CreateIconButton("UnBotSubButton"..commandId, menu, 0, 0)
            btn:ClearAllPoints()
            btn:SetPoint("BOTTOM", menu, "BOTTOM", 0, (i - 1) * (BUTTON_SIZE + BUTTON_GAP))

            btn.commandId = commandId
            btn.groupIndex = group
            btn.icon:SetTexture(self:GetIconPath(commandId))

            btn:SetScript("OnClick", function()
                if arg1 == "RightButton" then
                    UnBot:AssignCommandToGroup(this.groupIndex, this.commandId)
                else
                    UnBot:RunCommand(this.commandId)
                end
            end)

            btn:SetScript("OnEnter", function()
                UnBot:ShowCommandTooltip(this, this.commandId, "sub")
            end)

            self.subButtons[commandId] = btn
        end

        menu.commandCount = count
        parent.menu = menu
    end
end

function UnBot:ToggleSubMenu(groupIndex)
    local btn = self.groupButtons[groupIndex]
    if not btn or not btn.menu then return end

    if btn.menu:IsShown() then
        btn.menu:Hide()
    else
        self:HideAllSubFrames()
        btn.menu:Show()
    end
end

function UnBot:HideAllSubFrames()
    for group = 1, 10 do
        local btn = self.groupButtons[group]
        if btn and btn.menu then btn.menu:Hide() end
    end
end

-- Right-clicking a sub button makes it the group's default and saves it.
function UnBot:AssignCommandToGroup(groupIndex, commandId)
    local btn = self.groupButtons[groupIndex]
    if not btn then return end

    btn.commandId = commandId
    btn.icon:SetTexture(self:GetIconPath(commandId))
    self.config[groupIndex] = commandId

    if btn.menu then btn.menu:Hide() end
    self:Message(self:GetTitle(commandId).." -> slot "..groupIndex)
end

function UnBot:RefreshAllGroupIcons()
    for group = 1, 10 do
        local btn = self.groupButtons[group]
        if btn then
            btn.icon:SetTexture(self:GetIconPath(btn.commandId))
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
    end

    GameTooltip:AddDoubleLine(UnBotL.TT.CMD_ID, tostring(commandId), 0, 0.6, 1, 1, 1, 1)
    GameTooltip:Show()
end
