-- UnBot Data - command tables recovered from the 3.3.5 addon.
-- These are the heart of the addon: what each command sends and how.

-- Chat text sent for each command id. Empty string = handled by a special
-- handler in Commands.lua, or intentionally disabled upstream.
UnBotExecuteCommand = {
    -- Server commands for ike3 mangosbot. Syntax is
    --   .bot add|remove|list|refresh|random|levelup NAME
    --   .bot init=white|green|blue|epic NAME
    -- with "*" meaning every group member. Commands that need a character name
    -- are completed by handlers in Commands.lua.
    [2] = ".bot init=green",                    -- + target name
    [3] = ".bot init=green *",
    -- 4 (.bot refresh), 5 (.bot random) and 12 (.bot levelup) removed: this
    -- server does not know them. Only add / remove / list / init= work.
    [9] = "reset botAI",
    [10] = "reset botAI",
    -- 11 was the inspect-window integration. The Equip tab of the item window
    -- does the same job without hooking Blizzard's inspect UI.
    [13] = "summon",
    [14] = "summon",
    [15] = "follow",
    [16] = "follow",
    [17] = "trainer learn",
    [18] = "release",
    [19] = "release",
    [20] = "quests",
    [21] = "quests",
    [22] = "stats",
    [23] = "stats",
    [24] = "d add all loot",    -- actions need the "d" (do) prefix
    [25] = "flee",
    [26] = "@tank flee",
    [27] = "@dps flee",
    [28] = "@heal flee",
    [29] = "@melee flee",
    [30] = "@ranged flee",
    [31] = "flee",
    [32] = "attack",
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
    -- 50-53 (druid forms) and 55-61 (paladin auras and blessings) were guessed
    -- before the server told us its real names. The strategy editor and the
    -- spell window cover both properly now, so they no longer clutter the bar.
    [62] = "co",                                -- show combat strategy
    [63] = "co",
    -- Prefixes completed at runtime by handlers in Commands.lua.
    [70] = "combatstop",                        -- party chat, not a GM command
    [64] = "c",
    [65] = "destroy ",
    [66] = "e ",
    [67] = "s ",
    [68] = "u ",
    [69] = "cast ",
    [71] = "UninviteUnit ",
    -- 73 was ".appear <bot>", but that is GM-only on this server. Use summon
    -- (13/14) to bring the bot to you instead.
    [74] = "online",
    [76] = "stay",
    [77] = ".bot list",
    -- 72 (icon browser) and 78/79 (friend-list bots) dropped: the first was a
    -- development aid, the second does not exist in mangosbot.
    [81] = "drink",
    [82] = ".bot remove *",
    [83] = ".bot add *",
    -- 84 was "naxx", a single raid strategy. All of them live in the strategy
    -- editor under "instance" instead, so one button for Naxxramas alone made
    -- little sense.
    [85] = "reset",
    [86] = ".bot remove",                       -- + target name
    [87] = ".bot add",                          -- + target name
    [89] = "grind",

    -- Ids 90+ come from the bot's own action list. Per the mangosbot docs
    -- ("d add all loot", "d attack my target") actions are triggered with a
    -- leading "d", which is why a bare "add all loot" did nothing.
    [90] = "d buff",              -- buff the group right now
    [91] = "d attack my target",  -- attack what YOU have targeted
    [92] = "d pull my target",
    [93] = "d equip upgrades",    -- wear anything better from its bags
    [94] = "d repair",
    [95] = "d sell",              -- vendor greys
    [96] = "talents",             -- plain command, not an action
    [97] = "trainer",
    [98] = "d revive targets",
    [99] = "d food",
    [100] = "d stop follow",
    [101] = "d give leader",
    [102] = "",                 -- role bar, handled in Commands.lua
    -- "use" only covers items; world objects (chests, levers, herbs, mining
    -- nodes) need the game-object form.
    [103] = "d use go",
}

-- How the command is delivered:
--   1 = SAY, no target needed
--   2 = WHISPER to a friendly target (must be in party/raid)
--   3 = PARTY, requires a hostile target
--   4 = PARTY, applies to the whole group
UnBotCommandType = {
    [0] = 0,
    [1] = 1, [2] = 2, [3] = 1, [4] = 1, [5] = 2, [6] = 2, [7] = 2, [8] = 2,
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
    [79] = 1, [80] = 1, [81] = 4, [82] = 1, [83] = 1, [84] = 4, [85] = 4,
    [86] = 2, [87] = 2, [88] = 4, [89] = 4,
    -- new action-list commands: party-wide unless they act on one bot
    [90] = 4, [91] = 4, [92] = 4, [93] = 4, [94] = 4, [95] = 4,
    [96] = 2, [97] = 4, [98] = 4, [99] = 4, [100] = 4, [101] = 2,
    [102] = 1, [103] = 4,
}

-- Which of the 10 command-bar groups a command belongs to.
-- Role shortcuts intentionally stay on their own fixed Role button.
--
--   1 Combat                 6 Training & Abilities
--   2 Movement               7 Party Management
--   3 Support                8 Strategy & AI
--   4 Inventory              9 Formation
--   5 Info & Status           10 Roster & Social
UnBotCommandToGroups = {
    [0] = 0,
    -- combat: attack, retreat and stop
    [25] = 1, [26] = 1, [27] = 1, [28] = 1, [29] = 1, [30] = 1, [31] = 1,
    [32] = 1, [33] = 1, [34] = 1, [35] = 1, [36] = 1, [37] = 1,
    [70] = 1, [91] = 1, [92] = 1,
    -- movement
    [15] = 2, [16] = 2, [47] = 2, [76] = 2, [100] = 2,
    -- support and upkeep
    [18] = 3, [19] = 3, [24] = 3, [55] = 3, [56] = 3, [57] = 3,
    [58] = 3, [59] = 3, [60] = 3, [61] = 3, [80] = 3, [81] = 3,
    [89] = 3, [90] = 3, [98] = 3, [99] = 3, [103] = 3,
    -- inventory and item maintenance
    [11] = 4, [64] = 4, [65] = 4, [66] = 4, [67] = 4, [68] = 4,
    [93] = 4, [94] = 4, [95] = 4,
    -- information and status
    [20] = 5, [21] = 5, [22] = 5, [23] = 5, [62] = 5, [63] = 5,
    [72] = 5,
    -- training and abilities
    [5] = 6, [6] = 6, [7] = 6, [8] = 6, [17] = 6, [69] = 6,
    [96] = 6, [97] = 6,
    -- party management
    [1] = 7, [2] = 7, [3] = 7, [4] = 7, [12] = 7, [13] = 7, [14] = 7,
    [71] = 7, [73] = 7, [82] = 7, [83] = 7, [86] = 7, [87] = 7,
    [101] = 7,
    -- strategy, AI and target behaviour
    [9] = 8, [10] = 8, [48] = 8, [49] = 8, [50] = 8, [51] = 8,
    [52] = 8, [53] = 8, [54] = 8, [75] = 8, [84] = 8, [85] = 8,
    -- formation
    [38] = 9, [39] = 9, [40] = 9, [41] = 9, [42] = 9, [43] = 9,
    [44] = 9, [45] = 9, [46] = 9,
    -- account roster and social/group checks
    [74] = 10, [77] = 10, [78] = 10, [79] = 10, [88] = 10,
    -- 102 is handled by the separate Role button, not a group window.
    [102] = 0,
}

-- Display order inside each group.  Any future command not listed here is
-- appended using its command ID, so adding an action cannot hide it.
UnBotCommandOrder = {
    [1] = { 32, 91, 33, 34, 35, 36, 37, 92, 70, 26, 27, 28, 29, 30, 25, 31 },
    [2] = { 15, 16, 47, 76, 100 },
    [3] = { 80, 99, 90, 24, 89, 103, 98, 18, 19, 81 },
    [4] = { 64, 93, 66, 68, 94, 67, 95, 65 },
    [5] = { 22, 23, 62, 63, 20, 21 },
    [6] = { 96, 69, 97, 17 },
    [7] = { 87, 86, 83, 82, 3, 2, 13, 14, 101, 71 },
    [8] = { 54, 85, 9, 10 },
    [9] = { 46, 38, 42, 43, 40, 41, 39, 45, 44 },
    [10] = { 74, 77, 88 },
}

-- Icon per command.
-- The 3.3.5 addon leaned heavily on Achievement_* textures, which only shipped
-- with WotLK and render as an empty button on 1.12. Entries marked "orig" are
-- the untouched original icon; the rest are Vanilla-safe stand-ins.
local I = "Interface\\Icons\\"
UnBotCommandIcon = {
    [0]  = I.."Temp",                          -- orig (the WoW logo icon)

    -- group 1: bot roster, init, summoning
    [1]  = I.."INV_Misc_Horn_02",
    [2]  = I.."INV_Axe_01",                    -- orig
    [3]  = I.."INV_Axe_02",                    -- orig
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
    [1] = 91,   -- attack YOUR target
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

