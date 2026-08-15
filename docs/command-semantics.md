# Warband / mangosbot command semantics

Source inspected: `Shyalya/tortoise-wow`, exact deployed commit **`a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f`**. Core links below are commit-pinned primary-source links.

## Live deployment verification

Read-only verification on the deployment found that `/opt/tortoise-docker/Dockerfile` sets `SOURCE_REPO=https://github.com/Shyalya/tortoise-wow.git` and `SOURCE_REF=playerbots-integration-gh`. The running `mangosd` container's `/opt/turtle/SOURCE_COMMIT` contains `a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f`. No hostnames, addresses, or other private deployment details are recorded here.

This is a re-trace of all four topics against that exact commit, replacing the earlier branch-head trace at `e1f229f902001f697e0d56f2ddbb28e01c5b4c28`. **Conclusion changes: none.** The relevant dispatch, trigger, action, reset, and strategy files are identical between those commits. Later differences in `PlayerbotMgr.cpp` and `RandomPlayerbotMgr.cpp` are outside the traced handlers (bot-creation cache/grouping and auction locking); deployed-commit line citations are used below.

## 1. `attack` versus `d attack my target`

Warband sends bare `attack` to PARTY for its hostile-target attack buttons, while its newer action button sends `d attack my target` to PARTY ([`Data.lua:32-37,91-92`](../Data.lua), [`Data.lua:119-125`](../Data.lua)).

They converge on the same `AttackMyTargetAction`, but by different dispatch paths:

* Bare `attack` is queued as a normal chat command and parsed later; the `attack` chat trigger schedules action `attack my target` ([`PlayerbotAI.cpp:1186-1210`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/PlayerbotAI.cpp#L1186-L1210), [`ChatCommandHandlerStrategy.cpp:199-202`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/generic/ChatCommandHandlerStrategy.cpp#L199-L202)).
* A `d ` / `do ` prefix bypasses that trigger route and immediately calls `DoSpecificAction` with the remainder, here `attack my target` ([`PlayerbotAI.cpp:1546-1551`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/PlayerbotAI.cpp#L1546-L1551)). The action name is registered directly to `AttackMyTargetAction` ([`ChatActionContext.h:135`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/actions/ChatActionContext.h#L135)).

The action uses the command sender/requester's current selection, attacks it if valid, and records it as the AI `attack target`; heal-only bots reject it unless they have `offdps` ([`AttackAction.cpp:23-75,99-102`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/actions/AttackAction.cpp#L23-L102)). Thus the semantic target is the same; the proven difference is queued trigger execution versus immediate named-action execution.

PARTY chat is dispatched to owned bots and matching random bots ([`HostHooks.cpp:135-139`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/HostHooks.cpp#L135-L139)); each bot still applies command security before dispatch ([`PlayerbotAI.cpp:1535-1537`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/PlayerbotAI.cpp#L1535-L1537)).

## 2. `drink` versus `d food`

Warband sends both party-wide: command 81 is bare `drink`; command 99 is `d food` ([`Data.lua:79-81,99-100`](../Data.lua), [`Data.lua:127-130`](../Data.lua)). These are not synonyms in source:

* `d food` directly resolves action `food` to `EatAction` ([`PlayerbotAI.cpp:1546-1551`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/PlayerbotAI.cpp#L1546-L1551), [`ActionContext.h:126-127`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/actions/ActionContext.h#L126-L127)). `EatAction` refuses combat and performs food use subject to its action conditions ([`UseItemAction.h:728-755`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/actions/UseItemAction.h#L728-L755)).
* `DrinkAction` is a separate action: it refuses combat, requires a mana-using bot, and checks `should drink` ([`UseItemAction.h:648-726`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/actions/UseItemAction.h#L648-L726)). The normal food strategy schedules `drink` on `high mana` and `food` on `low health` ([`UseFoodStrategy.cpp:7-16`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/generic/UseFoodStrategy.cpp#L7-L16)).

**Unproven / important:** no normal chat trigger named `drink` is registered in `ChatCommandHandlerStrategy`'s supported command list ([`ChatCommandHandlerStrategy.cpp:25-116`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/generic/ChatCommandHandlerStrategy.cpp#L25-L116)). The parser only dispatches commands for which a trigger exists ([`ExternalEventHelper.h:13-45,63-80`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/ExternalEventHelper.h#L13-L80)). Therefore this source does not prove that bare `drink` invokes `DrinkAction`; the traced registrations instead indicate it is unhandled. This note does not claim runtime behavior beyond that source trace.

Do not confuse either chat form with `.bot food` / `.bot drink`: those manager commands both call `HandleBotFoodDrink`, which *adds* food through `PlayerbotFactory::AddFood` rather than consuming it ([`PlayerbotMgr.cpp:257-258`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/PlayerbotMgr.cpp#L257-L258), [`PlayerbotMgr.cpp:2930-2937`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/PlayerbotMgr.cpp#L2930-L2937)). The same handler is registered in the random-bot manager command surface, so that distinction applies to both `.bot` and `.rndbot` forms; it is separate from PARTY chat.

## 3. `reset botAI` versus `reset`

Warband sends `reset botAI` party-wide for command 9 and by whisper for selected command 10; command 85 sends bare `reset` party-wide ([`Data.lua:16-17,83`](../Data.lua), [`Data.lua:117-130`](../Data.lua)).

Bare `reset` has an exact special case before normal chat-command queuing and calls `PlayerbotAI::Reset(true)` ([`PlayerbotAI.cpp:1580-1583`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/PlayerbotAI.cpp#L1580-L1583)). That resets current state to non-combat, reaction state, transient targets/selection/travel/movement/spell state, and reinitializes engines; it does **not** rebuild strategy defaults or erase persisted AI values ([`PlayerbotAI.cpp:1345-1449`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/PlayerbotAI.cpp#L1345-L1449)).

`reset botAI` does not match that exact special case. Normal parsing tries `reset botAI` and then command `reset` with parameter `botAI`, but no `reset` chat trigger is registered; the registered full AI command is spelled **`reset ai`** ([`ExternalEventHelper.h:13-45`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/ExternalEventHelper.h#L13-L45), [`ChatCommandHandlerStrategy.cpp:53-58`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/generic/ChatCommandHandlerStrategy.cpp#L53-L58), [`ChatActionContext.h:140-146`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/actions/ChatActionContext.h#L140-L146)). On this source trace, `reset botAI` is unhandled.

For comparison, `reset ai` resets persisted AI values and default strategies, deletes saved values, and saves the reset strategy set ([`ResetAiAction.cpp:10-50`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/actions/ResetAiAction.cpp#L10-L50)). Random/world-bot console `reset` is a third, unrelated operation: it resets **all random bots and the event cache** ([`RandomPlayerbotMgr.cpp:3624-3628`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/RandomPlayerbotMgr.cpp#L3624-L3628), [`RandomPlayerbotMgr.cpp:4530`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/RandomPlayerbotMgr.cpp#L4530)).

## 4. `co`, selected AI status, and Warband's Strategy window

Server command `co` is the combat-strategy change action. Its action only prints status when its parameter contains `?`; the actual print format is `Combat Strategies: ` followed by `Engine::ListStrategies()` ([`ChangeStrategyAction.cpp:8-43`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/actions/ChangeStrategyAction.cpp#L8-L43), [`Engine.cpp:875-882`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/Engine.cpp#L875-L882)). Consequently, the proven status request is `co ?`, not bare `co`.

Warband labels commands 62/63 as party/selected AI status but sends bare `co` (PARTY / selected-bot WHISPER) ([`Data.lua:59-60`](../Data.lua), [`Data.lua:125`](../Data.lua)). It has no parser for `Combat Strategies:` replies: its only strategy-related whisper parser accepts help links containing `Hvalue:help:strategy:` and stores names ([`Core.lua:447-486`](../Core.lua)). Thus the selected AI-status button neither requests the server's proven printable form (`co ?`) nor parses its output into UI state.

The Strategy window is different. On open it:

1. whispers a generated `value:help:list:<class> strategy` hyperlink if names for that class are not cached;
2. harvests `Hvalue:help:strategy:<name>` links from whisper replies;
3. whispers bare `co` or `nc`; and
4. sends `co +name` / `co -name` (or `nc ...`) when the user clicks rows ([`Strategy.lua:271-300,503-509`](../Strategy.lua), [`Core.lua:447-486`](../Core.lua)).

The `+`/`-` mutations match the core's `ChangeCombatStrategyAction` and persistence path ([`ChangeStrategyAction.cpp:8-35`](https://github.com/Shyalya/tortoise-wow/blob/a1f3f4e3e63c88e491f22ae5cb76b5c51d2f9c5f/src/modules/PlayerBots/playerbot/strategy/actions/ChangeStrategyAction.cpp#L8-L35)). However, the window does not parse the active strategy list and therefore cannot prove/display which strategies are currently active; it is a cached help-name browser plus mutation sender. Bare `co` on window open also does not request printable status according to the traced handler.
