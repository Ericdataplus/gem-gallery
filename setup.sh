#!/usr/bin/env bash
# Gem Gallery - one-step setup and launch (Linux / macOS).
#   ./setup.sh            set up (first time) and play
#   ./setup.sh --rebake   rebuild the halls after editing content
# Needs Godot 4.7: on PATH as "godot", or set GODOT=/path/to/godot.
set -euo pipefail
cd "$(dirname "$0")"

GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
  echo "Godot 4.7 was not found. Download it from https://godotengine.org/download"
  echo "then run:  GODOT=/path/to/godot ./setup.sh"
  exit 1
fi
echo "Using Godot $("$GODOT" --version | head -n1)"

if [ ! -d .godot ]; then
  echo "Importing the project (first run only)..."
  "$GODOT" --headless --path . --import >/dev/null 2>&1 || true
fi
if [ "${1:-}" = "--rebake" ] || [ ! -f baked/manifest.res ]; then
  echo "Baking the halls (about a minute; a window opens and closes by itself)..."
  "$GODOT" --path . res://bake/bake.tscn
  [ -f baked/manifest.res ] || { echo "Bake failed - see the output above."; exit 1; }
fi
echo "Starting the gallery. First launch can take a minute while shaders compile."
"$GODOT" --path . &
