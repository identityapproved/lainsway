#!/bin/bash

# Usage: ./get_ws_class.sh <workspace_number>
ws_number="$1"

# Get the currently focused workspace number
focused=$(swaymsg -t get_workspaces -r | jq -r '.[] | select(.focused==true) | .num')

# Compare and output the class
if [[ "$ws_number" == "$focused" ]]; then
  echo "ws-active"
else
  echo "ws-btn"
fi
