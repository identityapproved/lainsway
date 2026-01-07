#!/usr/bin/env sh
set -eu

usage=$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
blocks=10
filled=$(( (usage * blocks + 50) / 100 ))
[ "$filled" -gt "$blocks" ] && filled=$blocks

bar=""
i=1
while [ $i -le $blocks ]; do
  if [ $i -le $filled ]; then
    bar+="█"
  else
    bar+="▒"
  fi
  i=$((i+1))
done

printf "%s %s" "󰋊" "$bar"
