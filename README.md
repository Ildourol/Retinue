<div align="center">

<img src="screens/banner.jpg" alt="Warband Playerbot Panel Banner" width="100%" />

# Warband

[![Interface](https://img.shields.io/badge/Interface-11200-blue.svg)]()
[![Turtle WoW](https://img.shields.io/badge/Turtle%20WoW-1.18.1-green.svg)](https://turtlecraft.gg/)
[![Target Core](https://img.shields.io/badge/Core-MaNGOS%20%2F%20IKE3%20Playerbots-orange.svg)]()
[![License](https://img.shields.io/badge/License-GPL%20v2-lightgrey.svg)](LICENSE)

An intuitive, graphical command panel for servers running mangosbot / IKE3 Playerbots.

[Overview](#overview) • [Features](#features) • [Installation](#installation) • [Usage](#usage) • [Compatibility](#compatibility) • [Credits](#credits)

</div>

---

## Overview

**Warband** is an in-game control interface built for World of Warcraft client version **1.12.1 (Vanilla)** and **Turtle WoW (1.18.1)**. It provides a visual management panel to control your account characters as bots: bring them online, invite them, inspect their bags, cast their spells, and manage their combat strategies without typing repetitive chat commands.

<div align="center">

<img src="screens/addon.png" alt="Warband in-game panel screenshot" width="90%" />

</div>

---

## Features

- **Command Bar**: Ten categorized group buttons with rapid role shortcuts. Clicking any category opens a dedicated, movable window with compact icon-and-label command buttons. Selecting another category reuses the same window frame to avoid screen clutter.
- **Favorites Strip**: Right-click any command to pin it to the Favorites strip above the primary bar. Removing entries requires confirmation, and a dedicated Clear button resets the strip. Overflow opens the full Favorites index.
- **Minimap Quick-Toggle**: A clean minimap icon to toggle panel visibility with a single click.
- **Roster & Auto-Fill**: Parses `.bot list` directly from the server to list your characters with correct class badges and levels. Filter by class and utilize one-click party (`Fill group`) or raid (`Fill raid`) deployment.
- **Inventory & Bags**: Visual icon grid with full item quality borders and tooltips. Dedicated filter tabs for Equip, Use, Sell, and Destroy operations.
- **Spells & Buffs**: Categorized by spell type (auras, blessings, shouts, aspects, seals) with a dedicated buffs-only filter for manual party preparation.
- **Strategy Management**: Dynamically queries the bot's supported strategies via in-game help, ensuring names match the server core without hardcoding. Includes collapsible sections for combat and non-combat strategy sets.
- **Role Shortcuts**: One-click role assignments per class. Left-click assigns primary roles (Tank / Healer), while right-click assigns secondary roles (DPS) across all matching bots in the group simultaneously.

---

## Installation

1. Download or clone this repository.
2. Copy the `Warband` directory into your World of Warcraft directory under:
   ```text
   Interface\AddOns\Warband
   ```
3. Ensure the folder name inside `AddOns` is named exactly `Warband`.
4. Restart your game client or reload the UI with `/console reloadui`.

---

## Usage

Use `/warband` to toggle the main command bar.

### Shortcut Commands

| Slash Command | Window Opened |
|:---|:---|
| `/warband roster` | Account characters and bot roster |
| `/warband strategy` | Strategy manager for the targeted bot |
| `/warband spells` | Spell and ability manager for the targeted bot |
| `/warband bags` | Inventory and equipment of the targeted bot |
| `/warband fill` | Automatically fill open party slots with available bots |

### Diagnostic Commands

- `/warband debug`: Toggle internal debug output.
- `/warband checkapi`: Audit client API availability.
- `/warband capture`: Capture and inspect server chat packets.

---

## Compatibility

### Client Differences (Turtle WoW 1.18.1 vs Vanilla 1.12.1)

- **Item Textures**: Turtle WoW's `GetItemInfo` API returns 10 values with the texture located in slot 9. Stock 1.12 clients return 8 values without an embedded texture; on stock 1.12 servers, Warband integrates seamlessly with AtlasLoot's icon dictionary or uses fallback icons.
- **Vanilla Script Environment**: Fully compliant with the 1.12 Lua 5.0 environment (uses `this`, `event`, `arg1` globals; avoids post-Vanilla `#` length operators, `string.match`, and varargs).
- **Safe Unit Checks**: Safe group-slot iteration replaces modern unit check methods to prevent disconnection or script errors on distant bots.

### Server Commands

Command availability automatically adjusts to the target server build. On Turtle WoW 1.18.1, the addon leverages `.bot add`, `.bot remove`, `.bot list`, and `.bot init=<quality>`, dynamically discovering strategies to maintain full compatibility.

---

## Credits

- Originally rewritten for 1.12 based on the concepts from the 3.3.5 addon **UnBot**. Command groupings and communication protocols adapted for classic compatibility.
- Maintained for **Turtle WoW Classic+ Extended** and the **mangosbot / IKE3** community.
