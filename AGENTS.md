# Repository Guidelines

## Project Structure & Module Organization
- This repo is a personal Sway rice for a Void Linux laptop; configs evolve quickly and are meant to be tried, refined, and replaced.
- `.config/` contains the dotfile payloads (Sway ecosystem, terminal, editor-adjacent, and CLI tools). Treat each folder as a self-contained app configuration.
- Root dotfiles (`.profile`, `.zprofile`) are session-entry files intended to be symlinked into `$HOME`.
- `checker` and `linker` are helper scripts for validating dependencies and symlinking configs.
- `lain-colors.md` is a symlink to `~/github/lainland-private/lain-colors.md` and is gitignored. It is the palette source of truth: resolve a role through its Semantic Role Map, then read the hex. Never invent values, and never rose-on-ochre.
- `~/github/lainland` is the complete rice from the main machine and the reference for keys, per-tool themes and window rules. It is read-only here; never edit it. Where a lainland value cannot be taken verbatim (font family, terminal, monitor geometry) note the host adaptation in a comment.
- `.config/eww/` is parked and not autostarted: its scripts already use `swaymsg`/`jq`, but `eww.yuck` hardcodes the old monitor name `C27R50x`. Reserved for a future wallpaper/widget layer.

## Build, Test, and Development Commands
- `./checker` verifies required tools are installed and reports missing binaries.
- `./linker` backs up existing dotfiles and symlinks this repo's configs into `$HOME/.config` and `$HOME`.
- `sway --validate -c ~/.config/sway/config` parses the compositor config without starting a session.
- There is no build system or test runner; changes are validated by launching the relevant application and reviewing behavior.

## Coding Style & Naming Conventions
- Shell scripts use `bash` with `set -euo pipefail`, or POSIX `sh` with `set -eu` for session scripts.
- Use 2-space indentation in shell and config files where the existing file uses it; otherwise match the file's current style.
- Keep config names aligned with app names (e.g., `.config/swaync`, `.config/foot`).
- Font is `IosevkaTermSlab Nerd Font Mono` everywhere; do not reintroduce plain `Iosevka`.

## Testing Guidelines
- No automated tests or coverage requirements exist.
- Validate edits by restarting the affected application and checking logs or UI output (e.g., `swaymsg reload` after editing `.config/sway/config`).
- For shell scripts, do a dry run in a safe environment and confirm backups are created.

## Commit & Pull Request Guidelines
- Keep commit subjects short and imperative (e.g., "Update sway keybindings").
- Stage files by explicit path; do not use `git add .`.
- Never add an agent `Co-Authored-By` trailer.
- Pull requests should describe the affected app(s), include before/after screenshots for UI changes, and list any new dependencies.

## Security & Configuration Tips
- Avoid committing machine-specific secrets or tokens; prefer environment variables or local overrides.
- Do not commit absolute `/home/<user>` paths; use `$HOME` or `~`.
- Be cautious with symlinks: `./linker` will move existing files to `*.bak-<timestamp>`.
