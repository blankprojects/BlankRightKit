# Contributing

感谢参与 RightKit。

## 提交前

1. 对用户可见行为先开 issue，说明使用场景、权限需求、失败模式和是否可撤销。
2. 新增菜单动作时同时补充 `ActionID`、`MenuPlanner` 适用条件和单元测试。
3. 文件写入必须使用无冲突名称；任何覆盖、移动或删除都需要显式冲突策略。
4. 不加入遥测、广告 SDK 或不必要的网络依赖。
5. 不使用 Finder 私有 API、代码注入或绕过 App Sandbox 的未说明权限。

## 本地检查

```sh
swift test
xcodegen generate
xcodebuild -project RightKit.xcodeproj -scheme RightKit CODE_SIGNING_ALLOWED=NO build
```

## 代码风格

- Swift 5 language mode，最低 macOS 13。
- UI 保持原生 SwiftUI/AppKit，优先使用 SF Symbols。
- Finder 扩展菜单构建必须快速；耗时工作不得长期阻塞主线程。
- 错误要转成可理解、可恢复的用户信息，不静默吞掉文件系统错误。
