# Security Policy

## 支持范围

安全修复优先覆盖最新发布版本和 `main` 分支。

## 报告问题

在正式公开仓库建立后，请通过仓库的 Security Advisory 私下报告涉及文件破坏、权限绕过、路径注入或敏感信息泄露的问题。不要在公开 issue 中附带真实私有路径或文件内容。

报告请包含：

- macOS 与 BlankRightKit 版本
- 涉及的动作和文件系统类型
- 最小复现步骤
- 实际影响以及文件是否可恢复

## 安全边界

- BlankRightKit 不需要网络权限。
- Finder 扩展运行在 App Sandbox 中。
- Shell 路径复制使用单引号转义，但 BlankRightKit 自身不执行该字符串。
- 新建与图片转换使用无冲突输出路径，不覆盖源文件。
