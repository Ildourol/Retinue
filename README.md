# Warband

A bot command panel for servers running
[mangosbot](https://github.com/ike3/mangosbot-bots).

Developed and tested against **Turtle WoW 1.18.1**, whose client is built on
**1.12 (Vanilla)**. It targets interface 11200 and uses only Vanilla APIs, so
it should work on other 1.12 servers too — with one caveat, see
[Client differences](#client-differences).

Control your own account characters as bots: bring them online, invite them,
inspect their bags, cast their spells and switch their combat strategies —
without typing chat commands.

![command bar](screens/bar.png)

## Features

**Command bar** — ten labelled command-group buttons plus role shortcuts. Click
any group to open one movable window of compact icon-and-label command
buttons. Selecting another group reuses that same window. Right-click a
command to toggle it in the Favorites strip above the bar; removing requires
confirmation, and the strip has a separate Clear button for clearing everything.
Overflow opens the complete Favorites list. The windows contain the same commands that were
previously hidden in icon-only right-click popups, so no command is lost. A minimap button
shows or hides the entire panel.

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

## Client differences

**Item icons are the one Turtle-specific part.** Turtle's `GetItemInfo`
returns ten values with the texture in slot 9; stock 1.12 returns eight and no
texture at all. On a plain 1.12 server the bag window therefore falls back to
[AtlasLoot](https://github.com/AtlasLootClassic)'s id → icon table when that
addon is installed, and to a generic icon otherwise. Names, tooltips and every
action keep working either way, because they come from the chat link rather
than the client's item cache.

Other things that differ from later expansions, all handled in the code and
commented where it matters:

- script handlers get no arguments — the globals `this`, `event` and `arg1`
  are used instead
- no `#` operator, no `string.match`, no varargs
- `InviteByName` and `UninviteByName`, not the later `InviteUnit` variants
- `UnitInParty` raises an error on a name that is not a nearby unit, so group
  membership is checked by walking the party and raid slots
- `GameTooltip:SetHyperlink` wants a bare `item:id:0:0:0`, not a full chat link
- bot actions need a `d` prefix (`d add all loot`), plain commands do not

## Server differences

Command availability varies between mangosbot builds. On Turtle 1.18.1 only
`.bot add`, `.bot remove`, `.bot list` and `.bot init=<quality>` exist —
`refresh`, `levelup` and `random` do not, and `.appear` is GM-only. Strategy
names are never hardcoded: the addon reads them from the bot's own in-game
help, so they always match whatever server you are on.

## Credits

Rewritten from the ground up for 1.12, based on the 3.3.5 addon **UnBot**.
The command ids, groupings and chat protocol come from that addon; none of its
code is included here.
