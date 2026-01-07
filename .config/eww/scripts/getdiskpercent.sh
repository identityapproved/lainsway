#!/usr/bin/env sh
set -eu

df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}'
