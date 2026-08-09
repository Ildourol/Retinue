-- UnBot Localization (English).
-- TITLE ids 0-66 are the original strings; 67-89 were reconstructed from the
-- command text and handler names after the original file was lost.

UnBotL = {}
UnBotFont = "Fonts\\FRIZQT__.TTF"

UnBotL.TITLE = {
    [0]  = "Close all windows and sub-button groups",
    [1]  = "Initialize all online bots",
    [2]  = "Gear selected bot (green)",
    [3]  = "Gear all party bots (green)",
    [4]  = "Refresh selected bot",
    [5]  = "Randomise selected bot",
    [6]  = "Selected bot: add remaining talents - tab 1",
    [7]  = "Selected bot: add remaining talents - tab 2",
    [8]  = "Selected bot: add remaining talents - tab 3",
    [9]  = "Reset whole party's bot AI",
    [10] = "Reset selected bot's AI",
    [11] = "View bot equipment window",
    [12] = "Initialize bot to your level",
    [13] = "Summon party bots to you",
    [14] = "Summon selected bot to you",
    [15] = "Make party bots follow you",
    [16] = "Make selected bot follow you",
    [17] = "Make party bots learn skills",
    [18] = "Make dead party bots release spirit",
    [19] = "Make selected bot release spirit",
    [20] = "View party bots' quest status",
    [21] = "View selected bot's quest status",
    [22] = "View party bots' current status",
    [23] = "View selected bot's current status",
    [24] = "Make party bots loot",
    [25] = "Make party bots flee",
    [26] = "Tank bots in party flee",
    [27] = "DPS bots in party flee",
    [28] = "Healer bots in party flee",
    [29] = "Melee bots in party flee",
    [30] = "Ranged bots in party flee",
    [31] = "Selected bot flee",
    [32] = "Party bots attack target",
    [33] = "Tank bots in party attack target",
    [34] = "DPS bots in party attack target",
    [35] = "Healer bots in party attack target",
    [36] = "Melee bots in party attack target",
    [37] = "Ranged bots in party attack target",
    -- Titles below match the command that is actually sent; the original
    -- English port had several of these labelled out of order.
    [38] = "Bot formation - Arrow",
    [39] = "Bot formation - Queue",
    [40] = "Bot formation - Near (dense)",
    [41] = "Bot formation - Melee",
    [42] = "Bot formation - Line",
    [43] = "Bot formation - Circle",
    [44] = "Bot formation - Chaos",
    [45] = "Bot formation - Shield",
    [46] = "View bot formation",
    [47] = "Whole party stop following",
    [48] = "Selected bot auto-select target",
    [49] = "Selected bot manual-select target",
    [50] = "Druid spell DPS",
    [51] = "Druid bear form",
    [52] = "Druid cat form",
    [53] = "Druid healing mode",
    [54] = "Bot strategy editor",
    [55] = "Paladin Frost Resistance Aura",
    [56] = "Paladin Fire Resistance Aura",
    [57] = "Paladin Devotion (armor) Aura",
    [58] = "Paladin Retribution Aura",  -- Crusader Aura does not exist on 1.12
    [59] = "Paladin Blessing of Kings",
    [60] = "Paladin Blessing of Wisdom",
    [61] = "Paladin Blessing of Might",
    [62] = "Whole party AI status",
    [63] = "Selected bot AI status",
    [64] = "View bot bags",
    [65] = "Bot drop item",
    [66] = "Bot equip item",
    -- reconstructed from here down
    [67] = "Bot sell item",
    [68] = "Bot use item",
    [69] = "Bot cast spell",
    [70] = "Stop combat for the whole party",
    [71] = "Disband all party bots",
    [72] = "Show icon list",
    [73] = "Teleport to selected bot",
    [74] = "Account bot roster (window)",
    [75] = "Selected bot - reserved",
    [76] = "Selected bot hold position",
    [77] = "List account bots (server reply)",
    [78] = "Bring friend-list bots online",
    [79] = "Invite friend-list bots",
    [80] = "Ready check",
    [81] = "Party bots eat / drink",
    [82] = "Log out all bots in your group",
    [83] = "Log in all bots in your group",
    [84] = "Naxxramas strategy",
    [85] = "Reset party bots",
    [86] = "Remove selected bot",
    [87] = "Add selected bot",
    [88] = "Add party members as friends",
    [89] = "Party bots grind",
    -- taken from the bot's own action list
    [90]  = "Buff the group now",
    [91]  = "Attack YOUR target",
    [92]  = "Pull YOUR target",
    [93]  = "Equip any upgrades from bags",
    [94]  = "Repair gear",
    [95]  = "Sell junk to vendor",
    [96]  = "Show selected bot's talents",
    [97]  = "Visit trainer",
    [98]  = "Resurrect the dead",
    [99]  = "Eat / drink",
    [100] = "Stop following",
    [101] = "Give leader to selected bot",
    [102] = "Role shortcuts",
    [103] = "Use nearby world object",
}

-- Longer help text, shown under the title in the tooltip.
UnBotL.HELP = {
    -- "*" means "everyone currently in my group", not "every character on my
    -- account". These only rebuild a group that already exists, e.g. after a
    -- server restart logged the bots out. Use the roster window to build one.
    [82] = "Only affects bots already in your group.",
    [83] = "Only reloads bots already in your group - use the roster window "..
           "(button 74) to bring new ones in.",
    [3]  = "Applies to bots already in your group.",
    [2]  = "Sends .bot init=green <your target>.",
    [87] = "Sends .bot add <your target>.",
    [86] = "Sends .bot remove <your target>.",
    [74] = "Your own account characters. Left-click a name to log it in.",
    [102] = "One button per class: left-click for its first role, right-click "..
            "for the second. Applies to the whole group.",
    [103] = "Chests, levers, herbs and ore - the Use tab only handles bag items.",
    [80] = "Uses the client's ready check where available.",
}

UnBotL.MSG = {
    CLOSE_BAR       = "All UnBot windows closed",
    INIT_START      = "UnBot initializing...",
    INIT_DONE       = "UnBot ready",
    NO_TARGET       = "You have no target",
    NEED_PLAYER_BOT = "Target must be a player bot",
    NOT_IN_PARTY    = "Target is not in your party or raid",
    NOT_LEADER      = "You must be the party leader",
    NO_FRIENDS      = "Your friends list is empty",
    ALREADY_IN_PARTY= "%s is already in your group",
    WIN_INIT_FAIL   = "Could not open window: ",
    CMD_NOT_FOUND   = "Command %s is not defined",
    CMD_EMPTY       = "Command %s has no chat text",
    EQUIP_THIS_ITEM = "Send to %s to equip",
    COMBATSTOP_RAID = "Stopping combat for raid member %s",
    COMBATSTOP_PARTY= "Stopping combat for party member %s",
}

UnBotL.TT = {
    TARGET_TYPE  = "Target",
    CMD_SENT     = "Sends",
    LCLICK_RUN   = "Left-click: run",
    RCLICK_GROUP = "Right-click: open group",
    RCLICK_APPLY = "Right-click: set as group default",
    RCLICK_CLOSE = "Right-click: close everything",
    CMD_ID       = "Command id",
}

UnBotL.TARGET_TYPE = {
    [1] = "None needed",
    [2] = "Friendly target",
    [3] = "Hostile target",
    [4] = "Whole party",
}

UnBotL.ONLINE = {
    MEMBER_FMT = "%s  (level %s)",
}

UnBotL.QR = {
    TITLE_SUFFIX  = " - choose reward",
    LABEL_MISSING = "Label %s missing for %s",
    NEED_QUERY    = "Item info not cached yet",
    PICK          = "Click to pick this reward for %s",
}

UnBotL.BAGS = {
    WIN_ICONS     = "Icon list",
    WIN_VIEW      = "Bot inventory",
    WIN_DROP      = "Destroy items",
    WIN_EQUIP     = "Equip items",
    WIN_SELL      = "Sell items",
    WIN_USE       = "Use items",
    WIN_SPELLS    = "Bot spells",
    COST_MANA     = "Mana: %s",
    COST_RAGE     = "Rage: %s",
    COST_ENERGY   = "Energy: %s",
    COST_RESOURCE = "Cost: %s",
}

UnBotL.EQUIP = {
    HELP_TEXT = "Left-click a slot: pick replacement   Right-click: unequip",
}

UnBotL.UI = {
    STRAT_EDITOR_SUFFIX = " - strategy editor",
    COMBAT_STRAT        = "Combat",
    NONCOMBAT_STRAT     = "Non-combat",
}

UnBotL.BIND = {
    HEADER = "UnBot",
    CMD    = "Command bar button %d",
    CLOSE  = "Close UnBot",
}

UnBotL.NPC = {
    SUMMON_DESC_PRE = "Summons: ",
    SELECT_SELF_NPC = "You must select your own NPC bot",
}
