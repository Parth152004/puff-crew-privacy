#!/bin/sh
set -eu
TASK_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mkdir -p "$TASK_ROOT/builds"
godot --headless --path "$TASK_ROOT/puff-crew" --editor --import --quit
if [ -f "$TASK_ROOT/puff-crew/android/build/gradlew" ]; then
  godot --headless --path "$TASK_ROOT/puff-crew" --export-debug Android "$TASK_ROOT/builds/Puff-Crew-0.2.0-Playtest.apk"
else
  godot --headless --path "$TASK_ROOT/puff-crew" --install-android-build-template --export-debug Android "$TASK_ROOT/builds/Puff-Crew-0.2.0-Playtest.apk"
fi
printf '\nAPK: %s\n' "$TASK_ROOT/builds/Puff-Crew-0.2.0-Playtest.apk"
