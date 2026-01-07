#!/usr/bin/env sh
set -eu

if command -v sensors >/dev/null 2>&1; then
  sensors | awk '/fan/ {gsub(/[^0-9]/, "", $2); if ($2 != "") {print $2; exit}}'
fi
