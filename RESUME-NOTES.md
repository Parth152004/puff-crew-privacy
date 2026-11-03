# Puff Crew: Rapids — current handoff, 18 October 2026

The owner explicitly stopped publishing preparation and asked to focus on game improvements. **Do not upload, submit or publish.** Publishing will be handled from another PC later. No live account, listing, product or release was changed here.

Current game: **0.2.0** playtest, Ramo Labs branding. Support contact supplied by owner: jayvekaria282@gmail.com. Owner confirmed intended audience 13+ and personal Play account created after 13 November 2023.

## Current deliverables

- `builds/Puff-Crew-0.2.0-Playtest.apk`: latest debug-signed ARM64 Android build. All outfits available; native billing SDK/dependencies, billing permission and checkout UI excluded.
- `builds/Puff-Crew-0.2.0-Source.zip`: editable sources, helper scripts and selected validation evidence.
- `builds/Puff-Crew-0.2.0-Gameplay.mp4`: actual automated renderer capture with the improved water and whirlpool.
- `puff-crew/docs/PLAYTEST-0.2.0.md`: exact changes and verification scope.

Changes: flowing water/caustics/shoreline foam; cleaned raft self-shadow artifacts; cullable scenery batches; blink/arm/scarf animation; three hats and matching scarves with LAN sync; graphics/haptic settings usable from pause; spiral whirlpool; result confetti; privacy, support, credits and full scrollable bundled notices.

Validation: 25/25 behavior checks, all three complete course runs, four desktop network processes, Android solo touch/UI including free outfit equip, two actual Android APK emulators with discovery and distinct host/client outfits. Emulator samples 50–60 FPS; physical phones/router/battery/thermal testing remains outstanding. Native payment SDK absence and APK signature/CRC verified. Staged purchase state-machine tests passed 16/16 with a fake adapter; no live purchases tested or enabled in playtest.

`release/STATUS.md` marks earlier publishing preparation as paused/superseded. An earlier signed AAB in `builds/release/` is NOT the current game; do not upload it. Private upload-key material created during preparation lives outside the workspace in `~/Library/Application Support/Ramo Labs/Puff Crew/signing`; it was never included in source archives. No credentials are recorded here.

Use `./tools/build_android.sh` to reproduce the playtest. QA runners accept PUFF_QA_APK and PUFF_QA_OUTPUT. The matching Android Gradle template/cache is generated locally and excluded from source ZIPs.

All temporary test hosts, emulators, ADB and Gradle daemons are stopped at handoff. No web server or recurring automation was created.

## Complete developer package — 18 October 2026

`builds/Puff-Crew-Developer-Handoff-2026-10-18.zip` adds the current APK/video, release drafts/assets, build/signing/release guides and per-file integrity manifest to the editable source. Start at its root `START-HERE.md`. No current AAB, private key or password is included. Nothing was published and no game server/emulator was started for packaging.

Packaging helper changes only: release helper now uses portable tool/signing paths, restores an adjacent key when an old-PC path is stale, installs the matching template via Godot and rejects mismatched release identity before building. `--check` deliberately fails on the current 0.2.0/1.0.0 mismatch. QA scripts default to the current playtest; Android pair helper accepts host/client serial arguments. Game source/assets and APK/video were unchanged. These helper changes received syntax/preflight checks, not a new Android/release export. Complete remaining tasks are in `handoff/`.
