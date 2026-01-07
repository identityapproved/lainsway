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

emit_state() {
  swaymsg -t get_tree -r | jq -c '
    def ws_for($n):
      [.. | objects | select(.type? == "workspace" and .num == $n)] | .[0];
    def leaf_count($w):
      ($w | .. | objects
        | select(.type? == "con" and ((.nodes | length) == 0) and ((.floating_nodes | length) == 0))
        | length);
    def focused_ws_num:
      ([.. | objects
        | select(.type? == "workspace" and (any(.. | objects; .focused? == true)))]
       | .[0].num) // -1;
    . as $tree
    | [range(1;11) as $n
      | ($tree | ws_for($n)) as $w
      | {
          num: $n,
          visible: (if $w == null then false else ((focused_ws_num == $n) or (leaf_count($w) > 0)) end),
          class: (if $w != null and (focused_ws_num == $n) then "ws-btn ws-active" else "ws-btn" end)
        }
    ]
  '
}

emit_state
swaymsg -t subscribe '["workspace","window"]' | while read -r _; do
  emit_state
done
