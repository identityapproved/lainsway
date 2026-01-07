#!/usr/bin/env sh
set -eu

if ! command -v swaymsg >/dev/null 2>&1; then
  printf '[]\n'
  exit 0
fi
if ! command -v jq >/dev/null 2>&1; then
  printf '[]\n'
  exit 0
fi

swaymsg -t get_workspaces -r | jq -c '
  map({
    num: .num,
    visible: (.visible == true),
    class: (if .focused then "ws-active" else "ws-inactive" end)
  })
  | sort_by(.num)
'
