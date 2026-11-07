# chatgpt-bin

将 OpenAI 官方 **ChatGPT 桌面版**（Codex app）Linux 构建重打包为 Arch Linux / CachyOS x86_64
软件包。维护者：**Yang <shareur@imyang.me>**，配方版本：**26.1029.61003-1**。

英文原文：[README.md](../../../../packages/chatgpt-bin/README.md)。

## 这个包是什么

OpenAI 通过 APT 仓库发布名为 `chatgpt` 的 DEB。应用是 Electron/Chromium 打包体：
`usr/lib/chatgpt/ChatGPT` 是浏览器主进程，`resources/app.asar` 是界面，`resources/codex` 是本地执行
Codex 任务的静态链接 Rust 代理。配方不编译任何源码，除 Debian 专有元数据外厂商载荷原样重打包。

安装后占用约 **1.8 GB**，因为打包体自带 Chromium、Node 运行时、Codex 二进制和 TeX 引擎。

## 安装

```bash
sudo pacman -S --needed base-devel namcap desktop-file-utils
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/chatgpt-bin
makepkg -si
chatgpt
```

以普通用户运行 `makepkg`。配方从 OpenAI 官方软件池下载固定版本的 DEB 并校验 SHA256。
更新时拉取仓库并重新运行 `makepkg -si`；卸载使用 `sudo pacman -R chatgpt-bin`，
用户目录中的登录状态与应用数据不受影响。

## 与官方 DEB 的差异

Debian 维护者脚本只读取、**绝不执行**，因此以下厂商行为在本包中被有意省略：

- **不配置 APT 源。** 官方 `postinst` 会写入 `/etc/apt/sources.list.d/chatgpt.sources`、
  APT keyring 和 `/etc/default/chatgpt`，让应用通过 `apt` 自更新。在 Arch 上这等于引入 pacman
  不认识的第二个更新通道，因此本包的更新只来自本配方，请以 pacman 为唯一更新途径。
- **不自动执行桌面数据库与 AppArmor 操作。** Arch 通过 pacman 钩子维护桌面、图标和 AppStream 缓存。
- **不加载 AppArmor 配置。** 厂商文件 `etc/apparmor.d/chatgpt` 作为配置文件随包安装（列入 `backup`），
  除非本机启用 AppArmor，否则它不生效。该配置只给 `/usr/lib/chatgpt/ChatGPT` 授予非特权 user
  namespace 权限，用于限制 userns 的发行版；Arch 默认允许，因此通常用不到。

另外去掉两处 Debian 路径：`usr/share/doc/chatgpt/copyright` 改安装到
`/usr/share/licenses/chatgpt-bin/copyright`，`/usr/share/lintian/` 下的 1 字节覆盖文件不再随包。
其余内容（含 `/usr/bin/chatgpt` → `../lib/chatgpt/codex-launcher` 符号链接和厂商桌面入口）保持原样。

## 沙箱

打包体内没有 setuid 的 `chrome-sandbox`，Chromium 沙箱依赖 user namespace。请勿添加
`--no-sandbox`：启动器只是把参数原样传给 `/usr/lib/chatgpt/ChatGPT`。

厂商桌面文件注册了 `x-scheme-handler/codex` 以及 `http`、`https` 和若干 Office MIME 类型。
它只是这些链接的**候选**处理程序，不会自动成为默认项；如不需要可在桌面设置中改回。

## 依赖

声明依赖来自对自带二进制的 ELF 检查，以及在运行时由 Chromium 动态加载的库
（`libnotify`、`libpulse`、`libpipewire`、`libglvnd`、`vulkan-icd-loader`）。`mesa` 是必需的，
因为 `libgbm.so.1` 由它提供；`xz` 是必需的，因为 Codex 代理会调用它。
可选部分：`git`（Codex 的版本控制功能）、Qt 5/6 桥接库（原生文件对话框）。
NVIDIA 专有 GLX/Vulkan 驱动为可选，仅在安装后生效。

## 验证与限制

在仓库根目录运行：

```bash
bash scripts/validate.sh chatgpt-bin
# 需要交互式 sudo；安装、检查、卸载，然后恢复安装
bash scripts/test-local-install.sh chatgpt-bin
```

`chatgpt --version` 输出 `26.1029.61003` 且不打开窗口，本地与 CI 都用它做冒烟检查。
验证覆盖源校验和、构建、`.SRCINFO` 一致性、namcap、桌面文件语法、启动器与目标布局、
Debian 元数据是否被清除，以及是否存在 setuid 文件。

**未覆盖**：安装后的 GUI、登录、模型访问、Codex 任务执行、沙箱行为、Wayland/X11 渲染，
以及 AppArmor 配置的实际加载。构建成功和版本命令通过都不能作为上述任一项的证据。

## 许可

该应用为专有软件（上游 AppStream 元数据声明 `LicenseRef-proprietary`），本包采用同一标识。
厂商 `copyright` 文件（覆盖 Electron 及捆绑组件）安装到
`/usr/share/licenses/chatgpt-bin/copyright`，Chromium 组件许可保留在
`/usr/lib/chatgpt/LICENSES.chromium.html`。本仓库只维护配方，不上传 DEB 或构建产物；
仓库自身的 MIT 许可不会重新授权 ChatGPT 及其捆绑组件。
