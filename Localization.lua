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
    [9]  = "Reset whole party's AI strategies",
    [10] = "Reset selected bot's AI strategies",
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
    [47] = "Make party bots hold their current position",
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
    [62] = "Show whole party's combat strategies",
    [63] = "Show selected bot's combat strategies",
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
    [74] = "Player roster window",
    [75] = "Selected bot - reserved",
    [76] = "Selected bot hold position",
    [77] = "List account bots (server reply)",
    [78] = "Bring friend-list bots online",
    [79] = "Invite friend-list bots",
    [80] = "Ready check",
    [81] = "Make mana-using party bots drink",
    [82] = "Log out all bots in your group",
    [83] = "Log in all bots in your group",
    [84] = "Naxxramas strategy",
    [85] = "Reset party bots' current state",
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
    [99]  = "Make party bots eat",
    [100] = "Stop following",
    [101] = "Give leader to selected bot",
    [102] = "Roles",
    [103] = "Use nearby world object",
    [104] = "Bot formation - Far",
    [105] = "Ping formation positions",
    [106] = "Combat stance - Near",
    [107] = "Combat stance - Tank",
    [108] = "Combat stance - Turnback",
    [109] = "Combat stance - Behind",
    [110] = "Combat stance - Spread",
    [111] = "Ping stance positions",
    [112] = "Attack RTI marked target",
    [113] = "Pull RTI marked target",
    [114] = "Toggle Auto Mark RTI",
    [115] = "Toggle Kite strategy",
    [116] = "Set RTI target: Skull",
    [117] = "Set RTI target: Cross",
    [118] = "Set RTI target: Square",
    [119] = "Set RTI target: Moon",
    [120] = "Set RTI target: Triangle",
    [121] = "Set RTI target: Diamond",
    [122] = "Set RTI target: Circle",
    [123] = "Set RTI target: Star",
    [124] = "Clear RTI target",
    [125] = "Set RTI crowd control: Skull",
    [126] = "Set RTI crowd control: Moon",
    [127] = "Clear RTI crowd control",

    -- loot strategy filters (128-135)
    [128] = "Loot filter: Equipment upgrades",
    [129] = "Loot filter: Quest items",
    [130] = "Loot filter: Trade skill materials",
    [131] = "Loot filter: Items to disenchant",
    [132] = "Loot filter: Consumables & reagents",
    [133] = "Loot filter: Items to vendor for gold",
    [134] = "Loot filter: Grey junk / trash",
    [135] = "Show bot loot filter rules",

    -- mana conservation levels (136-141)
    [136] = "Mana conservation: Off (full burst)",
    [137] = "Mana conservation: Level 2 (low)",
    [138] = "Mana conservation: Level 3 (medium)",
    [139] = "Mana conservation: Level 4 (high)",
    [140] = "Mana conservation: Level 5 (maximum)",
    [141] = "Show mana conservation level",

    -- guard post & position control (142-144)
    [142] = "Set guard post here",
    [143] = "Move to guard post",
    [144] = "Free movement / wander",

    -- autonomous RPG modes (145-150)
    [145] = "Toggle autonomous RPG mode",
    [146] = "RPG: Autonomous questing",
    [147] = "RPG: Autonomous vendor & AH",
    [148] = "RPG: Autonomous explore & flight",
    [149] = "RPG: Autonomous training & repair",
    [150] = "RPG: Autonomous crafting",

    -- utilities & diagnostics (151-156)
    [151] = "Check mailbox / unread mail",
    [152] = "Show blacklisted / skip spells",
    [153] = "Talk to quest giver / gossip NPC",
    [154] = "Accept all shared quests",
    [155] = "Check quest reward items",
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
    [9]  = "Resets saved party-bot strategies to their defaults.",
    [10] = "Resets the selected bot's saved strategies to their defaults.",
    [47] = "Sends stay to the whole party so bots hold their current positions.",
    [62] = "Prints the party bots' active combat strategies.",
    [63] = "Prints the selected bot's active combat strategies.",
    [74] = "Your account characters. Left-click a name to log it in.",
    [76] = "Sends stay to the selected bot so it holds its current position.",
    [85] = "Clears transient combat, movement and target state without resetting saved strategies.",
    [88] = "Adds your current party or raid members to the friends list.",
    [102] = "One button per class: left-click applies its primary combat strategy, "..
            "right-click applies the alternative. Talents and gear are unchanged.",
    [103] = "Chests, levers, herbs and ore - the Use tab only handles bag items.",
    [80] = "Uses the client's ready check where available.",
    [104] = "Bots follow in a spread-out far formation.",
    [105] = "Pings minimap/ground with current formation positions.",
    [106] = "Bots stay near their target in combat (default).",
    [107] = "Tanks face target away from group; others reposition.",
    [108] = "Bots position so target faces away from ranged members.",
    [109] = "Melee bots attempt to attack from behind the target.",
    [110] = "Bots spread out at least 10 yards to avoid AoE.",
    [111] = "Pings ground with current stance positions.",
    [112] = "Commands party bots to attack the RTI marked target.",
    [113] = "Commands party bots to pull the RTI marked target.",
    [114] = "Bots automatically mark combat targets with raid icons.",
    [115] = "Toggles kiting behaviour for party bots when attacked.",
    [116] = "Sets primary focus target icon to Skull.",
    [124] = "Clears primary focus target icon assignment.",
    [125] = "Sets crowd-control target icon to Skull.",
    [126] = "Sets crowd-control target icon to Moon.",
    [127] = "Clears crowd-control target icon assignment.",
    [128] = "Toggles whether bots loot equipment upgrades from fallen foes.",
    [129] = "Toggles whether bots loot quest objective items.",
    [130] = "Toggles whether bots loot profession crafting reagents.",
    [131] = "Toggles whether bots loot uncommon/rare items for disenchanting.",
    [132] = "Toggles whether bots loot potions, food, bandages and reagents.",
    [133] = "Toggles whether bots loot vendor items to earn gold.",
    [134] = "Toggles whether bots loot junk grey items.",
    [135] = "Prints the party bots' active loot filters to chat.",
    [136] = "Disables mana conservation so bots cast at full power.",
    [137] = "Conserves mana lightly during drawn-out battles.",
    [138] = "Moderate mana conservation balancing DPS and efficiency.",
    [139] = "High mana conservation, prioritizing essential spells and downranking.",
    [140] = "Maximum mana saving, only casting vital utility and wanding/autoattacking.",
    [141] = "Prints the party bots' active mana save level.",
    [142] = "Records your current coordinates as the bots' permanent guard post.",
    [143] = "Orders bots to travel to their assigned guard post and defend it.",
    [144] = "Allows bots to move freely and wander nearby out of combat.",
    [145] = "Toggles autonomous RPG behaviors when idle out of combat.",
    [146] = "Bots autonomously pick up and hand in quests to nearby NPCs.",
    [147] = "Bots autonomously sell junk, buy needed items and check mailbox.",
    [148] = "Bots discover flight masters, take flights and explore the zone.",
    [149] = "Bots visit class and profession trainers to learn new spells.",
    [150] = "Bots autonomously craft items and cast trade skills.",
    [151] = "Commands bots to check nearby mailboxes and report attached items.",
    [152] = "Prints the list of blacklisted spells that bots are forbidden to cast.",
    [153] = "Commands bots to gossip or interact with your selected NPC.",
    [154] = "Accepts all shared party quests from all members.",
    [155] = "Queries available quest reward items for the selected bot.",
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
    RCLICK_GROUP     = "Right-click: open group",
    RCLICK_APPLY     = "Right-click: set as group default",
    RCLICK_FAVORITE  = "Right-click: toggle favorite",
    RCLICK_CLOSE     = "Right-click: close everything",
    MINIMAP_SHOW = "Click to show command panel",
    MINIMAP_HIDE = "Click to hide command panel",
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

-- Keybinding labels in Blizzard options
BINDING_HEADER_WARBAND = "Warband"
BINDING_NAME_WARBAND_TOGGLE = "Toggle command bar"
BINDING_NAME_WARBAND_ROSTER = "Toggle bot roster"
BINDING_NAME_WARBAND_STRATEGY = "Toggle strategy window"
BINDING_NAME_WARBAND_FOLLOW = "Follow me"
BINDING_NAME_WARBAND_STAY = "Stay / hold position"
BINDING_NAME_WARBAND_FLEE = "Flee / retreat"
BINDING_NAME_WARBAND_ATTACK = "Attack my target"
BINDING_NAME_WARBAND_ATTACK_RTI = "Attack RTI marked target"
BINDING_NAME_WARBAND_PULL = "Pull my target"
BINDING_NAME_WARBAND_PULL_RTI = "Pull RTI marked target"
BINDING_NAME_WARBAND_LOOT = "Loot nearby items"
BINDING_NAME_WARBAND_KITE = "Toggle Kite strategy"
BINDING_NAME_WARBAND_MARK_RTI = "Toggle Auto Mark RTI"
BINDING_NAME_WARBAND_GUARD = "Move to guard post"
BINDING_NAME_WARBAND_SET_GUARD = "Set guard post here"
BINDING_NAME_WARBAND_FREE = "Free movement / wander"
BINDING_NAME_WARBAND_RPG = "Toggle RPG mode"

