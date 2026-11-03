# Evidence inventory and limitations

These are selected existing 0.2.0 development results, not a certification of a future Play release. Read `../handoff/KNOWN-GAPS.md` and `../puff-crew/docs/PLAYTEST-0.2.0.md`.

- `playtest-report.json`: final APK identity and test scope. Android checks ran the listed earlier SHA; final double-sided/unshaded whirlpool foam was video-reviewed and rebuilt, not rerun on Android.
- `simulation.log`: 25/25 behavior checks. `course-runs.log`: all three automated courses. `network-run.log`: four independent desktop ENet processes.
- `android-solo-qa.json` / `android-solo-run.log`: Android touch/UI/outfit tests. `android-pair-qa.json` / run + host/client logs: actual APK in two emulators, discovery, input/snapshots, distinct synced outfits. Shader-cache fallback warnings exist; emulator samples are not physical-phone benchmarks.
- `store-tests.log`: 16/16 fake-adapter state checks. No live Google Play purchase or release billing QA occurred.
- `apk-signature.log`, `apk-alignment.log`: static APK signature/alignment evidence; recheck the exact final release and Play-generated APKs.
- `movie.log`, `video-encode.log`: actual automated renderer capture/video encode; complete video decode was checked during the previous game-improvement work.
- `archive-import.log`, `archive-behavior.log`: import/behavior checks on the earlier source-only package, before the last material-only polish. They are not checks of this new ZIP. See `HANDOFF-CHECKS.json` for this package's checks.
- PNGs: actual Android emulator UI/co-op captures; `video-frame-21.png` is the final renderer's visible spiral whirlpool. A preview of an outfit does not demonstrate a completed purchase.

No physical phones/router/thermal/battery or 3–4 phone validation has been claimed. Logs preserve actual outputs and may contain the original development machine's paths. No private key/password is included. `release/store-assets/screenshots/` contains selected copies for the receiving developer to review/re-capture against final release behavior.
