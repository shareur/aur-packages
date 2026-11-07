# fcitx5-windinput-git

清风输入法 **WindInput**（开源中文输入法：五笔/拼音/双拼）的 Arch Linux / CachyOS
**Fcitx5 引擎源码包**。维护者：**Yang <shareur@imyang.me>**，跟踪上游 `main`
（撰写时为 `0.130.1.r41.gc70da4c-1`）。

英文原文：[README.md](../../../../packages/fcitx5-windinput-git/README.md)

## 这是什么

WindInput 的 Linux 版以 Fcitx5 输入法引擎的形式工作。上游只发 `.deb`，**没有官方 AUR 包**
（`docs/design/linux-port.md` 明确记录 Arch/PKGBUILD「尚未做」）；AUR 上现有
`fcitx5-windinput-bin` 是重打包该 `.deb`。本配方改为**全部从上游 Git 仓库源码构建**：

| 组件 | 来源 | 安装位置 |
| --- | --- | --- |
| 引擎服务（Rust，`wind_input`） | `huanfeng/WindInput` | `/usr/lib/windinput/wind_input` |
| 运行时数据（词库、OpenCC 表等） | 构建时 `scripts/dev.sh gd` 生成 | `/usr/lib/windinput/data/` |
| 图形设置程序（`wind_setting`） | `huanfeng/wind-setting`（+ `wind-ui-rust`） | `/usr/lib/windinput/wind_setting` |
| Fcitx5 addon（C++，`libwindinput.so`） | `huanfeng/WindInput`（`wind_linux/`） | `/usr/lib/fcitx5/libwindinput.so` |
| addon / 输入法描述 | `wind_linux/data/*.in` | `/usr/share/fcitx5/{addon,inputmethod}/windinput.conf` |

引擎、词库与候选渲染都在 Rust 服务里；addon 只转发按键、回写上屏/预编辑并自绘候选窗。
服务在可执行文件同目录找 `data/`，故与官方 `.deb` 一样装到 `/usr/lib/windinput/`。

## 安装

```bash
sudo pacman -S --needed base-devel rust cmake pkgconf git curl python
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/fcitx5-windinput-git
makepkg -si
```

必须以普通用户运行 `makepkg`。这是 `-git` 配方：首次构建会克隆三个上游仓库、release 编译
整个 Rust workspace 加 C++ addon，并生成词库数据——**首次构建较慢**。装好后在
「Fcitx5 配置」（`fcitx5-configtool`）里把「清风输入法 / WindInput」加入输入法列表。
升级后执行 `fcitx5 -rd`（或注销重新登录）：pacman 升级时若 Fcitx5 正在运行，旧 addon
要重启后才换新。

卸载用 `sudo pacman -R fcitx5-windinput-git`；用户配置（`~/.config/WindInput`）与用户数据
（`~/.local/share/WindInput`）不会被动。

## 与官方 `.deb` 的差异

- **不运行 Debian 维护脚本。** 官方 `postinst`/`postrm` 会在升级时结束旧 `wind_input`
  服务；pacman 不执行它们，本包也不执行。addon 连不上服务时会自动拉起新版，正在运行的
  Fcitx5 需重启（`fcitx5 -rd`）才换新 addon——这点写在上面的升级说明里，而不是靠脚本静默处理。
- **`compat.toml` 用 Linux 版。** 上游 `data/compat.toml` 的内置规则都是 Windows 宿主专属；
  与 `.deb` 一致，打包时用 `scripts/lib/gen-compat.sh` 生成 Linux 版（字段说明 + 零条内置规则）。
- **依赖改成 Arch 包名**，并用 `ldd` 核对链接库，见下。

## 依赖

必需：`fcitx5`（引擎框架及其 addon CMake/头文件）、`glibc`、`gcc-libs`、`libxcb`
（X11 候选窗，xcb/shape/randr）、`wayland`（Wayland 候选窗）、`glib2`（GNOME 光标扩展
客户端，gio）、`fontconfig`（服务运行时打开、设置程序渲染用）、`libxkbcommon`、
`hicolor-icon-theme`。

可选：`fcitx5-gtk` / `fcitx5-qt`（GTK/Qt 应用的输入法前端）、`xclip`（X11 剪贴板）或
`wl-clipboard`（Wayland 剪贴板）、`xdg-utils`、`xdg-desktop-portal` + `zenity`（设置程序
文件对话框）、`noto-fonts-cjk`（中文候选字形）、`noto-fonts-emoji`（emoji 候选）。

addon 绑定发行版 `fcitx5` 的 ABI；因为是 `-git` 包，会针对你本机 Fcitx5 重建，因此也能
自动适配 Arch 较新的 5.1.x 头文件（自动升 C++20）。

## 可复现性与联网

运行时词库**不在**上游 Git 树里。`scripts/dev.sh gd` 在构建期从多个上游仓库下载原始词库
（`gaboolic/rime-frost`、`mozillazg/pinyin-data`、`BYVoid/OpenCC`、`KyleBing/rime-wubi86-jidian`，
以及可选的 `rime-stroke`/`rime-emoji`/Unicode CLDR），再用自带的 `wind-tools` Rust 工具与
`python3` 脚本（`scripts/comment_dicts`）派生表。**这些上游 URL 目前未固定到具体 commit/版本**，
不同时间构建可能得到不同结果。故本配方**不声称可复现或可离线构建**；把数据源 pin 到固定
commit（并预置 `.cache/`）是后续要做的加固。

应用源码本身取自上述三个 Git 仓库（VCS 源，`SKIP` 校验、跟踪默认分支，这是 `-git` 包的常规做法）。

## 已知限制

- **预览状态**：上游把 Linux 版标注为预览/测试版。
- **GNOME（Wayland）**：原生应用的光标定位需要随包的 Shell 扩展
  （`windinput-caret@windinput`）；本配方不自动启用。
- **KDE Plasma（Wayland）**：在「系统设置 → 键盘 → 虚拟键盘」选「Fcitx 5」并重新登录；
  Wayland 原生应用**不要**设 `QT_IM_MODULE`/`GTK_IM_MODULE`。详见上游
  `wind_linux/README.md`（装到 `/usr/share/doc/windinput/`）。
- 应用各自记输入法状态，新开应用从键盘布局起步；想全局一致，在 Fcitx5 全局选项把
  「共享输入状态」设为「所有」。

## 验证与局限

在仓库根目录：

```bash
bash scripts/validate.sh fcitx5-windinput-git           # 源码、构建、.SRCINFO、namcap、布局、sha256
bash scripts/test-local-install.sh fcitx5-windinput-git # 交互式 sudo；安装/检查/卸载/恢复
```

`check-package.sh` 校验 addon 安装路径与描述、关键词库的存在与最小体积（对齐上游
`scripts/dev.sh` 的 `verify_dist_data` 发版门槛）、OpenCC 至少产出一张 `.octrie`、
`compat.toml` 不含内置规则、desktop 语法、以及无 Debian 打包残留。`test-install.sh`
安装后确认三个 ELF（`wind_input`、`wind_setting`、`libwindinput.so`）没有未解析的共享库，
再卸载并检查残留。

未覆盖：真实桌面会话里经 Fcitx5 实际打字、X11/Wayland 候选窗渲染、GNOME Shell 扩展、
`im-config`/桌面集成、以及可复现构建。构建与安装成功不能作为以上任一项的证据。

## 许可

应用本体为 GPL-3.0-or-later。随包词库/派生表适用各自的第三方许可（如 rime-frost/OpenCC/
rime-wubi 数据、rime-stroke 与 rime-emoji 的 LGPL、CC-CEDICT 的 CC BY-SA、CLDR 的 Unicode 许可）；
上游 `NOTICE.md` 逐条列明，并装到 `/usr/share/licenses/fcitx5-windinput-git/NOTICE.md`。
本仓库只维护配方，不托管源码或构建产物，其自有 MIT 许可不对 WindInput 及其随包数据再授权。
