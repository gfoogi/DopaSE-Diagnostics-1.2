#!/usr/bin/env bash
# Compile and execute the platform-neutral app core with any Swift 6 compiler.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
swiftc \
  "$ROOT/DopaSEDiagnostics/Sources/DeviceProfile.swift" \
  "$ROOT/DopaSEDiagnostics/Sources/Compatibility.swift" \
  "$ROOT/tests/swift/main.swift" -o "$TMP/dopase-core-check"
"$TMP/dopase-core-check" "$ROOT/DopaSEDiagnostics/Resources/compatibility.json"
swiftc -frontend -parse "$ROOT"/DopaSEDiagnostics/Sources/*.swift
echo 'PASS: All Swift source files parsed.'
