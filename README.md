# Gem Gallery

A walkable, first-person void gallery of real-world gems and treasures: raw mineral
specimens, every classic cut, a treasure heap, collector displays, the legendary gems,
Egyptian and Maya replicas, the Royal Treasury and the Collector's Wing.

Rebuilt from the gallery in `../greek-temple` so it starts fast. The previous version
is preserved in that repo at commit `415d7ae`.

## Run

```
godot --path . --screen 1
```

WASD walk Â· Shift run Â· Space jump Â· mouse look Â· E pick up a gem Â· F labels Â·
Esc/Tab free the mouse (click to recapture) Â· Q quit.

## How it is built

Nothing is generated when the game starts. Content is **baked** once into ready-made
scenes, and the game **streams** them in around the player.

| Folder | What it holds |
|---|---|
| `content/` | The procedural content library: gem cuts and the ray-traced gem shader, minerals, polished stones, displays, legendary gems, ancient pieces, treasury and collector pieces. Runs only at bake time (and for the gem you pick up). |
| `halls/halls.gd` | The floor plan: one recipe per hall, plus that hall's check-render camera spots. |
| `bake/` | `bake.tscn` runs every recipe and writes `baked/<hall>.scn` and `baked/manifest.res`. |
| `core/` | The runtime: loading screen, environment, player, HUD, gem inspector, hall streamer and screenshot harness. |
| `tools/` | Diagnostics: per-hall load timing and per-shader compile cost. |

### After changing content

Re-bake (needs a real window, not `--headless`):

```
godot --path . res://bake/bake.tscn --screen 1
```

`BAKE_ONLY=treasury,collector` re-bakes only those halls. Generated meshes are also cached
in `user://mesh_cache/`, so re-bakes are quick.

### Check renders

```
GALLERY_SHOT=1 GALLERY_ONLY=t_isc,c_ godot --path . --screen 1
```

Shots are defined per hall in `halls/halls.gd`; only the halls those shots need are loaded.
Images land in `images/`. `GALLERY_PROFILE=1` prints startup and streaming timings.

## Sharing it

`powershell -File tools/package.ps1` builds `dist/GemGallery.zip` (about 113 MB). It holds the Godot runtime renamed to `GemGallery.exe`, the gallery pack and a readme for the player (`tools/friend_README.txt`). Unzip it and double-click. No Godot install or export templates needed.

## Performance notes

- **Startup** loads only the hall you spawn in. The rest stream in on worker threads,
  within 40 m of the player, and are freed beyond 70 m.
- **Godot 4.7 recompiles every material shader on every launch**, at roughly 0.3â€“0.5 s
  for a heavy procedural one. The disk shader cache does not help here. Keep the
  number of distinct shaders small: the rock species share one shader
  (`RockShaders.uber_shader`), and polished stones share `ShopStones`.
- Small props get visibility ranges at bake time, and spotlights fade with distance.
