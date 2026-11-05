#!/usr/bin/env bash
# Package-specific lifecycle check; invoked from its package directory.
set -euo pipefail
mapfile -t packages < <(makepkg --packagelist)
[[ ${#packages[@]} == 1 && -f ${packages[0]} ]]
sudo pacman -U "${packages[0]}"
pacman -Qkk 115life-desktop-bin
# Restore the installation even when removal checks fail. Never delete user data.
restore() { sudo pacman -U --noconfirm "${packages[0]}"; }
trap restore EXIT
sudo pacman -R --noconfirm 115life-desktop-bin
for path in /opt/115life /usr/bin/115life-desktop /usr/bin/115pan /usr/bin/115life /usr/share/applications/life115.desktop /usr/share/licenses/115life-desktop-bin; do
    [[ ! -e $path && ! -L $path ]] || { echo "Leftover package path: $path" >&2; exit 1; }
done
for path in /usr/share/icons/hicolor/*/apps/life115.png /usr/share/doc/115life; do
    [[ ! -e $path ]] || { echo "Leftover package path: $path" >&2; exit 1; }
done
echo 'Removal verified; restoring package.'
