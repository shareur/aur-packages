# rustdesk-unattended-wayland

将 RustDesk 官方 **无人值守（unattended）Wayland** Linux x86_64 DEB 重打包为
Arch Linux / CachyOS 软件包。维护者：**Yang <shareur@imyang.me>**，配方版本：**1.5.1-1**。

英文原文：[README.md](../../../../packages/rustdesk-unattended-wayland/README.md)。

## 这是哪个上游构建

RustDesk 为 Linux 发布多个安装包。本配方使用 `rustdesk-unattended-wayland` DEB，其中带有厂商的
`libdrmtap` 库（位于 `/usr/lib/rustdesk/`）。该库通过 DRM/KMS 直接采集屏幕，无需交互式共享授权；
DRM 采集不可用时会回退到 PipeWire / XDG Desktop Portal。配方只重新打包官方二进制，
不编译源码，也不需要 Rust 工具链。

包名沿用上游产物名，未使用常见的 `-bin` 后缀；它仍然是对官方 DEB 的二进制重打包。

## 安装

```bash
sudo pacman -S --needed base-devel namcap desktop-file-utils
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/rustdesk-unattended-wayland
makepkg -si
rustdesk
```

以普通用户运行 `makepkg`。配方从 GitHub Releases 下载固定版本的官方 DEB，并在打包前校验 SHA256。
更新时拉取仓库并重新运行 `makepkg -si`；卸载使用
`sudo pacman -R rustdesk-unattended-wayland`，`~/.config/rustdesk` 中的用户配置与接收的文件保留。

配方按厂商 control 数据声明 `provides`/`conflicts` 为 `rustdesk`，因此不能与其他提供 `rustdesk`
的软件包（例如 `rustdesk-bin`）同时安装；pacman 会在同一事务中要求移除冲突包。

## 无人值守访问

配方安装 `/usr/lib/systemd/system/rustdesk.service`，但**不会启用或启动它**：Arch 软件包不应
自行开启以 root 运行的远程桌面服务，否则等于把本机暴露到网络。请在客户端中确认连接设置并设置
固定密码后再手动启用：

```bash
sudo systemctl enable --now rustdesk    # 立即启动并设置开机自启
systemctl status rustdesk
sudo systemctl disable --now rustdesk   # 停止并取消开机自启
```

该单元以 root 运行 `/usr/bin/rustdesk --service`，这是未登录桌面即可接受连接的前提。
配方只改动一处：`ExecStop` 使用绝对路径 `/usr/bin/pkill`，因为 systemd 拒绝非绝对可执行路径。
本包不添加或修改任何防火墙规则、端口转发或中继配置。

## 包布局与对 DEB 的偏离

- 厂商应用树安装到 `/usr/lib/rustdesk`，而不是 `/usr/share/rustdesk`，因为 ELF 文件不能放在
  `/usr/share` 下。树内布局（启动器、`lib/`、`data/`）保持不变，因此启动器的 `$ORIGIN/lib`
  runpath 与 Flutter 的 `data/` 查找仍然有效。
- `/usr/lib/rustdesk/libdrmtap.so.0*` 因此位于同一目录，仍与编译进 `librustdesk.so` 的绝对路径
  一致；把它挪到别处会直接导致 DRM 采集失效。
- `/usr/bin/rustdesk` 是指向 `/usr/lib/rustdesk/rustdesk` 的符号链接，在构建阶段创建，
  因为配方不执行 Debian 维护者脚本。
- 厂商单元安装到 `/usr/lib/systemd/system/`；Debian 的 `postinst`/`prerm`/`postrm` 仅做检查，
  不会被执行。
- 不做 strip、不拆分 debug 包，与仓库中其他二进制配方一致。

## 验证与限制

在仓库根目录运行：

```bash
bash scripts/validate.sh rustdesk-unattended-wayland
# 需要交互式 sudo；安装、检查、卸载，然后恢复安装
bash scripts/test-local-install.sh rustdesk-unattended-wayland
```

`/usr/bin/rustdesk --version` 输出 `1.5.1`，作为无界面冒烟检查。验证覆盖源文件校验和、构建、
`.SRCINFO` 一致性、namcap、桌面文件语法、包布局（启动器符号链接、DRM 库、单元文件）
以及依据自带 ELF 检查得出的依赖列表。

**未覆盖**：安装后的 GUI 界面、真实的无人值守连接、Wayland 合成器上的 DRM 采集、
PipeWire/portal 回退、以及 systemd 服务实际运行。构建成功和版本命令通过都不能作为上述任一项的证据。

## 许可

RustDesk 上游采用 **AGPL-3.0-only**。该 DEB 不含独立的许可证文件，第三方声明以
`/usr/lib/rustdesk/data/flutter_assets/NOTICES.Z` 形式随载荷分发，本包原样保留。
本仓库只维护配方，不上传 DEB 或构建产物；仓库自身的 MIT 许可不会重新授权 RustDesk
及其捆绑组件。
