# Validation report

**Current 0.2.0 playtest:** see [the 18 October changes and verification](PLAYTEST-0.2.0.md). The report below records the earlier 0.1.0 baseline. Publishing is paused at the owner's request.

## Earlier baseline — 17 October 2026

Build: **Puff Crew: Rapids 0.1.0**, package `com.puffcrew.rapids`, Godot 4.7.2. The Android artifact is a signed development APK for ARM64, minimum API 24, target API 36. It uses OpenGL ES 3.0.

## Completed checks

| Check | Result and scope |
|---|---|
| Behavioral suite | 25/25 passed: gas consumption/refill, thrust, momentum, reverse braking, opposing crew forces, checkpoint/fall recovery, collision cooldown, vortex, boost-gap success and failure, finish/best time, independent touch ownership and course widths. |
| All courses | The automated movement controller completed Sunlit Shoals in 41.7 s/0 splashes, Mango Twist in 59.5 s/1 splash, and Moonstone Run in 56.4 s/1 splash. It moves through the actual course/hazard simulation. These are controller results, not human playtest times. |
| Four-player networking | One desktop Godot host plus three independent desktop clients joined, submitted inputs and received synchronized movement. Host recorded four players and remote thrust. Latest logs contain no script errors or shutdown leaks. |
| Android solo | Installed APK on an ARM64 Pixel 9/API 36 emulator. App-internal debug instrumentation pushes real `InputEventScreenTouch`/drag events through the normal viewport and HUD hit testing. Verified menu launch, simultaneous aim and puff, separate finger releases, camera toggle, pause/resume with frozen timer, retry, leaving and canceling a pending connection. |
| Android client → desktop host | Android readied, supplied touch controls and received state snapshots. Both endpoints passed; the host observed remote inputs. |
| Android host → Android client | Two independent Android emulators ran the actual APK on shared virtual Wi-Fi. Automatic discovery, join, ready, captain launch, two touch input streams and state replication passed. Client recorded more than 100 snapshots; host observed remote thrust. |
| Rendering | Reviewed actual desktop-rendered video frames and Android menu/solo/co-op viewport images. Checked legible landscape HUD, fonts, shadows, camera, islands, characters, effects and wide-screen layout. |
| Video | An automated demonstration was captured from the real Godot renderer, encoded to H.264/AAC MP4, and fully decoded with FFmpeg. Duration approximately 24.6 seconds. |
| Artifact | APK signature and manifest inspected. ZIP CRC checks and SHA-256 checksums accompany delivery. |

The two-Android test uses Android Emulator 37.1.11 and its shared virtual Wi-Fi support. Both test devices were the Pixel_9_API_36 ARM64 AVD, launched as separate read-only instances with host GPU rendering. Observed frame-rate counters are emulator measurements and do not establish phone performance. Raw JSON and selected logs are in the source distribution's `validation/` directory.

## Reproduce

From the source distribution root, with Godot available as `godot`:

```sh
godot --headless --path puff-crew --editor --import --quit
godot --headless --path puff-crew --script tests/simulation_test.gd
godot --headless --path puff-crew --script tests/course_run_test.gd
python3 tools/test_network.py 4
./tools/build_android.sh
```

With the Android SDK's `adb` on PATH and a running emulator:

```sh
python3 tools/android_qa.py solo emulator-5554
python3 tools/android_qa.py client emulator-5554
```

For the Android pair test, start two compatible emulator instances on ports 5554 and 5556, then run `python3 tools/android_pair_qa.py`. Run network tests sequentially so temporary hosts do not compete for UDP ports. The runner installs the APK from `builds/`; test results are also written there.

Instrumentation is enabled only in a debug build when an explicit mode file is written in the app's private directory. Normal launching does not run the test controller. Test runners do not manipulate other apps or require personal data.

## Remaining device and product validation

- Physical Android phones, 2–4 physical phones on real Wi-Fi routers, hotspots, multicast restrictions, touch ergonomics, GPU compatibility, battery use and sustained thermal performance have not been tested.
- Four-player behavior is verified on four desktop processes; Android-to-Android behavior is verified on two emulators. These checks do not substitute for four physical phones.
- Human course difficulty, team coordination and subjective comparison with Fart Together need playtesting. Equal or better graphics has not been established objectively.
- This first build supports a pre-launch LAN lobby. It does not include public matchmaking, host migration or joining/rejoining during a run.
- Google Play release signing, store listing and production distribution remain future work. The supplied APK is for direct installation and evaluation.
