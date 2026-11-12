#!/usr/bin/env bash
# Copies only the diagnostics project to an existing local repository; doesn't alter jailbreak files.
set -euo pipefail
if [[ $# -ne 1 ]]; then echo "Usage: $0 /path/to/existing-local-repository" >&2; exit 2; fi
TARGET="$(cd "$1" && pwd)"
if [[ ! -f "$TARGET/Makefile" || ! -d "$TARGET/Application" ]]; then
  echo 'The destination does not look like the root of the official Dopamine repository.' >&2
  exit 1
fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$TARGET/SE2020_Research"
if [[ -e "$DEST" ]]; then echo "Destination already exists: $DEST (refusing to overwrite)" >&2; exit 1; fi
WF="$TARGET/.github/workflows/se2020-diagnostics.yml"
if [[ -e "$WF" ]]; then echo "Workflow already exists: $WF" >&2; exit 1; fi
mkdir -p "$DEST" "$TARGET/.github/workflows"
cp -R "$ROOT/DopaSEDiagnostics" "$ROOT/tools" "$ROOT/tests" "$ROOT/scripts" "$DEST/"
cp "$ROOT/README.md" "$ROOT/ROADMAP.md" "$ROOT/LICENSE" "$DEST/"
cp "$ROOT/.github/workflows/se2020-diagnostics.yml" "$WF"
echo "Read-only diagnostic project copied to: $DEST"
echo 'No official source code, exploit configuration, or jailbreak action was changed.'
