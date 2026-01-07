#!/usr/bin/env sh
set -eu

if command -v mpstat >/dev/null 2>&1; then
  mpstat 1 1 | awk '/all/ {printf "%d", 100 - $NF; exit}'
  exit 0
fi

read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
prev_total=$((user+nice+system+idle+iowait+irq+softirq+steal))
prev_idle=$((idle+iowait))

sleep 0.5

read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
curr_total=$((user+nice+system+idle+iowait+irq+softirq+steal))
curr_idle=$((idle+iowait))

total_delta=$((curr_total - prev_total))
idle_delta=$((curr_idle - prev_idle))

if [ "$total_delta" -gt 0 ]; then
  usage=$(( (100 * (total_delta - idle_delta)) / total_delta ))
else
  usage=0
fi

echo "$usage"
