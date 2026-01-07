#!/usr/bin/env sh
set -eu

ws_number="$1"

if ! command -v swaymsg >/dev/null 2>&1; then
  echo "false"
  exit 0
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "false"
  exit 0
fi

if swaymsg -t get_workspaces -r | jq -e --argjson ws "$ws_number" '.[] | select(.num == $ws)' >/dev/null 2>&1; then
  echo "true"
else
  echo "false"
fi
