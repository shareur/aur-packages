#!/usr/bin/env bash
# Run interactively as the desktop user after closing 115 Browser.
set -euo pipefail
mapfile -t archives < <(makepkg --packagelist)
[[ ${#archives[@]} == 1 && -f ${archives[0]} ]]
sudo pacman -U "${archives[0]}"
pacman -Qkk 115life-browser-bin
restore() { sudo pacman -U --noconfirm "${archives[0]}"; }
trap restore EXIT
sudo pacman -R --noconfirm 115life-browser-bin
for path in /opt/115Browser /usr/bin/115life-browser /usr/share/applications/115Browser.desktop /usr/share/icons/hicolor/256x256/apps/115life-browser.png /usr/share/licenses/115life-browser-bin; do
    [[ ! -e $path && ! -L $path ]] || { echo "Leftover package path: $path" >&2; exit 1; }
done
echo 'Removal verified; restoring package.'
