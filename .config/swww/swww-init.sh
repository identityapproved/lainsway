#!/usr/bin/env sh
set -eu

# Legacy shim for older autostarts. Prefer set-wallpaper.sh + sway exec.
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  exit 0
fi

if ! pgrep -x swww-daemon >/dev/null 2>&1; then
  swww-daemon >/dev/null 2>&1 &
  sleep 0.2
fi

exec "$HOME/.config/swww/set-wallpaper.sh"
