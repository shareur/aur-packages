# 验证：chatgpt-bin 26.1029.61003-1

英文原文：[VALIDATION.md](../../../../packages/chatgpt-bin/VALIDATION.md)。

- 上游：OpenAI 的 APT 仓库 `https://persistent.oaistatic.com/codex-app-prod/linux/deb`，
  包名 `chatgpt`，版本 26.1029.61003 amd64，主页 https://developers.openai.com/codex/app。
- 配方固定使用池路径 `pool/main/c/chatgpt/chatgpt_26.1029.61003_amd64.deb`。厂商同时提供
  浮动的 `/latest/chatgpt_amd64.deb` 别名，内容相同。SHA256 三处一致：本地文件、重新下载的
  固定 URL 文件（558314862 字节）以及 `dists/stable/main/binary-amd64/Packages` 中的 `SHA256:`
  字段，均为 `f3af8afec5d25c228eb6f4dbd9cfde0fea7ca5e4b42aff0145a1ded273d01b2d`。
- control：`Installed-Size: 1797560`（KiB）、`Recommends: git`、conffile
  `/etc/apparmor.d/chatgpt`。Debian 依赖覆盖 Chromium 运行栈、TPM2、libusb、ALSA、CUPS、
  xdg-utils、xz-utils 和 Vulkan ICD。
- 维护者脚本只读取、不执行。`postinst` 写入 `/etc/apt/sources.list.d/chatgpt.sources`、
  APT keyring 与 `/etc/default/chatgpt`，执行 `update-desktop-database` 并（重新）加载随包
  的 AppArmor 配置；`prerm` 卸载该配置；`postrm purge` 删除 APT 文件。这些在 pacman 下都不会
  发生，理由见包说明。
- ELF 检查：`ChatGPT` 链接 alsa、atk、atk-bridge、atspi、cairo、cups、dbus、expat、gbm、
  gdk-pixbuf、gio/glib/gobject、gtk-3、nspr4、nss3、nssutil3、smime3、pango、udev、X11、
  xcb、Xcomposite、Xdamage、Xext、Xfixes、xkbcommon、Xrandr，且没有 RUNPATH。
  `resources/codex`、`resources/codex-code-mode-host`、`resources/tectonic/tectonic` 为静态 PIE；
  自带 Node 运行时只需 glibc 与 gcc-libs；Chromium 自带 libEGL、libGLESv2、libvk_swiftshader
  和 libvulkan.so.1。
- 运行期动态加载的库补充：`libnotify.so.4`、`libpulse`、`libpipewire-0.3`、
  `libEGL`/`libGLESv2`/`libGL`（libglvnd）、`libvulkan`（vulkan-icd-loader）、
  `libxcb-dri3`/`glx`/`present`/`sync`（libxcb）、`libX11-xcb`、`libGLX_nvidia.so.0`
  （nvidia-utils，可选）。原生模块 `resources/native/remote-control-device-key.node` 需要
  `libtss2-mu`、`libtss2-esys`、`libtss2-tcti-device`（tpm2-tss），Work Louder 设备模块需要
  `libusb-1.0.so.0`（libusb）。`libgbm.so.1` 由 `mesa` 提供。
- 声明 `xz` 与 `xdg-utils`，因为 Codex 代理会调用 xz，客户端会调用 `xdg-open`。未照搬 Debian 的
  `libssl3`：BoringSSL 为静态链接，载荷中没有 `libssl`/`libcrypto` 引用。
- Python 列为可选而非硬依赖：多个自带脚本带 `#!/usr/bin/env python3`，Codex 代理也能运行
  Python 代码，但厂商 DEB 并未声明 Python，且客户端不装它也能启动。
- 沙箱：载荷中没有 setuid 辅助程序，也没有 `chrome-sandbox`；启动器只是把参数转发给
  `/usr/lib/chatgpt/ChatGPT`。
- `ChatGPT --version` 输出 `26.1029.61003`，退出码 0，无需显示服务，且不写入 `$HOME`。
- 本地 `makepkg --force --noconfirm` 构建成功，宿主机已具备全部声明依赖（未使用 `--nodeps`）：
  包约 646 MB，安装后 1838897633 字节（重建时归档时间戳变化会让包字节数略有差异）。
  `.SRCINFO` 一致性、包内布局检查（桌面文件语法、
  启动器符号链接目标、必需载荷路径、无 `/usr/share/doc` 与 `/usr/share/lintian`、启动器内容
  未被修改、无 setuid 文件）以及 `desktop-file-validate` 均通过；桌面文件唯一提示是
  `Categories` 含两个主分类。
- namcap 对本包放行恰好 7 条诊断，均已逐条核对：`lib32-gcc-libs`、`lib32-glibc`、
  `lib32-systemd` 来自随包的其他平台（ARM/32 位）`.node` 预编译产物；`java-runtime` 来自设备
  工具模块内的 `.jar` 数据文件；`nodejs` 来自使用自带 Node 运行时执行的 `#!/usr/bin/env node`
  脚本；`python-numpy`、`python-pillow` 来自自带 Python 助手与技能脚本中的可选导入。
- 其余 203 条 namcap 警告记录但不屏蔽：23 条缺 FULL RELRO、28 条非 PIE、12 条未 strip、
  55 条 unused shared library、55 条对自带 `pyproto` Python 模块的引用、16 条对自带私有库的
  引用、`python` 与 `qt6-base` 被判定为可选，以及 `xz`、`xdg-utils`、`vulkan-icd-loader`
  被判定“可能不需要”（它们由运行期进程调用或动态加载）。
- 未测试：宿主安装与卸载（未运行 `test-install.sh`）、GUI 启动、登录、模型访问、Codex 任务
  执行、沙箱实际生效、Wayland/X11 渲染、AppArmor 配置加载，以及远程 CI。
