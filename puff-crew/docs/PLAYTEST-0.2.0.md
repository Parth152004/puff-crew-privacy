# Puff Crew: Rapids 0.2.0 — 18 October 2026

Publisher branding: **Ramo Labs**. Current focus: improving the game. The owner will handle publishing later from another PC; no listing, product or release was uploaded/submitted/published here.

## Changes you can try

- Water now has broad flowing color, caustic light patterns, animated wave crests and pale shoreline foam.
- The raft hull/rim no longer show the earlier self-shadow artifacts. Static scenery is batched into sections that can be culled separately.
- Characters blink, move their arms while puffing and have gently moving scarves.
- **Crew outfits** lets you preview and wear Classic, Mariner, Sun Seeker and Stargazer. The three new looks have original hats and matching scarves, and replicate to the other crew members.
- All outfits are available in this playtest. There is no checkout UI, billing permission, native payment SDK or payment request in the APK. Future billing code is staged in the source and inactive in the debug playtest.
- Performance/Balanced/High graphics, sound and haptic settings persist locally. Display/sound settings are available while paused.
- Whirlpools now have a visibly rotating spiral instead of concentric rings. Completing an expedition adds animated confetti to the results screen.
- In-game privacy, support contact, credits and a scrollable offline license viewer are available under **Settings & info**.

## Validation

The final playtest APK is version 0.2.0/code 2, ARM64, Android API 24+, target API 36, OpenGL ES 3. It is debug-signed for direct installation and should update the previous debug build without requiring uninstall when the same signing identity was used.

- Behavior suite: **25/25 passed**.
- Automated full-course driver: **3/3 passed**, with the same course outcomes as 0.1.0 (41.7/59.5/56.4 seconds; 0/1/1 splashes). Physics was preserved.
- Four independent desktop ENet processes: **passed**, including host receipt of remote controls and client state replication.
- Android playtest solo touch/UI test: **passed**, including simultaneous aim/puff, independent releases, camera, pause/resume, retry, leave, pending-connection cancellation, quality switching, privacy, credits, license viewer, outfit preview/equip and wearing the selected outfit in solo play.
- Android playtest host + Android client: **passed** on two emulators' shared virtual Wi-Fi. Automatic discovery, ready/launch, both control streams, state snapshots and different host/client outfits were verified.
- Staged purchase state-machine unit tests: **16/16 passed** with a fake adapter. These are not live Google Play purchases. The payment SDK is excluded from this playtest.
- APK archive CRC and signature verified. Manifest/dependency checks confirm the payment permission and SDK are absent; only network and vibration permissions remain.

The emulator counters sampled about **50–60 FPS** during these runs on the host GPU. Those point samples are not a controlled hardware benchmark or proof of physical-phone performance. The two instances compete for the same computer's resources. Logs include emulator shader-cache fallback/recompilation warnings; no game-script crash was observed in the checked paths.

After the Android checks, the whirlpool foam material was made two-sided and unshaded for visibility; the final renderer video was inspected and the APK rebuilt/signature-checked. That final material-only change was not rerun on Android.

Physical phones, physical haptic feedback, real-router isolation/hotspot behavior, battery/thermal performance and 3–4 physical-phone play remain untested. The game continues to use LAN co-op, without internet matchmaking, host migration or mid-run rejoining.

The source distribution includes reproducible helpers and selected validation logs. Android QA supports `PUFF_QA_APK` and `PUFF_QA_OUTPUT` environment variables so old artifacts are not overwritten during testing.

## Build and play

Open `project.godot` in Godot 4.7.2, or run `./tools/build_android.sh` from the distribution root with matching Android export templates/SDK and Java 17 configured. The helper installs the matching Android Gradle template when it is absent. No private upload key is included in the source archive.

On the phone, open **Puff-Crew-0.2.0-Playtest.apk**. Choose a course, then solo or same-Wi-Fi crew play. Try the new looks from **Crew outfits** and quality settings from **Settings & info** or the pause menu.
