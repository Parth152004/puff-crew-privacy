# Gameplay study → Android implementation

Reviewed and implemented on 16–17 October 2026. This supplements the earlier market/store research. Video evidence was sampled at the points below; the long videos were not watched in their entirety. It is a visual design study rather than a measurement of the original game's physics or network implementation.

## Footage inspected

| Source | Sample | Visible evidence |
|---|---|---|
| [GamesMrkt official demo trailer](https://www.youtube.com/watch?v=N6aVfoC7Dss) | Opening / ~0:05 | Raft moving through a bounded water course, a close following camera, narrow routes and moving barriers |
| Same trailer | ~0:17 | A raft leaving the course near a large spiked obstacle; vertical falling makes the loss clear |
| Same trailer | ~0:20 | Higher camera view of a narrow elevated channel and rotating curved hazards |
| Same trailer | ~0:40 | A curved channel around cliffs, multiple hippos on the raft and obstacles ahead |
| [SrrishisLive session](https://www.youtube.com/watch?v=XHfW3_DjJWk) | ~34:59 | Four-character lobby, distinct character colors, selection/readiness controls |
| Same session | ~1:09:58–1:10:12 | Team movement in a wider pool and a checkpoint banner on entering the next section |
| [Bradster gameplay](https://www.youtube.com/watch?v=15icXM8hIJ8) | ~0:38–0:49 | Several characters on one raft, directional gas effects, course boundaries, start pool and a timer/progress HUD |

## Main design conclusions

**One common object makes teamwork legible.** Players can see the shared raft and the consequences of competing directions. This creates a useful tension between individual input and group success. The Android game keeps one raft for the whole crew and identifies the local character with a YOU marker.

**Direction, momentum and timing provide depth.** The footage visibly supports course correction and coordinated motion. Exact thrust, friction, stamina and collision constants cannot be recovered from these samples. Puff Crew uses its own fixed-step arcade model: momentum decays, reverse thrust brakes, player forces combine, and off-center forces contribute torque.

**Failure needs a clear cause and a short recovery.** A visibly missed obstacle or an obvious fall gives the crew something to improve. Checkpoints reduce repetition. The Android game pairs distinct obstacle silhouettes with knockback, a splash/fall animation, a quick checkpoint reset and a retry option.

**The camera is part of the control problem.** A close camera makes the characters expressive, while a higher view helps judge paths and timing. Puff Crew uses a stable following camera and a second higher view, with touch controls outside the main forward sightline.

**Course width changes the kind of coordination required.** Wide areas allow practice and correction; narrow passages demand precision. The Android courses use wider starts, bends, constrained sections and checkpoints before later challenges.

**A lobby must make ownership and readiness clear.** Four visually distinct characters help organize the group. Puff Crew displays crew colors, a local-player marker, ready states, the selected course, player count and a captain-controlled launch.

## Mobile adaptation

| Design problem | Implementation in this build |
|---|---|
| Aim while applying thrust | Independent multi-touch thumb stick and a hold-to-puff button |
| Fingers lifting in either order | Pointer IDs own each control independently; focus loss releases controls |
| Recognizing stamina | Local gas meter plus a gas ring around PUFF; release-to-refill prompt |
| Reliable shared physics | The captain integrates movement; clients submit their own validated inputs and receive snapshots |
| Starting without an account or service | Same-Wi-Fi discovery and manual IPv4 join |
| Limited GPU budget | OpenGL ES 3 renderer, simple original geometry, material batching and procedural water |
| Android Back/background behavior | In-game pause/leave handling and stale-input timeouts |
| Repeated attempts | Checkpoints, retry, results, best times and three short course variations |

## Original content and scope

Puff Crew has original capybara characters with expedition scarves, a separate name/icon, its own raft/scenery/obstacles, original audio and independently chosen courses and constants. It preserves the broad coordinated-propulsion concept studied in the videos. Source art, game code and course generation are editable.

This first build contains solo play and pre-launch co-op for 2–4 phones. Its levels are compact runs. Additional courses, richer character animation, public online matchmaking, host migration, mid-run reconnection, long-term progression and store publishing remain future product work.

## Evidence and verification limits

A renderer screenshot is evidence of the resulting presentation, not proof of equal or better subjective art quality. Automated course runs establish that a controller can complete the courses, not how difficult a new human group will find them. Emulator tests establish Android execution and code paths, not physical-device thermal behavior or compatibility with every home router.

Android Emulator 36.5+ supports shared virtual Wi-Fi between emulator instances; that setup was used for the two-Android test. [Android's emulator networking documentation](https://developer.android.com/studio/run/emulator-networking-interconnect).
