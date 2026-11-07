#!/usr/bin/env bash
# Interactive sudo; installs, checks and removes the package, then restores it.
# rustdesk.service is never enabled or started here: doing so would expose this
# machine to remote connections and is an explicit administrative decision.
set -euo pipefail
mapfile -t packages < <(makepkg --packagelist)
[[ ${#packages[@]} == 1 && -f ${packages[0]} ]]
sudo pacman -U "${packages[0]}"
pacman -Qkk rustdesk-unattended-wayland
/usr/bin/rustdesk --version
restore() { sudo pacman -U --noconfirm "${packages[0]}"; }
trap restore EXIT
sudo pacman -R --noconfirm rustdesk-unattended-wayland
for path in /usr/lib/rustdesk /usr/bin/rustdesk /usr/share/rustdesk \
            /usr/lib/systemd/system/rustdesk.service \
            /usr/share/applications/rustdesk.desktop \
            /usr/share/applications/rustdesk-link.desktop \
            /usr/share/icons/hicolor/256x256/apps/rustdesk.png \
            /usr/share/icons/hicolor/scalable/apps/rustdesk.svg; do
    [[ ! -e $path && ! -L $path ]] || { echo "Leftover package path: $path" >&2; exit 1; }
done
echo 'Removal verified; restoring package.'
