#!/usr/bin/env sh
set -eu

if command -v sensors >/dev/null 2>&1; then
  temp=$(sensors | awk '
    /(Package id 0|Tctl|Tdie|CPU Temp|temp1)/ {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^[+]*[0-9]+(\.[0-9]+)?°C$/) {
          gsub(/[+°C]/, "", $i);
          print $i;
          exit;
        }
      }
    }
  ')
  if [ -n "$temp" ]; then
    printf "%s" "${temp%.*}"
    exit 0
  fi
fi

if [ -r /sys/class/thermal/thermal_zone0/temp ]; then
  temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp)
  if [ -n "$temp_raw" ]; then
    printf "%s" "$((temp_raw / 1000))"
    exit 0
  fi
fi
