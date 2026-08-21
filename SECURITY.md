# Security Policy

## 支持范围

安全修复优先覆盖 `main` 和最新发布版本。早期 MVP 可能只在最新源码中修复问题。

## 私下报告

涉及下列问题时，请使用 GitHub 仓库的 **Security → Report a vulnerability** 创建私有 Security Advisory，不要提交公开 Issue：

- 文件被覆盖、破坏、移动或删除
- 路径遍历、符号链接竞态或目录逃逸
- 权限绕过、沙盒边界变化或意外提权
- 日志或错误提示泄露敏感路径、文件内容或用户数据
- 可由恶意文件名、图片或 Finder 上下文触发的崩溃或代码执行

报告请包含 BlankRightKit/macOS 版本、文件系统类型、最小复现、实际影响和文件是否可恢复。请先删除真实私人路径和文件内容。

## 响应目标

- 7 天内确认收到报告
- 14 天内给出初步影响判断和后续计划
- 修复可用后再协调公开披露

这些是维护目标，不构成服务等级保证。

## 当前安全边界

- BlankRightKit 不申请网络客户端或服务端 entitlement，不上传遥测或日志。
- App 和 Finder 扩展都启用 App Sandbox。
- 自用 Finder 扩展包含 `com.apple.security.temporary-exception.files.absolute-path.read-write = /`，使原生动作沿用当前登录用户已有的文件权限。
- 该临时例外不是 root 或提权，不会绕过 POSIX/ACL、SIP 或 macOS TCC；但它扩大了沙盒内可尝试访问的路径，因此当前构建不适合作为公开发行二进制。
- `BRKTRACE` 会在本地记录动作和完整目标路径。日志位于扩展容器，不上传，但分享日志前必须去除私人路径。
- Shell 路径只复制到剪贴板，BlankRightKit 不执行它。
- 新建与图片转换使用无冲突输出路径，不覆盖已有文件或源文件。
- 项目不注入 Finder，不调用 Finder 私有 API，也不包含任意脚本执行器。

## 公开分发前的要求

公开二进制发行前至少需要：替换临时绝对路径例外、设计安全范围书签或其他可审核授权模型、完成威胁建模、Developer ID 签名、公证、权限回归测试和兼容性矩阵。个人 Apple Development 签名的 App 不应作为公开 Release 附件发布。
