#!/usr/bin/env bash
# Run as root inside an ephemeral Arch Linux container. No host installation.
set -euo pipefail
[[ $EUID == 0 && ${AUR_DISPOSABLE_BUILD:-} == 1 ]] || {
    echo 'Use only in an explicitly designated disposable Arch container' >&2; exit 2;
}
package=${1:?Usage: ci-build.sh PACKAGE}
[[ $package =~ ^[a-z0-9][a-z0-9+_.-]*$ ]] || exit 2
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
# Minimal Arch images omit documentation via NoExtract. Validate the full
# package payload rather than suppressing pacman -Qkk failures.
grep -E '^[[:space:]]*NoExtract[[:space:]]*=' /etc/pacman.conf || true
sed -i '/^[[:space:]]*NoExtract[[:space:]]*=/d' /etc/pacman.conf
pacman -Syu --noconfirm --needed base-devel namcap desktop-file-utils sudo xorg-server-xvfb dbus ttf-dejavu xdotool mesa
useradd -m builder
printf 'builder ALL=(ALL) NOPASSWD: /usr/bin/pacman\n' > /etc/sudoers.d/builder
chown -R builder:builder "$root"
cd "$root/packages/$package"
runuser -u builder -- makepkg --syncdeps --noconfirm --nobuild
runuser -u builder -- bash "$root/scripts/validate.sh" "$package"
mapfile -t archives < <(runuser -u builder -- makepkg --packagelist)
pacman -U --noconfirm "${archives[@]}"
mapfile -t names < <(for archive in "${archives[@]}"; do pacman -Qp "$archive" | cut -d' ' -f1; done)
for name in "${names[@]}"; do
    pacman -Qkk "$name" >> "$root/reports/$package/installed-files.txt"
done
# Additional GUI smoke check for the first package; generic packages need no GUI.
if [[ $package == 115life-desktop-bin ]]; then
    runuser -u builder -- timeout 45s dbus-run-session -- xvfb-run -a \
        bash "$root/scripts/smoke-115life-desktop.sh" > "$root/reports/$package/smoke.log" 2>&1
elif [[ $package == 115life-browser-bin ]]; then
    runuser -u builder -- /usr/bin/115life-browser --version > "$root/reports/$package/version.txt"
elif [[ $package == rustdesk-unattended-wayland ]]; then
    runuser -u builder -- /usr/bin/rustdesk --version > "$root/reports/$package/version.txt"
elif [[ $package == chatgpt-bin ]]; then
    runuser -u builder -- /usr/bin/chatgpt --version > "$root/reports/$package/version.txt"
fi
pacman -R --noconfirm "${names[@]}"
if [[ $package == 115life-desktop-bin ]]; then
    [[ ! -e /opt/115life && ! -L /usr/bin/115life-desktop && ! -L /usr/bin/115pan && ! -L /usr/bin/115life ]]
    [[ ! -e /usr/share/applications/life115.desktop ]]
fi
if [[ $package == 115life-browser-bin ]]; then
    [[ ! -e /opt/115Browser && ! -L /usr/bin/115life-browser ]]
    [[ ! -e /usr/share/applications/115Browser.desktop ]]
fi
if [[ $package == rustdesk-unattended-wayland ]]; then
    [[ ! -e /usr/lib/rustdesk && ! -L /usr/bin/rustdesk ]]
    [[ ! -e /usr/lib/systemd/system/rustdesk.service ]]
    [[ ! -e /usr/share/applications/rustdesk.desktop ]]
fi
if [[ $package == chatgpt-bin ]]; then
    [[ ! -e /usr/lib/chatgpt && ! -L /usr/bin/chatgpt ]]
    [[ ! -e /usr/share/applications/chatgpt.desktop ]]
    [[ ! -e /usr/share/pixmaps/chatgpt.png ]]
fi
