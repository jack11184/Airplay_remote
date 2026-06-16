#!/usr/bin/env bash
# Launch TV Remote on your iPhone with hot reload.
#
#   ./run.sh            # auto-pick the connected iPhone
#   ./run.sh macos      # run on the Mac instead
#
# Once it's running, edits to the code go live by pressing:
#   r  - hot reload (keeps app state)   R - hot restart   q - quit
set -euo pipefail
cd "$(dirname "$0")"

TARGET="${1:-mobile}"

if [ "$TARGET" = "mobile" ]; then
  # Pick the first connected physical phone (iOS or Android), iPhone first.
  DEVICE_ID=$(flutter devices --machine 2>/dev/null | python3 -c '
import sys, json
try:
    devices = json.load(sys.stdin)
except Exception:
    devices = []
def phone(p):
    return (p or "").startswith("ios") or (p or "").startswith("android")
phones = [d for d in devices if phone(d.get("targetPlatform")) and not d.get("emulator", False)]
phones.sort(key=lambda d: 0 if (d.get("targetPlatform") or "").startswith("ios") else 1)
print(phones[0]["id"] if phones else "")
')
  if [ -z "$DEVICE_ID" ]; then
    echo "No phone detected."
    echo "  - iPhone: unlock it, same Wi-Fi (or plug in via USB), trust this computer."
    echo "  - Android: enable USB debugging and plug it in."
    echo
    echo "Detected devices:"
    flutter devices
    exit 1
  fi
  echo "Launching TV Remote on your phone ($DEVICE_ID)..."
  echo "Press 'r' to hot-reload changes, 'R' to restart, 'q' to quit."
  exec flutter run -d "$DEVICE_ID"
else
  echo "Launching TV Remote on $TARGET..."
  exec flutter run -d "$TARGET"
fi
