# 贡献指南

欢迎为本仓库的打包配方做出改进。本指南说明如何反馈问题、提出变更以及让 pull request 被合并。

## 参与方式

- 报告 Bug：按 issue 模板填写，注明包名与相关信息。
- 报告安全问题：参见 SECURITY.md，通过邮件私下联系维护者，不要开公开 issue。
- 改进软件包：修复配方、更新上游版本或新增配方。
- 改进工具或文档：脚本、工作流、README 与包说明。

## 基本原则

- 以上游为准：配方应遵循 Arch 官方打包规范，并以上游项目为事实来源。
- 不提交二进制：不要提交 DEB、构建产物、构建目录或下载的源码；这些已忽略，也不得加入。
- 不提交机密：绝不提交凭据、令牌、私钥或个人数据。
- 保持聚焦：每个 pull request 解决一件事，不相关的包不要混入。
- 仓库自有文件按仓库许可证（MIT）接受贡献；第三方软件保留各自许可证。

## 开发环境

需要 Arch Linux 或 CachyOS 宿主机，或一次性 Arch 容器。

    sudo pacman -S --needed base-devel namcap desktop-file-utils shellcheck

克隆仓库并在分支上工作：

    git clone https://github.com/shareur/aur-packages.git
    cd aur-packages
    git switch -c my-change

## 包目录结构

每个配方位于独立目录：

    packages/<pkgbase>/
      PKGBUILD            配方
      .SRCINFO            生成的元数据，需提交
      README.md           面向用户的说明（英文）
      VALIDATION.md       已验证与未验证的内容
      check-package.sh    可选的包级检查
      test-install.sh     可选的宿主安装/卸载检查
      download.link       上游下载或仓库地址
      .aur-files          可选，提交到 AUR 的额外文件清单

中文文档放在 `docs/zh-cn/packages/<pkgbase>/`。

## 修改流程

1. 更新版本时修改 `pkgver`/`pkgrel`，更新校验和并用新下载的文件验证。
2. 任何 PKGBUILD 改动后重新生成元数据：

       makepkg --printsrcinfo > .SRCINFO

3. 更新包 README 与 VALIDATION.md，说明改了什么、实际验证了什么；不要把未验证的行为写成已验证。
4. 若改动影响共享行为，请在 `docs/zh-cn/` 下以相同相对路径更新对应中文文档。

## 验证

在仓库根目录执行与改动相关的检查：

    bash scripts/validate.sh <pkgbase>   # 源码、构建、元数据、namcap、包检查
    shellcheck scripts/*.sh              # 修改共享 shell 脚本时

`scripts/validate.sh` 的日志写入 `reports/<pkgbase>/`。在宿主安装软件包会改变系统，请仅在明确需要时执行：

    bash scripts/test-local-install.sh <pkgbase>

不要在宿主机运行 `scripts/ci-build.sh`；它只用于一次性容器。

## 提交信息

使用简短的祈使句，注明包名或范围，例如：

    fcitx5-windinput-git: disable makepkg debug package

不相关改动分开放，不要改写已发布的历史。

## Pull request

一个 pull request 应当：

- 只涉及一个包或一件事；
- 保证 PKGBUILD 与 .SRCINFO 一致；
- 说明已验证与未验证的内容；
- 不包含二进制、构建产物、机密或不相关文件。

CI 在一次性 Arch 容器中构建变更包并检查安装与卸载，仅上传报告。CI 通过不能替代交互式桌面测试；请在 pull request 中明确说明无法验证的部分。

## 许可

提交贡献即表示你同意仓库自有内容按 LICENSE 中的 MIT 许可证授权，且你有权提交这些内容。
