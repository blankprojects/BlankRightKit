# Xcode 与 BlankRightKit 开发环境

## 安装完整 Xcode

BlankRightKit 包含 macOS App 和 Finder Sync App Extension，只有 Command Line Tools 不够，需要完整 Xcode。

最简单的方式是在 Mac App Store 搜索“Xcode”并安装。也可以在已登录 App Store 的机器上使用：

```sh
brew install mas
mas install 497799835
```

Xcode 下载和展开会占用几十 GB。建议安装前至少保留 50–60 GB 可用空间。

安装结束后运行：

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -version
swift --version
```

`-runFirstLaunch` 会接受许可并安装必要组件。执行 `sudo` 时 macOS 可能要求输入当前用户密码；密码不会显示在终端中。

## 安装 XcodeGen

```sh
brew install xcodegen
cd BlankRightKit
xcodegen generate
```

仓库提交了生成后的 `BlankRightKit.xcodeproj`，但修改 `project.yml` 后必须重新生成。

## 自用签名与安装

自用不需要 Apple ID 或付费开发者会员。使用 Xcode 内置的临时签名即可：

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project BlankRightKit.xcodeproj \
  -scheme BlankRightKit \
  -configuration Release \
  -derivedDataPath LocalDerivedData \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY=- \
  DEVELOPMENT_TEAM= \
  build
```

构建日志中的 Signing Identity 应显示 `Sign to Run Locally`。安装并启用：

```sh
ditto LocalDerivedData/Build/Products/Release/BlankRightKit.app /Applications/BlankRightKit.app
pluginkit -a /Applications/BlankRightKit.app/Contents/PlugIns/BlankRightKitFinder.appex
pluginkit -e use -i io.github.blankrightkit.BlankRightKit.FinderExtension
open /Applications/BlankRightKit.app
```

准备对外发布时，才需要登录 Apple ID，为宿主和扩展选择同一个 Team，替换默认 Bundle Identifier，并配置对应的 App Group。

只验证编译、不运行扩展时，也可以完全跳过签名：

```sh
xcodebuild \
  -project BlankRightKit.xcodeproj \
  -scheme BlankRightKit \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 启用与诊断 Finder 扩展

运行宿主 App 后，点击“立即启用”。手动路径是：

`系统设置 → 通用 → 登录项与扩展 → Finder`

查看系统是否发现扩展：

```sh
pluginkit -m -p com.apple.FinderSync
```

修改扩展后 Finder 没有刷新，可先退出正在运行的 BlankRightKit，再在开发环境中重新运行；必要时重新开关扩展。不要把 `killall Finder` 放进安装脚本，避免突然关闭用户正在操作的 Finder 窗口。
