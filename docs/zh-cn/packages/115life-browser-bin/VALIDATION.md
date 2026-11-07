# 验证：115life-browser-bin 36.0.1-1

英文原文：[VALIDATION.md](../../../../packages/115life-browser-bin/VALIDATION.md)。

- 本地 DEB 与重新下载的官方 DEB SHA256 一致：
  `a26f84625b5c1ca1a7f6e2eb5a89327c49627fb7f04db1b71e27c48904b88d8b`。
- control 为 115browser 36.0.1 amd64；未找到独立许可声明，本地 LICENSE 只是信息说明。
- 原 postinst 仅设置启动器权限与沙箱 helper 的 root 所有权、4755 权限，配方不执行它。
- 主程序迁至 /opt/115Browser；保留 115Browser.desktop，修正启动器和图标路径。
- ELF 检查覆盖 GTK3、NSS/NSPR、ALSA、CUPS、GBM/Mesa、AT-SPI、X11/XCB 等；
  自带 curl 额外需要 libidn2/zlib，Qt 桥接库保留并列入可选依赖。
- 未安装的原始主程序以应用库路径运行 --version，输出 115Browser 125.0.6422.61。
- 不编译源码，不禁用沙箱，不设置系统默认浏览器；保留应用内 OpenSSL 1.1。
- makepkg 构建、SHA256、.SRCINFO、namcap、桌面文件、迁移路径和 root/4755 沙箱检查通过。
  仅接受具体包的 /opt 诊断；记录厂商 RELRO、setuid、可选 Qt5、自带 OpenSSL 和 unused-library
  警告。厂商桌面文件 Comment 与 Name 相同，产生非致命提示。
- ShellCheck、文档链接、工作流 YAML 和双包矩阵发现通过。两个构建产物的非目录文件无重叠，
  这只是文件级共存证据，不代表已经执行同时安装测试。
- 未执行宿主安装/卸载、实际 GUI/沙箱、登录、传输、播放；未提交，所以尚无该包远程 CI。
