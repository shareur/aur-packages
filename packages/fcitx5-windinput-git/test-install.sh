#!/usr/bin/env bash
# 交互式 sudo；安装、检查、卸载后再恢复。Fcitx5 输入法不在无桌面会话下启动，
# 这里只做安装完整性 / 动态库可解析 / 卸载残留检查（沿用上游 deb CI 的冒烟口径）。
set -euo pipefail
mapfile -t packages < <(makepkg --packagelist)
[[ ${#packages[@]} == 1 && -f ${packages[0]} ]]
sudo pacman -U --noconfirm "${packages[0]}"
pacman -Qkk fcitx5-windinput-git
# 三个 ELF 不能有未解析到包的动态库：“装得上、一加载就找不到 so”是这类包最常见的静默坏法。
for f in /usr/lib/windinput/wind_input /usr/lib/windinput/wind_setting \
         /usr/lib/fcitx5/libwindinput.so; do
    [[ -f $f ]] || { echo "Missing: $f" >&2; exit 1; }
    if ldd "$f" | grep 'not found'; then
        echo "Unresolved shared library in: $f" >&2; exit 1
    fi
done
# addon 描述与数据目录必须在位。
[[ -f /usr/share/fcitx5/addon/windinput.conf ]]
[[ -f /usr/lib/windinput/data/schemas/pinyin/cn_dicts/base.dict.yaml ]]
restore() { sudo pacman -U --noconfirm "${packages[0]}"; }
trap restore EXIT
sudo pacman -R --noconfirm fcitx5-windinput-git
for path in /usr/lib/windinput /usr/lib/fcitx5/libwindinput.so \
            /usr/share/fcitx5/addon/windinput.conf \
            /usr/share/fcitx5/inputmethod/windinput.conf \
            /usr/share/applications/windinput-setting.desktop \
            /usr/share/applications/windinput-import.desktop \
            /usr/share/mime/packages/windinput.xml \
            /usr/share/licenses/fcitx5-windinput-git; do
    [[ ! -e $path && ! -L $path ]] || { echo "Leftover package path: $path" >&2; exit 1; }
done
echo 'Removal verified; restoring package.'
