-- UnBot Data - command tables recovered from the 3.3.5 addon.
-- These are the heart of the addon: what each command sends and how.

Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue

-- Chat text sent for each command id. Empty string = handled by a special
-- handler in Commands.lua, or intentionally disabled upstream.
UnBotExecuteCommand = {
    -- Modern TortoiseBots / vMaNGOS command suite.
    -- Commands that need character names or bulk party queues
    -- are completed by handlers in Commands.lua.
    [2] = ".bot autogear",                      -- + target name (replaces legacy init=)
    [3] = "",                                   -- bulk autogear for group (handler in Commands.lua)
    [9] = "reset strats",                       -- native TortoiseBots strategy reset for party bots
    [10] = "reset strats",                      -- native TortoiseBots strategy reset for selected bot
    [13] = "summon",
    [14] = "summon",
    [15] = ".bot action follow",                -- modern tactical follow formation
    [16] = "follow",
    [17] = ".bot action learn",                 -- companion bots learn spells from matching trainers
    [18] = "release",
    [19] = "release",
    [20] = "quests",
    [21] = "quests",
    [22] = "stats",
    [23] = "stats",
    [24] = "d add all loot",
    [25] = ".bot action flee",                  -- break off combat into passive follow
    [26] = "@tank flee",
    [27] = "@dps flee",
    [28] = "@heal flee",
    [29] = "@melee flee",
    [30] = "@ranged flee",
    [31] = "flee",
    [32] = ".bot action attack",                -- intent-driven party attack (150yd, evade-safe)
    [33] = "@tank attack",
    [34] = "@dps attack",
    [35] = "@heal attack",
    [36] = "@melee attack",
    [37] = "@ranged attack",
    [38] = "formation arrow",
    [39] = "formation queue",
    [40] = "formation near",
    [41] = "formation melee",
    [42] = "formation line",
    [43] = "formation circle",
    [44] = "formation chaos",
    [45] = "formation shield",
    [46] = "formation",
    [47] = "stay",
    [54] = "strategy",
    [62] = "co ?",                              -- show combat strategies
    [63] = "co ?",
    -- Prefixes completed at runtime by handlers in Commands.lua.
    [70] = ".bot action stop",                  -- stop combat & clear attack queues
    [64] = "c",
    [65] = "destroy ",
    [66] = "e ",
    [67] = "s ",
    [68] = "u ",
    [69] = "cast ",
    [71] = "UninviteUnit ",
    [74] = "online",
    [76] = "stay",
    [77] = ".bot roster",
    [80] = ".bot action ready",                 -- server-side ready check (HP, mana, buffs)
    [81] = "d drink",                           -- drink order (party bots rest and drink)
    [82] = "",                                  -- bulk group logout (handler in Commands.lua)
    [83] = "",                                  -- bulk group login (handler in Commands.lua)
    [85] = "reset",
    [86] = ".bot remove",                       -- + target name
    [87] = ".bot add",                          -- + target name
    [89] = "grind",

    [90] = "d buff",                            -- buff the group right now
    [91] = ".bot action attack",                -- attack current target
    [92] = ".bot action pull 10 ranged",        -- tank pull with party hold
    [93] = "d equip upgrades",                  -- wear anything better from bags
    [94] = ".bot action repair",                -- repair gear at nearby vendor
    [95] = ".bot action sell",                  -- vendor grey trash
    [96] = "talents",
    [97] = "trainer",
    [98] = "d revive targets",
    [99] = "d food",                            -- eat order (party bots rest and eat)
    [100] = ".bot action stay",                 -- halt and hold spot
    [101] = "d give leader",
    [102] = "",                                 -- role bar, handled in Commands.lua
    [103] = "d use go",                         -- use nearby world object (chests, levers, herbs, ore)

    -- Formations
    [104] = "formation far",
    [105] = "formation show",

    -- Stances
    [106] = "stance near",
    [107] = "stance tank",
    [108] = "stance turnback",
    [109] = "stance behind",
    [110] = ".bot behavior party spread on",    -- combat spacing (replaces invalid stance spread)
    [111] = "stance show",

    -- RTI and Combat Tactics
    [112] = "attack rti",
    [113] = "pull rti",
    [114] = "co ~mark rti",
    [115] = "co ~kite",

    -- RTI Target Marks
    [116] = "rti skull",
    [117] = "rti cross",
    [118] = "rti square",
    [119] = "rti moon",
    [120] = "rti triangle",
    [121] = "rti diamond",
    [122] = "rti circle",
    [123] = "rti star",
    [124] = "rti none",

    -- RTI CC Marks
    [125] = "rti cc skull",
    [126] = "rti cc moon",
    [127] = "rti cc none",

    -- Loot Strategy Filters (ll)
    [128] = "ll ~equip",
    [129] = "ll ~quest",
    [130] = "ll ~skill",
    [131] = "ll ~disenchant",
    [132] = "ll ~use",
    [133] = "ll ~vendor",
    [134] = "ll ~trash",
    [135] = "ll ?",

    -- Mana Conservation Tuning (save mana)
    [136] = "save mana 1",
    [137] = "save mana 2",
    [138] = "save mana 3",
    [139] = "save mana 4",
    [140] = "save mana 5",
    [141] = "save mana ?",

    -- Guard Post & Position Control
    [142] = "position guard set",
    [143] = "guard",
    [144] = "free",

    -- Autonomous Non-Combat RPG Modes (nc)
    [145] = "nc ~rpg",
    [146] = "nc ~rpg quest",
    [147] = "nc ~rpg vendor",
    [148] = "nc ~rpg explore",
    [149] = "nc ~rpg maintenance",
    [150] = "nc ~rpg craft",

    -- Utility, Blacklist & Interaction
    [151] = "mail ?",
    [152] = "ss ?",
    [153] = "talk",
    [154] = "accept *",
    [155] = "r ?",

    -- Modern TortoiseBots Tactical, Raid & Bot Management Commands
    [156] = ".bot action interrupt",            -- interrupt hostile spellcast
    [157] = ".bot action pullback 5 ranged",    -- tank pullback to player anchor
    [158] = "end pull",                         -- abort running pull
    [159] = ".bot action focus skull",          -- DPS focus fire on skull
    [160] = ".bot action aoe",                  -- toggle AoE spells on/off
    [161] = ".bot action auto cc",              -- toggle smart auto CC of adds
    [162] = ".bot action sap",                  -- toggle rogue pre-pull sap
    [163] = ".bot action come",                 -- sprint to player position
    [164] = ".bot action corpse run",           -- run ghost back to corpse
    [165] = "rebuff",                           -- top off expiring party buffs
    [166] = ".bot behavior party mimic on",     -- mimic player potion/elixir use
    [167] = ".bot totem party drop",            -- shamans drop configured totems
    [168] = ".bot action trade",                -- open trade window with bot
    [169] = ".bot maintenance",                 -- restock reagents/consumables/ammo
    [170] = ".bot action raid tankface",        -- drag dragon away from raid
    [171] = ".bot action raid douse",           -- douse nearby Molten Core runes
    [172] = ".bot action raid custom on",       -- enable Turtle raid strategies
    [173] = "wander",                           -- free roaming wander mode
    [174] = "co ~focus",                        -- single-target burn (no splash)
    [175] = "co ~aoe fear",                     -- toggle AoE fears in dungeons
    [176] = ".bot behavior party threat on",    -- ease off near tank threat
    [177] = ".bot behavior party boost on",     -- toggle offensive cooldowns
    [178] = ".bot behavior party potions on",   -- toggle automated potion reactions
    [179] = "share",                            -- share eligible quests with party
    [180] = "home",                             -- bind hearthstone at innkeeper
    [181] = "taxi",                             -- purchase flight path
    [182] = "reset",                            -- soft reset transient combat state
    [183] = ".bot action raid custom off",      -- disable Turtle custom raid tactics
    [184] = ".bot action raid custom status",   -- check Turtle custom raid tactics
    [185] = ".bot action raid status",          -- list loaded boss tactics per bot
}

-- How the command is delivered:
--   1 = SAY, no target needed
--   2 = WHISPER to a friendly target (must be in party/raid)
--   3 = PARTY, requires a hostile target
--   4 = PARTY, applies to the whole group
UnBotCommandType = {
    [0] = 0,
    [1] = 1, [2] = 2, [3] = 4, [4] = 1, [5] = 2, [6] = 2, [7] = 2, [8] = 2,
    [9] = 4, [10] = 2, [11] = 2, [12] = 2, [13] = 4, [14] = 2, [15] = 4,
    [16] = 2, [17] = 4, [18] = 4, [19] = 2, [20] = 4, [21] = 2, [22] = 4,
    [23] = 2, [24] = 4, [25] = 4, [26] = 4, [27] = 4, [28] = 4, [29] = 4,
    [30] = 4, [31] = 2, [32] = 3, [33] = 3, [34] = 3, [35] = 3, [36] = 3,
    [37] = 3, [38] = 4, [39] = 4, [40] = 4, [41] = 4, [42] = 4, [43] = 4,
    [44] = 4, [45] = 4, [46] = 4, [47] = 4, [48] = 2, [49] = 2, [50] = 2,
    [51] = 2, [52] = 2, [53] = 2, [54] = 2, [55] = 2, [56] = 2, [57] = 2,
    [58] = 2, [59] = 2, [60] = 2, [61] = 2, [62] = 4, [63] = 2, [64] = 2,
    [65] = 2, [66] = 2, [67] = 2, [68] = 2, [69] = 2, [70] = 4, [71] = 4,
    [72] = 1, [73] = 1, [74] = 1, [75] = 2, [76] = 2, [77] = 1, [78] = 1,
    [79] = 1, [80] = 1, [81] = 4, [82] = 4, [83] = 4, [84] = 4, [85] = 4,
    [86] = 2, [87] = 2, [88] = 4, [89] = 4,
    -- action-list commands: party-wide unless they act on one bot
    [90] = 4, [91] = 4, [92] = 4, [93] = 4, [94] = 4, [95] = 4,
    [96] = 2, [97] = 4, [98] = 4, [99] = 4, [100] = 4, [101] = 2,
    [102] = 1, [103] = 4,
    -- formations, stances, rti and combat tactics (party-wide)
    [104] = 4, [105] = 4, [106] = 4, [107] = 4, [108] = 4, [109] = 4,
    [110] = 4, [111] = 4, [112] = 4, [113] = 4, [114] = 4, [115] = 4,
    [116] = 4, [117] = 4, [118] = 4, [119] = 4, [120] = 4, [121] = 4,
    [122] = 4, [123] = 4, [124] = 4, [125] = 4, [126] = 4, [127] = 4,
    -- loot filters, mana conservation, guard, rpg, utilities
    [128] = 4, [129] = 4, [130] = 4, [131] = 4, [132] = 4, [133] = 4, [134] = 4, [135] = 4,
    [136] = 4, [137] = 4, [138] = 4, [139] = 4, [140] = 4, [141] = 4,
    [142] = 4, [143] = 4, [144] = 4,
    [145] = 4, [146] = 4, [147] = 4, [148] = 4, [149] = 4, [150] = 4,
    [151] = 4, [152] = 4, [153] = 4, [154] = 4, [155] = 4,
    -- modern TortoiseBots tactical & management commands
    [156] = 3, [157] = 3, [158] = 4, [159] = 4, [160] = 4, [161] = 4, [162] = 4,
    [163] = 4, [164] = 4, [165] = 4, [166] = 4, [167] = 4, [168] = 2, [169] = 2,
    [170] = 4, [171] = 4, [172] = 4, [173] = 4, [174] = 4, [175] = 4, [176] = 4,
    [177] = 4, [178] = 4, [179] = 4, [180] = 2, [181] = 2, [182] = 2,
    [183] = 4, [184] = 4, [185] = 4,
}

-- Which of the command-bar groups a command belongs to.
-- Role shortcuts intentionally stay on their own fixed Role button.
--
--   1 Combat                 7 Party Management
--   2 Movement               8 Strategy
--   3 Support                9 Formation
--   4 Inventory              10 Roster
--   5 Info & Status          11 Utilities & Mail
--   6 Abilities
UnBotCommandToGroups = {
    [0] = 0,
    -- combat: attack, retreat, RTI and tactics
    [25] = 1, [26] = 1, [27] = 1, [28] = 1, [29] = 1, [30] = 1, [31] = 1,
    [32] = 1, [33] = 1, [34] = 1, [35] = 1, [36] = 1, [37] = 1,
    [70] = 1, [91] = 1, [92] = 1,
    [112] = 1, [113] = 1, [114] = 1, [115] = 1,
    [116] = 1, [117] = 1, [118] = 1, [119] = 1, [120] = 1, [121] = 1,
    [122] = 1, [123] = 1, [124] = 1, [125] = 1, [126] = 1, [127] = 1,
    [156] = 1, [157] = 1, [158] = 1, [159] = 1, [160] = 1, [161] = 1, [162] = 1,
    [174] = 1, [175] = 1,
    -- movement & stances
    [15] = 2, [16] = 2, [47] = 2, [76] = 2, [100] = 2,
    [106] = 2, [107] = 2, [108] = 2, [109] = 2, [110] = 2, [111] = 2,
    [142] = 2, [143] = 2, [144] = 2, [163] = 2, [173] = 2,
    -- support and upkeep
    [18] = 3, [19] = 3, [24] = 3, [55] = 3, [56] = 3, [57] = 3,
    [58] = 3, [59] = 3, [60] = 3, [61] = 3, [80] = 3, [81] = 3,
    [89] = 3, [90] = 3, [98] = 3, [99] = 3,
    [145] = 3, [146] = 3, [147] = 3, [148] = 3, [149] = 3, [150] = 3,
    [164] = 3, [165] = 3, [166] = 3, [167] = 3, [178] = 3,
    -- inventory and item maintenance
    [11] = 4, [64] = 4, [65] = 4, [66] = 4, [67] = 4, [68] = 4,
    [93] = 4, [94] = 4, [95] = 4,
    [128] = 4, [129] = 4, [130] = 4, [131] = 4, [132] = 4, [133] = 4, [134] = 4, [135] = 4,
    [168] = 4,
    -- information and status
    [20] = 5, [21] = 5, [22] = 5, [23] = 5, [62] = 5, [63] = 5,
    -- training and abilities
    [5] = 6, [6] = 6, [7] = 6, [8] = 6, [17] = 6, [69] = 6,
    [96] = 6, [97] = 6,
    -- party management
    [1] = 7, [2] = 7, [3] = 7, [4] = 7, [12] = 7, [13] = 7, [14] = 7,
    [71] = 7, [73] = 7, [82] = 7, [83] = 7, [86] = 7, [87] = 7,
    [101] = 7, [169] = 7,
    -- strategy, AI and target behaviour
    [9] = 8, [10] = 8, [48] = 8, [49] = 8, [50] = 8, [51] = 8,
    [52] = 8, [53] = 8, [54] = 8, [75] = 8, [84] = 8, [85] = 8,
    [136] = 8, [137] = 8, [138] = 8, [139] = 8, [140] = 8, [141] = 8,
    [170] = 8, [171] = 8, [172] = 8, [176] = 8, [177] = 8, [182] = 8,
    -- formation
    [38] = 9, [39] = 9, [40] = 9, [41] = 9, [42] = 9, [43] = 9,
    [44] = 9, [45] = 9, [46] = 9, [104] = 9, [105] = 9,
    [102] = 0,
    -- group 11: utilities, mail, blacklist & world interaction
    [72] = 11, [88] = 11, [103] = 11, [151] = 11, [152] = 11, [153] = 11, [154] = 11, [155] = 11,
    [179] = 11, [180] = 11, [181] = 11,
}

-- Display order inside each group.  Any future command not listed here is
-- appended using its command ID, so adding an action cannot hide it.
UnBotCommandOrder = {
    [1] = { 32, 91, 156, 92, 157, 158, 159, 112, 113, 33, 35, 34, 36, 37,
            160, 161, 162, 174, 175, 115, 114, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
            70, 25, 31, 26, 28, 27, 29, 30 },
    [2] = { 15, 16, 163, 100,
            47, 76, 142, 143, 144, 173,
            106, 107, 108, 109, 110, 111 },
    [3] = { 80, 90, 165, 99, 81, 166, 178, 167,
            24, 89,
            145, 146, 147, 148, 149, 150,
            98, 164, 18, 19 },
    [4] = { 64, 168, 93, 66, 94,
            68, 67, 95, 65,
            128, 129, 130, 131, 132, 133, 134, 135 },
    [5] = { 22, 23,
            62, 63,
            20, 21 },
    [6] = { 96, 69,
            97, 17 },
    [7] = { 87, 86, 2, 169,
            83, 82, 3,
            13, 14,
            101, 71 },
    [8] = { 54, 85, 9, 10, 182,
            176, 177,
            170, 171, 172,
            136, 137, 138, 139, 140, 141 },
    [9] = { 46, 105, 38, 42, 43, 40, 41, 39, 45, 44, 104 },
    [10] = {},
    [11] = { 151, 154, 155, 179,
             180, 181,
             152, 153,
             103, 72, 88 },
}

-- Icon per command.
-- The 3.3.5 addon leaned heavily on Achievement_* textures, which only shipped
-- with WotLK and render as an empty button on 1.12. Entries marked "orig" are
-- the untouched original icon; the rest are Vanilla-safe stand-ins.
local I   = "Interface\\Icons\\"
local IRT = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local IM  = "Interface\\AddOns\\Retinue\\Images\\"

-- Ingame icon mappings for all commands including raid marks and crowd control:
UnBotCommandRaidTarget = {
    [116] = 8,  -- Target: Skull
    [117] = 7,  -- Target: Cross
    [118] = 6,  -- Target: Square
    [119] = 5,  -- Target: Moon
    [120] = 4,  -- Target: Triangle
    [121] = 3,  -- Target: Diamond
    [122] = 2,  -- Target: Circle
    [123] = 1,  -- Target: Star
    [125] = 8,  -- CC: Skull
    [126] = 5,  -- CC: Moon
    [159] = 8,  -- Focus Skull
}
UnBotCommandIcon = {
    [0]  = I.."Temp",                          -- orig (the WoW logo icon)

    -- group 1: bot roster, init, summoning
    [1]  = I.."INV_Misc_Horn_02",
    [2]  = I.."INV_Misc_Gear_01",
    [3]  = I.."INV_Misc_Gear_02",
    [4]  = I.."INV_Banner_03",                 -- orig
    [12] = I.."INV_Misc_Book_09",
    [13] = I.."Spell_Arcane_PortalStormWind",  -- orig
    [14] = I.."Spell_Arcane_TeleportStormWind",-- orig
    [82] = I.."Ability_Vanish",                -- orig
    [83] = I.."INV_Misc_Horn_02",              -- orig
    [86] = I.."Ability_Druid_SupriseAttack",   -- orig
    [87] = I.."Spell_ChargePositive",          -- orig INV_Misc_Horn_04 absent on 1.12

    -- group 2: movement and upkeep
    [15] = I.."Ability_Rogue_Sprint",
    [16] = I.."Ability_Rogue_Sprint",          -- orig
    [17] = I.."INV_Misc_Book_09",              -- orig
    [18] = I.."Spell_Holy_Resurrection",
    [19] = I.."Spell_Holy_Resurrection",
    [24] = I.."INV_Holiday_Christmas_Present_01", -- orig
    [89] = I.."Ability_Hunter_BeastTaming",    -- orig

    -- group 3: flee
    [25] = I.."Ability_Vanish",
    [26] = I.."Ability_FiegnDead",             -- orig
    [27] = I.."INV_Sword_04",
    [28] = I.."Ability_Hunter_Pathfinding",    -- orig
    [29] = I.."Ability_Warrior_Charge",
    [30] = I.."Ability_Mage_Invisibility",     -- orig
    [31] = I.."Ability_Rogue_Feint",           -- orig Ability_Hunter_Readiness absent on 1.12

    -- group 4: attack
    [32] = I.."Ability_DualWield",             -- orig
    [33] = I.."INV_Shield_06",
    [34] = I.."INV_Sword_04",
    [35] = I.."Spell_Holy_Heal",
    [36] = I.."Ability_Whirlwind",
    [37] = I.."Ability_Marksmanship",          -- orig

    -- group 5: formations
    [38] = I.."INV_Weapon_Bow_02",             -- arrow
    [39] = I.."Ability_Warrior_DefensiveStance",
    [40] = I.."Ability_Tracking",              -- orig
    [41] = I.."Ability_Whirlwind",
    [42] = I.."INV_Misc_Rune_01",              -- line
    [43] = I.."Spell_Nature_WispSplode",       -- circle
    [44] = I.."Ability_GolemThunderClap",      -- chaos; orig throwing-spec absent
    [45] = I.."INV_Shield_06",
    [46] = I.."Ability_Search",

    -- group 6: stance and class toggles
    [47] = I.."Ability_Warrior_DefensiveStance",
    [48] = I.."Ability_Search",
    [49] = I.."Ability_Marksmanship",
    [50] = I.."Spell_Nature_ForceOfNature",    -- orig
    [51] = I.."Ability_Racial_BearForm",       -- orig
    [52] = I.."Ability_Druid_CatForm",         -- orig
    [53] = I.."Spell_Nature_HealingTouch",
    [62] = I.."Spell_Holy_PrayerOfHealing",
    [63] = I.."Spell_Holy_PrayerOfHealing",
    [70] = I.."INV_Misc_EngGizmos_27",         -- orig
    [71] = I.."Ability_Vanish",
    [75] = I.."INV_Misc_QuestionMark",
    [76] = I.."ABILITY_SEAL",                  -- orig

    -- group 7: items
    [11] = I.."Ability_CheapShot",             -- orig
    [64] = I.."INV_Misc_Bag_08",               -- orig
    [65] = I.."Ability_Creature_Cursed_05",
    [66] = I.."INV_Helmet_02",
    [67] = I.."INV_Scroll_11",                 -- orig
    [68] = I.."INV_Potion_51",                 -- orig INV_Misc_Toy_04 absent on 1.12
    [81] = I.."INV_Drink_05",

    -- group 8: info and buffs
    [20] = I.."INV_Misc_Note_01",
    [21] = I.."INV_Misc_Note_01",
    [22] = I.."INV_Misc_Coin_02",              -- orig
    [23] = I.."INV_Misc_Coin_01",              -- orig Coin_17 absent on 1.12
    [54] = I.."INV_Misc_Book_09",
    [55] = I.."Spell_Frost_WizardMark",        -- orig
    [56] = I.."Spell_Fire_SealOfFire",         -- orig
    [57] = I.."Spell_Holy_DevotionAura",       -- orig
    [58] = I.."Ability_Rogue_Sprint",
    [59] = I.."Spell_Magic_MageArmor",         -- orig
    [60] = I.."Spell_Holy_SealOfWisdom",       -- orig
    [61] = I.."Spell_Holy_FistOfJustice",      -- orig
    [69] = I.."INV_Misc_Book_06",              -- orig
    [73] = I.."Spell_Shadow_Twilight",         -- orig

    -- group 9: talents and raid
    [5]  = I.."INV_Misc_Book_09",
    [6]  = I.."INV_Misc_Book_09",
    [7]  = I.."INV_Misc_Book_09",
    [8]  = I.."INV_Misc_Book_09",
    [9]  = I.."Spell_Nature_Purge",
    [10] = I.."Spell_Nature_Purge",
    [84] = I.."Spell_Shadow_ShadowBolt",       -- naxx
    [85] = I.."INV_Helmet_02",                 -- orig

    -- group 10: windows and social
    [72] = I.."INV_Misc_QuestionMark",
    [74] = I.."INV_Banner_02",                 -- orig GroupNeedMore absent on 1.12
    [77] = I.."INV_Misc_Head_Human_01",
    [78] = I.."Spell_unused2",                 -- orig
    [79] = I.."Spell_Holy_PrayerofSpirit",     -- orig
    [80] = I.."INV_Misc_PocketWatch_01",
    [88] = I.."Spell_ChargePositive",

    -- action-list commands
    [90]  = I.."Spell_Holy_GreaterBlessingofKings",
    [91]  = I.."Ability_Warrior_Charge",
    [92]  = I.."Ability_Marksmanship",
    [93]  = I.."INV_Misc_Gear_01",
    [94]  = I.."Trade_BlackSmithing",
    [95]  = I.."INV_Misc_Coin_02",
    [96]  = I.."INV_Misc_Book_09",
    [97]  = I.."INV_Misc_Note_01",
    [98]  = I.."Spell_Holy_Resurrection",
    [99]  = I.."INV_Misc_Food_15",
    [100] = I.."Ability_Warrior_DefensiveStance",
    [101] = I.."INV_Banner_02",
    [102] = I.."Ability_Warrior_BattleShout",   -- GroupLooking is absent on 1.12
    [103] = I.."INV_Box_01",

    -- formations, stances, rti and combat tactics
    [104] = I.."Ability_Hunter_EagleEye",
    [105] = I.."Ability_Search",
    [106] = I.."Ability_Warrior_DefensiveStance",
    [107] = I.."INV_Shield_06",
    [108] = I.."Ability_Rogue_Distract",
    [109] = I.."Ability_Backstab",
    [110] = I.."Spell_Nature_Earthquake",
    [111] = I.."Ability_Tracking",
    [112] = I.."Ability_Hunter_SniperShot",     -- Attack RTI
    [113] = I.."Ability_TrueShot",              -- Pull RTI
    [114] = I.."Ability_Marksmanship",          -- Auto mark RTI
    [115] = I.."Ability_Hunter_RunningShot",    -- Toggle Kite
    [116] = IRT,                                -- Target: Skull (RTI 8)
    [117] = IRT,                                -- Target: Cross (RTI 7)
    [118] = IRT,                                -- Target: Square (RTI 6)
    [119] = IRT,                                -- Target: Moon (RTI 5)
    [120] = IRT,                                -- Target: Triangle (RTI 4)
    [121] = IRT,                                -- Target: Diamond (RTI 3)
    [122] = IRT,                                -- Target: Circle (RTI 2)
    [123] = IRT,                                -- Target: Star (RTI 1)
    [124] = I.."Spell_ChargeNegative",          -- Target: Clear
    [125] = IRT,                                -- CC: Skull (RTI 8)
    [126] = IRT,                                -- CC: Moon (RTI 5)
    [127] = I.."Spell_Holy_DispelMagic",        -- CC: Clear

    -- loot strategy filters (128-135)
    [128] = I.."INV_Chest_Chain_05",
    [129] = I.."INV_Misc_Book_08",
    [130] = I.."Trade_Engineering",
    [131] = I.."Spell_Holy_DispelMagic",
    [132] = I.."INV_Potion_51",
    [133] = I.."INV_Misc_Coin_01",
    [134] = I.."INV_Misc_Bone_01",
    [135] = I.."INV_Misc_QuestionMark",

    -- mana conservation levels (136-141)
    [136] = I.."Spell_Frost_ManaRecharge",
    [137] = I.."INV_Misc_Gem_Sapphire_01",
    [138] = I.."INV_Misc_Gem_Sapphire_02",
    [139] = I.."INV_Misc_Gem_Sapphire_03",
    [140] = I.."INV_Misc_Gem_Sapphire_04",
    [141] = I.."INV_Misc_QuestionMark",

    -- guard post & position control (142-144)
    [142] = I.."INV_Misc_Map_01",
    [143] = I.."Ability_Defend",
    [144] = I.."Ability_Racial_Shadowmeld",

    -- autonomous RPG modes (145-150)
    [145] = I.."INV_Misc_Dice_02",
    [146] = I.."INV_Misc_Book_07",
    [147] = I.."INV_Misc_Bag_10_Green",
    [148] = I.."Ability_Mount_Raptor",
    [149] = I.."Trade_BlackSmithing",
    [150] = I.."INV_Misc_Gear_08",

    -- utilities & mail (151-155)
    [151] = I.."INV_Letter_15",
    [152] = I.."Spell_Shadow_SacrificialShield",
    [153] = I.."Spell_Holy_Silence",
    [154] = I.."INV_Misc_Note_02",
    [155] = I.."INV_Box_02",
    -- modern TortoiseBots actions (156-182)
    [156] = I.."Ability_Kick",
    [157] = I.."Ability_Hunter_RunningShot",
    [158] = I.."Spell_ChargeNegative",
    [159] = IRT,                                -- Focus Skull (RTI 8)
    [160] = I.."Spell_Fire_SelfDestruct",       -- Toggle AoE
    [161] = I.."Spell_Nature_Polymorph",
    [162] = I.."Ability_Sap",
    [163] = I.."Spell_Nature_TimeStop",
    [164] = I.."Spell_Shadow_AntiShadow",
    [165] = I.."Spell_Holy_GreaterBlessingofKings",
    [166] = I.."INV_Potion_93",
    [167] = I.."Spell_Nature_EarthBindTotem",   -- Drop totems
    [168] = I.."INV_Misc_Coin_01",
    [169] = I.."Trade_BlackSmithing",
    [170] = I.."INV_Misc_Head_Dragon_01",
    [171] = I.."Spell_Frost_Glacier",
    [172] = I.."INV_Misc_Head_Dragon_Bronze",
    [173] = I.."Ability_Hunter_BeastTaming",
    [174] = I.."Ability_Gouge",
    [175] = I.."Spell_Shadow_PsychicScream",
    [176] = I.."Ability_Rogue_Feint",           -- Threat back-off
    [177] = I.."Spell_Nature_BloodLust",        -- Offensive boost
    [178] = I.."INV_Potion_54",
    [179] = I.."INV_Misc_Note_03",
    [180] = I.."INV_Misc_Rune_01",
    [181] = I.."Ability_Mount_Gryphon_01",
    [182] = I.."Spell_Holy_DispelMagic",
    [183] = I.."Spell_Shadow_AntiShadow",
    [184] = I.."Spell_Arcane_PortalIronForge",
    [185] = I.."INV_Misc_Book_11",
}

-- Original 3.3.5 icon indices, kept for reference only.
UnBotIconFiles = {
    [0] = 5983, [1] = 514, [2] = 1177, [3] = 1178, [4] = 1287, [5] = 1125,
    [6] = 940, [7] = 943, [8] = 938, [9] = 548, [10] = 547, [11] = 4,
    [12] = 541, [13] = 5398, [14] = 5415, [15] = 364, [16] = 369, [17] = 3006,
    [18] = 569, [19] = 569, [20] = 928, [21] = 925, [22] = 3057, [23] = 3072,
    [24] = 2212, [25] = 80, [26] = 85, [27] = 133, [28] = 134, [29] = 112,
    [30] = 203, [31] = 171, [32] = 81, [33] = 483, [34] = 485, [35] = 304,
    [36] = 480, [37] = 214, [38] = 5089, [39] = 4497, [40] = 399, [41] = 493,
    [42] = 4659, [43] = 565, [44] = 301, [45] = 372, [46] = 562, [47] = 523,
    [48] = 357, [49] = 609, [50] = 5740, [51] = 325, [52] = 28, [53] = 78,
    [54] = 5678, [55] = 5548, [56] = 5507, [57] = 5578, [58] = 5574, [59] = 5694,
    [60] = 5666, [61] = 5593, [62] = 817, [63] = 779, [64] = 2888, [65] = 5979,
    [66] = 900, [67] = 4445, [68] = 3966, [69] = 3003, [70] = 3163, [71] = 169,
    [72] = 4662, [73] = 5946, [74] = 3513, [75] = 515, [76] = 380, [77] = 598,
    [78] = 5982, [79] = 5639, [80] = 5974, [81] = 1758, [82] = 402, [83] = 3596,
    [84] = 615, [85] = 2065, [86] = 74, [87] = 3598, [88] = 174, [89] = 103,
}

-- Legacy default commands retained for saved-variable compatibility.  The
-- current command bar uses these ten slots as labelled group launchers, so
-- the commands themselves are now selected inside each group's window.
UnBotGroupDefault = {
    [1] = 32,   -- attack your target
    [2] = 15,   -- follow
    [3] = 80,   -- ready check
    [4] = 64,   -- bags window
    [5] = 22,   -- party status
    [6] = 69,   -- spell window
    [7] = 13,   -- party management
    [8] = 54,   -- strategy window
    [9] = 38,   -- formation
    [10] = 74,  -- account roster window
}

--=========================================================================--
--  TortoiseBots TBM Protocol Constants & Roles Alignment
--=========================================================================--

Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue
Retinue.C = Retinue.C or {}
local C = Retinue.C

C.VERSION = "1.1.0"
C.ADDON_PREFIX = "TBM"
C.ADDON_TRANSPORT = "PARTY"
C.SEND_DELAY = 0.35

C.STATUS = {
    OFFLINE         = "offline",
    OFFLINE_PENDING = "offline-pending",
    UNKNOWN         = "unknown",
    FAILED          = "failed",
    QUEUED          = "queued",
    STARTING        = "starting",
    ONLINE          = "online",
    COMMANDING      = "commanding",
    SUMMONING       = "summoning",
    INVITING        = "inviting",
    KICKING         = "kicking",
    REMOVING        = "removing",
}

C.CLASS_NAMES = {
    [1]  = "Warrior",
    [2]  = "Paladin",
    [3]  = "Hunter",
    [4]  = "Rogue",
    [5]  = "Priest",
    [6]  = "Death Knight",
    [7]  = "Shaman",
    [8]  = "Mage",
    [9]  = "Warlock",
    [11] = "Druid",
}

C.CLASS_NAME_TO_ID = {
    Warrior = 1, WARRIOR = 1,
    Paladin = 2, PALADIN = 2,
    Hunter  = 3, HUNTER  = 3,
    Rogue   = 4, ROGUE   = 4,
    Priest  = 5, PRIEST  = 5,
    ["Death Knight"] = 6, DEATHKNIGHT = 6,
    Shaman  = 7, SHAMAN  = 7,
    Mage    = 8, MAGE    = 8,
    Warlock = 9, WARLOCK = 9,
    Druid   = 11, DRUID  = 11,
}

C.CLASS_COLORS = {
    [1]  = { 0.78, 0.61, 0.43, hex = "ffc79c6e" },
    [2]  = { 0.96, 0.55, 0.73, hex = "fff58cba" },
    [3]  = { 0.67, 0.83, 0.45, hex = "ffabd473" },
    [4]  = { 1.00, 0.96, 0.41, hex = "fffff569" },
    [5]  = { 1.00, 1.00, 1.00, hex = "ffffffff" },
    [6]  = { 0.77, 0.12, 0.23, hex = "ffc41f3b" },
    [7]  = { 0.00, 0.44, 0.87, hex = "ff0070de" },
    [8]  = { 0.41, 0.80, 0.94, hex = "ff69ccf0" },
    [9]  = { 0.58, 0.51, 0.79, hex = "ff9482c9" },
    [11] = { 1.00, 0.49, 0.04, hex = "ffff7d0a" },
}

--=========================================================================--
--  Class Coordinates (256x256 UI-CharacterCreate-Classes) & Colors
--  Vanilla 1.12.1 / Turtle WoW FrameXML does not provide CLASS_ICON_TCOORDS
--  globally, so we define and export it universally to avoid nil indexing.
--=========================================================================--

CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS or {
    WARRIOR     = {0.0, 0.25, 0.0, 0.25},
    MAGE        = {0.25, 0.49609375, 0.0, 0.25},
    ROGUE       = {0.49609375, 0.7421875, 0.0, 0.25},
    DRUID       = {0.7421875, 0.98828125, 0.0, 0.25},
    HUNTER      = {0.0, 0.25, 0.25, 0.5},
    SHAMAN      = {0.25, 0.49609375, 0.25, 0.5},
    PRIEST      = {0.49609375, 0.7421875, 0.25, 0.5},
    WARLOCK     = {0.7421875, 0.98828125, 0.25, 0.5},
    PALADIN     = {0.0, 0.25, 0.5, 0.75},
    DEATHKNIGHT = {0.25, 0.5, 0.5, 0.75},
}

CLASS_COLOR = CLASS_COLOR or {
    WARRIOR     = {0.78, 0.61, 0.43, hex = "ffc79c6e"},
    PALADIN     = {0.96, 0.55, 0.73, hex = "fff58cba"},
    HUNTER      = {0.67, 0.83, 0.45, hex = "ffabd473"},
    ROGUE       = {1.00, 0.96, 0.41, hex = "fffff569"},
    PRIEST      = {1.00, 1.00, 1.00, hex = "ffffffff"},
    DEATHKNIGHT = {0.77, 0.12, 0.23, hex = "ffc41f3b"},
    SHAMAN      = {0.00, 0.44, 0.87, hex = "ff0070de"},
    MAGE        = {0.41, 0.80, 0.94, hex = "ff69ccf0"},
    WARLOCK     = {0.58, 0.51, 0.79, hex = "ff9482c9"},
    DRUID       = {1.00, 0.49, 0.04, hex = "ffff7d0a"},
}

local classAliases = {
    [1]  = "WARRIOR",     ["1"]  = "WARRIOR",     Warrior = "WARRIOR",     warrior = "WARRIOR",
    [2]  = "PALADIN",     ["2"]  = "PALADIN",     Paladin = "PALADIN",     paladin = "PALADIN",
    [3]  = "HUNTER",      ["3"]  = "HUNTER",      Hunter  = "HUNTER",      hunter  = "HUNTER",
    [4]  = "ROGUE",       ["4"]  = "ROGUE",       Rogue   = "ROGUE",       rogue   = "ROGUE",
    [5]  = "PRIEST",      ["5"]  = "PRIEST",      Priest  = "PRIEST",      priest  = "PRIEST",
    [6]  = "DEATHKNIGHT", ["6"]  = "DEATHKNIGHT", ["Death Knight"] = "DEATHKNIGHT", deathknight = "DEATHKNIGHT",
    [7]  = "SHAMAN",      ["7"]  = "SHAMAN",      Shaman  = "SHAMAN",      shaman  = "SHAMAN",
    [8]  = "MAGE",        ["8"]  = "MAGE",        Mage    = "MAGE",        mage    = "MAGE",
    [9]  = "WARLOCK",     ["9"]  = "WARLOCK",     Warlock = "WARLOCK",     warlock = "WARLOCK",
    [11] = "DRUID",       ["11"] = "DRUID",       Druid   = "DRUID",       druid   = "DRUID",
}

for alias, canonical in pairs(classAliases) do
    if CLASS_ICON_TCOORDS[canonical] and not CLASS_ICON_TCOORDS[alias] then
        CLASS_ICON_TCOORDS[alias] = CLASS_ICON_TCOORDS[canonical]
    end
    if CLASS_COLOR[canonical] and not CLASS_COLOR[alias] then
        CLASS_COLOR[alias] = CLASS_COLOR[canonical]
    end
end

Retinue.CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
C.CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
Retinue.CLASS_COLOR = CLASS_COLOR
C.CLASS_COLOR = CLASS_COLOR

function UnBot:GetClassColor(classOrId)
    local fallback = { 0.92, 0.90, 0.84, hex = "ffebe6d6" }
    if not classOrId then return fallback end
    if CLASS_COLOR and CLASS_COLOR[classOrId] then
        return CLASS_COLOR[classOrId]
    end
    local num = tonumber(classOrId)
    if num and CLASS_COLOR and CLASS_COLOR[num] then
        return CLASS_COLOR[num]
    end
    if type(classOrId) == "string" then
        local up = string.upper(classOrId)
        if CLASS_COLOR and CLASS_COLOR[up] then
            return CLASS_COLOR[up]
        end
    end
    if Retinue and Retinue.C and Retinue.C.CLASS_COLORS then
        if num and Retinue.C.CLASS_COLORS[num] then
            return Retinue.C.CLASS_COLORS[num]
        end
    end
    return fallback
end

function UnBot:GetClassCoords(classOrId)
    if not classOrId then return nil end
    local coords = CLASS_ICON_TCOORDS or (Retinue and Retinue.CLASS_ICON_TCOORDS)
    if not coords then return nil end
    if coords[classOrId] then return coords[classOrId] end
    local num = tonumber(classOrId)
    if num and coords[num] then return coords[num] end
    if type(classOrId) == "string" then
        local up = string.upper(classOrId)
        if coords[up] then return coords[up] end
    end
    return nil
end

function UnBot:GetClassName(classOrId)
    if not classOrId then return "Unknown" end
    local num = tonumber(classOrId)
    if num and Retinue and Retinue.C and Retinue.C.CLASS_NAMES and Retinue.C.CLASS_NAMES[num] then
        return Retinue.C.CLASS_NAMES[num]
    end
    if type(classOrId) == "string" then
        local up = string.upper(classOrId)
        if Retinue and Retinue.C and Retinue.C.CLASS_NAME_TO_ID and Retinue.C.CLASS_NAME_TO_ID[up] then
            local id = Retinue.C.CLASS_NAME_TO_ID[up]
            if Retinue.C.CLASS_NAMES and Retinue.C.CLASS_NAMES[id] then
                return Retinue.C.CLASS_NAMES[id]
            end
        end
        return classOrId
    end
    return tostring(classOrId)
end

function UnBot:GetClassToken(classOrId)
    if not classOrId then return "WARRIOR" end
    local num = tonumber(classOrId)
    if num and Retinue and Retinue.C and Retinue.C.CLASS_NAMES and Retinue.C.CLASS_NAMES[num] then
        return string.upper(Retinue.C.CLASS_NAMES[num])
    end
    if type(classOrId) == "string" then
        local up = string.upper(classOrId)
        if CLASS_COLOR and CLASS_COLOR[up] then return up end
        if Retinue and Retinue.C and Retinue.C.CLASS_NAME_TO_ID and Retinue.C.CLASS_NAME_TO_ID[up] then
            local id = Retinue.C.CLASS_NAME_TO_ID[up]
            if Retinue.C.CLASS_NAMES and Retinue.C.CLASS_NAMES[id] then
                return string.upper(Retinue.C.CLASS_NAMES[id])
            end
        end
        return up
    end
    return "WARRIOR"
end

C.CC_MARKS = {
    { id = "moon",     label = "Moon",     icon = 5 },
    { id = "circle",   label = "Circle",   icon = 2 },
    { id = "square",   label = "Square",   icon = 6 },
    { id = "cross",    label = "Cross",    icon = 7 },
    { id = "triangle", label = "Triangle", icon = 4 },
    { id = "diamond",  label = "Diamond",  icon = 3 },
    { id = "star",     label = "Star",     icon = 1 },
    { id = "skull",    label = "Skull",    icon = 8 },
}
C.CC_MARK_LABELS = {}
C.CC_MARK_ICONS = {}
for i = 1, table.getn(C.CC_MARKS) do
    local mark = C.CC_MARKS[i]
    C.CC_MARK_LABELS[mark.id] = mark.label
    C.CC_MARK_ICONS[mark.id] = mark.icon
end

C.PULL_DELAY_DEFAULT     = 10
C.PULLBACK_DELAY_DEFAULT = 3
C.PULL_DELAY_MIN         = 0
C.PULL_DELAY_MAX         = 60

C.BEHAVIORS = {
    { key = "loot",     label = "Loot corpses", tip = "Loot corpses after a fight." },
    { key = "aoe",      label = "AoE spells",   tip = "Use area-of-effect abilities (held back next to crowd-controlled mobs)." },
    { key = "autocc",   label = "Auto CC",      tip = "Crowd-control a loose add that hits your healer, on its own. Your CC marks always win." },
    { key = "savemana", label = "Save mana",    tip = "Wait longer between repeated casts to stretch mana on long fights.", mana = true },
    { key = "boost",    label = "Cooldowns",    tip = "Use big offensive cooldowns during fights." },
    { key = "threat",   label = "Watch threat", tip = "Ease off damage when close to pulling aggro from the tank." },
    { key = "potions",  label = "Potions",      tip = "Drink healing and mana potions when low." },
}
C.NO_MANA_CLASSES = { [1] = true, [4] = true }

-- Paperdoll slot mapping for Bot Inspector
C.GEAR_LEFT = {
    { slot = 0,  label = "Head",     empty = "Head" },
    { slot = 1,  label = "Neck",     empty = "Neck" },
    { slot = 2,  label = "Shoulder", empty = "Shoulder" },
    { slot = 14, label = "Back",     empty = "Chest" },
    { slot = 4,  label = "Chest",    empty = "Chest" },
    { slot = 3,  label = "Shirt",    empty = "Shirt" },
    { slot = 18, label = "Tabard",   empty = "Tabard" },
    { slot = 8,  label = "Wrist",    empty = "Wrists" },
}
C.GEAR_RIGHT = {
    { slot = 9,  label = "Hands",    empty = "Hands" },
    { slot = 5,  label = "Waist",    empty = "Waist" },
    { slot = 6,  label = "Legs",     empty = "Legs" },
    { slot = 7,  label = "Feet",     empty = "Feet" },
    { slot = 10, label = "Ring",     empty = "Finger" },
    { slot = 11, label = "Ring",     empty = "Finger" },
    { slot = 12, label = "Trinket",  empty = "Trinket" },
    { slot = 13, label = "Trinket",  empty = "Trinket" },
}
C.GEAR_BOTTOM = {
    { slot = 15, label = "Main hand", empty = "MainHand" },
    { slot = 16, label = "Off hand",  empty = "SecondaryHand" },
    { slot = 17, label = "Ranged",    empty = "Ranged" },
}

-- Unified Combat Role Policy
Retinue = Retinue or {}
retinue = Retinue
UnBot = Retinue
Retinue.Roles = Retinue.Roles or {}
local Roles = Retinue.Roles

Roles.CLASS_ROLES = {
    [1] = { -- Warrior
        { id = "tank", label = "Tank", strat = "+protection,-arms,-fury" },
        { id = "dps",  label = "DPS",  strat = "+arms,-protection" },
    },
    [2] = { -- Paladin
        { id = "tank", label = "Tank",   strat = "+protection,-holy,-retribution" },
        { id = "heal", label = "Healer", strat = "+holy,-protection,-retribution,-offdps" },
        { id = "dps",  label = "DPS",    strat = "+retribution,-protection,-holy" },
    },
    [3] = { -- Hunter
        { id = "bm",       label = "Beastmaster", strat = "+beast mastery,-marksmanship,-survival" },
        { id = "mm",       label = "Marksman",    strat = "+marksmanship,-beast mastery,-survival" },
        { id = "survival", label = "Survival",    strat = "+survival,-beast mastery,-marksmanship" },
    },
    [4] = { -- Rogue
        { id = "combat",   label = "Combat",       strat = "+combat,-assassination,-subtlety" },
        { id = "assa",     label = "Assassination", strat = "+assassination,-combat,-subtlety" },
        { id = "subtlety", label = "Subtlety",      strat = "+subtlety,-combat,-assassination" },
    },
    [5] = { -- Priest
        { id = "heal",   label = "Healer", strat = "+holy,-shadow,-offdps" },
        { id = "hybrid", label = "Hybrid", strat = "+holy,+offdps,-shadow" },
        { id = "dps",    label = "Shadow", strat = "+shadow,-holy,-discipline,-offdps" },
    },
    [7] = { -- Shaman
        { id = "heal", label = "Healer",  strat = "+restoration,-elemental,-enhancement,-offdps" },
        { id = "ele",  label = "Ele DPS", strat = "+elemental,-restoration,-enhancement" },
        { id = "enh",  label = "Enh DPS", strat = "+enhancement,-restoration,-elemental" },
    },
    [8] = { -- Mage
        { id = "frost",  label = "Frost",  strat = "+frost,-fire,-arcane" },
        { id = "fire",   label = "Fire",   strat = "+fire,-frost,-arcane" },
        { id = "arcane", label = "Arcane", strat = "+arcane,-frost,-fire" },
    },
    [9] = { -- Warlock
        { id = "affliction",  label = "Affliction",  strat = "+affliction,-demonology,-destruction" },
        { id = "demonology",  label = "Demonology",  strat = "+demonology,-affliction,-destruction" },
        { id = "destruction", label = "Destruction", strat = "+destruction,-affliction,-demonology" },
    },
    [11] = { -- Druid
        { id = "tank",    label = "Bear Tank",  strat = "+tank feral,-dps feral,-restoration,-balance" },
        { id = "cat",     label = "Cat DPS",    strat = "+dps feral,-tank feral,-restoration,-balance" },
        { id = "heal",    label = "Resto Heal", strat = "+restoration,-tank feral,-dps feral,-balance,-offdps" },
        { id = "boomkin", label = "Boomkin",    strat = "+balance,-tank feral,-dps feral,-restoration" },
    },
}

function Roles.GetClassRoles(classId)
    if type(classId) == "string" and C.CLASS_NAME_TO_ID then
        classId = C.CLASS_NAME_TO_ID[classId] or classId
    end
    return (Roles.CLASS_ROLES and Roles.CLASS_ROLES[classId]) or {}
end

function Roles.FindRole(classId, roleId)
    if not roleId and type(classId) == "string" then
        roleId = classId
        classId = nil
    end
    if not roleId then return nil end
    local lowerRole = type(roleId) == "string" and string.lower(roleId) or nil
    if classId then
        local list = Roles.GetClassRoles(classId)
        for i = 1, table.getn(list) do
            local r = list[i]
            if r.id == roleId or (lowerRole and r.label and string.lower(r.label) == lowerRole) then
                return r
            end
        end
        return nil
    end
    if Roles.CLASS_ROLES then
        for _, list in pairs(Roles.CLASS_ROLES) do
            for i = 1, table.getn(list) do
                local r = list[i]
                if r.id == roleId or (lowerRole and r.label and string.lower(r.label) == lowerRole) then
                    return r
                end
            end
        end
    end
    return nil
end

function Roles.GetBotRole(botName, classId)
    local dbRoles = (RetinueConfig and RetinueConfig.botRoles) or {}
    local currentId = dbRoles[botName]
    local roles = Roles.GetClassRoles(classId)
    if not currentId and roles[1] then
        currentId = roles[1].id
    end
    return currentId, Roles.FindRole(classId, currentId)
end

function Roles.GetPlayerRole(classId)
    local roleId = RetinueConfig and RetinueConfig.playerRole
    local roles = Roles.GetClassRoles(classId)
    if not roleId and roles[1] then
        roleId = roles[1].id
    end
    return roleId, Roles.FindRole(classId, roleId)
end

function Roles.SetPlayerRole(roleId, classId)
    if not RetinueConfig then RetinueConfig = {} end
    RetinueConfig.playerRole = roleId
    if roleId then
        UnBot:SendBotCommand("role self " .. roleId)
    end
end

function Roles.CycleBotRole(botName, classId)
    if not botName then return end
    local roles = Roles.GetClassRoles(classId)
    local total = table.getn(roles)
    if total == 0 then return end

    local currentId = Roles.GetBotRole(botName, classId)
    local nextIndex = 1
    for i = 1, total do
        if roles[i].id == currentId then
            nextIndex = math.mod(i, total) + 1
            break
        end
    end

    local nextRole = roles[nextIndex]
    if not RetinueConfig then RetinueConfig = {} end
    if not RetinueConfig.botRoles then RetinueConfig.botRoles = {} end
    RetinueConfig.botRoles[botName] = nextRole.id

    UnBot:SendBotCommand("role " .. botName .. " " .. nextRole.id)
    return nextRole
end

function Roles.GetRoleLabel(classId, roleId, fallback)
    local r = Roles.FindRole(classId, roleId)
    return r and r.label or (fallback or tostring(roleId or ""))
end

Roles.ROLE_ORDER = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}

Roles.ROLE_PRESETS = {
    WARRIOR = {
        primary   = { label = "Tank", on = {"protection"}, off = {"arms", "fury"} },
        secondary = { label = "DPS",  on = {"fury"}, off = {"protection"} },
    },
    PALADIN = {
        primary   = { label = "Heal", on = {"holy"}, off = {"protection", "retribution"} },
        secondary = { label = "Tank", on = {"protection"}, off = {"holy", "retribution"} },
    },
    HUNTER = {
        primary   = { label = "Marks", on = {"marksmanship"},
                      off = {"beast mastery", "survival"} },
        secondary = { label = "Beast", on = {"beast mastery"},
                      off = {"marksmanship", "survival"} },
    },
    ROGUE = {
        primary   = { label = "Combat",  on = {"combat"},
                      off = {"subtlety", "assassination"} },
        secondary = { label = "Subtle", on = {"subtlety"},
                      off = {"combat", "assassination"} },
    },
    PRIEST = {
        primary   = { label = "Heal",   on = {"holy"},   off = {"shadow"} },
        secondary = { label = "Shadow", on = {"shadow"}, off = {"holy", "discipline"} },
    },
    SHAMAN = {
        primary   = { label = "Heal", on = {"restoration"},
                      off = {"elemental", "enhancement"} },
        secondary = { label = "DPS",  on = {"enhancement"},
                      off = {"restoration", "elemental"} },
    },
    MAGE = {
        primary   = { label = "Frost", on = {"frost"}, off = {"fire", "arcane"} },
        secondary = { label = "Fire",  on = {"fire"},  off = {"frost", "arcane"} },
    },
    WARLOCK = {
        primary   = { label = "Destro", on = {"destruction"},
                      off = {"affliction", "demonology"} },
        secondary = { label = "Affli",  on = {"affliction"},
                      off = {"destruction", "demonology"} },
    },
    DRUID = {
        primary   = { label = "Heal", on = {"restoration"},
                      off = {"balance", "dps feral", "tank feral"} },
        secondary = { label = "Feral", on = {"dps feral"},
                      off = {"restoration", "balance"} },
    },
}

Retinue.ROLE_ORDER = Roles.ROLE_ORDER
Retinue.ROLE_PRESETS = Roles.ROLE_PRESETS



