#!/usr/bin/env bash
# Run in a disposable desktop session; never log in to an account here.
set -euo pipefail
/usr/bin/115life-desktop &
client=$!
# Invoked by the EXIT trap.
# shellcheck disable=SC2329
cleanup() {
    kill "$client" 2>/dev/null || true
    wait "$client" 2>/dev/null || true
}
trap cleanup EXIT
for ((attempt=0; attempt<30; attempt++)); do
    kill -0 "$client" 2>/dev/null || { echo 'Client exited before creating a window' >&2; exit 1; }
    if windows=$(xdotool search --onlyvisible --pid "$client" 2>/dev/null); then
        printf 'Visible client window(s): %s\n' "$windows"
        sleep 2
        kill -0 "$client"
        exit 0
    fi
    sleep 1
done
echo 'No visible client window within 30 seconds' >&2
exit 1
