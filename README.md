# BlankRightKit

BlankRightKit 是一个免费、开源、原生的 macOS Finder 右键工具箱。它使用 Apple 的 Finder Sync API，不注入 Finder，不依赖云服务，也不收集遥测数据。

当前版本：`0.1.0`（可构建 MVP）

## 已实现

- 新建文本、Markdown、JSON 和文件夹；自动生成无冲突名称，绝不覆盖已有文件
- 复制完整路径、文件名和可直接粘贴到 Shell 的安全转义路径
- 在 Terminal、iTerm2 或 Ghostty 打开
- 在 Visual Studio Code、Cursor、Zed 或 Xcode 打开
- 流式计算一个或多个文件的 SHA-256 并复制结果
- 将常见图片转换为 PNG 或 JPEG
- 每项功能独立开关；可选择收进单个 `BlankRightKit` 子菜单（默认开启）
- 可编辑新建文件的默认名称、扩展名和初始内容
- 简体中文原生设置界面
- 无网络 entitlement、无账号、无广告、无遥测

## 为什么再做一个

市场上已经有成熟的收费产品，也有少数开源项目。BlankRightKit 的方向不是追求最长的功能清单，而是：

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
- 自用构建需要免费 Apple ID 对应的 Xcode Personal Team；不需要付费开发者会员
- 对外分发才需要 Developer ID 或 Mac App Store 签名

## 构建

```sh
brew install xcodegen
git clone <your-fork-url>
cd BlankRightKit
make project
open BlankRightKit.xcodeproj
```

### 自用安装（免费 Personal Team）

先在 Xcode 的 `Settings → Accounts` 登录 Apple ID。将下面的 `<YOUR_TEAM_ID>` 换成 Personal Team 的 Team ID：

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project BlankRightKit.xcodeproj \
  -scheme BlankRightKit \
  -configuration Release \
  -derivedDataPath SignedDerivedData \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM=<YOUR_TEAM_ID> \
  CODE_SIGN_STYLE=Automatic \
  build

# 升级时先退出并移走旧的 /Applications/BlankRightKit.app，避免合并不同构建的包内容。
ditto SignedDerivedData/Build/Products/Release/BlankRightKit.app /Applications/BlankRightKit.app
pluginkit -a /Applications/BlankRightKit.app/Contents/PlugIns/BlankRightKitFinder.appex
pluginkit -e use -i io.github.blankrightkit.BlankRightKit.FinderExtension
open /Applications/BlankRightKit.app
```

也可以直接在 Xcode 中打开工程，为两个 target 开启 `Automatically manage signing` 并选择同一个 Personal Team 后运行。首次安装后，可在 App 中点“立即启用”，或前往“系统设置 → 通用 → 登录项与扩展 → Finder”确认扩展已开启。

当前 macOS 会拒绝临时签名（`Sign to Run Locally` / ad hoc）的 Finder 扩展：宿主 App 可能能启动，但右键功能不会加载。因此临时签名只适合编译检查，不能用于实际安装测试。

请勿直接把 Debug 和 Release 构建用 `ditto` 合并覆盖到同一个 `.app`；旧文件残留会破坏代码签名。升级前应先退出并移走旧 App，再复制完整的新 App。

当前工程是面向自用的开发签名配置。Finder 扩展保持 App Sandbox，但声明了 `/` 的临时文件读写例外，使原生文件动作能够使用当前登录用户本来就拥有的访问权限；POSIX/ACL、SIP 和隐私控制（TCC）仍然有效。该临时例外不等于 root 或“完全磁盘访问”，遇到系统拒绝时 App 会提示并写入诊断日志。

只有准备对外分发时，才需要 Developer ID 或 Mac App Store 证书、替换 Bundle Identifier，并重新设计为安全范围书签/App Group 等可审核的权限模型；不要直接发布当前自用 entitlement。

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
- Finder 扩展保持 App Sandbox；自用构建包含 `com.apple.security.temporary-exception.files.absolute-path.read-write = /`，按当前用户权限处理 Finder 中的目标。它不会绕过 POSIX/ACL、SIP 或 TCC，也不是 root/提权能力。
- 项目不申请网络权限，也不提供任意 Shell 脚本执行入口。右键点击、目标路径和动作结果会写入扩展容器内的本地 `trace.log`，仅用于诊断，不上传。
- SHA-256 与图片转换在扩展进程内执行；超大文件的任务队列和可取消进度属于后续版本工作。

## 路线图

见 [ROADMAP.md](ROADMAP.md)。欢迎先提交 issue 讨论行为、权限和冲突策略，再提交实现。

## License

MIT。详见 [LICENSE](LICENSE)。
