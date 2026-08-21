# RightKit

RightKit 是一个免费、开源、原生的 macOS Finder 右键工具箱。它使用 Apple 的 Finder Sync API，不注入 Finder，不依赖云服务，也不收集遥测数据。

当前版本：`0.1.0`（可构建 MVP）

## 已实现

- 新建文本、Markdown、JSON 和文件夹；自动生成无冲突名称，绝不覆盖已有文件
- 复制完整路径、文件名和可直接粘贴到 Shell 的安全转义路径
- 在 Terminal、iTerm2 或 Ghostty 打开
- 在 Visual Studio Code、Cursor、Zed 或 Xcode 打开
- 流式计算一个或多个文件的 SHA-256 并复制结果
- 将常见图片转换为 PNG 或 JPEG
- 每项功能独立开关；可选择收进单个 `RightKit` 子菜单
- 可编辑新建文件的默认名称、扩展名和初始内容
- 简体中文原生设置界面
- 无网络 entitlement、无账号、无广告、无遥测

## 为什么再做一个

市场上已经有成熟的收费产品，也有少数开源项目。RightKit 的方向不是追求最长的功能清单，而是：

1. 原生类型化实现，不通过任意 Shell 脚本执行日常文件操作。
2. 默认安全，不提供永久删除、静默覆盖或权限提升等误触成本高的动作。
3. 核心菜单规划和文件操作可单元测试。
4. 权限、限制和行为全部可审计。

竞品和技术调研见 [docs/RESEARCH.zh-CN.md](docs/RESEARCH.zh-CN.md)，架构说明见 [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)。
首次配置开发环境可参考 [docs/SETUP.zh-CN.md](docs/SETUP.zh-CN.md)。

## 系统要求

- macOS 13 Ventura 或更新版本
- Xcode 16 或更新版本
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.43 或更新版本
- 本地运行需要在 Xcode 中配置 Apple 开发团队；发布需要相应的 Developer ID 或 Mac App Store 签名

## 构建

```sh
brew install xcodegen
git clone <your-fork-url>
cd RightKit
make project
open RightKit.xcodeproj
```

在 Xcode 中：

1. 打开 `RightKit` 和 `RightKitFinder` 两个 target 的 Signing & Capabilities。
2. 为两者选择同一个 Team。
3. 将两个 Bundle Identifier 换成你控制的唯一前缀。
4. 把 `group.io.github.rightkit` 同时替换为你自己的 App Group；需要修改：
   - `project.yml`
   - `App/RightKit.entitlements`
   - `FinderExtension/RightKitFinder.entitlements`
   - `Shared/Sources/RightKitCore/SettingsStore.swift`
5. 运行 `RightKit` scheme。
6. 在 App 中点“立即启用”，或前往“系统设置 → 通用 → 登录项与扩展 → Finder”启用扩展。

修改 `project.yml` 后请重新运行 `make project`。仓库同时提交了生成后的 `.xcodeproj`，未安装 XcodeGen 时也可以直接打开。

## 测试

```sh
swift test
```

完整 App 编译（跳过签名）：

```sh
make build
```

## 已知系统限制

- Apple 将 Finder Sync 主要定位为同步类扩展；某些 File Provider/iCloud Drive 目录可能优先使用其自己的扩展，导致菜单不显示。
- macOS 15.0/15.1 的 Finder 扩展管理界面有已知系统问题，建议使用 15.2 或更高版本。
- App Sandbox 对任意文件访问和外部可执行程序有限制，因此 RightKit 不把 Shell 脚本作为默认动作系统。
- SHA-256 与图片转换在扩展进程内执行；超大文件的任务队列和可取消进度属于后续版本工作。

## 路线图

见 [ROADMAP.md](ROADMAP.md)。欢迎先提交 issue 讨论行为、权限和冲突策略，再提交实现。

## License

MIT。详见 [LICENSE](LICENSE)。
