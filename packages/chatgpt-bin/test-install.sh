#!/usr/bin/env bash
# Interactive sudo; installs, checks and removes the package, then restores it.
# The ChatGPT window is never started here; --version exits without a display.
set -euo pipefail
mapfile -t packages < <(makepkg --packagelist)
[[ ${#packages[@]} == 1 && -f ${packages[0]} ]]
sudo pacman -U "${packages[0]}"
pacman -Qkk chatgpt-bin
/usr/bin/chatgpt --version
restore() { sudo pacman -U --noconfirm "${packages[0]}"; }
trap restore EXIT
sudo pacman -R --noconfirm chatgpt-bin
for path in /usr/lib/chatgpt /usr/bin/chatgpt /usr/share/applications/chatgpt.desktop \
            /usr/share/pixmaps/chatgpt.png /usr/share/licenses/chatgpt-bin \
            /usr/share/metainfo/com.openai.chatgpt.metainfo.xml \
            /usr/share/swcatalog/xml/com.openai.chatgpt.xml; do
    [[ ! -e $path && ! -L $path ]] || { echo "Leftover package path: $path" >&2; exit 1; }
done
echo 'Removal verified; restoring package.'
