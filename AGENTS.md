# Repository Guidelines

## Project Structure & Module Organization
- This repo is for serial experiments on a Sway rice; configs evolve quickly and are meant to be tried, refined, and replaced.
- `.config/` contains the primary dotfile payloads (Sway ecosystem, terminals, editors, and CLI tools). Treat each folder as a self-contained app configuration.
- Root dotfiles (`.aliases`, `.profile`, `.zshrc`) are shell defaults intended to be symlinked into `$HOME`.
- `checker` and `linker` are helper scripts for validating dependencies and symlinking configs.
- `reference/` holds upstream reference material; `reference/Hyprlain/` is the Hyprland source of truth used only for inspiration and pattern matching (do not copy blindly).

## Build, Test, and Development Commands
- `./checker` verifies required tools are installed and reports missing binaries.
- `./linker` backs up existing dotfiles and symlinks this repo’s configs into `$HOME/.config` and `$HOME`.
- There is no build system or test runner; changes are validated by launching the relevant application and reviewing behavior.

## Coding Style & Naming Conventions
- Shell scripts use `bash` with `set -euo pipefail`; keep new scripts consistent.
- Use 2-space indentation in shell and config files where the existing file uses it; otherwise match the file’s current style.
- Keep config names aligned with app names (e.g., `.config/waybar`, `.config/mako`).

## Testing Guidelines
- No automated tests or coverage requirements exist.
- Validate edits by restarting the affected application and checking logs or UI output (e.g., reload Waybar after editing `.config/waybar`).
- For shell scripts, do a dry run in a safe environment and confirm backups are created.

## Commit & Pull Request Guidelines
- This directory is not currently a git repository, so commit conventions cannot be derived from history.
- If you use git locally, keep commit messages short and imperative (e.g., “Update waybar modules”).
- Pull requests should describe the affected app(s), include before/after screenshots for UI changes, and list any new dependencies.

## Security & Configuration Tips
- Avoid committing machine-specific secrets or tokens; prefer environment variables or local overrides.
- Be cautious with symlinks: `./linker` will move existing files to `*.bak-<timestamp>`.
