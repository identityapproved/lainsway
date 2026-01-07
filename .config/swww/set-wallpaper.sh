#!/usr/bin/env sh
set -eu

if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  exit 0
fi

if ! pgrep -x swww-daemon >/dev/null 2>&1; then
  swww-daemon >/dev/null 2>&1 &
  sleep 0.2
fi

wall_dir="$HOME/.config/wallpapers"

wallpaper_list=$(find -L "$wall_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \))
if [ -z "$wallpaper_list" ]; then
  exit 0
fi

wallpaper_count=$(printf "%s\n" "$wallpaper_list" | wc -l | tr -d ' ')
cache_dir="$HOME/.cache/lainsway-swww"
mkdir -p "$cache_dir"

pick_wallpaper() {
  output_name="$1"
  last_file="$cache_dir/$output_name.last"
  last_wallpaper=""
  if [ -f "$last_file" ]; then
    last_wallpaper=$(cat "$last_file")
  fi

  if command -v shuf >/dev/null 2>&1; then
    if [ -n "$last_wallpaper" ] && [ "$wallpaper_count" -ge 2 ]; then
      candidate=$(printf "%s\n" "$wallpaper_list" | grep -Fvx "$last_wallpaper" | shuf -n 1)
    else
      candidate=$(printf "%s\n" "$wallpaper_list" | shuf -n 1)
    fi
  else
    candidate=$(printf "%s\n" "$wallpaper_list" | head -n 1)
    if [ "$candidate" = "$last_wallpaper" ]; then
      candidate=$(printf "%s\n" "$wallpaper_list" | sed -n '2p')
    fi
  fi

  if [ -z "$candidate" ]; then
    candidate="$last_wallpaper"
  fi

  if [ -n "$candidate" ]; then
    printf "%s" "$candidate" >"$last_file"
  fi
  printf "%s\n" "$candidate"
}

wp_primary=$(pick_wallpaper HDMI-A-1)
wp_secondary=$(pick_wallpaper DVI-D-1)

swww img -o HDMI-A-1 "$wp_primary" --transition-type none --transition-duration 0 --resize stretch
swww img -o DVI-D-1 "$wp_secondary" --transition-type none --transition-duration 0 --resize stretch
