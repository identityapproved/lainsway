#!/usr/bin/env sh
set -eu

current=$(eww get sysmon_enabled 2>/dev/null || echo "true")
if [ "$current" = "true" ]; then
  eww update sysmon_enabled=false
else
  eww update sysmon_enabled=true
fi
