#!/usr/bin/env bash
set -euo pipefail
archive=$1
reports=$2
for desktop in rustdesk.desktop rustdesk-link.desktop; do
    bsdtar -xOf "$archive" "usr/share/applications/$desktop" > "$reports/$desktop"
    desktop-file-validate "$reports/$desktop"
done
bsdtar -tf "$archive" > "$reports/paths.txt"
# Launcher, private DRM capture library and unit file must keep the paths the
# vendor binaries and the systemd service depend on.
bsdtar -tvf "$archive" | grep -E ' usr/bin/rustdesk -> /usr/lib/rustdesk/rustdesk$'
bsdtar -tvf "$archive" | grep -E ' usr/lib/rustdesk/libdrmtap\.so\.0 -> libdrmtap\.so\.0\.5\.12$'
grep -qx 'usr/lib/rustdesk/rustdesk' "$reports/paths.txt"
grep -qx 'usr/lib/rustdesk/lib/librustdesk.so' "$reports/paths.txt"
grep -qx 'usr/lib/rustdesk/data/icudtl.dat' "$reports/paths.txt"
grep -qx 'usr/lib/systemd/system/rustdesk.service' "$reports/paths.txt"
# The vendor /usr/share/rustdesk tree must not be shipped: ELF files belong in
# /usr/lib and the relocation is the documented packaging change.
if grep -q '^usr/share/rustdesk/' "$reports/paths.txt"; then
    echo 'Unexpected /usr/share/rustdesk payload' >&2; exit 1
fi
bsdtar -xOf "$archive" usr/lib/systemd/system/rustdesk.service > "$reports/rustdesk.service"
grep -qx 'ExecStart=/usr/bin/rustdesk --service' "$reports/rustdesk.service"
grep -qx 'ExecStop=/usr/bin/pkill -f "rustdesk --"' "$reports/rustdesk.service"
