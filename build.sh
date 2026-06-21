#!/bin/bash
# Build Noice and assemble a runnable .app bundle (menu-bar agent).
set -euo pipefail

CONFIG="${1:-release}"
APP_NAME="Noice"
BUNDLE_ID="app.noice.Noice"
ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/$APP_NAME.app"

echo "==> swift build -c $CONFIG"
swift build -c "$CONFIG"

BIN="$(swift build -c "$CONFIG" --show-bin-path)/$APP_NAME"

echo "==> Assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp "$BIN" "$APP/Contents/MacOS/$APP_NAME"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"

# Copy SPM-built resource bundles (audio, assets) if any exist.
BUNDLES_DIR="$(dirname "$BIN")"
for b in "$BUNDLES_DIR"/*.bundle; do
  [ -e "$b" ] && cp -R "$b" "$APP/Contents/Resources/" || true
done

# Ad-hoc codesign so launchd/login items and audio session behave.
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true

echo "==> Built $APP"
