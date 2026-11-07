# 115life-browser-bin

将官方 **115浏览器** DEB 重打包为 Arch Linux / CachyOS x86_64 软件包。
维护者：**Yang <shareur@imyang.me>**，配方版本：**36.0.1-1**。

英文原文：[README.md](../../../../packages/115life-browser-bin/README.md)。

## 安装与使用

```bash
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/115life-browser-bin
makepkg -si
115life-browser
```

以普通用户运行；菜单入口为“115浏览器”。KDE Wayland 可能需要 XWayland、相应驱动与字体。
拉取仓库更新后重新运行 makepkg -si；卸载使用 `sudo pacman -R 115life-browser-bin`，
保留用户配置和下载文件。

配方将原 `/usr/local/115Browser` 迁移到 `/opt/115Browser`，同步启动脚本和桌面入口；
保留厂商库加载方式。按照原 postinst 要求，将 chrome-sandbox 安装为 root 所有、4755
权限，不执行厂商安装脚本，不添加 --no-sandbox，不修改默认浏览器或用户设置。
桌面客户端位于 `/opt/115life`，桌面文件和图标不同，两个包的文件可共存。

## 验证与限制

在仓库根目录运行 `bash scripts/validate.sh 115life-browser-bin`。
关闭浏览器后，可运行 `bash scripts/test-local-install.sh 115life-browser-bin`，
交互测试安装、卸载与恢复；该操作需要 sudo 并会修改系统安装。

已重新下载官方 DEB 比对 SHA256。检查包括元数据、桌面文件、迁移路径及沙箱权限。
版本命令返回 **115Browser 125.0.6422.61**，与产品版本 36.0.1 不同；重打包不会升级内核。
实际验证结果见 [VALIDATION.md](VALIDATION.md)。

仅对明确命名的厂商二进制包允许 namcap 的 /opt 布局诊断；记录自带库、RELRO 和可选
Qt 桥接库警告，不笼统忽略错误。GTK3 为必需依赖，Qt5/Qt6 集成为可选依赖，
自带 OpenSSL 1.1 保留在应用目录。

CI 检查安装、卸载和 --version，不代表实际 GUI 与沙箱可用；宿主安装、窗口启动、
登录、传输和播放仍待测试。

## 许可与发布

原 DEB 没有独立许可证或第三方声明文件。本地 LICENSE 仅记录这一限制并指向厂商版权
信息和 chrome://credits，不授予厂商软件的再分发权。再分发或提交 AUR 前须核对上游条款。
仓库只维护配方，AUR 自动发布保持关闭；.aur-files 列出了构建必需的本地 LICENSE 文件。
