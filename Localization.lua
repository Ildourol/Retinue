-- UnBot Localization (English).
-- TITLE ids 0-66 are the original strings; 67-89 were reconstructed from the
-- command text and handler names after the original file was lost.

Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue

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
    [2]  = "Autogear selected bot",
    [3]  = "Autogear all party bots",
    [9]  = "Reset party bot strategies",
    [10] = "Reset selected bot strategies",
    [17] = "Make party bots learn spells",
    [70] = "Stop combat and clear attack queues",
    [80] = "Server-side ready check",
    [81] = "Make party bots rest (drink)",
    [82] = "Log out all group bots",
    [83] = "Log in offline roster bots",
    [91] = "Party bots attack current target",
    [92] = "Tank pull target with party hold",
    [94] = "Make party bots repair at vendor",
    [95] = "Make party bots sell junk at vendor",
    [99] = "Make party bots rest (eat)",
    [100] = "Halt and hold current position",
    [103] = "Loot nearby world object or corpse",
    [110] = "Toggle party combat spacing",
    -- modern TortoiseBots actions (156-182)
    [156] = "Interrupt target spellcast",
    [157] = "Tank pullback to player anchor",
    [158] = "Abort active tank pull",
    [159] = "Focus fire on Skull target",
    [160] = "Toggle party AoE abilities (CC safety)",
    [161] = "Toggle smart auto CC on loose adds",
    [162] = "Toggle rogue pre-pull Sap on mark",
    [163] = "Sprint bots to player coordinates",
    [164] = "Command ghosts to run back to corpse",
    [165] = "Rebuff expiring party buffs",
    [166] = "Toggle mimic player consumables",
    [167] = "Make shamans drop configured totems",
    [168] = "Open trade window with companion bot",
    [169] = "Maintenance kit restock for selected bot",
    [170] = "Raid: Tankface dragon away from raid",
    [171] = "Raid: Douse nearby Molten Core runes",
    [172] = "Raid: Enable custom Turtle raid tactics",
    [173] = "Toggle free autonomous wandering",
    [174] = "Toggle single-target focus burn",
    [175] = "Toggle AoE fear spells in instances",
    [176] = "Toggle threat ease-off behavior",
    [177] = "Toggle offensive boost cooldowns",
    [178] = "Toggle automated potion reactions",
    [179] = "Share eligible quests with party",
    [180] = "Bind hearthstone at current innkeeper",
    [181] = "Purchase flight master destination",
    [182] = "Soft reset transient combat states",
    [183] = "Raid: Disable custom Turtle raid tactics",
    [184] = "Raid: Check custom Turtle raid tactics status",
    [185] = "Raid: Check loaded boss tactics per bot",
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
    [2]  = "Sends .bot autogear <your target>.",
    [87] = "Sends .bot add <your target>.",
    [86] = "Sends .bot remove <your target>.",
    [9]  = "Sends 'reset strats' to party bots to restore default combat and non-combat strategies.",
    [10] = "Sends 'reset strats' to the selected bot to restore its default strategies.",
    [47] = "Sends stay to the whole party so bots hold their current positions.",
    [62] = "Prints the party bots' active combat strategies.",
    [63] = "Prints the selected bot's active combat strategies.",
    [74] = "Your account characters. Left-click a name to log it in.",
    [76] = "Sends stay to the selected bot so it holds its current position.",
    [85] = "Clears transient combat, movement and target state without resetting saved strategies.",
    [156] = "Evaluates party bots and orders the first one with a ready interrupt (Kick, Pummel, Counterspell, Earth Shock) to interrupt the target.",
    [157] = "Orders the tank to pull from range/melee and drag the mob back to your anchor point while DPS bots hold.",
    [158] = "Immediately aborts an active pull without waiting for the 15-second timeout.",
    [159] = "Sets or targets the Skull raid icon and orders all party DPS bots to focus fire.",
    [160] = "Toggles all area spells off to protect crowd control and avoid pulling extra packs.",
    [161] = "Opt-in smart auto CC: bots automatically sheep or crowd-control loose adds attacking healers.",
    [162] = "Controls whether rogues stealth up and Sap the CC mark before the pull.",
    [163] = "Commands all companion bots to sprint immediately to your exact coordinates.",
    [164] = "Commands dead spirit bots to run back to their corpse or instance entrance.",
    [165] = "Tops off expiring party buffs out of combat (2-minute pass).",
    [166] = "Causes bots to consume class/level-appropriate equivalents when you use elixirs, potions, flasks, or food.",
    [167] = "Orders party shamans to drop their configured totem set immediately.",
    [168] = "Opens a direct trade window with the targeted companion bot.",
    [169] = "Refreshes reagents, consumables, ammo, and repairs for an owned bot without visiting vendors.",
    [170] = "Orders tank bots to drag dragon bosses away from the raid so breath and cleave miss group members.",
    [171] = "Orders scoped bots to douse nearby Molten Core runes using Quintessence.",
    [172] = "Enables custom Turtle raid encounter tactics (Emerald Sanctum, Karazhan Crypt, Lower Karazhan).",
    [173] = "Allows bots to roam freely and explore out of combat.",
    [174] = "Vetoes splash damage and area spells near crowd control targets.",
    [175] = "Toggles AoE fear spells (Psychic Scream, Howl of Terror, Intimidating Shout) inside instances.",
    [176] = "Directs non-tank bots to ease off attacks near the tank's threat ceiling.",
    [177] = "Allows bots to use long offensive cooldowns and trinkets.",
    [178] = "Enables automated combat potion and healthstone usage.",
    [179] = "Shares eligible quests from the bot's log with group members.",
    [180] = "Interacts with an innkeeper to bind the bot's hearthstone.",
    [181] = "Purchases a flight path to the specified destination from a flight master.",
    [182] = "Flushes action queues and clears transient combat states without rewriting AI configuration.",

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
    [117] = "Sets primary focus target icon to Cross.",
    [118] = "Sets primary focus target icon to Square.",
    [119] = "Sets primary focus target icon to Moon.",
    [120] = "Sets primary focus target icon to Triangle.",
    [121] = "Sets primary focus target icon to Diamond.",
    [122] = "Sets primary focus target icon to Circle.",
    [123] = "Sets primary focus target icon to Star.",
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

UnBotL.ROSTER = {
    TAB_ACCOUNT         = "Account",
    TAB_GUILD           = "Guild",
    TAB_PARTY           = "Party",
    TAB_RAID            = "Raid",
    TAB_CC              = "CC Marks",
    CLAIMED_TITLE       = "Claimed Guild Bots",
    CLAIMED_EMPTY       = "No Claimed Guild Bots",
    CLAIMED_EMPTY_DESC  = "Invite autonomous wandering bots in the world using /ginvite <BotName> to claim them as personal raid alt-bots.",
    RELEASE_CONFIRM     = "Release %s back to the wandering bot pool (/gkick)?",
    LOCKED_BADGE        = "[Locked]",
    LEVELING_BADGE      = "[Leveling]",
    PARTY_EMPTY         = "No other party members.\nInvite your bots from Roster to manage party roles and CC marks.",
    RAID_INTRO          = "Orders go to your bots in this raid. Target one of your bots to send an order to that bot only.",
}

UnBotL.INSPECT = {
    TAB_GEAR            = "Gear & Bags",
    TAB_BEHAVIOUR       = "Behaviour",
    GIVE_TO_ME          = "Give to me",
    TRADE               = "Trade",
    DURABILITY          = "Durability",
    UPGRADE             = "Upgrade",
    EQUIP               = "Equip",
    UNEQUIP             = "Unequip",
}

-- Keybinding labels in Blizzard options
BINDING_HEADER_RETINUE = "Retinue"
BINDING_NAME_RETINUE_TOGGLE = "Toggle command bar"
BINDING_NAME_RETINUE_ROSTER = "Toggle bot roster"
BINDING_NAME_RETINUE_STRATEGY = "Toggle strategy window"
BINDING_NAME_RETINUE_FOLLOW = "Follow me"
BINDING_NAME_RETINUE_STAY = "Stay / hold position"
BINDING_NAME_RETINUE_FLEE = "Flee / retreat"
BINDING_NAME_RETINUE_ATTACK = "Attack my target"
BINDING_NAME_RETINUE_ATTACK_RTI = "Attack RTI marked target"
BINDING_NAME_RETINUE_PULL = "Pull my target"
BINDING_NAME_RETINUE_PULL_RTI = "Pull RTI marked target"
BINDING_NAME_RETINUE_LOOT = "Loot nearby items"
BINDING_NAME_RETINUE_KITE = "Toggle Kite strategy"
BINDING_NAME_RETINUE_MARK_RTI = "Toggle Auto Mark RTI"
BINDING_NAME_RETINUE_GUARD = "Move to guard post"
BINDING_NAME_RETINUE_SET_GUARD = "Set guard post here"
BINDING_NAME_RETINUE_FREE = "Free movement / wander"
BINDING_NAME_RETINUE_RPG = "Toggle RPG mode"
BINDING_NAME_RETINUE_CATALOG = "Toggle Item Catalog & Spawner"

-- Backwards compatibility aliases
BINDING_HEADER_WARBAND = BINDING_HEADER_RETINUE
BINDING_NAME_WARBAND_TOGGLE = BINDING_NAME_RETINUE_TOGGLE
BINDING_NAME_WARBAND_ROSTER = BINDING_NAME_RETINUE_ROSTER
BINDING_NAME_WARBAND_STRATEGY = BINDING_NAME_RETINUE_STRATEGY
BINDING_NAME_WARBAND_FOLLOW = BINDING_NAME_RETINUE_FOLLOW
BINDING_NAME_WARBAND_STAY = BINDING_NAME_RETINUE_STAY
BINDING_NAME_WARBAND_FLEE = BINDING_NAME_RETINUE_FLEE
BINDING_NAME_WARBAND_ATTACK = BINDING_NAME_RETINUE_ATTACK
BINDING_NAME_WARBAND_ATTACK_RTI = BINDING_NAME_RETINUE_ATTACK_RTI
BINDING_NAME_WARBAND_PULL = BINDING_NAME_RETINUE_PULL
BINDING_NAME_WARBAND_PULL_RTI = BINDING_NAME_RETINUE_PULL_RTI
BINDING_NAME_WARBAND_LOOT = BINDING_NAME_RETINUE_LOOT
BINDING_NAME_WARBAND_KITE = BINDING_NAME_RETINUE_KITE
BINDING_NAME_WARBAND_MARK_RTI = BINDING_NAME_RETINUE_MARK_RTI
BINDING_NAME_WARBAND_GUARD = BINDING_NAME_RETINUE_GUARD
BINDING_NAME_WARBAND_SET_GUARD = BINDING_NAME_RETINUE_SET_GUARD
BINDING_NAME_WARBAND_FREE = BINDING_NAME_RETINUE_FREE
BINDING_NAME_WARBAND_RPG = BINDING_NAME_RETINUE_RPG
BINDING_NAME_WARBAND_CATALOG = BINDING_NAME_RETINUE_CATALOG

