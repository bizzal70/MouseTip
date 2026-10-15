# MouseTip

Shows tooltips at the mouse cursor instead of the corner of the screen. An addon for World of Warcraft: Forever (client 1.60.x).

## What it does

World of Warcraft puts the tooltip for anything in the world (a creature, a player, a mailbox) in the bottom-right corner of the screen. MouseTip shows it at your mouse cursor instead.

Tooltips for buttons, bag items and spells already appear beside what you point at, and are left alone.

## Options

Type `/mousetip` to open the options, or use the addon's entry in the minimap's addon list.

| Setting | What it does | Command |
|---|---|---|
| Show tooltips at the mouse | Turns the addon on or off | `/mousetip on`, `off`, `toggle` |
| In combat too | Whether tooltips also follow the mouse during combat | `/mousetip combat` |
| Position | Above, to the right of, or to the left of the cursor | `/mousetip above`, `right`, `left` |

## Known limits

- During combat the game restricts what addons may do. If it refuses to move a tooltip, the tooltip stays where the game put it.

## More from this author

Other small addons for World of Warcraft: Forever, all free:

- **[GatherTrail](https://github.com/bizzal70/GatherTrail)** remembers ore, herbs, fishing pools, skinning spots, chests and rares across all your characters, and guides you back to the best spots.
- **[RangeShade](https://www.curseforge.com/wow/addons/rangeshade)** shades action buttons red when your target is out of range.
- **[VendorMate](https://github.com/bizzal70/VendorMate)** sells junk and repairs at vendors, and warns when your gear is wearing out.
- **[AltBoard](https://github.com/bizzal70/AltBoard)** shows all your characters at a glance: level, gold, rested and where you left them.

## Installing

Copy this folder into `World of Warcraft\_classic_beta_\Interface\AddOns\` as `MouseTip`, restart the game, and enable MouseTip on the character select screen.

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
