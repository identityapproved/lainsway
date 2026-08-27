# Void mounts /tmp noexec; cargo/build-scripts exec from $TMPDIR, redirect to exec-allowed home dir
export TMPDIR="$HOME/.cache/tmp"

. "$HOME/.cargo/env"
