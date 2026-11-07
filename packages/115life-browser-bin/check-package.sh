#!/usr/bin/env bash
set -euo pipefail
archive=$1
reports=$2
bsdtar -xOf "$archive" usr/share/applications/115Browser.desktop > "$reports/115Browser.desktop"
desktop-file-validate "$reports/115Browser.desktop"
bsdtar -xOf "$archive" opt/115Browser/115.sh > "$reports/launcher.sh"
grep -qx 'APP_DIR=/opt/115Browser' "$reports/launcher.sh"
bsdtar -tvf "$archive" opt/115Browser/chrome-sandbox | grep -E '^-rwsr-xr-x.*root[[:space:]]+root'
bsdtar -tf "$archive" > "$reports/paths.txt"
if grep -q '^usr/local/' "$reports/paths.txt"; then
    echo 'Unexpected /usr/local payload' >&2; exit 1
fi
