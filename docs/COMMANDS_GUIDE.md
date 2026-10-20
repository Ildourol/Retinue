# Warband Companion Addon: Complete Tactical Command Guide & Reference

> **Addon Name**: `Warband` (`mod-twow-playerbots-addon`)  
> **Target Environment**: Turtle WoW (Client 1.12.1 / Engine 1.18.1.7272)  
> **Companion Engine**: `TortoiseBots` (PlayerBot Subsystem)  
> **Encoding**: UTF-8 without BOM  
> **Total Commands Documented**: 182 tactical, movement, inventory, strategy, and management actions.

---

## 1. Overview & Architecture

The **Warband** companion addon provides a comprehensive command center for controlling `TortoiseBots` on Turtle WoW. It enables solo players to command a fully functional group of player bots across dungeons, raids, battlegrounds, and open-world questing.

### 1.1 Communication Scopes & Dispatch Pipeline
Warband delivers instructions through four distinct communication channels:
1. **Server Command (`Scope 1 / SAY`)**: Dispatched as an authoritative engine dot-command (`.bot <verb>`). Processed with zero network latency directly by the world server.
2. **Whisper Scope (`Scope 2 / WHISPER`)**: Whispered directly to your currently targeted bot companion (`/w <BotName> <verb>`).
3. **Party Target Scope (`Scope 3 / PARTY Target`)**: Dispatched through group chat (`/p <verb>`), requiring a hostile target selected by the player.
4. **Whole Party Scope (`Scope 4 / PARTY Group`)**: Broadcast to all companion bots in your current party or raid (`/p <verb>`).

### 1.2 Strategy Modifiers (`+`, `-`, `~`)
In the TortoiseBots engine, combat (`co`), non-combat (`nc`), and loot (`ll`) strategy toggles operate using three native prefix symbols:
- **`+` (Enable / Add)**: Activates the strategy (e.g. `co +focus` enables single-target burn; `co +aoe fear` enables AoE fears).
- **`-` (Disable / Remove)**: Deactivates the strategy (e.g. `co -focus` allows AoE; `co -aoe fear` suppresses fears).
- **`~` (Single-Click Toggle)**: **The native TortoiseBots toggle operator** (Engine `case '~': toggleStrategy()`). If the strategy is currently active, it is disabled; if inactive, it is enabled. Used on buttons like **Command 174** (`co ~focus`), **Command 175** (`co ~aoe fear`), **Command 114** (`co ~mark rti`), and **Command 115** (`co ~kite`).

### 1.3 Protocol Suppression (Chat Cleanliness)
All inbound status reports and machine-readable protocol messages prefixed with `^TBM:` are intercepted and suppressed from the main chat frame by Warband's custom chat filter. This guarantees that your combat log and general chat remain uncluttered while the GUI processes real-time bot status telemetry.

### 1.4 The Persistent Favorites System
- The main Warband bar includes **10 persistent quick-action favorite slots** along the top row.
- **Add Favorite**: Open any category dropdown window, locate the desired command, and **Right-Click** its button. A yellow asterisk `*` indicates a favorited command.
- **Remove Favorite**: Right-Click the button on the favorites bar to confirm removal, or click the **Clear (`X`)** button to wipe all favorites.
- **Expanded Modal (`>`)**: If you configure more than 10 favorites, the `>` button opens an expanded grid view allowing mouse-wheel scrolling through your full favorites collection.

---

## 2. Command Categories & Action Details

### Group 1: Combat
*Direct engagement, pulling, crowd control, priority targeting, and disengage orders.*

#### Section: Attack & Pull
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **32** | Attack target | Party Target (`/party`) | `.bot action attack` | Commands party bots to attack the player's current hostile target (evade-safe, 150yd range). |
| **91** | Attack target | Whole Party (`/party`) | `.bot action attack` | Orders all party bots to switch targets and attack the player's current target. |
| **156** | Interrupt cast | Party Target (`/party`) | `.bot action interrupt` | Orders party bots to prioritize and immediately cast interrupts (Kick, Pummel, Counterspell, Earth Shock). |
| **92** | Tactical pull | Whole Party (`/party`) | `.bot action pull 10 ranged` | Initiates a ranged tank pull (10yd pull): tank engages while party holds position. |
| **157** | Tactical pullback | Party Target (`/party`) | `.bot action pullback 5 ranged` | Orders the tank to pull from range and drag the mob back to player anchor coordinates while party holds. |
| **158** | End pull | Whole Party (`/party`) | `end pull` | Immediately aborts an active tank pull without waiting for timeout. |
| **159** | Focus Skull | Whole Party (`/party`) | `.bot action focus skull` | Sets Skull mark on target and commands all DPS bots to focus burn. |
| **112** | Attack RTI | Whole Party (`/party`) | `attack rti` | Commands party bots to attack the target marked with the active RTI combat icon. |
| **113** | Pull RTI | Whole Party (`/party`) | `pull rti` | Orders tank to pull the mob marked with the active RTI combat icon. |
| **33** | Tank attack | Party Target (`/party`) | `@tank attack` | Orders only tank bots to charge and engage the target, establishing initial threat. |
| **35** | Healer attack | Party Target (`/party`) | `@heal attack` | Orders healer bots to enter combat and contribute offensive damage when healing is not required. |
| **34** | DPS attack | Party Target (`/party`) | `@dps attack` | Orders only DPS bots to engage the target. |
| **36** | Melee attack | Party Target (`/party`) | `@melee attack` | Orders all melee bots to engage the target in close-quarters combat. |
| **37** | Ranged attack | Party Target (`/party`) | `@ranged attack` | Orders all ranged bots to begin ranged combat on the target. |

#### Section: Crowd Control & Tactics
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **160** | Toggle AoE | Whole Party (`/party`) | `.bot action aoe` | Toggles all party AoE spells on/off (critical for crowd control preservation in instances). |
| **161** | Auto CC | Whole Party (`/party`) | `.bot action auto cc` | Toggles smart auto-CC: bots automatically crowd control loose adds threatening healers. |
| **162** | Pre-pull Sap | Whole Party (`/party`) | `.bot action sap` | Toggles rogue pre-pull Sap behavior on marked targets before combat begins. |
| **174** | Single burn (focus) | Whole Party (`/party`) | `co ~focus` | Toggles single-target focus burn via native `co ~focus`: suppresses AoE and splash abilities to protect CC targets. |
| **175** | Toggle AoE fear | Whole Party (`/party`) | `co ~aoe fear` | Toggles AoE fear spells (Psychic Scream, Howl of Terror, Intimidating Shout) via native `co ~aoe fear` (off by default in instances). |
| **115** | Toggle Kite | Whole Party (`/party`) | `co ~kite` | Toggles autonomous kiting behavior for ranged bots when attacked in melee via `co ~kite`. |
| **114** | Auto mark RTI | Whole Party (`/party`) | `co ~mark rti` | Toggles automated RTI raid target marking during combat via `co ~mark rti`. |
| **116** | Target: Skull | Whole Party (`/party`) | `rti skull` | Sets primary focus fire raid icon to Skull. |
| **117** | Target: Cross | Whole Party (`/party`) | `rti cross` | Sets primary focus fire raid icon to Cross. |
| **118** | Target: Square | Whole Party (`/party`) | `rti square` | Sets primary focus fire raid icon to Square. |
| **119** | Target: Moon | Whole Party (`/party`) | `rti moon` | Sets primary focus fire raid icon to Moon. |
| **120** | Target: Triangle | Whole Party (`/party`) | `rti triangle` | Sets primary focus fire raid icon to Triangle. |
| **121** | Target: Diamond | Whole Party (`/party`) | `rti diamond` | Sets primary focus fire raid icon to Diamond. |
| **122** | Target: Circle | Whole Party (`/party`) | `rti circle` | Sets primary focus fire raid icon to Circle. |
| **123** | Target: Star | Whole Party (`/party`) | `rti star` | Sets primary focus fire raid icon to Star. |
| **124** | Target: Clear | Whole Party (`/party`) | `rti none` | Clears primary focus fire raid icon assignment. |
| **125** | CC: Skull | Whole Party (`/party`) | `rti cc skull` | Sets crowd control raid target icon to Skull. |
| **126** | CC: Moon | Whole Party (`/party`) | `rti cc moon` | Sets crowd control raid target icon to Moon. |
| **127** | CC: Clear | Whole Party (`/party`) | `rti cc none` | Clears crowd control raid target icon assignment. |

#### Section: Stop & Flee
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **70** | Stop combat | Whole Party (`/party`) | `.bot action stop` | Commands bots to halt all spellcasts, drop hostility targets, and clear aggro queues. |
| **25** | Flee party | Whole Party (`/party`) | `.bot action flee` | Orders all party bots to immediately break combat, cease spellcasts, and flee towards player. |
| **31** | Flee selected | Selected Bot (`/whisper`) | `flee` | Orders the selected bot to disengage and flee. |
| **26** | Tank flee | Whole Party (`/party`) | `@tank flee` | Orders all tank bots in the group to disengage and flee. |
| **28** | Healer flee | Whole Party (`/party`) | `@heal flee` | Orders all healer bots in the group to disengage and flee. |
| **27** | DPS flee | Whole Party (`/party`) | `@dps flee` | Orders all DPS bots in the group to disengage and flee. |
| **29** | Melee flee | Whole Party (`/party`) | `@melee flee` | Orders all melee bots in the group to disengage and flee. |
| **30** | Ranged flee | Whole Party (`/party`) | `@ranged flee` | Orders all ranged bots in the group to disengage and flee. |

### Group 2: Movement & Stances
*Formations, following, anchoring, guard spots, and close-quarters combat stances.*

#### Section: Following & Anchor
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **15** | Follow party | Whole Party (`/party`) | `.bot action follow` | Commands all party bots to enter modern tactical follow formation behind the player. |
| **16** | Follow selected | Selected Bot (`/whisper`) | `follow` | Commands the selected bot to follow the player closely. |
| **163** | Come to me | Whole Party (`/party`) | `.bot action come` | Commands all party bots to drop current movement targets and immediately sprint to player coordinates. |
| **100** | Stop & hold | Whole Party (`/party`) | `.bot action stay` | Orders bots to immediately stop following and hold position. |

#### Section: Position & Guard
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **47** | Hold party | Whole Party (`/party`) | `stay` | Orders all party bots to halt and hold their exact current ground coordinates. |
| **76** | Hold selected | Selected Bot (`/whisper`) | `stay` | Orders the selected bot to hold its current position. |
| **142** | Set guard spot | Whole Party (`/party`) | `position guard set` | Records current player coordinates as the bots' permanent guard post. |
| **143** | Move to guard | Whole Party (`/party`) | `guard` | Orders bots to travel to their assigned guard post and defend it. |
| **144** | Free movement | Whole Party (`/party`) | `free` | Releases bots from guard posts and allows autonomous nearby wandering. |
| **173** | Wander mode | Whole Party (`/party`) | `wander` | Toggles free autonomous roaming and exploration when out of combat. |

#### Section: Combat Stances
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **106** | Stance: near | Whole Party (`/party`) | `stance near` | Sets combat stance to Near (bots stay close to target during combat). |
| **107** | Stance: tank | Whole Party (`/party`) | `stance tank` | Sets combat stance to Tank (tank faces boss away from raid group). |
| **108** | Stance: turnback | Whole Party (`/party`) | `stance turnback` | Sets combat stance to Turnback (positions target facing away from casters). |
| **109** | Stance: behind | Whole Party (`/party`) | `stance behind` | Sets combat stance to Behind (melee bots position behind target to bypass parry/block). |
| **110** | Combat spacing | Whole Party (`/party`) | `.bot behavior party spread on` | Enables party combat spacing (bots maintain 10-yard spread to avoid AoE splash). |
| **111** | Ping stance | Whole Party (`/party`) | `stance show` | Pings current combat stance positions on the ground. |

### Group 3: Support & Upkeep
*Buffing, consumable consumption, autonomous RPG exploration, resurrecting, and soulstones.*

#### Section: Preparation & Buffs
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **80** | Ready check | Server (`/say`) | `.bot action ready` | Initiates a server-side Ready Check across all party and raid bots. |
| **90** | Buff party | Whole Party (`/party`) | `d buff` | Commands all party bots to refresh class buffs on the group immediately. |
| **165** | Rebuff party | Whole Party (`/party`) | `rebuff` | Orders bots to top off expiring party buffs out of combat (2-minute refresh pass). |
| **99** | Eat (rest) | Whole Party (`/party`) | `.bot action rest` | Orders bots to sit down and eat food to restore health. |
| **81** | Drink (rest) | Whole Party (`/party`) | `.bot action rest` | Orders all mana-using bots to sit down and drink water to restore mana. |
| **166** | Mimic consumables | Whole Party (`/party`) | `.bot behavior party mimic on` | Enables consumable mimicry: bots drink matching potions/elixirs when the player drinks one. |
| **178** | Potions engine | Whole Party (`/party`) | `.bot behavior party potions on` | Enables automated combat potion and healthstone consumption when health drops critical. |
| **167** | Drop totems | Whole Party (`/party`) | `.bot totem party drop` | Orders party Shamans to drop their configured totem set immediately. |

#### Section: Activities
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **24** | Loot party | Whole Party (`/party`) | `d add all loot` | Orders all party bots to inspect and loot eligible corpses in the vicinity. |
| **89** | Grind party | Whole Party (`/party`) | `grind` | Toggles autonomous area grinding mode: bots engage nearby hostile mobs independently. |

#### Section: Autonomous RPG
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **145** | Toggle RPG mode | Whole Party (`/party`) | `nc ~rpg` | Toggles autonomous RPG behaviors when idle out of combat via `nc ~rpg`. |
| **146** | RPG: Quests | Whole Party (`/party`) | `nc ~rpg quest` | Autonomous RPG: Bots autonomously pick up and hand in quests to nearby NPCs via `nc ~rpg quest`. |
| **147** | RPG: Vendors & AH | Whole Party (`/party`) | `nc ~rpg vendor` | Autonomous RPG: Bots autonomously vendor trash, buy reagents, and check mailbox via `nc ~rpg vendor`. |
| **148** | RPG: Explore & Fly | Whole Party (`/party`) | `nc ~rpg explore` | Autonomous RPG: Bots discover flight masters, take flights, and explore via `nc ~rpg explore`. |
| **149** | RPG: Train & Gear | Whole Party (`/party`) | `nc ~rpg maintenance` | Autonomous RPG: Bots visit trainers to learn spells and repair equipment via `nc ~rpg maintenance`. |
| **150** | RPG: Crafting | Whole Party (`/party`) | `nc ~rpg craft` | Autonomous RPG: Bots autonomously craft items using trade skills via `nc ~rpg craft`. |

#### Section: Death & Res
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **98** | Resurrect | Whole Party (`/party`) | `d revive targets` | Commands healer bots to cast resurrection spells on dead group members. |
| **164** | Corpse run | Whole Party (`/party`) | `.bot action corpse run` | Commands all dead spirit bots to immediately run back to their corpses or instance entrance. |
| **18** | Release party | Whole Party (`/party`) | `release` | Forces all dead party bots to release spirit and appear at the nearest graveyard. |
| **19** | Release selected | Selected Bot (`/whisper`) | `release` | Forces the selected dead bot to release spirit. |

### Group 4: Inventory & Trade
*Bag inspection, direct gear upgrades, vendor trash selling, equipment repair, and automated loot filters.*

#### Section: Bags & Trade
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **64** | Inventory | Selected Bot (`/whisper`) | `c` | Opens the remote Inventory and Bag viewer for the targeted bot. |
| **168** | Trade with bot | Selected Bot (`/whisper`) | `.bot action trade` | Opens a direct trade window with the targeted companion bot. |
| **93** | Equip upgrades | Whole Party (`/party`) | `d equip upgrades` | Commands all bots to scan their bags and automatically equip any item upgrades. |
| **66** | Equip item | Selected Bot (`/whisper`) | `e ` | Opens the remote Equip Item window to inspect and equip gear. |
| **94** | Repair gear | Whole Party (`/party`) | `.bot action repair` | Orders bots to approach the nearest vendor and repair all damaged equipment. |

#### Section: Item actions
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **68** | Use item | Selected Bot (`/whisper`) | `u ` | Opens the remote Use Item window to command bots to consume or activate items. |
| **67** | Sell item | Selected Bot (`/whisper`) | `s ` | Opens the remote Sell Item window to select vendor sales. |
| **95** | Sell junk | Whole Party (`/party`) | `.bot action sell` | Orders bots to approach the nearest vendor and sell all grey junk items. |
| **65** | Destroy item | Selected Bot (`/whisper`) | `destroy ` | Opens the remote Destroy Item window to discard junk from bot bags. |

#### Section: Loot Filters
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **128** | Loot: Equip | Whole Party (`/party`) | `ll ~equip` | Toggles whether bots loot equipment upgrades from fallen foes via `ll ~equip`. |
| **129** | Loot: Quests | Whole Party (`/party`) | `ll ~quest` | Toggles whether bots loot quest objective items via `ll ~quest`. |
| **130** | Loot: Trade skills | Whole Party (`/party`) | `ll ~skill` | Toggles whether bots loot trade skill crafting materials via `ll ~skill`. |
| **131** | Loot: Disenchant | Whole Party (`/party`) | `ll ~disenchant` | Toggles whether bots loot uncommon/rare items to disenchant via `ll ~disenchant`. |
| **132** | Loot: Consumables | Whole Party (`/party`) | `ll ~use` | Toggles whether bots loot consumables, potions, food, and bandages via `ll ~use`. |
| **133** | Loot: Vendor gold | Whole Party (`/party`) | `ll ~vendor` | Toggles whether bots loot vendor trash items to sell for gold via `ll ~vendor`. |
| **134** | Loot: Grey trash | Whole Party (`/party`) | `ll ~trash` | Toggles whether bots loot poor grey junk items via `ll ~trash`. |
| **135** | Loot: Show rules | Whole Party (`/party`) | `ll ?` | Displays the party's currently active loot filter configuration via `ll ?`. |

### Group 5: Info & Status
*Diagnostic status reporting, active combat strategies review, and quest log inspection.*

#### Section: Status
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **22** | Party status | Whole Party (`/party`) | `stats` | Prints live health, mana, role, and current state metrics for all party bots. |
| **23** | Selected status | Selected Bot (`/whisper`) | `stats` | Prints live health, mana, role, and current state metrics for the selected bot. |

#### Section: Combat strategies
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **62** | Party combat strategies | Whole Party (`/party`) | `co ?` | Prints the full active combat strategy chain for all party bots to chat. |
| **63** | Selected combat strategies | Selected Bot (`/whisper`) | `co ?` | Prints the active combat strategy chain for the selected bot. |

#### Section: Quests
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **20** | Party quests | Whole Party (`/party`) | `quests` | Queries and displays quest progression and objectives for all party bots. |
| **21** | Selected quests | Selected Bot (`/whisper`) | `quests` | Queries and displays quest progression and objectives for the selected bot. |

### Group 6: Abilities & Spells
*Bot talent allocation, spellbook review, NPC trainer interactions, and skill learning.*

#### Section: View
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **96** | Talents | Selected Bot (`/whisper`) | `talents` | Prints the targeted bot's current talent specialization tree distribution. |
| **69** | Spells | Selected Bot (`/whisper`) | `cast ` | Opens the Spellbook & Blacklist window to inspect learned spells and disable unwanted abilities. |

#### Section: Training
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **97** | Trainer | Whole Party (`/party`) | `trainer` | Commands the bot to interact with a nearby class or profession trainer. |
| **17** | Learn skills | Whole Party (`/party`) | `.bot action learn` | Orders party bots to interact with nearby class trainers and purchase all available spells. |

### Group 7: Party Management
*Targeted bot adding/removing, whole party login/logout, autogear, summoning, and party leadership transfer.*

#### Section: Selected bot
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **87** | Add selected | Selected Bot (`/whisper`) | `.bot add` | Logs in and adds the selected bot to your party. |
| **86** | Remove selected | Selected Bot (`/whisper`) | `.bot remove` | Logs out the selected bot. |
| **2** | Autogear target | Selected Bot (`/whisper`) | `.bot autogear` | Calculates bot gear slots against inventory bags and automatically equips green-or-better upgrades. |
| **169** | Maintenance | Selected Bot (`/whisper`) | `.bot maintenance` | Restocks reagents, consumables, and ammunition for the selected bot without visiting vendors. |

#### Section: Party Roster
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **83** | Log in party | Whole Party (`/party`) | *Interactive UI / Handler* | Logs in all controlled bots saved to your party. |
| **82** | Log out party | Whole Party (`/party`) | *Interactive UI / Handler* | Gracefully logs out all controlled bots currently in your party. |
| **3** | Autogear party | Whole Party (`/party`) | *Interactive UI / Handler* | Iterates through all party bots and automatically equips best-in-slot items from their bags. |

#### Section: Summoning & Leadership
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **13** | Summon party | Whole Party (`/party`) | `summon` | Summons all controlled party bots directly to the player's current world coordinates. |
| **14** | Summon selected | Selected Bot (`/whisper`) | `summon` | Summons the selected bot directly to the player's current world coordinates. |
| **101** | Give leader | Selected Bot (`/whisper`) | `d give leader` | Transfers party leader permissions to the selected bot. |
| **71** | Disband party | Whole Party (`/party`) | `UninviteUnit ` | Uninvites all bots and dissolves the current party or raid. |

### Group 8: Strategy & Tactics
*Full strategy toggle editor, state reset, raid positioning rules, AoE fear controls, and save-mana levels.*

#### Section: Editor & Reset
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **54** | Strategy | Selected Bot (`/whisper`) | `strategy` | Opens the interactive Strategy Editor window displaying all available combat toggles for the bot. |
| **85** | Reset current state | Whole Party (`/party`) | `reset` | Clears combat lockouts and resets the AI state machine for the current target. |
| **9** | Reset party strats | Whole Party (`/party`) | `.bot strategy reset` | Resets all active strategy toggles to default archetype baselines for all party bots. |
| **10** | Reset selected strats | Selected Bot (`/whisper`) | `.bot strategy reset` | Resets all active strategy toggles to default archetype baselines for the targeted bot. |
| **182** | Soft state reset | Selected Bot (`/whisper`) | `reset` | Performs a soft reset on the bot AI behavior tree without dropping combat or logging out. |

#### Section: Combat Behaviors
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **176** | Threat back-off | Whole Party (`/party`) | `.bot behavior party threat on` | Directs non-tank bots to ease off attacks when approaching the tank's threat ceiling. |
| **177** | Offensive boost | Whole Party (`/party`) | `.bot behavior party boost on` | Allows bots to activate major offensive cooldowns, racials, and trinkets during boss fights. |

#### Section: Raid Tactics
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **170** | Dragon tankface | Whole Party (`/party`) | `.bot action raid tankface` | Raid tactic: Tank bots turn dragon bosses away from the raid to prevent cleave/breath damage. |
| **171** | Douse MC runes | Whole Party (`/party`) | `.bot action raid douse` | Raid tactic: Bots douse nearby Molten Core runes using Quintessence. |
| **172** | Turtle raid tactics | Whole Party (`/party`) | `.bot action raid custom on` | Enables custom Turtle WoW raid encounter tactics (Emerald Sanctum, Karazhan Crypt, etc.). |

#### Section: Save Mana Level
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **136** | Mana: Burst (Off) | Whole Party (`/party`) | `save mana 1` | Disables mana conservation: bots cast highest rank spells at full burst. |
| **137** | Mana: Level 2 (Low) | Whole Party (`/party`) | `save mana 2` | Sets mana conservation to Level 2: light conservation in sustained battles. |
| **138** | Mana: Level 3 (Med) | Whole Party (`/party`) | `save mana 3` | Sets mana conservation to Level 3: balanced DPS and mana efficiency. |
| **139** | Mana: Level 4 (High) | Whole Party (`/party`) | `save mana 4` | Sets mana conservation to Level 4: aggressive spell downranking to preserve mana. |
| **140** | Mana: Level 5 (Max) | Whole Party (`/party`) | `save mana 5` | Sets mana conservation to Level 5: maximum conservation (vital utility and wanding only). |
| **141** | Mana: Show level | Whole Party (`/party`) | `save mana ?` | Displays current mana conservation level for party bots via `save mana ?`. |

### Group 9: Formations
*Tactical battlefield formations (shield wall, circle, queue, line, arrow, chaos).*

#### Section: Current formation
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **46** | View formation | Whole Party (`/party`) | `formation` | Displays the party's current active movement formation name. |
| **105** | Ping formation | Whole Party (`/party`) | `formation show` | Pings current formation positions on the minimap/ground. |

#### Section: Set formation
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **38** | Formation: arrow | Whole Party (`/party`) | `formation arrow` | Sets bot formation to Arrow (V-shape with tank at vanguard). |
| **42** | Formation: line | Whole Party (`/party`) | `formation line` | Sets bot formation to Line (wide horizontal battle line). |
| **43** | Formation: circle | Whole Party (`/party`) | `formation circle` | Sets bot formation to Circle (defensive perimeter surrounding player). |
| **40** | Formation: near | Whole Party (`/party`) | `formation near` | Sets bot formation to Near (dense clustering within 3 yards). |
| **41** | Formation: melee | Whole Party (`/party`) | `formation melee` | Sets bot formation to Melee (melee in front, casters staggered back). |
| **39** | Formation: queue | Whole Party (`/party`) | `formation queue` | Sets bot formation to Queue (single file line behind player). |
| **45** | Formation: shield | Whole Party (`/party`) | `formation shield` | Sets bot formation to Shield (tight phalanx defensive wall). |
| **44** | Formation: chaos | Whole Party (`/party`) | `formation chaos` | Sets bot formation to Chaos (loose organic dispersed positions). |
| **104** | Formation: far | Whole Party (`/party`) | `formation far` | Sets bot formation to Far (spread-out 15-20 yard loose spacing). |

### Group 10: Player Roster
*Account-wide character roster, real-time search, one-click login/invite, group fill/logout.*

The **Player Roster** is an interactive full-screen management interface rather than a static command list. Clicking Group 10 opens the Roster GUI:
- **Live Character Search & Add**: Type any substring into the search bar (`UnBotRosterSearch`) for real-time filtering. If the typed character is not in the roster, press **Enter** or click **`+ Add "<Name>"`** in Row 1 to instantly register them!
- **`+ Target` Button**: Click the dedicated `+ Target` button directly beneath the Druid class tab to immediately add your currently targeted friendly character or bot to the roster.
- **Party & Raid Auto-Discovery**: Opening the roster, clicking Sync, or changing groups automatically scans `party1..4` and `raid1..40`, auto-populating active companions without manual input.
- **Dual Server Sync**: Clicking `Sync` queries both `.bot roster` (account alts via TBM protocol) and `.bot list` (active world bot instances).
- **Class Filtering**: 10 class tabs filter characters by class (`ALL`, `Warrior`, `Paladin`, `Hunter`, `Rogue`, `Priest`, `Shaman`, `Mage`, `Warlock`, `Druid`).
- **Instant Group Invites**: Left-click any online character to instantly invite them via native `.bot invite <name>` (bypasses prompt delays).
- **Offline Logins**: Left-click any offline character to log them in via `.bot add <name>` and queue their group invite.
- **Bulk Group Fill**: One-click party (`Fill group` to 5) or raid (`Fill raid` to 40) auto-population from filtered roster candidates.
- **Status Badges**: Real-time color-coded badges indicate `in group` (cyan), `online` (green), and `offline` (grey).
- **Clean Dismiss**: Right-click any grouped bot to remove them cleanly via `.bot uninvite <name>`.

### Group 11: Utilities & World
*Mailbox collection, quest sharing, hearthstone binding, flight master travel, and world object interaction.*

#### Section: Mail & Quests
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **151** | Check mailbox | Whole Party (`/party`) | `mail ?` | Commands bots to check nearby mailboxes and report attached items via `mail ?`. |
| **154** | Accept all quests | Whole Party (`/party`) | `accept *` | Accepts all shared party quests from all group members. |
| **155** | Quest rewards | Whole Party (`/party`) | `r ?` | Queries available quest reward choices for the selected bot via `r ?`. |
| **179** | Share quests | Whole Party (`/party`) | `share` | Shares all eligible quests from the bot's log with group members. |

#### Section: Travel & Life
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **180** | Bind hearthstone | Selected Bot (`/whisper`) | `home` | Interacts with the nearest innkeeper to bind the bot's hearthstone. |
| **181** | Taxi flight | Selected Bot (`/whisper`) | `taxi` | Purchases a flight path from the nearest flight master. |

#### Section: NPC & Spells
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **152** | Blacklisted spells | Whole Party (`/party`) | `ss ?` | Displays list of blacklisted spells that bots are forbidden to cast via `ss ?`. |
| **153** | Talk to NPC | Whole Party (`/party`) | `talk` | Commands bots to interact or gossip with your selected NPC. |

#### Section: System & Objects
| ID | Label | Scope | Native Command / Chat | Tactical Action & Server Behavior |
|:---|:---|:---|:---|:---|
| **103** | Loot world object | Whole Party (`/party`) | `loot` | Commands bot to interact with the nearest usable world object (chests, levers, nodes). |
| **72** | Bot status | Server (`/say`) | *Interactive UI / Handler* | Prints live health, mana, role, and current state metrics for all party bots. |
| **88** | Add friends | Whole Party (`/party`) | *Interactive UI / Handler* | Iterates over all current group members and adds them to your character friends list. |

---

## 3. Dedicated Interactive Windows

### 3.1 Player Roster Window (Command ID 74 / Group 10)
- **Access**: Click Group 10 icon on command bar, or type `/warband roster` or `/wb roster`.
- **Controls**:
  - **Search & Add Input**: Live character filtering as you type into `UnBotRosterSearch`. If the character is not in the roster, press **Enter** or click the green **`+ Add "<Name>"`** prompt in Row 1 to add them immediately.
  - **`+ Target` Button**: Dedicated button on the left panel (under Druid) that immediately registers your currently selected friendly player or bot into the saved roster.
  - **Auto-Discovery**: Automatically scans your active party or raid members (`party1..4`, `raid1..40`) on window open, group changes, and target changes.
  - **Class Filter**: 10 buttons along the left margin filter by class.
  - **Left-Click Row**: If bot is online and not grouped, issues `.bot invite <name>`. If bot is offline, logs bot in via `.bot add <name>` and queues invite. If already grouped, targets the bot.
  - **Right-Click Row**: If bot is in group, issues `.bot uninvite <name>` (removes from party). If bot is online outside group, issues `.bot remove <name>` (logs out).
  - **Shift + Left-Click**: Logs bot in without party invite (solo world presence).
  - **Shift + Right-Click**: Removes character entry from local saved roster cache.
  - **Fill Group**: Automatically fills free slots in a 5-player party from filtered roster candidates.
  - **Fill Raid**: Automatically converts group to raid if needed and fills up to 40 slots.
  - **Remove Selected**: Uninvites all checked bots from your party via `.bot uninvite`.
  - **Log Out Selected**: Logs out all checked bots via `.bot remove`.
  - **Sync**: Automatically scans group and dispatches both `.bot roster` (account alts) and `.bot list` (active world bot instances) to synchronize database and world states.

### 3.2 Strategy Editor Window (Command ID 54 / Group 8)
- **Access**: Click `Editor` in Group 8, or type `/warband strategy`.
- **Controls**:
  - Displays all AI combat strategy toggles reported by the targeted bot (e.g. `dps`, `tank`, `heal`, `aoe`, `threat`, `shadow`, `frost`, `fire`, `buff`, etc.).
  - **Left-Click Toggle**: Appends toggle with `+` (activates strategy, e.g. `co +aoe`).
  - **Right-Click Toggle**: Appends toggle with `-` (deactivates strategy, e.g. `co -aoe`).
  - **Class Archetype Tabs**: Switch between Warrior, Paladin, Hunter, Rogue, Priest, Shaman, Mage, Warlock, and Druid strategy baselines.

### 3.3 Remote Role Assignment (Command ID 102 / Role Button)
- **Access**: Click the dedicated `Role` button at the far right of the Warband command bar.
- **Controls**:
  - Fast 1-click role presets for all 9 classes:
    - **Warrior**: Protection (Tank) / Arms/Fury (Melee DPS)
    - **Paladin**: Holy (Healer) / Protection (Tank) / Retribution (Melee DPS)
    - **Hunter**: Marksmanship / Beast Mastery (Ranged Physical)
    - **Rogue**: Combat / Assassination (Melee DPS)
    - **Priest**: Holy/Discipline (Healer) / Shadow (Ranged Spell DPS)
    - **Shaman**: Restoration (Healer) / Elemental (Caster DPS) / Enhancement (Melee DPS)
    - **Mage**: Frost (Control/AoE) / Fire (High DPS) / Arcane (Burst)
    - **Warlock**: Affliction (DoTs/Debuffs) / Destruction (Direct Fire)
    - **Druid**: Feral (Tank or Melee) / Restoration (Healer) / Balance (Boomkin)

### 3.4 Spellbook & Ability Blacklist (Command ID 69 / Group 6)
- **Access**: Click `Spells` in Group 6, or type `/warband spells`.
- **Controls**:
  - Inspects all spells known by the targeted bot.
  - **Click Spell**: Adds or removes spell from bot's casting blacklist (`nc -<spell>` or `nc +<spell>`), preventing bots from casting problematic spells in specific encounters.

### 3.5 Remote Inventory & Bag Management (Command IDs 64-68 / Group 4)
- **Access**: Click `Bags` in Group 4, or type `/warband bags`.
- **Controls**:
  - Inspects all 16 backpack slots and 4 bag containers of the targeted bot.
  - Modes: `View` (read-only inventory inspection), `Equip` (force equip item), `Use` (consume potion/food), `Sell` (flag for vendor sale), `Destroy` (delete trash item).

---

## 4. Slash Commands & Macro Reference

| Slash Command | Arguments | Effect & Description |
|:---|:---|:---|
| `/warband` or `/wb` or `/unbot` | *none* | Toggles the visibility of the main Warband command bar. |
| `/wb roster` | *none* | Opens the interactive Player Roster management window. |
| `/wb fill` | *none* | Fills empty party slots (up to 5) from filtered roster candidates. |
| `/wb fillraid` | *none* | Converts to raid if needed and fills up to 40 group slots. |
| `/wb strategy` | *none* | Opens the Strategy Editor window for the currently targeted bot. |
| `/wb spells` | *none* | Opens the Spellbook and Blacklist manager for the targeted bot. |
| `/wb bags` | *none* | Opens the remote Bag and Inventory inspection window. |
| `/wb debug` | *none* | Toggles verbose in-game debug chat logging for all inbound/outbound packets. |
| `/wb capture` | *none* | Toggles packet capture logging for protocol analysis. |
| `/wb capture clear` | *none* | Clears the in-memory packet capture history buffer. |
| `/wb checkapi` | *none* | Audits and prints availability of Vanilla/Turtle client API functions. |
| `/wb ask <topic>` | `<topic>` | Queries bot AI help strings for specific strategy, item, or action verbs. |
| `/ubc <commandId>` | `<id>` | Directly executes any command ID (1-182) from macro or chat. |

### 4.1 Useful Macro Examples

#### Emergency Stop & Sprint to Me
```text
/ubc 70
/ubc 163
```
*Instantly halts all bot attacks, drops hostile targeting queues, and sprints the entire party directly to your coordinates.*

#### Tactical Tank Pull & Hold
```text
/ubc 92
```
*Orders the tank bot to pull your target from range while holding the rest of the party at your position.*

#### Focus Fire Skull
```text
/ubc 159
```
*Sets or selects the Skull raid target and directs all DPS bots to focus fire.*

---

## 5. Master Command Index (Numerical 1–182)

| ID | Category | Action Label | Scope | Native Command / Trigger | Tactical Behavior & Description |
|:---:|:---|:---|:---:|:---|:---|
| **1** | Party Management | Interface\\Icons\\Ability_DualWield | Server (`/say`) | *Interactive UI / Handler* | Initializes all controlled bots currently logged into the world. |
| **2** | Party Management | Autogear target | Selected Bot (`/whisper`) | `.bot autogear` | Calculates bot gear slots against inventory bags and automatically equips green-or-better upgrades. |
| **3** | Party Management | Autogear party | Whole Party (`/party`) | *Interactive UI / Handler* | Iterates through all party bots and automatically equips best-in-slot items from their bags. |
| **4** | Party Management | Interface\\Icons\\INV_Misc_Bag_08 | Server (`/say`) | *Interactive UI / Handler* | Forces a full state refresh and gear resynchronization on the selected bot. |
| **5** | Abilities & Spells | Interface\\Icons\\INV_Misc_Note_01 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Randomizes the selected bot's appearance and gear within level boundaries (GM/debug tool). |
| **6** | Abilities & Spells | Interface\\Icons\\INV_Misc_Book_09 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Allocates all unspent talent points into specialization Tree 1 for the targeted bot. |
| **7** | Abilities & Spells | Interface\\Icons\\INV_Misc_Horn_02 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Allocates all unspent talent points into specialization Tree 2 for the targeted bot. |
| **8** | Abilities & Spells | Interface\\Icons\\Spell_Nature_Purge | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Allocates all unspent talent points into specialization Tree 3 for the targeted bot. |
| **9** | Strategy & Tactics | Reset party strats | Whole Party (`/party`) | `.bot strategy reset` | Resets all active strategy toggles to default archetype baselines for all party bots. |
| **10** | Strategy & Tactics | Reset selected strats | Selected Bot (`/whisper`) | `.bot strategy reset` | Resets all active strategy toggles to default archetype baselines for the targeted bot. |
| **11** | Inventory & Trade | Interface\\Icons\\INV_Letter_15 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Opens the remote equipment inspection window for the targeted bot. |
| **12** | Party Management | Command 12 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Synchronizes the targeted bot's level, weapon skills, and base stats to match the player. |
| **13** | Party Management | Summon party | Whole Party (`/party`) | `summon` | Summons all controlled party bots directly to the player's current world coordinates. |
| **14** | Party Management | Summon selected | Selected Bot (`/whisper`) | `summon` | Summons the selected bot directly to the player's current world coordinates. |
| **15** | Movement & Stances | Follow party | Whole Party (`/party`) | `.bot action follow` | Commands all party bots to enter modern tactical follow formation behind the player. |
| **16** | Movement & Stances | Follow selected | Selected Bot (`/whisper`) | `follow` | Commands the selected bot to follow the player closely. |
| **17** | Abilities & Spells | Learn skills | Whole Party (`/party`) | `.bot action learn` | Orders party bots to interact with nearby class trainers and purchase all available spells. |
| **18** | Support & Upkeep | Release party | Whole Party (`/party`) | `release` | Forces all dead party bots to release spirit and appear at the nearest graveyard. |
| **19** | Support & Upkeep | Release selected | Selected Bot (`/whisper`) | `release` | Forces the selected dead bot to release spirit. |
| **20** | Info & Status | Party quests | Whole Party (`/party`) | `quests` | Queries and displays quest progression and objectives for all party bots. |
| **21** | Info & Status | Selected quests | Selected Bot (`/whisper`) | `quests` | Queries and displays quest progression and objectives for the selected bot. |
| **22** | Info & Status | Party status | Whole Party (`/party`) | `stats` | Prints live health, mana, role, and current state metrics for all party bots. |
| **23** | Info & Status | Selected status | Selected Bot (`/whisper`) | `stats` | Prints live health, mana, role, and current state metrics for the selected bot. |
| **24** | Support & Upkeep | Loot party | Whole Party (`/party`) | `d add all loot` | Orders all party bots to inspect and loot eligible corpses in the vicinity. |
| **25** | Combat | Flee party | Whole Party (`/party`) | `.bot action flee` | Orders all party bots to immediately break combat, cease spellcasts, and flee towards player. |
| **26** | Combat | Tank flee | Whole Party (`/party`) | `@tank flee` | Orders all tank bots in the group to disengage and flee. |
| **27** | Combat | DPS flee | Whole Party (`/party`) | `@dps flee` | Orders all DPS bots in the group to disengage and flee. |
| **28** | Combat | Healer flee | Whole Party (`/party`) | `@heal flee` | Orders all healer bots in the group to disengage and flee. |
| **29** | Combat | Melee flee | Whole Party (`/party`) | `@melee flee` | Orders all melee bots in the group to disengage and flee. |
| **30** | Combat | Ranged flee | Whole Party (`/party`) | `@ranged flee` | Orders all ranged bots in the group to disengage and flee. |
| **31** | Combat | Flee selected | Selected Bot (`/whisper`) | `flee` | Orders the selected bot to disengage and flee. |
| **32** | Combat | Attack target | Party Target (`/party`) | `.bot action attack` | Commands party bots to attack the player's current hostile target (evade-safe, 150yd range). |
| **33** | Combat | Tank attack | Party Target (`/party`) | `@tank attack` | Orders only tank bots to charge and engage the target, establishing initial threat. |
| **34** | Combat | DPS attack | Party Target (`/party`) | `@dps attack` | Orders only DPS bots to engage the target. |
| **35** | Combat | Healer attack | Party Target (`/party`) | `@heal attack` | Orders healer bots to enter combat and contribute offensive damage when healing is not required. |
| **36** | Combat | Melee attack | Party Target (`/party`) | `@melee attack` | Orders all melee bots to engage the target in close-quarters combat. |
| **37** | Combat | Ranged attack | Party Target (`/party`) | `@ranged attack` | Orders all ranged bots to begin ranged combat on the target. |
| **38** | Formations | Formation: arrow | Whole Party (`/party`) | `formation arrow` | Sets bot formation to Arrow (V-shape with tank at vanguard). |
| **39** | Formations | Formation: queue | Whole Party (`/party`) | `formation queue` | Sets bot formation to Queue (single file line behind player). |
| **40** | Formations | Formation: near | Whole Party (`/party`) | `formation near` | Sets bot formation to Near (dense clustering within 3 yards). |
| **41** | Formations | Formation: melee | Whole Party (`/party`) | `formation melee` | Sets bot formation to Melee (melee in front, casters staggered back). |
| **42** | Formations | Formation: line | Whole Party (`/party`) | `formation line` | Sets bot formation to Line (wide horizontal battle line). |
| **43** | Formations | Formation: circle | Whole Party (`/party`) | `formation circle` | Sets bot formation to Circle (defensive perimeter surrounding player). |
| **44** | Formations | Formation: chaos | Whole Party (`/party`) | `formation chaos` | Sets bot formation to Chaos (loose organic dispersed positions). |
| **45** | Formations | Formation: shield | Whole Party (`/party`) | `formation shield` | Sets bot formation to Shield (tight phalanx defensive wall). |
| **46** | Formations | View formation | Whole Party (`/party`) | `formation` | Displays the party's current active movement formation name. |
| **47** | Movement & Stances | Hold party | Whole Party (`/party`) | `stay` | Orders all party bots to halt and hold their exact current ground coordinates. |
| **48** | Strategy & Tactics | Command 48 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Enables autonomous target acquisition for the selected bot. |
| **49** | Strategy & Tactics | Command 49 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Disables autonomous target acquisition, requiring player orders to attack. |
| **50** | Strategy & Tactics | Command 50 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Configures targeted Druid bot to favor Balance/Caster DPS role. |
| **51** | Strategy & Tactics | Command 51 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders targeted Druid bot to shift into Bear/Dire Bear Form (Tank role). |
| **52** | Strategy & Tactics | Command 52 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders targeted Druid bot to shift into Cat Form (Melee DPS role). |
| **53** | Strategy & Tactics | Command 53 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders targeted Druid bot to focus exclusively on Restoration healing. |
| **54** | Strategy & Tactics | Strategy | Selected Bot (`/whisper`) | `strategy` | Opens the interactive Strategy Editor window displaying all available combat toggles for the bot. |
| **55** | Support & Upkeep | Command 55 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders Paladin bot to activate Frost Resistance Aura. |
| **56** | Support & Upkeep | Command 56 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders Paladin bot to activate Fire Resistance Aura. |
| **57** | Support & Upkeep | Command 57 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders Paladin bot to activate Devotion (Armor) Aura. |
| **58** | Support & Upkeep | Command 58 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders Paladin bot to activate Retribution Aura. |
| **59** | Support & Upkeep | Command 59 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders Paladin bot to buff party with Blessing of Kings. |
| **60** | Support & Upkeep | Command 60 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders Paladin bot to buff party with Blessing of Wisdom. |
| **61** | Support & Upkeep | Command 61 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Orders Paladin bot to buff party with Blessing of Might. |
| **62** | Info & Status | Party combat strategies | Whole Party (`/party`) | `co ?` | Prints the full active combat strategy chain for all party bots to chat. |
| **63** | Info & Status | Selected combat strategies | Selected Bot (`/whisper`) | `co ?` | Prints the active combat strategy chain for the selected bot. |
| **64** | Inventory & Trade | Inventory | Selected Bot (`/whisper`) | `c` | Opens the remote Inventory and Bag viewer for the targeted bot. |
| **65** | Inventory & Trade | Destroy item | Selected Bot (`/whisper`) | `destroy ` | Opens the remote Destroy Item window to discard junk from bot bags. |
| **66** | Inventory & Trade | Equip item | Selected Bot (`/whisper`) | `e ` | Opens the remote Equip Item window to inspect and equip gear. |
| **67** | Inventory & Trade | Sell item | Selected Bot (`/whisper`) | `s ` | Opens the remote Sell Item window to select vendor sales. |
| **68** | Inventory & Trade | Use item | Selected Bot (`/whisper`) | `u ` | Opens the remote Use Item window to command bots to consume or activate items. |
| **69** | Abilities & Spells | Spells | Selected Bot (`/whisper`) | `cast ` | Opens the Spellbook & Blacklist window to inspect learned spells and disable unwanted abilities. |
| **70** | Combat | Stop combat | Whole Party (`/party`) | `.bot action stop` | Commands bots to halt all spellcasts, drop hostility targets, and clear aggro queues. |
| **71** | Party Management | Disband party | Whole Party (`/party`) | `UninviteUnit ` | Uninvites all bots and dissolves the current party or raid. |
| **72** | Utilities & World | Bot status | Server (`/say`) | *Interactive UI / Handler* | Prints live health, mana, role, and current state metrics for all party bots. |
| **73** | Party Management | Command 73 | Server (`/say`) | *Interactive UI / Handler* | Teleports player directly to the selected bot coordinates (GM/debug tool). |
| **74** | Player Roster | Player roster | Server (`/say`) | `online` | Toggles the interactive Player Roster window with real-time name search, +Target adding, and one-click party fill. |
| **75** | Strategy & Tactics | Command 75 | Selected Bot (`/whisper`) | *Interactive UI / Handler* | Reserved bot communication channel. |
| **76** | Movement & Stances | Hold selected | Selected Bot (`/whisper`) | `stay` | Orders the selected bot to hold its current position. |
| **77** | Player Roster | Refresh bot list | Server (`/say`) | `.bot roster` | Requests live online status and account roster from the server via `.bot roster`. |
| **78** | Party Management | Command 78 | Server (`/say`) | *Interactive UI / Handler* | Brings all character bots listed on your friends list online. |
| **79** | Party Management | Command 79 | Server (`/say`) | *Interactive UI / Handler* | Invites all character bots listed on your friends list into your group. |
| **80** | Support & Upkeep | Ready check | Server (`/say`) | `.bot action ready` | Initiates a server-side Ready Check across all party and raid bots. |
| **81** | Support & Upkeep | Drink (rest) | Whole Party (`/party`) | `.bot action rest` | Orders all mana-using bots to sit down and drink water to restore mana. |
| **82** | Party Management | Log out party | Whole Party (`/party`) | *Interactive UI / Handler* | Gracefully logs out all controlled bots currently in your party. |
| **83** | Party Management | Log in party | Whole Party (`/party`) | *Interactive UI / Handler* | Logs in all controlled bots saved to your party. |
| **84** | Strategy & Tactics | Command 84 | Whole Party (`/party`) | *Interactive UI / Handler* | Enables Naxxramas encounter-specific boss strategies. |
| **85** | Strategy & Tactics | Reset current state | Whole Party (`/party`) | `reset` | Clears combat lockouts and resets the AI state machine for the current target. |
| **86** | Party Management | Remove selected | Selected Bot (`/whisper`) | `.bot remove` | Logs out the selected bot. |
| **87** | Party Management | Add selected | Selected Bot (`/whisper`) | `.bot add` | Logs in and adds the selected bot to your party. |
| **88** | Utilities & World | Add friends | Whole Party (`/party`) | *Interactive UI / Handler* | Iterates over all current group members and adds them to your character friends list. |
| **89** | Support & Upkeep | Grind party | Whole Party (`/party`) | `grind` | Toggles autonomous area grinding mode: bots engage nearby hostile mobs independently. |
| **90** | Support & Upkeep | Buff party | Whole Party (`/party`) | `d buff` | Commands all party bots to refresh class buffs on the group immediately. |
| **91** | Combat | Attack target | Whole Party (`/party`) | `.bot action attack` | Orders all party bots to switch targets and attack the player's current target. |
| **92** | Combat | Tactical pull | Whole Party (`/party`) | `.bot action pull 10 ranged` | Initiates a ranged tank pull (10yd pull): tank engages while party holds position. |
| **93** | Inventory & Trade | Equip upgrades | Whole Party (`/party`) | `d equip upgrades` | Commands all bots to scan their bags and automatically equip any item upgrades. |
| **94** | Inventory & Trade | Repair gear | Whole Party (`/party`) | `.bot action repair` | Orders bots to approach the nearest vendor and repair all damaged equipment. |
| **95** | Inventory & Trade | Sell junk | Whole Party (`/party`) | `.bot action sell` | Orders bots to approach the nearest vendor and sell all grey junk items. |
| **96** | Abilities & Spells | Talents | Selected Bot (`/whisper`) | `talents` | Prints the targeted bot's current talent specialization tree distribution. |
| **97** | Abilities & Spells | Trainer | Whole Party (`/party`) | `trainer` | Commands the bot to interact with a nearby class or profession trainer. |
| **98** | Support & Upkeep | Resurrect | Whole Party (`/party`) | `d revive targets` | Commands healer bots to cast resurrection spells on dead group members. |
| **99** | Support & Upkeep | Eat (rest) | Whole Party (`/party`) | `.bot action rest` | Orders bots to sit down and eat food to restore health. |
| **100** | Movement & Stances | Stop & hold | Whole Party (`/party`) | `.bot action stay` | Orders bots to immediately stop following and hold position. |
| **101** | Party Management | Give leader | Selected Bot (`/whisper`) | `d give leader` | Transfers party leader permissions to the selected bot. |
| **102** | Strategy & Tactics | Roles | Server (`/say`) | *Interactive UI / Handler* | Opens the 1-click Per-Class Role Assignment window (Tank, Healer, Melee, Ranged). |
| **103** | Utilities & World | Loot world object | Whole Party (`/party`) | `loot` | Commands bot to interact with the nearest usable world object (chests, levers, nodes). |
| **104** | Formations | Formation: far | Whole Party (`/party`) | `formation far` | Sets bot formation to Far (spread-out 15-20 yard loose spacing). |
| **105** | Formations | Ping formation | Whole Party (`/party`) | `formation show` | Pings current formation positions on the minimap/ground. |
| **106** | Movement & Stances | Stance: near | Whole Party (`/party`) | `stance near` | Sets combat stance to Near (bots stay close to target during combat). |
| **107** | Movement & Stances | Stance: tank | Whole Party (`/party`) | `stance tank` | Sets combat stance to Tank (tank faces boss away from raid group). |
| **108** | Movement & Stances | Stance: turnback | Whole Party (`/party`) | `stance turnback` | Sets combat stance to Turnback (positions target facing away from casters). |
| **109** | Movement & Stances | Stance: behind | Whole Party (`/party`) | `stance behind` | Sets combat stance to Behind (melee bots position behind target to bypass parry/block). |
| **110** | Movement & Stances | Combat spacing | Whole Party (`/party`) | `.bot behavior party spread on` | Enables party combat spacing (bots maintain 10-yard spread to avoid AoE splash). |
| **111** | Movement & Stances | Ping stance | Whole Party (`/party`) | `stance show` | Pings current combat stance positions on the ground. |
| **112** | Combat | Attack RTI | Whole Party (`/party`) | `attack rti` | Commands party bots to attack the target marked with the active RTI combat icon. |
| **113** | Combat | Pull RTI | Whole Party (`/party`) | `pull rti` | Orders tank to pull the mob marked with the active RTI combat icon. |
| **114** | Combat | Auto mark RTI | Whole Party (`/party`) | `co ~mark rti` | Toggles automated RTI raid target marking during combat via `co ~mark rti`. |
| **115** | Combat | Toggle Kite | Whole Party (`/party`) | `co ~kite` | Toggles autonomous kiting behavior for ranged bots when attacked in melee via `co ~kite`. |
| **116** | Combat | Target: Skull | Whole Party (`/party`) | `rti skull` | Sets primary focus fire raid icon to Skull. |
| **117** | Combat | Target: Cross | Whole Party (`/party`) | `rti cross` | Sets primary focus fire raid icon to Cross. |
| **118** | Combat | Target: Square | Whole Party (`/party`) | `rti square` | Sets primary focus fire raid icon to Square. |
| **119** | Combat | Target: Moon | Whole Party (`/party`) | `rti moon` | Sets primary focus fire raid icon to Moon. |
| **120** | Combat | Target: Triangle | Whole Party (`/party`) | `rti triangle` | Sets primary focus fire raid icon to Triangle. |
| **121** | Combat | Target: Diamond | Whole Party (`/party`) | `rti diamond` | Sets primary focus fire raid icon to Diamond. |
| **122** | Combat | Target: Circle | Whole Party (`/party`) | `rti circle` | Sets primary focus fire raid icon to Circle. |
| **123** | Combat | Target: Star | Whole Party (`/party`) | `rti star` | Sets primary focus fire raid icon to Star. |
| **124** | Combat | Target: Clear | Whole Party (`/party`) | `rti none` | Clears primary focus fire raid icon assignment. |
| **125** | Combat | CC: Skull | Whole Party (`/party`) | `rti cc skull` | Sets crowd control raid target icon to Skull. |
| **126** | Combat | CC: Moon | Whole Party (`/party`) | `rti cc moon` | Sets crowd control raid target icon to Moon. |
| **127** | Combat | CC: Clear | Whole Party (`/party`) | `rti cc none` | Clears crowd control raid target icon assignment. |
| **128** | Inventory & Trade | Loot: Equip | Whole Party (`/party`) | `ll ~equip` | Toggles whether bots loot equipment upgrades from fallen foes via `ll ~equip`. |
| **129** | Inventory & Trade | Loot: Quests | Whole Party (`/party`) | `ll ~quest` | Toggles whether bots loot quest objective items via `ll ~quest`. |
| **130** | Inventory & Trade | Loot: Trade skills | Whole Party (`/party`) | `ll ~skill` | Toggles whether bots loot trade skill crafting materials via `ll ~skill`. |
| **131** | Inventory & Trade | Loot: Disenchant | Whole Party (`/party`) | `ll ~disenchant` | Toggles whether bots loot uncommon/rare items to disenchant via `ll ~disenchant`. |
| **132** | Inventory & Trade | Loot: Consumables | Whole Party (`/party`) | `ll ~use` | Toggles whether bots loot consumables, potions, food, and bandages via `ll ~use`. |
| **133** | Inventory & Trade | Loot: Vendor gold | Whole Party (`/party`) | `ll ~vendor` | Toggles whether bots loot vendor trash items to sell for gold via `ll ~vendor`. |
| **134** | Inventory & Trade | Loot: Grey trash | Whole Party (`/party`) | `ll ~trash` | Toggles whether bots loot poor grey junk items via `ll ~trash`. |
| **135** | Inventory & Trade | Loot: Show rules | Whole Party (`/party`) | `ll ?` | Displays the party's currently active loot filter configuration via `ll ?`. |
| **136** | Strategy & Tactics | Mana: Burst (Off) | Whole Party (`/party`) | `save mana 1` | Disables mana conservation: bots cast highest rank spells at full burst. |
| **137** | Strategy & Tactics | Mana: Level 2 (Low) | Whole Party (`/party`) | `save mana 2` | Sets mana conservation to Level 2: light conservation in sustained battles. |
| **138** | Strategy & Tactics | Mana: Level 3 (Med) | Whole Party (`/party`) | `save mana 3` | Sets mana conservation to Level 3: balanced DPS and mana efficiency. |
| **139** | Strategy & Tactics | Mana: Level 4 (High) | Whole Party (`/party`) | `save mana 4` | Sets mana conservation to Level 4: aggressive spell downranking to preserve mana. |
| **140** | Strategy & Tactics | Mana: Level 5 (Max) | Whole Party (`/party`) | `save mana 5` | Sets mana conservation to Level 5: maximum conservation (vital utility and wanding only). |
| **141** | Strategy & Tactics | Mana: Show level | Whole Party (`/party`) | `save mana ?` | Displays current mana conservation level for party bots via `save mana ?`. |
| **142** | Movement & Stances | Set guard spot | Whole Party (`/party`) | `position guard set` | Records current player coordinates as the bots' permanent guard post. |
| **143** | Movement & Stances | Move to guard | Whole Party (`/party`) | `guard` | Orders bots to travel to their assigned guard post and defend it. |
| **144** | Movement & Stances | Free movement | Whole Party (`/party`) | `free` | Releases bots from guard posts and allows autonomous nearby wandering. |
| **145** | Support & Upkeep | Toggle RPG mode | Whole Party (`/party`) | `nc ~rpg` | Toggles autonomous RPG behaviors when idle out of combat via `nc ~rpg`. |
| **146** | Support & Upkeep | RPG: Quests | Whole Party (`/party`) | `nc ~rpg quest` | Autonomous RPG: Bots autonomously pick up and hand in quests to nearby NPCs via `nc ~rpg quest`. |
| **147** | Support & Upkeep | RPG: Vendors & AH | Whole Party (`/party`) | `nc ~rpg vendor` | Autonomous RPG: Bots autonomously vendor trash, buy reagents, and check mailbox via `nc ~rpg vendor`. |
| **148** | Support & Upkeep | RPG: Explore & Fly | Whole Party (`/party`) | `nc ~rpg explore` | Autonomous RPG: Bots discover flight masters, take flights, and explore via `nc ~rpg explore`. |
| **149** | Support & Upkeep | RPG: Train & Gear | Whole Party (`/party`) | `nc ~rpg maintenance` | Autonomous RPG: Bots visit trainers to learn spells and repair equipment via `nc ~rpg maintenance`. |
| **150** | Support & Upkeep | RPG: Crafting | Whole Party (`/party`) | `nc ~rpg craft` | Autonomous RPG: Bots autonomously craft items using trade skills via `nc ~rpg craft`. |
| **151** | Utilities & World | Check mailbox | Whole Party (`/party`) | `mail ?` | Commands bots to check nearby mailboxes and report attached items via `mail ?`. |
| **152** | Utilities & World | Blacklisted spells | Whole Party (`/party`) | `ss ?` | Displays list of blacklisted spells that bots are forbidden to cast via `ss ?`. |
| **153** | Utilities & World | Talk to NPC | Whole Party (`/party`) | `talk` | Commands bots to interact or gossip with your selected NPC. |
| **154** | Utilities & World | Accept all quests | Whole Party (`/party`) | `accept *` | Accepts all shared party quests from all group members. |
| **155** | Utilities & World | Quest rewards | Whole Party (`/party`) | `r ?` | Queries available quest reward choices for the selected bot via `r ?`. |
| **156** | Combat | Interrupt cast | Party Target (`/party`) | `.bot action interrupt` | Orders party bots to prioritize and immediately cast interrupts (Kick, Pummel, Counterspell, Earth Shock). |
| **157** | Combat | Tactical pullback | Party Target (`/party`) | `.bot action pullback 5 ranged` | Orders the tank to pull from range and drag the mob back to player anchor coordinates while party holds. |
| **158** | Combat | End pull | Whole Party (`/party`) | `end pull` | Immediately aborts an active tank pull without waiting for timeout. |
| **159** | Combat | Focus Skull | Whole Party (`/party`) | `.bot action focus skull` | Sets Skull mark on target and commands all DPS bots to focus burn. |
| **160** | Combat | Toggle AoE | Whole Party (`/party`) | `.bot action aoe` | Toggles all party AoE spells on/off (critical for crowd control preservation in instances). |
| **161** | Combat | Auto CC | Whole Party (`/party`) | `.bot action auto cc` | Toggles smart auto-CC: bots automatically crowd control loose adds threatening healers. |
| **162** | Combat | Pre-pull Sap | Whole Party (`/party`) | `.bot action sap` | Toggles rogue pre-pull Sap behavior on marked targets before combat begins. |
| **163** | Movement & Stances | Come to me | Whole Party (`/party`) | `.bot action come` | Commands all party bots to drop current movement targets and immediately sprint to player coordinates. |
| **164** | Support & Upkeep | Corpse run | Whole Party (`/party`) | `.bot action corpse run` | Commands all dead spirit bots to immediately run back to their corpses or instance entrance. |
| **165** | Support & Upkeep | Rebuff party | Whole Party (`/party`) | `rebuff` | Orders bots to top off expiring party buffs out of combat (2-minute refresh pass). |
| **166** | Support & Upkeep | Mimic consumables | Whole Party (`/party`) | `.bot behavior party mimic on` | Enables consumable mimicry: bots drink matching potions/elixirs when the player drinks one. |
| **167** | Support & Upkeep | Drop totems | Whole Party (`/party`) | `.bot totem party drop` | Orders party Shamans to drop their configured totem set immediately. |
| **168** | Inventory & Trade | Trade with bot | Selected Bot (`/whisper`) | `.bot action trade` | Opens a direct trade window with the targeted companion bot. |
| **169** | Party Management | Maintenance | Selected Bot (`/whisper`) | `.bot maintenance` | Restocks reagents, consumables, and ammunition for the selected bot without visiting vendors. |
| **170** | Strategy & Tactics | Dragon tankface | Whole Party (`/party`) | `.bot action raid tankface` | Raid tactic: Tank bots turn dragon bosses away from the raid to prevent cleave/breath damage. |
| **171** | Strategy & Tactics | Douse MC runes | Whole Party (`/party`) | `.bot action raid douse` | Raid tactic: Bots douse nearby Molten Core runes using Quintessence. |
| **172** | Strategy & Tactics | Turtle raid tactics | Whole Party (`/party`) | `.bot action raid custom on` | Enables custom Turtle WoW raid encounter tactics (Emerald Sanctum, Karazhan Crypt, etc.). |
| **173** | Movement & Stances | Wander mode | Whole Party (`/party`) | `wander` | Toggles free autonomous roaming and exploration when out of combat. |
| **174** | Combat | Single burn (focus) | Whole Party (`/party`) | `co ~focus` | Toggles single-target focus burn via native `co ~focus`: suppresses AoE and splash abilities to protect CC targets. |
| **175** | Combat | Toggle AoE fear | Whole Party (`/party`) | `co ~aoe fear` | Toggles AoE fear spells (Psychic Scream, Howl of Terror, Intimidating Shout) via native `co ~aoe fear` (off by default in instances). |
| **176** | Strategy & Tactics | Threat back-off | Whole Party (`/party`) | `.bot behavior party threat on` | Directs non-tank bots to ease off attacks when approaching the tank's threat ceiling. |
| **177** | Strategy & Tactics | Offensive boost | Whole Party (`/party`) | `.bot behavior party boost on` | Allows bots to activate major offensive cooldowns, racials, and trinkets during boss fights. |
| **178** | Support & Upkeep | Potions engine | Whole Party (`/party`) | `.bot behavior party potions on` | Enables automated combat potion and healthstone consumption when health drops critical. |
| **179** | Utilities & World | Share quests | Whole Party (`/party`) | `share` | Shares all eligible quests from the bot's log with group members. |
| **180** | Utilities & World | Bind hearthstone | Selected Bot (`/whisper`) | `home` | Interacts with the nearest innkeeper to bind the bot's hearthstone. |
| **181** | Utilities & World | Taxi flight | Selected Bot (`/whisper`) | `taxi` | Purchases a flight path from the nearest flight master. |
| **182** | Strategy & Tactics | Soft state reset | Selected Bot (`/whisper`) | `reset` | Performs a soft reset on the bot AI behavior tree without dropping combat or logging out. |
