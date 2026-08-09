# Warband

A bot command panel for **WoW 1.12 (Vanilla)** servers running
[mangosbot](https://github.com/ike3/mangosbot-bots).

Control your own account characters as bots: bring them online, invite them,
inspect their bags, cast their spells and switch their combat strategies —
without typing chat commands.

![command bar](screens/bar.png)

## Features

**Command bar** — ten grouped buttons plus role shortcuts. Right-click a group
to open its popup, right-click an entry there to move it onto the bar. Your
layout is saved.

**Roster** — reads `.bot list` straight from the server, so your characters
appear with the correct class automatically. Filter by class, then:

- *Fill group* — logs in and invites until the party is full
- *Fill raid* — same for a raid, converting the party when it runs out of room
- Left-click a name to log that one in and invite it

**Bags** — the bot's inventory as an icon grid with quality borders and full
tooltips. Tabs for Equip, Use, Sell and Destroy, each filtered to the item
types that action can handle.

**Spells** — grouped by type (auras, blessings, shouts, aspects, seals…) with
a buffs-only filter, since that is usually what you want to trigger by hand.

**Strategies** — the bot's own strategy list, read from its in-game help, so
the names always match your server. Collapsible sections, combat and
non-combat sets.

**Role shortcuts** — one button per class. Left-click sets its primary role
(tank/heal), right-click the secondary (dps), applied to every bot of that
class in the group at once.

## Installation

Copy the `Warband` folder into `Interface\AddOns\` and restart the client.

## Usage

`/warband` shows or hides the bar. Everything else has a button; these
shortcuts open the same windows:

| Command | Opens |
| --- | --- |
| `/warband roster` | your account bots |
| `/warband strategy` | strategy editor for your target |
| `/warband spells` | spell list for your target |
| `/warband bags` | inventory of your target |
| `/warband fill` | fill the party |

Diagnostics: `/warband debug`, `/warband checkapi`, `/warband capture`.

## Notes on 1.12

Several things work differently here than on later clients, and the code is
commented where it matters:

- script handlers get no arguments — the globals `this`, `event` and `arg1`
  are used instead
- no `#` operator, no `string.match`, no varargs
- `InviteByName` and `UninviteByName`, not the later `InviteUnit` variants
- `UnitInParty` raises an error on a name that is not a nearby unit, so group
  membership is checked by walking the party and raid slots
- bot actions need a `d` prefix (`d add all loot`), plain commands do not

## Credits

Rewritten from the ground up for 1.12, based on the 3.3.5 addon **UnBot**.
The command ids, groupings and chat protocol come from that addon; none of its
code is included here.
