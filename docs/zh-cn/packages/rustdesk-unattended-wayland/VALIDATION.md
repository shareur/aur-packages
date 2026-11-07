# 验证：rustdesk-unattended-wayland 1.5.1-1

英文原文：[VALIDATION.md](../../../../packages/rustdesk-unattended-wayland/VALIDATION.md)。

- 上游 DEB：https://github.com/rustdesk/rustdesk/releases/download/1.5.1/rustdesk-unattended-wayland-1.5.1-x86_64.deb
- 本地 DEB 与重新下载的官方文件 SHA256 一致：
  `f7760dad505b5eca1e99531f15b4de21e83acc7dbfce77a3ba456ef2afb0e961`。
- control：`rustdesk-unattended-wayland` 1.5.1 amd64，声明
  `Provides`/`Conflicts`/`Replaces: rustdesk`。Debian `Depends` 含 GTK3、xcb-randr/xcb-shape/
  xcb-xfixes、libxdo、libxfixes、ALSA、libsystemd、curl、VA-API、GStreamer pipewire、
  libdrm、libEGL/libGLES2 与 libc；`Recommends: libayatana-appindicator3-1`。
- 维护者脚本只读取、不执行。`postinst` 创建 `/usr/bin/rustdesk`、把单元复制到
  `/usr/lib/systemd/system/` 并执行 `systemctl daemon-reload/enable/start`；`prerm` 停止服务
  并删除启动器与单元；`postrm purge` 删除 `/root/.config/rustdesk`。配方只复现启动器与单元的安装。
- 对 `rustdesk`（Flutter/Gtk 启动器）、`librustdesk.so`、`libflutter_linux_gtk.so` 与
  `libdrmtap.so.0.5.12` 的 ELF 检查得出配方声明的依赖：glibc、gcc-libs、zlib、glib2、gtk3、
  gdk-pixbuf2、pango、cairo、at-spi2-core、libepoxy、fontconfig、dbus、libpulse、gstreamer、
  gst-plugins-base、libx11、libxfixes、libxtst、libxcb、libxkbcommon、wayland、libdrm、libva、
  libglvnd。`dlopen` 字符串另外引用 `libxdo`（xdotool）、`libxkbcommon-x11`、`libXi`、
  `libva-drm`/`libva-x11`、两种 AppIndicator 库，以及可选的 NVIDIA NVENC 与 Intel 媒体栈。
- 自带二进制中未发现 libcurl、libsystemd、libpam、libvdpau 或 libasound 的引用，因此没有照搬
  Debian 的这几项依赖：音频走 libpulse，`procps-ng` 则因为单元的 `ExecStop` 调用
  `/usr/bin/pkill` 而声明。
- `librustdesk.so` 内含绝对字符串 `/usr/lib/rustdesk/libdrmtap.so.0`，启动器 RUNPATH 为
  `$ORIGIN/lib`。因此应用树安装到 `/usr/lib/rustdesk/`（合法的 ELF 位置），并把
  `libdrmtap.so.0*` 放在同一目录，两处查找都能成立；没有任何自带二进制引用
  `/usr/share/rustdesk`。
- 厂商单元原样安装，仅把 `ExecStop=pkill` 改为 `/usr/bin/pkill`，因为 systemd 要求绝对路径。
- 在已打包但未安装的目录中运行 `--version` 输出 `1.5.1`。
- 本地 `makepkg` 构建、`.SRCINFO` 一致性、namcap、桌面文件语法，以及启动器/DRM 库/单元布局
  断言全部通过。
- 本机未安装 `xdotool`，`scripts/validate.sh` 会在 makepkg 的运行时依赖检查处停止。实际用
  `makepkg --nodeps` 构建，其余校验步骤单独执行，因此**本地未验证依赖解析**；`makepkg -si`
  与 CI 环境需要先具备 `xdotool`。
- namcap 对厂商 Flutter 插件报 9 条
  `Insecure RUNPATH '/workspace/flutter/linux/flutter/ephemeral'`。`scripts/validate.sh`
  仅对这个包、仅对这一诊断放行：该路径是厂商构建目录，在 Arch 上不存在、非特权用户也无法创建，
  且只有在真实库路径查找失败后才会被使用；要消除它需要用 patchelf 改写厂商 ELF 头。
  其余诊断记录但不屏蔽：11 条 FULL RELRO、11 条未 strip、1 条非 PIE 辅助库、87 条 unused
  shared library、1 条对私有库 `libflutter_linux_gtk.so` 的引用、若干条针对 dlopen/外部命令
  依赖的“可能不需要”提示，以及 2 条 `x86_64` 与 `$CARCH` 的 PKGBUILD 提示。
- `desktop-file-validate` 提示厂商桌面文件的 `Comment` 与 `GenericName` 重复，属上游非致命问题。
- 未测试：宿主安装与卸载（未运行 `test-install.sh`）、GUI 启动、真实无人值守连接、
  Wayland 合成器上的 DRM 采集、PipeWire/portal 回退、以 root 运行的 systemd 服务，
  以及任何防火墙、端口转发或中继配置。该包尚无远程 CI 结果。
