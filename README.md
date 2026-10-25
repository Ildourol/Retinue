<div align="center">

<img src="screens/banner.jpg" alt="Retinue Playerbot Panel Banner" width="100%" />

# Retinue

**The Definitive Companion & Playerbot Tactical Suite for World of Warcraft (Vanilla 1.12.1 / Turtle WoW 1.18.1)**

[![Interface](https://img.shields.io/badge/Interface-11200-blue.svg)]()
[![Turtle WoW](https://img.shields.io/badge/Turtle%20WoW-1.18.1-green.svg)](https://turtlecraft.gg/)
[![Target Core](https://img.shields.io/badge/Core-TortoiseBots%20%2F%20vMaNGOS-orange.svg)]()
[![GitHub Repo](https://img.shields.io/badge/GitHub-Ildourol%2FRetinue-blue?logo=github)](https://github.com/Ildourol/Retinue)
[![License](https://img.shields.io/badge/License-GPL%20v2-lightgrey.svg)](LICENSE)

An elegant, high-performance in-game graphical control suite built specifically for World of Warcraft servers running the **TortoiseBots** engine and **vMaNGOS**.

[Overview](#overview) • [Core Features](#core-features) • [Quick Start](#quick-start) • [Interactive Windows](#interactive-windows) • [Slash Commands](#slash-commands) • [Macro Examples](#macro-examples) • [Commands Guide](docs/COMMANDS_GUIDE.md)

</div>

---

## Overview

**Retinue** replaces cumbersome console typing and chat macro spam with a streamlined, responsive graphical interface. Whether assembling a 5-player dungeon squad or mobilizing a 40-player raid, Retinue gives you total command over your bot companions: summoning alts, managing party formations, toggling combat tactics, inspecting remote bags, assigning class roles, casting buffs, and trading loot in real time.

<div align="center">

<img src="screens/addon.png" alt="Retinue in-game panel screenshot" width="90%" />

</div>

---

## Core Features

### ⚔️ Tactical Command Bar
- **10 Categorized Action Groups**: Access 185 native companion commands (Combat, Movement, Spacing, Formations, Stances, RTI Targets, Utility, Gearing, and Maintenance).
- **Stepped Pull Timers**: Direct delay steppers on Pull (`/rc 92`: 0s, 1s, 2s, 3s, 5s) and Pullback (`/rc 157`: 5s, 8s, 10s, 15s, 20s).
- **Consensus Status Lamps**: Live party consensus indicator lamps (Green = all on, Red = all off, Amber = mixed) on AoE, Auto CC, and Loot actions.
- **Direct Force Rest Actions**: Dual-dispatch on Drink (81), Eat (99), and Use GO / Loot (103) sending direct vMaNGOS force actions (`d drink`, `d food`, `d use go`) and `.bot action ...` with quiet console command dispatch and zero chat bubble leakage.
- **Zero Frame Clutter**: Clicking any category opens a dedicated modal; selecting another group cleanly reuses the window without stacking multiple frames on your screen.

### ⭐ Persistent 10-Slot Quick Favorites
- Pin your most-used commands directly to the top row of the Retinue bar.
- **Right-Click** any button across any modal to pin/unpin it with a visual star (`*`).
- **Expanded Drawer (`>`)**: Supports unlimited favorited actions with mouse-wheel scrolling.

### 👥 Interactive 5-View Roster Hub
- **Tab 1: [Account]**: View and manage personal account alts, summon/invite/delete, live search, `+ Target` fast add, and sequential batch queue with automatic raid conversion.
- **Tab 2: [Guild]**: Live view of guild-claimed wandering bots (`TBM:CLAIMED_*`) with Level 60 `[Locked]` gold badges vs Level 1-59 `[Leveling]` green badges, role cycling, and safe release confirmation modal.
- **Tab 3: [Party]**: 5-member live squad card view displaying player master role selector, bot health/mana bars, assigned CC marks, role cycle buttons, and 1-click Gear Inspector shortcuts.
- **Tab 4: [Raid]**: Boss tactics panel with `Tank face away` (`raid tankface`), `Douse runes` (`raid douse`), `Custom tactics: on/off` toggle switch with status lamp, and `Check bots` (`raid status`) summary.
- **Tab 5: [CC Marks]**: Visual crowd control assignment matrix covering all 8 Raid Target Icons (Star, Circle, Diamond, Triangle, Moon, Square, Cross, Skull) with bot assignment and clear controls.

### 🧠 Dynamic Strategy & Bot Behaviour Editor
- **4 Navigation Modes**: `[Strategies]` (parallel dual-column overview), `[Combat]` (`co`), `[Non-combat]` (`nc`), and dedicated `[Behaviour]` (`behavior`).
- **Parallel Dual-Column Overview**: Side-by-side 242px columns for Combat and Non-combat strategies with independent scroll steppers, live scrolling UI range indicators (`(1-14/X)`), full vertical scrollbars, and mousewheel scrolling.
- **Soft Muted Status Indicators**: Calm, non-intense green (`|cff40a040●|r`, `[ON]`) and red (`|cffa04040○|r`, `[OFF]`) indicators to eliminate visual fatigue.
- **Dynamic Multi-Channel Dispatch**: Strategy toggles deliver intelligently via WHISPER (when bot is targeted or inspected), PARTY (when in a group), or SAY fallback with optimistic state updating.
- **Dedicated Behaviour Options Panel**: Toggle core combat and survival habits (Loot corpses, AoE spells, Auto CC, Save mana, Offensive Cooldowns, Threat throttling, Potions, Spread out, Mimic consumables) with live green `[ ON ]` vs grey `[ OFF ]` status lamps and real-time state querying.
- **Dual-Dispatch Command Engine**: Simultaneously dispatches canonical TortoiseBots commands (`.bot behavior <bot> <key> <state>`) and companion whisper strategy verbs (`co +/-...`, `nc +/-...`) for seamless vMaNGOS bot reaction.
- **Active State Highlights**: Strategy rows show green `● [ON]` indicator lamps for active combat and non-combat strategies.
- **Role Presets**: 1-click archetype role presets for all 9 classes (Warrior, Paladin, Hunter, Rogue, Priest, Shaman, Mage, Warlock, Druid).

### 🥋 Bot Inspector (Full-Body Paperdoll & Bags)
- **Tab 1: [Gear]**: Centered 3D animated `PlayerModel` paperdoll with full-body scaling (0.35, head-to-toe), interactive mouse drag 360° horizontal rotation, and mouse wheel zoom scaling (0.15 to 1.20). Displays 19 equipment slots, authentic quality borders, durability status bar, item tooltips, and equipped money tally.
- **Tab 2: [Bags]**: 56-slot remote bag container grid, item upgrade indicator badges (`+`), "Give to me" trade sequencing, direct "Trade" initiation, and Item Catalog jump.

### 📦 Item Catalog & Spawner (Turtle WoW 1.18.1 / Vanilla 1.12.1)
- Browse, filter, and search **26,542 authentic Turtle WoW and Vanilla items** (levels 1-60).
- **Canonical Database Sourced**: Sourced directly from `tortoise-db-viewer` with genuine client DBC icon mappings pre-loaded for instant display.
- **Zero Synthetic Clones**: Strictly excludes all synthetic scaled clones from `mod-twow-item-level-scaling` to maintain pure item authenticity.
- **Dynamic Multi-Filters**: Filter by Level (All, `1-10` to `51-60`), Rarity (Poor to Legendary), and 22 Equipment Slots (Weapons, Armor, Relics, Bags, Consumables).
- **Real-Time Name Search**: Instant substring search with clear/reset controls.
- **1-Click Target Gearing**: Left-click any item to run `.additem <id> 1` directly onto your targeted bot companion or yourself.
- **Bar & Window Integration**: Mounted directly on the main tactical bar at slot 12 next to Roster, accessible via `/retinue catalog`, `/retinue itemus`, `/retinue spawn`, or the `[Catalog]` button in the remote inventory window.

### 🛡️ Instant Role Assignment
- Fast 1-click role bar for your entire group:
  - **Left-Click**: Assigns primary roles (Protection Tank / Holy-Resto Healer).
  - **Right-Click**: Assigns secondary roles (DPS / Utility).

### 🔮 Spellbook & Buff Management
- Browse abilities known by the targeted companion with live scrolling range indicator (`(1-16/X)`) and vertical scrollbar.
- **Click to Blacklist**: Prevents bots from casting unwanted or situational spells in specific raid encounters (`nc -<spell>` / `nc +<spell>`).

### 🔘 360° Draggable Minimap Button
- Draggable minimap button with tooltip metrics and left-click bar toggle.

---

## Quick Start

### Installation
1. Download or clone this repository:
   ```bash
   git clone https://github.com/Ildourol/Retinue.git
   ```
2. Copy the `Retinue` folder into your World of Warcraft addons directory:
   ```text
   World of Warcraft\Interface\AddOns\Retinue\
   ```
3. Verify that `Retinue.toc` is located directly inside `Interface\AddOns\Retinue\Retinue.toc`.
4. Launch your game client or run `/console reloadui`.

---

## Interactive Windows

| Window | Access Shortcut | Purpose |
|:---|:---|:---|
| **Command Bar** | `/retinue` or `/ret` | Main tactical control bar with 10 command groups, pull steppers, and consensus lamps |
| **Roster Hub** | `/ret roster` | 5-tab deployment hub: Account alts, Guild claimed bots, Party cards, Raid tactics, CC Marks |
| **Bot Inspector** | `/ret bags` or `/ret inspect` | 2-tab inspector: Full-body 3D Gear Paperdoll and 56-slot Bags grid |
| **Strategy Editor** | `/ret strategy` | 4-tab hub: Dual-column Strategies, Combat, Non-combat, and Bot Behaviour |
| **Spellbook** | `/ret spells` | Inspect bot spells and toggle casting blacklists |
| **Role Bar** | Role Button on bar | Rapidly set Tank, Healer, and DPS presets across all party bots |
| **Item Catalog** | `/ret catalog` or bar | Browse 26,542 items, filter by slot/rarity/level, 1-click spawn |

---

## Slash Commands

Retinue provides intuitive, short commands as well as legacy aliases for backwards compatibility:

| Slash Command | Arguments | Description |
|:---|:---|:---|
| `/retinue` or `/ret` or `/rtn` | *none* | Toggle the primary Retinue command bar |
| `/ret roster` | *none* | Open the 5-tab Roster Hub (Account, Guild, Party, Raid, CC Marks) |
| `/ret sync` | *none* | Manually synchronize roster states with the server |
| `/ret strategy` | *none* | Open the Strategy Editor for your current target |
| `/ret spells` | *none* | Open the remote Spellbook & Buffs panel |
| `/ret bags` or `/ret inspect` | *none* | Open the Bot Inspector (Paperdoll, Bags, Behaviour) |
| `/ret catalog` | *none* | Open the 26k+ Item Catalog & Spawner browser |
| `/ret fill` | *none* | Auto-fill open party slots (up to 5) with filtered bots |
| `/ret fillraid` | *none* | Auto-convert to raid and fill open slots (up to 40) |
| `/retcom <id>` or `/rc <id>` | `<id>` | Execute any action ID (1–185) directly via macro |
| `/ret debug` | *none* | Toggle verbose event logging in chat |
| `/ret capture` | *none* | Toggle packet capture stream inspection |

*(Legacy `/warband`, `/wb`, `/unbot`, and `/ubc <id>` aliases remain fully supported).*

---

## Macro Examples

Create custom macros in your client for rapid tactical execution:

#### 🚨 Emergency Stop & Regroup
```text
/rc 70
/rc 163
```
*Instantly halts combat, clears bot action queues, and sprints all companions directly to your position.*

#### 🛡️ Tank Pull & Hold
```text
/rc 92
```
*Orders the group tank to engage your current target with ranged pull while party DPS holds damage.*

#### 🏃 Retreat & Flee
```text
/rc 25
```
*Commands all bots to break engagement and sprint away from danger.*

#### ⚔️ Focus Attack RTI Skull
```text
/rc 112
```
*Directs all bot damage onto the Raid Target Icon (RTI) marked target.*

---

## Comprehensive Command Manual

For the complete reference covering all 182 actions, command IDs, dispatch scopes (`SAY`, `WHISPER`, `PARTY`, `TARGET`), and engine syntax, consult the tactical guide:

📖 [**Retinue Commands & Tactical Manual**](docs/COMMANDS_GUIDE.md)

---

## Compatibility

- **Turtle WoW Classic+ (1.18.1)**: Full compatibility with extended item queries (`GetItemInfo`), custom zones, and native engine features.
- **Vanilla WoW (1.12.1)**: Pure Lua 5.0 compliance (`table.getn`, `math.mod`, global frame event handling).
- **TortoiseBots Subsystem**: Native support for modern `TBM:` protocol lines (`TBM:ROSTER_BEGIN`, `TBM:ROSTER`, `TBM:ROSTER_END`, `TBM:ALTBOTS`) and legacy `mangosbot` syntax (`.bot list`, `.bot add`, `.bot remove`).

---

## License & Credits

- Licensed under [GPL v2](LICENSE).
- Originally based on concepts from the 3.3.5 addon *UnBot*.
- Re-architected, optimized, and maintained for **Turtle WoW** and the **TortoiseBots** engine.
