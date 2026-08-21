# Architecture

## 组件

```text
BlankRightKit.app (SwiftUI 设置)
          │
          │ ~/Library/Application Support/BlankRightKit/settings.json
          ▼
BlankRightKitFinder.appex (FinderSync)
          │
          ├── ActionContext：冻结 Finder 当前目标/选择
          ├── MenuPlanner：按设置与文件类型过滤动作
          └── SystemActionExecutor
                  ├── Foundation/FileManager
                  ├── NSWorkspace / NSPasteboard
                  ├── CryptoKit (SHA-256)
                  └── ImageIO + UniformTypeIdentifiers
```

## 源码布局

- `App/`：宿主 App、扩展启用入口和设置 UI。
- `FinderExtension/`：`FIFinderSync` 子类和菜单桥接。
- `Shared/Sources/BlankRightKitCore/`：不依赖 UI 的模型、设置、命名和菜单规划。
- `Shared/Sources/BlankRightKitActions/`：原生文件动作与系统集成。
- `Tests/`：Swift Package 单元测试。
- `project.yml`：XcodeGen 的工程真源；`.xcodeproj` 是生成结果。

Xcode 的 App 与 Extension target 直接编译共享源码；`Package.swift` 只用于快速单元测试和 CI。因此 Finder 扩展没有额外动态 framework 嵌入问题。

## 菜单生命周期

1. Finder 调用 `menu(for:)`。
2. 扩展立即读取 `targetedURL`、`selectedItemURLs` 和共享设置。
3. `MenuPlanner` 过滤不适用动作。例如图片转换仅在所有选中常规文件都是已知图片类型时显示。
4. 扩展按设置返回 `BlankRightKit` 子菜单或扁平 `NSMenu`。Finder 通过 XPC 序列化菜单，因此每个动作使用独立 Objective-C selector，不依赖可能在跨进程传递时丢失的 `representedObject` 或显式 target。
5. 点击后扩展再次读取 Finder selection（Apple 仅在此窗口保证其有效），执行动作并显示新文件或更新剪贴板。

## 数据安全约束

- `UniqueNameResolver` 在写入前查找无冲突路径，实际创建再使用 `withoutOverwriting` 原子占位抵抗竞态；MVP 不含覆盖分支。
- 图片转换先原子保留输出名，再写入源文件旁的新路径；转换失败时清理未完成输出。
- SHA-256 按 1 MiB 分块读取，避免把大文件一次性载入内存。
- Shell 路径只写入剪贴板；BlankRightKit 不执行它。单引号使用 POSIX 兼容方式转义。
- App 与 Extension 都开启 App Sandbox；宿主 App 只获准读写自己的 `Application Support/BlankRightKit` 设置目录。
- 自用 Finder 扩展声明 `/` 的绝对路径临时读写例外，让动作按当前登录用户已有权限处理 Finder 目标。它不会绕过 POSIX/ACL、SIP 或 TCC，也不提供 root/提权能力；公开分发前必须替换成安全范围书签等可审核模型。
- 动作只处理 Finder 当前目标或明确选择的项目；新建与转换始终使用无冲突名称。
- 项目不申请网络权限、不注入 Finder、不包含任意脚本执行器。
- entitlements 中没有网络客户端或服务端权限。
- 扩展把菜单生成、点击、目标路径和动作结果追加到自身容器内的 `trace.log`；日志只留在本机，不上传。

## 当前技术债

- 哈希和图片转换仍由扩展 action 同步发起。大文件需要独立任务队列、进度、取消和完成通知。
- Finder Sync 在 File Provider 目录中的表现取决于系统和其他扩展注册情况。
- 同步与异步错误会弹出提示并写入本地 trace；仍需要宿主 App 中的可诊断活动页和日志清理策略。
- 还没有签名发布流水线、Sparkle 或 DMG 产物。
