# Puff Crew: Rapids — developer handoff

**Ramo Labs · 18 October 2026 · current game 0.2.0 playtest**

This package contains the complete editable game, current Android playtest, gameplay video, original assets, build/QA helpers, release drafts and selected verification evidence. The owner will arrange publishing from another PC. No Play account, app listing, billing product or release was uploaded, submitted or published during this work.

## Start here

1. Install `builds/Puff-Crew-0.2.0-Playtest.apk` on a compatible ARM64 phone to review the game. It is a debug-signed playtest, not a Play submission artifact. Watch `builds/Puff-Crew-0.2.0-Gameplay.mp4` for an actual automated gameplay capture.
2. Open `puff-crew/project.godot` with **Godot 4.7.2**. Read [build instructions](handoff/BUILD-ON-ANOTHER-PC.md), then [project map](handoff/PROJECT-MAP.md).
3. Read [known gaps](handoff/KNOWN-GAPS.md) before estimating release work. The release preset enables staged billing, while this playtest excludes it and unlocks every outfit. The two paths are not equivalent.
4. Follow [release checklist](handoff/RELEASE-CHECKLIST.md) to prepare a fresh release. Release copy/privacy/config are drafts; no current AAB is supplied. An older AAB was deliberately omitted because it predates the improved game.
5. Handle signing through [owner signing transfer](handoff/SIGNING-TRANSFER.md). The ZIP contains a public upload certificate only. Private keys, passwords, Google credentials and Play access must be handled separately.

## Agreed product details

| Item | Current decision |
| --- | --- |
| Game / package | Puff Crew: Rapids / `com.puffcrew.rapids` |
| Public publisher | Ramo Labs |
| Public support | jayvekaria282@gmail.com |
| Owner account | India; personal Play account created after 13 November 2023 |
| Intended audience | Teens/adults 13+; IARC content rating not completed |
| Play | Solo; 2–4 phones on the same Wi-Fi; three short courses |
| Monetization proposal | Free base + optional one-time cosmetic bundle; proposed India price ₹149 |
| Current APK | 0.2.0 / code 2 / ARM64 / min API 24 / target API 36 / GLES 3 |
| Release preset | Draft 1.0.0 / code 2; version consistency still needs work |

The monetization proposal has not been configured or tested in Google Play. Production access, merchant/tax readiness, Data safety and physical-phone QA remain unverified. Do not treat the game or this ZIP as approved for public release.

## Package contents

- `puff-crew/`: all game source, editable procedural geometry/shader/UI, fonts, original audio, plugin, licenses and tests. No generated Android/Gradle or `.godot` cache.
- `tools/`: local build, audio generation, network and Android QA scripts. These do not publish to Google Play.
- `builds/`: latest playtest APK and video. No outdated AAB or duplicate source ZIP.
- `release/`: draft listing, privacy HTML, proposed config, billing notes, icon/feature graphic, screenshots and public certificate.
- `research/`: reference-game analysis and India publishing/revenue research with dated source records.
- `validation/`: selected existing logs, screenshots and exact-build caveats. See `validation/README.md`.
- `handoff/`: receiving-developer instructions and remaining release work.
- `MANIFEST.json` and `SHA256SUMS.txt`: packaged-file sizes/hashes. `python tools/verify_handoff.py` checks the extracted handoff without starting any server.

This is a private development handoff. Third-party licenses are included; no blanket open-source license is granted for the original project. Local Android SDKs, Java, Godot binaries/templates, Python environments and signing credentials are not vendored. They must be installed separately.
