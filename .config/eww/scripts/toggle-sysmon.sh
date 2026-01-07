#!/usr/bin/env sh
set -eu

mode=$(eww get sysmon_mode 2>/dev/null || echo bar)
if [ "$mode" = "percent" ]; then
  eww update sysmon_mode=bar
else
  eww update sysmon_mode=percent
fi
