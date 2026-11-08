# aur-packages

由 **Yang**（shareur@imyang.me）维护的 Arch Linux / CachyOS 打包配方，统一托管于
[shareur/aur-packages](https://github.com/shareur/aur-packages)。

英文原文：[README.md](../../README.md)。GitHub `master` 是唯一维护源。
目前仅在 GitHub 发布；维护者尚无 AUR 账号，AUR 发布保持关闭。

浏览器配方：[115life-browser-bin 36.0.1-1](packages/115life-browser-bin/README.md)，
本地构建与版本检查完成，宿主安装和 GUI 待验证。

RustDesk 配方：[rustdesk-unattended-wayland 1.5.1-1](packages/rustdesk-unattended-wayland/README.md)，
本地构建与版本检查完成；宿主安装、systemd 服务、无人值守连接和 GUI 均待验证。

ChatGPT 配方：[chatgpt-bin 26.1029.61003-1](packages/chatgpt-bin/README.md)，
本地构建与版本检查完成；宿主安装、GUI 与登录均待验证。

FCITX5 配方：[fcitx5-windinput-git 0.130.1.r41.gc70da4c-1](packages/fcitx5-windinput-git/README.md)，
从源码构建 WindInput 引擎、Fcitx5 addon 与运行时词库；本地构建与包布局校验完成，宿主安装与实际输入待验证。

## 安装与验证

```bash
sudo pacman -S --needed base-devel namcap desktop-file-utils
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/115life-desktop-bin
makepkg -si
cd ../..
bash scripts/validate.sh 115life-desktop-bin
```

当前配方为 **115life-desktop-bin 37.3.2-3**。旧包名下已验证本地安装、KDE 菜单与登录界面、
卸载及恢复；更名后的安装迁移尚待验证。登录后的传输和播放仍待用户验证。详细信息见
[软件包说明](packages/115life-desktop-bin/README.md)及
[历史验证记录](packages/115life-desktop-bin/VALIDATION.md)。

仓库只发布配方、脚本、文档及 CI 检查日志，不上传官方 DEB 或构建产物。
卸载运行 `sudo pacman -R 115life-desktop-bin`，用户配置与下载文件保留。
更新时在仓库运行 `git pull --ff-only`，再到软件包目录运行 `makepkg -si`。

## 维护

配方及辅助文件位于 `packages/<pkgbase>/`，共享脚本在 `scripts/`。
新增软件包应提供 PKGBUILD 与匹配的 .SRCINFO；运行验证后再提交。
不传包名的 `bash scripts/validate.sh` 会检查所有包，日志位于 `reports/<pkgbase>/`。

CI 在临时 Arch 容器中验证变更包，执行构建、安装和卸载；115life-desktop-bin 另检查
Xvfb 会话中是否出现可见窗口。自动化 GUI 检查不等同于完整 KDE 功能测试。
浏览器包、RustDesk 包与 ChatGPT 包另外检查 --version，尚不进行 GUI 测试。生活桌面版的官方版本接口目前无效，因此版本检查仅支持手动触发，不自动升级或发布。

RustDesk 包只安装 `rustdesk.service`，不会启用它；无人值守访问需由管理员在确认设置后手动开启，
详见该包说明。

AUR 注册恢复后，核对账号权限与包名，再按
[手动发布说明](../automation.md)处理。发布脚本默认只预览；`--push` 才提交并发布，
必须获得明确授权。旧禁用工作流仅供参考，不能直接启用。

仓库自有配方、脚本与文档采用 MIT；第三方软件仍适用上游许可证。

命名约定：115life-desktop-bin 为生活桌面客户端，115life-browser-bin 为独立的 Chromium 浏览器配方，
rustdesk-unattended-wayland 为 RustDesk 面向无人值守访问的 Wayland 构建，
chatgpt-bin 为 OpenAI 的 ChatGPT 桌面应用。
前四者重打包上游预编译二进制；fcitx5-windinput-git 从源码构建。当前仓库包含五个独立配方。

## 贡献、安全与许可

- 贡献指南：[CONTRIBUTING.md](CONTRIBUTING.md)
- 安全策略与私下报告：[SECURITY.md](SECURITY.md)
- 行为准则：[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- 许可证：[LICENSE](../../LICENSE)（仓库自有配方、脚本与文档为 MIT；第三方软件及随包组件保留各自许可证）
- 发布流程：[自动化与发布说明](../automation.md)
- 英文原文位于仓库根目录。

仓库结构：`packages/<pkgbase>/` 存放配方与包说明，`scripts/` 存放共享工具，`.github/workflows/` 存放 CI，`docs/` 存放项目文档；每个包含自己的 `README.md` 与 `VALIDATION.md`。
