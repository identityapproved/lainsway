#!/usr/bin/env sh
set -eu

if ! command -v playerctl >/dev/null 2>&1; then
  echo ""
  exit 0
fi

status=$(playerctl status 2>/dev/null || true)
case "$status" in
  Playing) echo "playing" ;;
  Paused) echo "paused" ;;
  *) echo "" ;;
esac
