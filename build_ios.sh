#!/usr/bin/env bash
# Build on macOS+Xcode. Produces a REAL compiled but UNSIGNED iOS IPA.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/DopaSEDiagnostics"
OUT="$ROOT/artifacts"
DERIVED="$ROOT/.build"
command -v xcodebuild >/dev/null || { echo 'An Xcode installation on macOS is required' >&2; exit 1; }
PROJECT="$APP/DopaSEDiagnostics.xcodeproj/project.pbxproj"
if [[ ! -f "$PROJECT" ]]; then
  echo 'Missing committed Xcode project: DopaSEDiagnostics.xcodeproj' >&2
  exit 1
fi
cd "$APP"
xcodebuild \
  -project DopaSEDiagnostics.xcodeproj \
  -scheme DopaSEDiagnostics \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY='' build
BUILT="$DERIVED/Build/Products/Release-iphoneos/DopaSEDiagnostics.app"
test -d "$BUILT" || { echo 'Expected .app missing' >&2; exit 1; }
test -f "$BUILT/compatibility.json" || { echo 'Manifest was not packaged in the .app; aborting' >&2; exit 1; }
test -f "$BUILT/DopaSEDiagnostics" || { echo 'Executable missing from the .app; aborting' >&2; exit 1; }
mkdir -p "$OUT"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/Payload"
ditto "$BUILT" "$TMP/Payload/DopaSEDiagnostics.app"
(cd "$TMP" && zip -qry "$OUT/DopaSEDiagnostics-unsigned.ipa" Payload)
unzip -tq "$OUT/DopaSEDiagnostics-unsigned.ipa" >/dev/null
printf '\nCompiled unsigned IPA: %s\n' "$OUT/DopaSEDiagnostics-unsigned.ipa"
echo 'This IPA is NOT signed and cannot be installed without signing for the device.'
echo 'This diagnostic app does NOT jailbreak iOS.'
