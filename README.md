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
- **10 Categorized Action Groups**: Access 182 native companion commands (Combat, Movement, Spacing, Formations, Stances, RTI Targets, Utility, Gearing, and Maintenance).
- **Zero Frame Clutter**: Clicking any category opens a dedicated modal; selecting another group cleanly reuses the window without stacking multiple frames on your screen.

### ⭐ Persistent 10-Slot Quick Favorites
- Pin your most-used commands directly to the top row of the Retinue bar.
- **Right-Click** any button across any modal to pin/unpin it with a visual star (`*`).
- **Expanded Drawer (`>`)**: Supports unlimited favorited actions with mouse-wheel scrolling.

### 👥 Interactive Player Roster & Deployment
- **Dual Server Discovery**: Seamlessly queries account alts via structured TBM protocol (`.bot roster`) and active world instances (`.bot list`).
- **Live Search & Filter**: Real-time substring search with instant `+ Add "<Name>"` fallback for unregistered bots.
- **`+ Target` Fast Add**: One-click addition of friendly players or bots to your persistent roster cache.
- **One-Click Group Fill**: Automatically fill free slots in 5-man parties (`Fill group`) or 40-man raids (`Fill raid`) from filtered candidates.
- **Automated Raid Conversion**: Automatically converts parties to raids when inviting 6+ members.
- **Quiet Sync Architecture**: Server roster updates process silently in the background without polluting chat with repeated sync alerts.

### 🧠 Dynamic Strategy & Behavior Editor
- Queries live AI strategies supported directly by the targeted bot from the server engine.
- Supports native TortoiseBots strategy operators:
  - `+` (Enable / Add strategy)
  - `-` (Disable / Remove strategy)
  - `~` (Toggle active state with a single click)
- Dedicated archetype tabs for all 9 classes (Warrior, Paladin, Hunter, Rogue, Priest, Shaman, Mage, Warlock, Druid).

### 🎒 Remote Inventory & Bag Management
- Inspect all 16 backpack slots and 4 bag containers for the selected bot.
- Interactive action modes:
  - **View**: Inspect items with authentic item quality borders and tooltips.
  - **Equip**: Force the bot to equip selected gear.
  - **Use**: Direct the bot to consume food, drinks, bandages, or potions.
  - **Sell**: Flag junk and inventory items for vendor sale.
  - **Destroy**: Purge unwanted items from bot bags.
  - **Catalog Shortcut**: Jump directly into the 26k+ Item Catalog & Spawner with one click.

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
- Browse abilities known by the targeted companion.
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
| **Command Bar** | `/retinue` or `/ret` | Main tactical control bar with 10 command groups |
| **Player Roster** | `/ret roster` | View alts, invite/uninvite bots, fill party/raid, search bots |
| **Strategy Editor** | `/ret strategy` | View and toggle AI combat and non-combat strategies |
| **Spellbook** | `/ret spells` | Inspect bot spells and toggle casting blacklists |
| **Bags & Items** | `/ret bags` | Inspect bot inventory, force equip gear, use consumables, vendor items |
| **Role Bar** | Role Button on bar | Rapidly set Tank, Healer, and DPS presets across all party bots |
| **Item Catalog** | `/ret catalog` or bar | Browse 26,542 items, filter by slot/rarity/level, 1-click spawn |

---

## Slash Commands

Retinue provides intuitive, short commands as well as legacy aliases for backwards compatibility:

| Slash Command | Arguments | Description |
|:---|:---|:---|
| `/retinue` or `/ret` or `/rtn` | *none* | Toggle the primary Retinue command bar |
| `/ret roster` | *none* | Open the Player Roster window |
| `/ret sync` | *none* | Manually synchronize roster states with the server |
| `/ret strategy` | *none* | Open the Strategy Editor for your current target |
| `/ret spells` | *none* | Open the remote Spellbook & Buffs panel |
| `/ret bags` | *none* | Open the remote Bag & Inventory inspection grid |
| `/ret catalog` | *none* | Open the 26k+ Item Catalog & Spawner browser |
| `/ret fill` | *none* | Auto-fill open party slots (up to 5) with filtered bots |
| `/ret fillraid` | *none* | Auto-convert to raid and fill open slots (up to 40) |
| `/retcom <id>` or `/rc <id>` | `<id>` | Execute any action ID (1–182) directly via macro |
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
