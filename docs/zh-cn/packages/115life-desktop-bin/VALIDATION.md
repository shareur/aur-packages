# 验证记录（2026-11-05）

英文原文：[VALIDATION.md](../../../../packages/115life-desktop-bin/VALIDATION.md)。

以下为旧包 `115pan-bin` 的历史记录，包更名不会将历史测试自动视为新包已验证。

## 上游与环境

- 本机：CachyOS x86_64，KDE Wayland；makepkg 已有，namcap 3.6.0-3 在项目 tools 目录中运行（本机 sudo 要求交互密码）。
- 官方文件：https://down.115.com/client/115pc/lin/115Life_37.3.2.deb
- 本地文件和重新下载的官方文件 SHA256 相同：`b6530f321787c5e7ea4c00ccd0bc6eee1d99b5997f8cda8f701d0dd00c022f7e`。
- DEB control：115life 37.3.2 amd64；自包含 .NET 10.0.10、Avalonia、ICU 72.1.0.3；主程序 `/opt/115life/Life115`。第三方许可在 `/opt/115life/Licenses`。
- 官网首页指向 pc.115.com；该页使用 `appversion.115.com/1/web/1.0/api/chrome?callback=get_version`。linux 字段为 115浏览器 36.0.1，linux_115 为旧版本且 URL 指向本地回环地址。因此无法用该接口确认 115生活最新版本，检查器会明确失败，绝不把浏览器版本当作生活版升级。

## 打包决策

- DEB 只提取 data.tar.xz，不执行 postinst/prerm/postrm，不写共享 mimeapps.list 或 root 的用户配置；桌面和图标缓存交由 Arch 系统 pacman 钩子。
- 保留官方 desktop ID `life115.desktop`、协议和 torrent MIME 声明；新增命令 `115pan`，保留 `115life`。
- 无 strip、无 debug 拆包，保留官方预编译文件；许可证按 LicenseRef-115-Proprietary 声明并安装许可证文件。
- DEB 的 115life 符号链接以 0755 记录；重建为标准 0777，修正首次安装的 pacman -Qkk 权限诊断。
- 补齐三个自带 ICU SONAME 链接，不链接系统不同 ABI 的 ICU。
- GTK/WebKitGTK/libsecret/libnotify/OpenSSL 由托管代码动态加载；Avalonia.X11.dll 可见 libX11、ICE、SM、Xi、Xext、Xrandr、Xcursor、GL 的加载名，作为明确依赖。libffcore 需要 libva/libva-drm/fontconfig。gcc-libs 保持兼容 Arch 的运行时依赖聚合包。

## 已执行及限制

- makepkg 构建、SHA256、desktop-file-validate、namcap 检查已执行；修复许可证 SPDX 标识和 ICU 缺少 SONAME 链接。
- namcap 仍报告官方 /opt 布局（明确豁免）、官方库 FULL RELRO、unused library 和动态加载依赖可能不需要等诊断；不代表零警告。可选跟踪库未安装时有 liblttng-ust 警告。
- 用户已安装 37.3.2-1，并确认 KDE 菜单可见且正常打开登录界面。自动启动命令无输出且立即返回 0，单凭此不能作为 GUI 成功证据；桌面结果以用户确认计。
- 37.3.2-2 增补运行库依赖、ICU 链接和符号链接权限修正。用户执行 `scripts/test-local-install.sh` 已完成升级安装、卸载检查和恢复安装；pacman -Qkk 显示 `387 total files, 0 altered files`，卸载检查输出 `Removal verified; restoring package.`，桌面与图标缓存钩子均正常执行。
- 上传下载、账号登录、视频播放及协议操作需要用户测试；没有使用用户账号执行这些操作。
- CI YAML 已做本地语法检查；未在 GitHub 执行容器测试，不能声称 CI 已通过。版本检查器已用实际官方响应验证为安全失败，并检查了有效版本、新版本、回环地址、错误产品和文件名版本不匹配五种情况。工作流内嵌 shell 经 bash -n 验证，脚本经 shellcheck 验证。
- 没有公开发布、上传二进制、创建远程仓库或推送 AUR；发布默认禁用并要求人工审批。

## Monorepo 迁移验证

- 项目已整理为 `packages/115pan-bin/`，PKGBUILD 和 .SRCINFO 内容保持不变；原始 DEB、构建产物及历史日志保留在本地并排除版本控制。
- 迁移后从仓库外调用通用 `scripts/validate.sh 115pan-bin`，makepkg、SHA256、namcap、桌面文件与元数据一致性检查完成；原有上游二进制诊断继续保留。
- 验证变更检测的首次全量、单包变化、共享脚本变化和仅文档变化四种情形。
- 验证手动发布默认仅预览，Git checkout 保持干净；非法包名和错误 AUR origin 会拒绝。
- ShellCheck、工作流 YAML 与内嵌 Bash 语法检查通过。GitHub CI 尚未远程执行。
- 第一阶段停用自动发布；旧单包工作流移至 docs 下的 .disabled 模板。当前只保留 validate.yml 和 upstream.yml 为可执行工作流。

## 更名为 115life-desktop-bin

- 维护者邮箱改为 shareur@imyang.me；配方修订为 37.3.2-3。
- 新包提供旧包名并与旧包冲突，便于同事务迁移；未添加 replaces，不主动替换系统软件包。
- 新增 115life-desktop 启动入口，保留 115pan 与 115life 兼容命令。
- 上游 DEB、版本和 SHA256 保持不变；未来浏览器配方将使用独立包名 115life-browser-bin。
- 新包 37.3.2-3 的 makepkg 构建、SHA256、.SRCINFO 一致性、namcap（保留既有上游诊断）、桌面文件及 ShellCheck 检查已完成；校验产物含新启动入口和旧包 provides/conflicts 元数据。
- 新包名的实际安装、迁移和 GUI 运行尚未执行；未修改宿主系统安装，尚未执行更名后的远程 CI。
