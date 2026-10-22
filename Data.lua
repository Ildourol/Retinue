-- UnBot Data - command tables recovered from the 3.3.5 addon.
-- These are the heart of the addon: what each command sends and how.

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
    [81] = ".bot action rest",                  -- drink & food rest order
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
    [99] = ".bot action rest",                  -- sit and consume food/drink
    [100] = ".bot action stay",                 -- halt and hold spot
    [101] = "d give leader",
    [102] = "",                                 -- role bar, handled in Commands.lua
    [103] = "loot",                             -- loot nearby corpse or object

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

-- Raid Target Icon mapping (1..8) for commands that represent specific raid marks:
-- 1 = Star, 2 = Circle, 3 = Diamond, 4 = Triangle
-- 5 = Moon, 6 = Square, 7 = Cross, 8 = Skull
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

