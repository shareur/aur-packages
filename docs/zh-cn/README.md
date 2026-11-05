# aur-packages

由 **Yang**（shareur@imyang.me）维护的 Arch Linux / CachyOS 打包配方，统一托管于
[shareur/aur-packages](https://github.com/shareur/aur-packages)。

英文原文：[README.md](../../README.md)。GitHub `master` 是唯一维护源。
目前仅在 GitHub 发布；维护者尚无 AUR 账号，AUR 发布保持关闭。

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
[历史验证记录](../../packages/115life-desktop-bin/VALIDATION.md)。

仓库只发布配方、脚本、文档及 CI 检查日志，不上传官方 DEB 或构建产物。
卸载运行 `sudo pacman -R 115life-desktop-bin`，用户配置与下载文件保留。
更新时在仓库运行 `git pull --ff-only`，再到软件包目录运行 `makepkg -si`。

## 维护

配方及辅助文件位于 `packages/<pkgbase>/`，共享脚本在 `scripts/`。
新增软件包应提供 PKGBUILD 与匹配的 .SRCINFO；运行验证后再提交。
不传包名的 `bash scripts/validate.sh` 会检查所有包，日志位于 `reports/<pkgbase>/`。

CI 在临时 Arch 容器中验证变更包，执行构建、安装和卸载；115life-desktop-bin 另检查
Xvfb 会话中是否出现可见窗口。自动化 GUI 检查不等同于完整 KDE 功能测试。
官方版本接口目前无效，因此版本检查仅支持手动触发，不自动升级或发布。

AUR 注册恢复后，核对账号权限与包名，再按
[手动发布说明](../automation.md)处理。发布脚本默认只预览；`--push` 才提交并发布，
必须获得明确授权。旧禁用工作流仅供参考，不能直接启用。

仓库自有配方、脚本与文档采用 MIT；第三方软件仍适用上游许可证。

命名约定：115life-desktop-bin 为生活桌面客户端，115life-browser-bin 用于未来的浏览器配方。
两者均使用官方 DEB 中的预编译二进制进行重打包，不编译源码；当前仓库只包含桌面客户端。
