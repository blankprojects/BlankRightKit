# Contributing to BlankRightKit

感谢你愿意参与 BlankRightKit。这个项目优先考虑可预测的文件行为、清楚的权限边界和可验证的 Finder 集成。

## 开始之前

- Bug 请使用仓库的 Bug report 表单，并提供可复现步骤和 `BRKTRACE` 中相关片段。
- 新功能请先提交 Feature request，说明使用场景、Finder 上下文、权限需求、失败模式和撤销策略。
- 安全问题不要创建公开 Issue，请按 [SECURITY.md](SECURITY.md) 通过 GitHub Security Advisory 私下报告。
- 参与项目即表示同意遵守 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。

## 本地环境

- macOS 13 或更高版本
- Xcode 16 或更高版本
- Swift 6 工具链（项目源码使用 Swift 5 language mode）
- XcodeGen 2.43 或更高版本

```sh
brew install xcodegen
git clone <your-fork-url>
cd BlankRightKit
make project
make test
make build
```

`make build` 使用 `CODE_SIGNING_ALLOWED=NO`，适合验证编译。真正运行 Finder 扩展需要 Personal Team 开发签名，参见 [docs/SETUP.zh-CN.md](docs/SETUP.zh-CN.md)。

## 修改原则

1. 新增菜单动作时，同时补充 `ActionID`、`MenuPlanner` 适用条件、执行实现和单元测试。
2. 文件写入必须使用无冲突名称；任何覆盖、移动或删除都要先设计确认和恢复流程。
3. 不加入遥测、广告 SDK、不必要的网络依赖、Finder 私有 API 或代码注入。
4. 不静默吞掉文件系统错误；用户要看到可理解的失败信息，诊断日志要保留底层错误。
5. Finder 菜单构建必须快速；耗时任务不能长期阻塞主线程。
6. 权限变化必须同步更新 README、SECURITY 和架构文档。

## 工程文件

`project.yml` 是 Xcode 工程真源。修改 target、资源、entitlement 或构建设置后运行：

```sh
xcodegen generate
git diff -- BlankRightKit.xcodeproj/project.pbxproj
```

提交 `project.yml` 的同时也要提交生成后的共享 `.xcodeproj`。

## 提交前检查

```sh
swift test
xcodegen generate
xcodebuild \
  -project BlankRightKit.xcodeproj \
  -scheme BlankRightKit \
  -configuration Debug \
  -derivedDataPath DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
git diff --check
```

## Pull Request

- 一个 PR 聚焦一个问题，标题使用清楚的祈使句。
- 描述行为变化、测试方法、权限影响和已知限制。
- UI 变化请附截图；Finder 回调问题请附去除私人路径后的日志。
- 不要提交签名证书、Provisioning Profile、用户数据、构建目录或真实私人路径。
- 确保 CI 通过，并回应 review 中尚未解决的问题。

提交贡献即表示你有权提交这些内容，并同意其按项目的 [MIT License](LICENSE) 发布。
