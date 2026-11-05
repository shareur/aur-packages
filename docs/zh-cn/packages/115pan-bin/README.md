# 115pan-bin

将 115 官方 **115生活** Linux x86_64 DEB 重打包为 Arch Linux / CachyOS 软件包；无需编译、无需系统 .NET。当前配方为 **37.3.2-2**，不是 115浏览器。

## 安装与更新

```bash
sudo pacman -S --needed base-devel namcap desktop-file-utils
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/115pan-bin
makepkg -si
```

当前目录已有官方 DEB 时，makepkg 会先校验并使用它；否则从固定的 HTTPS 官方地址下载。菜单入口是“115生活”，命令为 `115pan`（亦保留官方 `115life`）。KDE Wayland 下通过 XWayland 运行，需有 `xorg-xwayland`；图形驱动与系统字体由桌面系统提供。源码仓库和 AUR 仅发布配方，不上传 DEB 或打好的二进制包。

更新配方后再次运行 `makepkg -si`。不要依赖应用内更新来覆盖 `/opt/115life`，该目录由 pacman 管理。卸载使用 `sudo pacman -R 115pan-bin`；用户配置、登录信息和下载文件保留。协议关联可在 KDE 系统设置中选择，本包不强制覆盖 MIME 默认值。

## 本地验证

以下命令在仓库的 `packages/115pan-bin/` 目录运行。

```bash
bash ../../scripts/validate.sh 115pan-bin
# 先关闭客户端；验证安装、卸载、文件清理，最后恢复安装（需要 sudo）
bash ../../scripts/test-local-install.sh 115pan-bin
```

验证包括 SHA256、makepkg、`.SRCINFO` 一致性、namcap、桌面文件格式与文件清单。日志在仓库根目录的 `reports/115pan-bin/`。人工检查菜单、登录、上传下载、播放、托盘和协议打开；CI 的 Xvfb 冒烟测试不能替代 KDE 桌面测试。

namcap 对官方 `/opt/115life` 布局报 `ELF files outside of a valid path ('opt/').`，这是本项目唯一允许的错误诊断：保留厂商绝对路径、桌面 ID 和 app-local .NET/ICU 布局，避免破坏客户端内部路径。其余 E 诊断会阻止 CI。RELRO、多余库和“依赖可能不需要”警告来自厂商二进制及 .NET/PInvoke 动态加载；不通过删除运行库或改写二进制来消除。`liblttng-ust.so.0` 用于可选 .NET 跟踪，见 optdepends。完整分析见 [VALIDATION.md](../../../../packages/115pan-bin/VALIDATION.md)。

## 维护与 CI

- 修改版本前人工核对官方 **115生活 Linux** 下载地址、DEB control、桌面入口和许可证；下载后计算 `sha256sum`，更新 `pkgver` / `sha256sums`，上游升级时重置 `pkgrel=1`，仅配方修正则递增 pkgrel。
- 运行 `makepkg --printsrcinfo > .SRCINFO` 和本地验证，提交配方及元数据。维护者为 Yang；不要提交 DEB、构建目录和日志。
- `validate.yml` 在临时 Arch 容器中构建、namcap 检查、安装、Xvfb 启动和卸载；仅上传报告。动态库通过 GTK3 和明确的 X11/WebKitGTK 等依赖提供。
- `upstream.yml` 手动检查官方版本接口，**只报告，不修改、不发布**。目前接口的 `linux` 是浏览器，`linux_115` 返回无效旧地址，因此检查会失败并提示人工核对；不能声称 37.3.2 已确认为最新。接口修复或官方更换端点后需维护检查器。

## AUR 发布

首次采用手动发布，仅发布 PKGBUILD 与 `.SRCINFO`。维护者为 Yang；目前未注册 AUR 账号，暂仅在 GitHub 发布。操作方法见根目录 [README](../../README.md)。

GitHub Actions 目前只做验证与版本检查，不持有 AUR SSH 私钥，不执行发布。此前带人工审批的自动发布方案保存在 [后续自动化说明](../../../automation.md)，首次成功手动发布后再启用。

原 DEB 明示专有部分未经授权不可再分发，本项目不上传 DEB 或构建产物。这里只维护从官方地址下载的打包配方。
