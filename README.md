# MouseTip

Shows tooltips at the mouse cursor instead of the corner of the screen. An addon for World of Warcraft: Forever (client 1.60.x).

## What it does

World of Warcraft puts the tooltip for anything in the world (a creature, a player, a mailbox) in the bottom-right corner of the screen. MouseTip shows it at your mouse cursor instead.

Tooltips for buttons, bag items and spells already appear beside what you point at, and are left alone.

## Options

Type `/mousetip` (or `/mtip`) to open the options, or use the addon's entry in the minimap's addon list.

| Setting | What it does | Command |
|---|---|---|
| Show tooltips at the mouse | Turns the addon on or off | `/mousetip on`, `off`, `toggle` |
| In combat too | Whether tooltips also follow the mouse during combat | `/mousetip combat` |
| With a controller: lower right corner | While you play with a controller (no mouse pointer to follow), tooltips go to the lower right corner of the screen; back on the mouse, they follow the cursor again. On by default | `/mousetip pad` |
| Position | Above, to the right of, or to the left of the cursor | `/mousetip above`, `right`, `left` |

## Known limits

- During combat the game restricts what addons may do. If it refuses to move a tooltip, the tooltip stays where the game put it.

## Controller

While you play with a controller, tooltips for things in the world go to the lower right corner of the screen instead of following a mouse pointer that is not there. The moment you use the mouse again they follow the cursor. Turn this off with `/mousetip pad` or in the options.

With a game controller, the **B** button closes the MouseTip options, like the X and Escape do. While a window is open, B closes it; once it is closed, B goes back to whatever you have it set to. When a fight starts, B goes straight back to its usual job, even with the window open.

## More from this author

Other small addons for World of Warcraft: Forever, all free:

- **[GatherLog](https://www.curseforge.com/wow/addons/gatherlog)** remembers ore, herbs, fishing pools, skinning spots, chests and rares across all your characters, and guides you back to the best spots.
- **[RangeShade](https://www.curseforge.com/wow/addons/rangeshade)** shades action buttons red when your target is out of range.
- **[JunkMate](https://www.curseforge.com/wow/addons/junkmate)** sells junk and repairs at vendors, and warns when your gear is wearing out.
- **[AltGlance](https://www.curseforge.com/wow/addons/altglance)** shows all your characters at a glance: level, gold, rested and where you left them.
- **[SwiftQuest](https://www.curseforge.com/wow/addons/swiftquest)** accepts quests and hands them in as soon as you talk to the quest giver, without ever choosing a reward for you.
- **[SessionRecap](https://www.curseforge.com/wow/addons/sessionrecap)** keeps a running tally of your play session: gold, experience per hour, quests, gathering and loot.
- **[MacroKit](https://www.curseforge.com/wow/addons/macrokit)** adds ready-made macros for your class and spec, for all nine classes, and never overwrites your own.
- **[ZoomPad](https://www.curseforge.com/wow/addons/zoompad)** puts big + and - buttons on screen that zoom the camera, made for the Steam Deck touchscreen.
- **[GamepadMacros](https://www.curseforge.com/wow/addons/gamepadmacros)** adds ready-made macros for controller and Steam Deck players: heal yourself, use a quest item, save and wear gear, leave a group, emotes.

## Installing

Copy this folder into `World of Warcraft\_forever_\Interface\AddOns\` as `MouseTip`, restart the game, and enable MouseTip on the character select screen.

## Developing

- `tools\Link-Addon.ps1` links this folder into the game's AddOns folder, so edits are live after `/reload`.
- `python tests/run.py` runs the tests (`pip install lupa` once). They run the addon in real Lua 5.1 against a fake of the game's API.
- `tools\Publish.ps1 -Message "..."` runs the tests and pushes to GitHub. GitHub runs the tests again on every push.

## Releasing

`tools\Publish.ps1 -Message "Release x.y.z" -Tag vx.y.z` publishes and tags. The tag makes GitHub package the addon and attach the zip to a GitHub release.

To also upload to CurseForge and Wago, two things are needed once:

1. Create the project on each site, then add its ID to `MouseTip.toc`:
   `## X-Curse-Project-ID: 123456` and `## X-Wago-ID: abc123`.
2. Create an upload token on each site and add it to this repository's secrets (Settings, Secrets and variables, Actions) as `CF_API_KEY` and `WAGO_API_TOKEN`.

Before each release: raise `## Version:` in `MouseTip.toc` and add the version to `CHANGELOG.md`.

## Licence

MIT. See `LICENSE`.
