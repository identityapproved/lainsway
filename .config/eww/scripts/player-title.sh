#!/usr/bin/env sh
set -eu

if ! command -v playerctl >/dev/null 2>&1; then
  echo ""
  exit 0
fi

playerctl metadata --format '{{title}}' 2>/dev/null || true
