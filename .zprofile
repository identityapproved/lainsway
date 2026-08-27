# zsh login shells read .zprofile, not .profile — this is the file that
# actually fires on a tty1 login.
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  mkdir -p "$HOME/.local/state"
  exec "$HOME/.config/sway/start-sway" >>"$HOME/.local/state/sway.log" 2>&1
fi
