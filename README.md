# lainsway

> [!NOTE]
> **Archived.** Everything here has moved to
> [lainland](https://github.com/identityapproved/lainland), one dotfiles repo
> covering every host. This repo stays read-only for history.

Personal Sway rice for a Void Linux laptop, in the *Serial Experiments Lain*
palette (rose `#CE7688`, ochre `#C1B48E`, black `#000000`).

This rice is unfinished and not expected to be completed anytime soon.
Treat this repo as a personal stash/trash for sway experiments and notes.

## Layout

| Path | What |
| --- | --- |
| `.config/sway/` | compositor config, session launcher (`start-sway`), wallpaper script |
| `.config/waybar/` | **unused** — kept as reference, not linked or started |
| `.config/swaync/` | notification daemon + control center |
| `.config/foot/` | terminal, lain colors |
| `.config/tmux/` | multiplexer, lain status bar |
| `.config/yazi/` | file manager, openers, raw/CR2 previewer, `lain` flavor |
| `.config/wallpapers/` | lain wallpapers, picked at random by `set-wallpaper.sh` |
| `.config/{zathura,swappy,btop}/` | PDF viewer, screenshot annotator, resource monitor — all lain-themed |
| `.config/offpunk/` | gemini/gopher browser — **rc file only**, `cert_cache/` stays local |
| `.config/mpd/` | music daemon behind rmpc, PipeWire output |
| `.config/rmpc/` | MPD client, sixel album art |
| `.config/tofi/` | launcher, `Mod+Space` |
| `.config/{delta,lazygit}/` | lain-coloured git diffs |
| `.config/fontconfig/` | monospace prefer-list |
| `.config/{mpv,bat,fastfetch}/` | odds and ends |
| `scripts/` | non-compositor helpers, linked onto `$PATH` in `~/.local/bin` |
| `.config/mimeapps.list` | default applications — **no browser handler**, see gaps |
| `.zshrc` / `.zshenv` / `.dircolors` | login shell, env, ls colours |
| `.config/{audacious,fish,swww,vesktop,environment.d}/` | **reference only** — tracked, never linked (see below) |
| `.config/eww/` | **parked**, see below |
| `lain-colors.md` | palette source of truth — **symlink** into `lainland-private`, gitignored |
| `system/udev/` | system-level rules — **not** symlinked, see Hardware |
| `checker` / `linker` | dependency check and symlink installer |

## Install

```sh
./checker   # report missing binaries
./linker    # back up existing dotfiles and symlink this repo into $HOME
```

`linker` moves anything it would overwrite to `<path>.bak-<timestamp>` first. It prompts
per entry, and that includes the legacy directories above — answer `n` to those.

The yazi `lain` flavor is not committed here — `.config/yazi/flavors/` is
gitignored because this host symlinks it to the flavor's own checkout
(`~/github/lain.yazi`) so it can be edited and debugged in place. On a fresh
machine install it instead with:

```sh
ya pkg add identityapproved/lain
```

`.config/yazi/theme.toml` already selects it (`[flavor] dark = "lain"`).

## Session start

`agetty-tty1` gives a login on tty1; `.zprofile` execs
`.config/sway/start-sway`, which sets up `dbus-run-session` and the Wayland
environment before `exec sway`. Logs land in `~/.local/state/sway.log`.

There is no systemd here, so `~/.config/environment.d/` would never be read —
those variables live in `start-sway` instead, and pipewire is started from an
`exec` in the Sway config rather than being socket-activated.

## Migrated from voidots

This host previously ran dwl, with configs symlinked out of the `voidots`
repo. That repo is no longer load-bearing: nothing under `$HOME` links into it
any more. The dwl/dwlb helper scripts (`start-dwl`, `dwlb-status*`, `bri-*`,
`vol-*`, `tmux-bri`, `tmux-vol`) were dropped rather than migrated — sway
binds `pactl` and `brightnessctl` directly — and the alacritty/vimb/luakit
configs went with the binaries, which are no longer installed. dunst was
dropped for swaync, `random-wallpaper` for `.config/sway/scripts/set-wallpaper.sh`.

## Hardware (Arduino / ESP / USB drives)

**`kernel.modules_disabled=1` is the thing that breaks USB hotplug here.**
`/etc/runit/2` sets it at the end of stage 2, which permanently locks kernel
module loading until the next boot. Devices still enumerate — `lsusb` shows
them — but their driver can never load, so no `/dev/ttyACM*`, `/dev/ttyUSB*`
or `/dev/sd*` node appears. That is why hardware only ever worked "after a
reboot": whatever loaded during boot worked, nothing plugged in later did.

The lock is one-way; it cannot be cleared at runtime. The fix keeps the
hardening and preloads the drivers *before* the lock, using the
`/etc/modules-load.d` hook `/etc/runit/2` already has.

`/etc/runit/2` also needs a one-word fix: its loader runs
`grep -v '^#' "$f" | xargs -r modprobe`, which passes every module after the
first as a *parameter* to the first one. Every stock conf holds a single module,
which is why nobody noticed.

```sh
doas install -Dm 644 system/modules-load.d/usb-hotplug.conf /etc/modules-load.d/usb-hotplug.conf
doas sed -i 's/xargs -r modprobe/xargs -rn1 modprobe/' /etc/runit/2
doas reboot
```

After the reboot, `lsmod | grep -E 'cdc_acm|usb_storage'` should list them, and
boards and drives appear on plug-in with no further action.

To drop the hardening instead, comment out line 23 of `/etc/runit/2`
(`sysctl -w kernel.modules_disabled=1`) and reboot; module autoloading then
behaves normally. Note `/etc/sysctl.d/99-hardened.conf` *looks* like it sets
this to 0, but that line has an inline `#` comment, which `sysctl.d` does not
support — it is not the thing setting the value.

## Serial device permissions

USB serial boards are `root:dialout 0660` on Void, and the shipped
`70-uaccess.rules` only covers ttyACM devices flagged as signal analyzers — so
a plain board is unreadable unless you are in `dialout`. Group changes only
apply to a *new login*, which is why boards appeared to work only after a
reboot.

`system/udev/71-usb-serial-uaccess.rules` fixes it with `TAG+="uaccess"`, so
elogind attaches an ACL for the active seat user at hotplug time — no group, no
re-login, no reboot. It covers USB ttys plus the raw-USB vendor IDs that
flashing tools need (CH340, CP210x, FTDI, Espressif, Arduino, SparkFun, Prolific).

This is the *second* half of the problem — it only matters once the driver can
actually load, so apply the module fix above as well.

Install it once, as root:

```sh
# -D creates /etc/udev/rules.d, which Void does not ship until you add a rule.
# The 71- prefix matters: 73-seat-late.rules is what acts on TAG=="uaccess",
# and udev reads rules in lexical order, so a 99- rule tags too late.
doas install -Dm 644 system/udev/71-usb-serial-uaccess.rules /etc/udev/rules.d/71-usb-serial-uaccess.rules
doas udevadm control --reload-rules
doas udevadm trigger --subsystem-match=tty --subsystem-match=usb
```

## Palette

`lain-colors.md` is a symlink to `~/github/lainland-private/lain-colors.md` and
is gitignored, so the canonical palette never enters this repo's history — the
same arrangement `lainland` uses. Resolve every colour through its **Semantic
Role Map**: pick the role, read the token, take the hex. Do not invent values.

Pairing rule from that document: rose on black for chrome, ochre on black for
content, black on ochre for selection. Never rose on ochre — the two ramps sit
close in luminance and the pairing goes muddy.

Keys, per-tool themes and window rules are ported from `~/github/lainland`,
which is the complete rice from the main machine. Host adaptations are noted in
a comment wherever a lainland value could not be taken verbatim (font family,
terminal, monitor geometry).

## Not linked on purpose

`linker` carries a `never_link` list. These stay tracked as reference and are
never symlinked into `$HOME`:

| Config | Why |
| --- | --- |
| `audacious`, `fish`, `vesktop` | kept by request; the shell here is zsh and the player is rmpc |
| `swww` | `swww` is a transitional dummy package on Void; wallpapers go through `swaybg` |
| `environment.d` | a systemd mechanism — nothing reads it on Void. Its variables live in `.config/sway/start-sway` |
| `waybar` | parked. If a bar is wanted it gets reinstalled and rewritten then |
| `eww` | unported; `eww.yuck` hardcodes the old desktop monitor name `C27R50x` |

## Browser (Firefox)

Firefox is in Void's repos, so it installs like anything else — no tarballs, no
third-party templates, and `xbps-install -Su` keeps it current.

```sh
doas xbps-install -S firefox
```

`firefox-esr` is also packaged if you would rather have fewer, larger jumps.

### Tuning for this hardware

`.config/firefox/user.js` is tuned for a Pentium N3540 (Bay Trail, 4 slow
cores) with 7.6 GB RAM. Memory is not the constraint here; the CPU is.

The important part is video. `vainfo --display drm` reports 16 VA-API profiles
but only **MPEG2 and H.264** — Bay Trail has no VP9 or AV1 hardware decode.
YouTube serves VP9/AV1 by default, which would fall back to software decode and
saturate all four cores, so `user.js` disables the WebM/MSE path and AV1 to
force H.264 through the GPU.

`start-sway` pins `LIBVA_DRIVER_NAME=i965`: the driver fails on the Wayland
backend against current Mesa with `undefined symbol: wl_drm_interface`, while
the DRM backend works.

The rest trims speculative connections, the accessibility engine, telemetry and
Pocket, and drops content processes from 8 to 4 — fewer context switches matter
more than the RAM on this box.

`user.js` has to live inside the profile, which does not exist until Firefox has
run once. Note that Firefox 154 on Void is XDG-compliant: profiles live under
`~/.config/mozilla/firefox/`, **not** the traditional `~/.mozilla/firefox/`.

Which profile actually launches is the one named by `Default=` in the
`[Install...]` section of `profiles.ini`, which is not necessarily the one
carrying `Default=1`. Linking into every profile avoids having to care:

```sh
for p in ~/.config/mozilla/firefox/*/; do
  [ -f "$p/prefs.js" ] || [ -d "$p" ] || continue
  ln -sfn ~/github/lainsway/.config/firefox/user.js "$p/user.js"
done
```

Confirm the prefs were consumed - Firefox copies `user.js` values into
`prefs.js` on each start:

```sh
grep -c '^user_pref' ~/.config/mozilla/firefox/*/prefs.js
```

Verify afterwards in `about:support`: "Window Protocol" should read `wayland`,
and under Media, the decoder for a playing H.264 video should show as hardware.

## Known gaps

- **eww is parked.** Its scripts already speak `swaymsg`/`jq`, so the
  compositor side is fine, but `eww.yuck` hardcodes the old desktop monitor
  name `C27R50x`. It is not autostarted. Intended for a future wallpaper/widget
  layer.
- **The music drive is mounted by hand.** `music_directory` is `/mnt/music`,
  which is not in `fstab` by choice. Mount the drive before starting mpd, or the
  library reads as empty until you do.
- **There is no status bar.** waybar was dropped and is not being replaced for
  now; nothing starts a bar. If one is wanted later it gets installed and
  rewritten then.
- Editor config lives in a separate repo (`id.app.nvim`) and is still
  kanagawa-themed; retheming it is a later job.
