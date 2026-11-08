# aur-packages

[![Validate](https://github.com/shareur/aur-packages/actions/workflows/validate.yml/badge.svg?branch=master)](https://github.com/shareur/aur-packages/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../../LICENSE)

由 **Yang**（shareur@imyang.me）维护的 Arch Linux / CachyOS 打包配方，统一托管于 [shareur/aur-packages](https://github.com/shareur/aur-packages)。

英文原文：[README.md](../../README.md)

## 目录

- [项目定位](#项目定位)
- [软件包](#软件包)
- [环境要求](#环境要求)
- [安装](#安装)
- [维护与验证](#维护与验证)
- [持续集成](#持续集成)
- [仓库结构](#仓库结构)
- [贡献、安全与许可](#贡献安全与许可)
- [支持](#支持)
- [后续 AUR 发布](#后续-aur-发布)

## 项目定位

本仓库包含 Arch Linux 与 CachyOS 的打包配方、共享辅助脚本与文档，是打包项目，不是被打包应用的分支。

- 只发布配方与文档，不托管 DEB、构建产物或下载的源码。
- 上游应用保留各自的许可证与 issue 跟踪；应用本身的 Bug 请反馈给上游，配方问题请在本仓库反馈。
- 仓库自有配方、脚本与文档采用 MIT；第三方应用及随包组件保留各自许可证。
- GitHub `master` 是唯一维护源；AUR 发布目前关闭，见 [后续 AUR 发布](#后续-aur-发布)。

## 软件包

| 软件包 | 版本 | 说明 | CI |
| --- | --- | --- | --- |
| [115life-desktop-bin](packages/115life-desktop-bin/) | 37.3.2-3 | 115 生活桌面客户端（二进制发布） | 构建、安装/卸载、Xvfb 窗口 |
| [115life-browser-bin](packages/115life-browser-bin/) | 36.0.1-1 | 115 浏览器（Chromium，二进制发布） | 构建、安装/卸载、版本 |
| [rustdesk-unattended-wayland](packages/rustdesk-unattended-wayland/) | 1.5.1-1 | RustDesk 面向无人值守访问的 Wayland 客户端（二进制发布） | 构建、安装/卸载、版本 |
| [chatgpt-bin](packages/chatgpt-bin/) | 26.1029.61003-1 | OpenAI ChatGPT 桌面应用（二进制发布） | 构建、安装/卸载、版本 |
| [fcitx5-windinput-git](packages/fcitx5-windinput-git/) | 0.130.1.r41.gc70da4c-1 | 清风输入法 WindInput 的 Fcitx5 引擎，源码构建 | 构建、安装/卸载 |

每个包都有独立说明，包含依赖、限制与验证状态；历史测试记录见各自的 `VALIDATION.md`，CI 结果见 Actions 页面。

## 环境要求

- Arch Linux 或 CachyOS，`x86_64`。
- 验证需要 `base-devel`（含 `makepkg`）、`namcap`、`desktop-file-utils`、`shellcheck`。
- 源码构建的包需要其声明的构建依赖；`makepkg --syncdeps` 会自动解决。

## 安装

```bash
sudo pacman -S --needed base-devel namcap desktop-file-utils shellcheck
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/fcitx5-windinput-git
makepkg -si
```

构建前请先阅读 PKGBUILD，并以普通用户运行 `makepkg`。源码来自上游，除已注明的 VCS 源外均使用固定校验和验证；本仓库不托管官方 DEB 或构建产物。

更新时在仓库执行 `git pull --ff-only`，再到包目录运行 `makepkg -si`。卸载运行 `sudo pacman -R <pkgname>`；用户配置与下载文件保留。

## 维护与验证

配方及辅助文件位于 `packages/<pkgbase>/`，共享工具在 `scripts/`，工作流在 `.github/workflows/`。

```bash
# 在仓库根目录执行；省略包名则验证所有包。
bash scripts/validate.sh <pkgbase>
shellcheck scripts/*.sh
# 会通过 sudo 安装/卸载/恢复宿主软件包，运行前请先关闭客户端。
bash scripts/test-local-install.sh <pkgbase>
```

`scripts/validate.sh` 会校验源码、构建、重新生成并比较 `.SRCINFO`、运行 `namcap`、运行可选的 `check-package.sh`，并记录清单与 SHA256。它有两条约定：

- 对 VCS 包（PKGBUILD 定义了 `pkgver()`），`.SRCINFO` 比较会忽略 `pkgver` 行，因为该值随上游变化；其余元数据仍严格比较。
- `makepkg` 在 `debug` 选项下生成的 `*-debug` 包不参与 lint 与包检查，因为其 `/usr/lib/debug/.build-id` 软链指向主包内文件。源码构建的 WindInput 配方另外显式关闭了 `debug` 与 `lto`。

PKGBUILD 改动后请重新生成 `.SRCINFO`，并在提交前完成验证。日志写入 `reports/<pkgbase>/`，已忽略。

## 持续集成

`validate.yml` 会挑选本次推送或 PR 改动的包，在一次性 `archlinux:base-devel` 容器中逐个构建、安装、检查、卸载，并且只上传报告。改动 `scripts/` 或 `.github/workflows/` 会验证所有包。`upstream.yml` 仅手动检查某上游版本，绝不修改配方或发布。CI 通过不能替代交互式桌面测试；每个包说明都会写明未验证的内容。

## 仓库结构

    packages/<pkgbase>/     配方、.SRCINFO、说明、VALIDATION.md、可选检查
    scripts/                共享验证、CI 与发布脚本
    .github/workflows/      CI 工作流
    docs/                   项目文档与发布说明
    docs/zh-cn/             中文文档，保持相同相对路径

## 贡献、安全与许可

- 贡献指南：[CONTRIBUTING.md](CONTRIBUTING.md)
- 安全策略与私下报告：[SECURITY.md](SECURITY.md)
- 行为准则：[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- 许可证：[LICENSE](../../LICENSE)（仓库自有文件为 MIT；第三方应用保留各自许可证）
- 英文原文：[README.md](../../README.md)

## 支持

- 配方问题、构建失败与文档问题：在本仓库开 issue。
- 安全报告：按 [SECURITY.md](SECURITY.md) 通过邮件私下联系维护者。
- 应用 Bug 与功能请求：请联系上游项目，本仓库只做打包。

## 后续 AUR 发布

维护者目前还无法注册 AUR 账号，因此发布保持关闭。注册后每个 pkgbase 使用独立 AUR 仓库；手动发布脚本默认只预览，`--push` 才提交并发布，且需明确授权。详见 [发布说明](../automation.md)；`.disabled` 工作流示例仅为历史参考，不能直接启用。

## 命名约定

`115life-desktop-bin` 为生活桌面客户端；`115life-browser-bin` 为独立的 Chromium 浏览器配方；`rustdesk-unattended-wayland` 为 RustDesk 面向无人值守访问的 Wayland 构建；`chatgpt-bin` 为 OpenAI 的 ChatGPT 桌面应用；`fcitx5-windinput-git` 为清风输入法 WindInput 的 Fcitx5 引擎（源码构建）。
