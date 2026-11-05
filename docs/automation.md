# 后续自动发布

第一阶段只运行 validate.yml 和 upstream.yml，发布由维护者手动执行。GitHub master 是配方唯一维护源；AUR 每个 pkgbase 使用独立仓库。请勿在 AUR 直接修改后再反向覆盖 GitHub。

旧单包方案保存在 aur-publish.yml.disabled 和 build-single-package.yml.disabled，仅作为迁移参考，路径仍是旧版，不可直接启用。它们位于 docs，不会被 Actions 执行。

首个软件包手动成功上线后，第二阶段可以增加 publish.yml：

1. 手动 workflow_dispatch 选择包名和完整 master SHA；检查变更包，复用按包隔离构建。
2. 验证同一 SHA 的 PKGBUILD、SHA256、.SRCINFO、安装/卸载，并人工确认桌面功能。
3. 对 aur-publish Environment 配置 Required reviewers、Prevent self-review、禁止管理员绕过、仅允许 master。只写 YAML 不会建立这些保护。
4. AUR_SSH_PRIVATE_KEY 和经独立指纹核验的 AUR_KNOWN_HOSTS 仅放入该 Environment；PR 验证任务没有 secrets，不使用 pull_request_target 执行 PR 代码。
5. 审批后从同一提交导出所选包配方，调用按包发布脚本推送对应 AUR 仓库，不强推，不上传二进制。

GitHub 账号方案需支持环境审批规则，参见 [官方文档](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)。目前没有启用任何自动发布任务。
