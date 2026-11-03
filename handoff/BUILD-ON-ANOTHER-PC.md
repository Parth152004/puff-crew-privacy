# Build on Windows, macOS or Linux

Extract the entire ZIP first; preserve its folder structure. Run commands from the folder containing `START-HERE.md`. Do not build inside an archive viewer.

## Install once

- Godot **4.7.2 standard**, with matching **4.7.2 stable export templates**. This is a GDScript project; .NET is not required. Preserve this version for the first reproduction rather than migrating the engine at the same time.
- OpenJDK **17**. Set `JAVA_HOME` to the JDK directory, not its `bin` directory. Configure Godot Editor Settings → Export → Android → Java SDK Path and Android SDK Path.
- Android SDK via Android Studio/command-line tools. The actual local matching template used compile/target API **36**, min **24**, Build Tools **36.1.0**, NDK **29.0.14206865**, Android Gradle plugin **8.6.1**, Kotlin **2.1.21**. Install platform-tools and command-line tools too. The build template and Gradle dependencies need internet on first setup. These versions describe the local template; use its `android/build/config.gradle` after generation as the authority for that template, rather than an older generic tutorial.
- Python **3.9+** for the release, network, integrity and Android QA helpers. No pip dependency is needed for these helpers or the optional audio generator; audio WAVs are already included and do not need regeneration.

Official setup reference: [Godot Android export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html). Its generic package examples can differ from this project's exact matching template. Get engine/templates from [Godot downloads](https://godotengine.org/download/).

## Review without Android tools

Import `puff-crew/project.godot` into Godot, allow asset import, then press Run. Desktop controls: WASD/arrows aim, Space puffs, Escape pauses. Read `puff-crew/README.md` for touch controls, courses and LAN behavior.

## Reproduce the playtest APK

In Godot, install the Android build template using Project → Install Android Build Template if it is missing. Open Project → Export, select **Android**, then export an APK with **Export With Debug** enabled. The preset targets ARM64 and uses your local development signing identity.

macOS/Linux command-line alternative, with `godot` on PATH:

```sh
./tools/build_android.sh
```

Windows PowerShell alternative (replace the executable path with your installed console executable):

```powershell
$Godot = 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
New-Item -ItemType Directory -Force builds | Out-Null
& $Godot --headless --path puff-crew --editor --import --quit
& $Godot --headless --path puff-crew --install-android-build-template --export-debug Android builds/Puff-Crew-0.2.0-Playtest.apk
```

The install-template flag is needed for a fresh checkout; omit it on subsequent builds once `puff-crew/android/build/gradlew` exists. Use an absolute output path if your installed Godot interprets relative export paths differently. The editor GUI is the fallback for all three operating systems.

This debug build deliberately excludes the native billing dependencies and unlocks outfits. It is not a monetization test. Another PC's debug certificate will normally differ: installing over the supplied APK can fail with a signature mismatch. Back up any wanted local data, then uninstall the old debug app if needed; uninstalling clears local progress/settings.

## Prepare a release AAB later

Read `RELEASE-CHECKLIST.md` and `KNOWN-GAPS.md` first. Choose the release's outfit/payment behavior, complete its implementation, and align `CrewRelease.VERSION`, the **Google Play** preset and `release/release-config.json`. Choose an unused versionCode based on the actual Console history. Keep the Android playtest preset/file labels consistent if using them for that release's QA too.

The helper intentionally refuses the handoff's current 0.2.0-versus-1.0.0 mismatch before it reads secrets, creates keys or starts a build:

```sh
python3 tools/build_release.py --check
```

On Windows use `py -3` instead of `python3`. This only checks identity consistency; passing it does not mean billing, policy or QA is ready.

Restore the signing backup outside the extracted folder, then set `PUFF_SIGNING_DIR` to that directory. `GODOT_BIN` may contain the full path to the Godot executable (without surrounding quote characters in the value). `JAVA_HOME` selects Java/keytool. Configure Android SDK paths in Godot first.

macOS/Linux example:

```sh
export GODOT_BIN='/path/to/godot'
export JAVA_HOME='/path/to/jdk-17'
export PUFF_SIGNING_DIR='/private/path/to/signing'
python3 tools/build_release.py
```

PowerShell example:

```powershell
$env:GODOT_BIN = 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
$env:JAVA_HOME = 'C:\Tools\jdk-17'
$env:PUFF_SIGNING_DIR = 'C:\Private\PuffCrewSigning'
py -3 tools/build_release.py
```

The helper reads private `upload-credentials.json`, falls back to the adjacent `puff-crew-upload.jks` when the backup contains an obsolete original-PC path, supplies signing values through process environment variables, installs the Android build template if absent and exports `builds/release/Puff-Crew-<version>.aab`. It also exports a public certificate and writes local import/export logs. It does not upload, create products, accept terms or submit anything.

Only deliberately create a new upload key with `--create-upload-key` after checking the owner's intended signing identity and Play App Signing configuration. Existing keys are not overwritten. On Windows, protect the signing directory with account permissions/ACLs; Python chmod is not equivalent to POSIX owner-only access. The helper was reviewed and its consistency preflight checked on macOS; Windows/Linux export and the modified release path have not been executed here.

GUI alternative: set the release key/alias/password locally in the Google Play export preset, export AAB with **Export With Debug disabled**, then remove secrets before sharing source. Do not commit generated `.godot/export_credentials.cfg` or private signing material.

## Optional QA commands

With `godot` on PATH, from the handoff root:

```sh
godot --headless --path puff-crew --editor --import --quit
godot --headless --path puff-crew --script res://tests/simulation_test.gd
godot --headless --path puff-crew --script res://tests/course_run_test.gd
godot --headless --path puff-crew --script res://tests/store_test.gd
python3 tools/test_network.py 4
```

The network helper launches temporary local game host/client processes. It is not needed to unpack/review this handoff. Ensure ports UDP 28970/28971 are free before LAN tests.

Android QA needs ADB and deliberately selected running test emulators. Set `PUFF_QA_APK` to the **absolute path of the APK you just built** and `PUFF_QA_OUTPUT` to a fresh results directory. Then run `python3 tools/android_qa.py solo <serial>` or `python3 tools/android_pair_qa.py <host-serial> <client-serial>`. These install and instrument the app. They are debug-only checks and cannot replace manual Play-installed release/billing tests. See `validation/README.md` for historical evidence and limitations.
