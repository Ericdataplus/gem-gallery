# Notes for AI coding agents

Read this before changing the project. It explains how the gallery is built and
the few rules that keep it fast.

## What this is

A first-person, walkable museum of gems, minerals and treasures, built in **Godot 4.7**
(Forward+, Vulkan) with GDScript only. Every model and material is procedural: there
are no imported meshes or textures.

## Run it

| Task | Command |
|---|---|
| Set up and play (first time bakes the halls) | `powershell -ExecutionPolicy Bypass -File setup.ps1` (Windows) or `./setup.sh` |
| Play | `godot --path .` |
| Re-bake after changing content | `godot --path . res://bake/bake.tscn` |
| Re-bake one hall | `BAKE_ONLY=treasury godot --path . res://bake/bake.tscn` |
| Check renders | `GALLERY_SHOT=1 GALLERY_ONLY=t_isc,c_ godot --path .`, which writes `images/<shot>.png` and quits |
| Startup timings | `GALLERY_PROFILE=1 godot --path .` |
| Build the shareable Windows zip | `powershell -File tools/package.ps1` |
| Syntax-check a script | `godot --headless --path . --check-only --script res://path/file.gd` |

The bake needs a real window, not `--headless`, because mesh data lives on the GPU side.
After creating a new `class_name` script, run `godot --headless --path . --import` once.
Until you do, the class is unknown and the game window hangs on a parse error.

## Architecture

```
content/   procedural library (bake-time; also used by the gem inspector)
halls/     halls.gd  - floor plan: one recipe per hall + its check-render shots
bake/      bake.tscn - runs every recipe -> baked/<hall>.scn + baked/manifest.res
core/      runtime   - main, loading screen, environment, player, HUD,
                       hall streamer, gem inspector, spinner, screenshot harness
tools/     diagnostics + package.ps1
```

- **Nothing is generated at runtime.** Recipes draw into a `HallBuilder` (`content/hall_builder.gd`), which is packed into a scene. Content changes need a re-bake.
- **Streaming.** `core/hall_streamer.gd` loads only the spawn hall behind the loading screen. Other halls load and instance on worker threads within 40 m of the player and are freed beyond 70 m.
- **Moving pieces.** `content/turntable.gd` marks display pieces at bake time (group `turntable`, meta `spin_speed`, optional `spin_swing`). `core/spinner.gd` turns them at runtime: free-standing pieces spin, boards and busts sway.
- **Gems** are ray-traced inside their own facets (`GemFactory` faceted shader + `GemCuts` facet planes): real IOR, per-channel dispersion, total internal reflection and Beer-Lambert colour.

## Rules that keep it fast and correct

1. **Keep the number of distinct shaders small.** Godot 4.7 recompiles every material shader on every launch, at roughly 0.3–0.5 s each. Add a new look as a `kind` branch in an existing uber shader (`ShopStones`, `RockShaders.uber_shader`), not a new `Shader`.
2. **Colour shader parameters must be `Color`, not `Vector3`.** A `source_color` uniform set from a `Vector3` works live but is dropped when the hall is baked.
3. **Moving pieces don't cast shadows** (`Turntable.mark` turns them off). A moving caster makes every nearby shadowed spotlight redraw its shadow map each frame. Floor specimens keep theirs, because sun shadows redraw every frame anyway.
4. **Small props get visibility ranges at bake time** (`HallBuilder.finalize`). Don't remove that.
5. **Verify with targeted renders.** Render only the shots you changed with `GALLERY_ONLY`, and look at the images before saying something works.
6. Use GDScript static typing carefully. `var x := <Variant>` is a parse error, for example when indexing an untyped array. Annotate the type instead.

## Adding a piece

1. Add the builder function to the right content file, for example `content/collector_wing.gd`. Add its entry to that file's `PIECES` list: key, title, subtitle, note, and a plinth `Vector3(width, top, depth)`.
2. If it's a board or box whose back is plain, add its key to that file's `FLAT` list. It will then sway instead of turning.
3. Re-bake that hall (`BAKE_ONLY=collector`), then render its shot (`GALLERY_ONLY=c_<key>`).
