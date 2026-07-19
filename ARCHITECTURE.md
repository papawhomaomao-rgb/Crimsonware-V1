# Crimsonware — architecture & gotchas

A map of how the script loads and the three ways a careless edit (or a fork)
silently breaks it. If you read one thing before touching this repo, read the
**Gotchas** section — every bug fixed on 2026-07-19 was one of them.

## Load order

Everything hangs off this sequence. Each stage assumes the previous one already
ran, so **order is a contract**, not a detail.

```
init.lua            entry point. Downloads files from GitHub at a pinned commit,
                    handles versioning, then runs main.lua.
  └─ main.lua       Waits for the game to load. Prompts for a GUI (or honors a
                    forced/ saved choice), loads guis/<gui>.lua → returns `vape`.
                    Then, in order:
       ├─ guis/<gui>.lua      The UI framework: categories, the module registry,
       │                      option components, notifications, config save/load,
       │                      and the STATIC half of vape.Libraries.
       ├─ games/universal.lua Core libraries + game-agnostic modules + shared
       │                      helpers. Registers the DYNAMIC half of vape.Libraries.
       ├─ games/<PlaceId>.lua Per-game modules (e.g. 6872274481 = BedWars).
       │                      CONSUMES vape.Libraries / vape.Modules / remotes.
       └─ libraries/premium.lua
```

GUIs: `new` (default), `classic` (crimson theme), `old`, `rise`. The picker in
`main.lua` offers `new` and `classic`.

## The registries

Three shared tables on `vape` are how the stages talk to each other. All three
are keyed by **string names**, and all three are populated by earlier stages and
read by later ones.

| Registry          | Written by                                   | Read by            |
|-------------------|----------------------------------------------|--------------------|
| `vape.Libraries`  | GUI static table + `universal.lua` + GUI     | game files, universal |
| `vape.Modules`    | every `:CreateModule{ Name = … }`            | modules cross-referencing each other |
| `vape.Categories` | GUI `CreateCategory` / `CreateCategoryList`  | game files (`vape.Categories.Blatant:CreateModule…`) |

### vape.Libraries — the part that keeps breaking

Game files pull their dependencies off this table at the top, e.g.
`local entitylib = vape.Libraries.entity`. If a key isn't registered **before**
the game file runs, it's `nil` and the first use throws.

- **Static half** (in the GUI, e.g. `guis/classic.lua`): `color`,
  `getcustomasset`, `getfontsize`, `tween`, `uipallet`, and later `targetinfo`.
- **Dynamic half** (in `games/universal.lua`): `entity`, `whitelist`,
  `prediction`, `hash`, `string`, `calculatePosition`, `auraanims`,
  `sessioninfo`.

> If a game file references `vape.Libraries.X`, **X must be registered above.**
> `tools/luau_check.py` enforces this.

## Gotchas (read this)

**1. A module's `Name` is its identity — three ways at once.**
`Name` is the display label **and** the `vape.Modules[Name]` key **and** the
config-save key. So renaming a module:
- resets everyone's saved settings for it (config is keyed by the old name), and
- breaks any `vape.Modules['OldName']` reference elsewhere → nil-crash.

Before renaming, grep for `'OldName'` across `games/` and `guis/`. If saved
settings must survive, add an alias in the GUI's config `Load` path.

**2. Don't drop a library registration.**
This is what a fork does by accident. If you move/rename/remove something in
`universal.lua`'s registration block, every game file that reads it starts
nil-crashing mid-game — not at load, so it looks like "the feature just stopped
working." (2026-07-19: `calculatePosition` and `string` were both missing this
way; Killaura swung but dealt no damage because its attack packet threw.)

**3. A module loop that errors dies silently.**
Each module's `Function` runs in its own thread. An error after the first
`task.wait()` just kills that thread — the toggle still shows ON. The GUIs now
wrap the invocation and pop a `crashed — <error>` notification, but the loop is
still dead until re-toggled. Nil-guard optional cross-module refs (see
`vape.Modules['Silent Aura']` in the BedWars file for the pattern).

## Before you push

```
python3 tools/luau_check.py
```

Parses every `.lua` with the real Luau grammar and sweeps for unregistered
`vape.Libraries` / unresolved `vape.Modules` references. CI
(`.github/workflows/checks.yml`) runs the same thing on every push and PR, so a
dropped reference fails the build instead of reaching players mid-match.
Deps: `pip install tree-sitter tree_sitter_luau`.

## Directory layout

```
init.lua            bootstrap / downloader / versioning
main.lua            GUI picker + load orchestration
guis/               UI frameworks (new, classic, old, rise)
games/              universal.lua + per-PlaceId module sets
libraries/          entity, prediction, hash, string, drawing, …
assets/             per-GUI image assets
profiles/           saved config, commit pin
tools/luau_check.py static checks (run before pushing)
```
