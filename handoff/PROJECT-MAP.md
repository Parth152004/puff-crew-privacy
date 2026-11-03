# Project map

Godot 4.7.2 / GDScript / GL Compatibility. Entry: `puff-crew/main.tscn`, with `scripts/game.gd` orchestrating the session. Geometry, materials, UI and effects are built in code; there is no missing Blender project or proprietary character asset pack.

| Path under puff-crew | Responsibility |
| --- | --- |
| `scripts/game.gd` | 60 Hz simulation, course/session lifecycle, checkpoints, best times, persistence, host-authoritative ENet |
| `scripts/hud.gd` | Landscape menus/lobby/results, touch joystick + puff ownership, pause, settings, outfit UI |
| `scripts/course.gd` | Three course definitions, original islands/scenery, hazards, scenery batching |
| `scripts/raft.gd` | Raft, crew appearance/outfits and character animation |
| `scripts/visuals.gd` | Original procedural meshes/material helpers |
| `shaders/water.gdshader` | Flowing water, caustics, depth/color/foam styling |
| `scripts/audio.gd`, `assets/audio/` | Audio playback and included original WAVs; generator under top-level tools |
| `scripts/release_info.gd` | Public version/publisher/support/privacy strings |
| `scripts/store.gd` | Staged purchase/restore/acknowledgement and local entitlement cache |
| `addons/GodotGooglePlayBilling/` | First-party MIT plugin 3.3.0; custom debug-export exclusion; bundled debug/release AARs |
| `scripts/android_qa.gd` | Debug-only instrumentation; excluded from Google Play preset |
| `tests/` | Behavior, full-course, fake-billing and renderer-capture scripts; excluded from exports |
| `assets/` | Original SVG/PNG icon, fonts, audio and full third-party notices |

Host snapshots run at 20 Hz, bounded player inputs at approximately 30 Hz; clients interpolate raft presentation. Appearance choices sync across LAN; purchase tokens do not. Ports: UDP 28970 (game) and 28971 (discovery).

Local data lives in Godot `user://puff_crew.cfg` (settings/times/outfit) and `user://purchases.cfg` (staged entitlement cache). No company server/database is needed. New monetization/SDK additions require revisiting privacy and data disclosures.

Generated folders `.godot/` and `android/build/` are intentionally omitted and regenerate locally. Keep `.gd.uid` and included `.import` sidecars. The source archive contains the plugin AARs and all runtime content, but not Godot templates, Android SDK/NDK, JDK or Gradle caches. No paid asset/runtime service is required to run the current game.

Read `puff-crew/docs/THIRD-PARTY.md`, `assets/FONT-LICENSE.txt`, `assets/GODOT-LICENSE.txt`, `assets/GODOT-THIRD-PARTY.txt` and plugin `LICENSE` before shipping. Original project content is private; handoff does not impose an open-source license.
