#!/usr/bin/env bash
# PaksLauncher one-shot changes. Run from the ROOT of the repo (where gradlew is).
set -e
[ -f gradlew ] || { echo "Run this inside the repo root (folder with gradlew)."; exit 1; }
NAME="PaksLauncher"

echo "1) App name -> $NAME"
find . -path ./node_modules -prune -o -name strings.xml -path "*/res/values/*" -print | while read f; do
  sed -i -E 's#(<string name="app_name"[^>]*>)[^<]*#\1'"$NAME"'#' "$f"
done

echo "2) Package id -> com.paks.launcher (installs next to the original)"
for g in app_pojavlauncher/build.gradle app_pojavlauncher/build.gradle.kts; do
  [ -f "$g" ] && sed -i -E 's#applicationId[ =]+["'"'"'][^"'"'"']+["'"'"']#applicationId "com.paks.launcher"#' "$g" || true
done

echo "3) Workflow: debug build, skip empty signing, new APK name"
for w in .github/workflows/*.yml .github/workflows/*.yaml; do
  [ -f "$w" ] || continue
  sed -i 's/assembleRelease/assembleDebug/g; s#apk/release#apk/debug#g; s/-n "\$KEYSTORE_PATH"/-s "$KEYSTORE_PATH"/g; s/CS-LAUNCHER-V2/'"$NAME"'/g' "$w"
done

echo "Done. Review with: git diff --stat"
echo "Kept: LICENSE, NOTICE and all credits (required by GPL)."
