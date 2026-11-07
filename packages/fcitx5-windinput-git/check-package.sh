#!/usr/bin/env bash
# Package-specific layout/内容校验。由 scripts/validate.sh 在打包后调用：
#   bash check-package.sh <package.tar.zst> <reports-dir>
set -euo pipefail
archive=$1
reports=$2
bsdtar -tf "$archive" > "$reports/paths.txt"

# addon 必须落在 Fcitx5 的标准 addon 目录（Arch 为 /usr/lib/fcitx5），
# 且 addon 由库文件名 Library= 与 .so 名对应。
grep -qxF 'usr/lib/fcitx5/libwindinput.so' "$reports/paths.txt"
bsdtar -xOf "$archive" usr/share/fcitx5/addon/windinput.conf > "$reports/windinput-addon.conf"
grep -qxF 'Library=libwindinput' "$reports/windinput-addon.conf"
bsdtar -xOf "$archive" usr/share/fcitx5/inputmethod/windinput.conf > "$reports/windinput-inputmethod.conf"
grep -qxF 'Addon=windinput' "$reports/windinput-inputmethod.conf"

# 服务、设置程序、词库私有目录与 .deb 布局一致。
for path in usr/lib/windinput/wind_input usr/lib/windinput/wind_setting \
            usr/lib/windinput/data/compat.toml \
            usr/share/applications/windinput-setting.desktop \
            usr/share/mime/packages/windinput.xml \
            "usr/share/licenses/fcitx5-windinput-git/NOTICE.md"; do
    grep -qxF "$path" "$reports/paths.txt"
done

# 运行时数据完整性（阈值与上游 scripts/dev.sh 的 verify_dist_data 对齐）：
# 缺失/过小意味着词库下载或派生表生成失败，装上去会表现为“能打字但没候选/不能简繁”。
check_min() { # path min-bytes
    local path=$1 min=$2 size
    grep -qxF "$path" "$reports/paths.txt" || { echo "缺失数据文件: $path" >&2; exit 1; }
    size=$(bsdtar -xOf "$archive" "$path" | wc -c)
    if (( size < min )); then
        echo "数据文件过小: $path ($size < $min)" >&2; exit 1
    fi
}
check_min usr/lib/windinput/data/schemas/pinyin/cn_dicts/base.dict.yaml 1000000
check_min usr/lib/windinput/data/schemas/pinyin/cn_dicts/8105.dict.yaml 10000
check_min usr/lib/windinput/data/schemas/english/en.dict.yaml 1000
check_min usr/lib/windinput/data/pinyin_map.txt 10000
check_min usr/lib/windinput/data/schemas/wubi86/wubi86_jidian.dict.yaml 1000000
check_min usr/lib/windinput/data/schemas/wubi86/wubi86_jidian_extra.dict.yaml 10000
check_min usr/lib/windinput/data/schemas/wubi86/wubi86_jidian_extra_district.dict.yaml 10000
check_min usr/lib/windinput/data/schemas/comments/zh_en.txt 3000000

# OpenCC 简繁转换至少编译出一张非空 .octrie。
grep -qE '^usr/lib/windinput/data/opencc/.+\.octrie$' "$reports/paths.txt"

# Linux 版 compat.toml 必须是零内置规则（不得夹带 Windows 规则表）。
bsdtar -xOf "$archive" usr/lib/windinput/data/compat.toml > "$reports/compat.toml"
if grep -q '^\[\[' "$reports/compat.toml"; then
    echo 'compat.toml 夹带了内置规则表' >&2; exit 1
fi

# 桌面入口语法（CI 容器已装 desktop-file-utils）。
if command -v desktop-file-validate >/dev/null 2>&1; then
    for d in windinput-setting windinput-import; do
        bsdtar -xOf "$archive" "usr/share/applications/$d.desktop" > "$reports/$d.desktop"
        desktop-file-validate "$reports/$d.desktop"
    done
fi

# Debian 打包残留不得进入 Arch 包。
if grep -qE '^(DEBIAN/|usr/share/lintian/)' "$reports/paths.txt"; then
    echo 'Unexpected Debian packaging payload' >&2; exit 1
fi
