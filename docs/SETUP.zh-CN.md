# Xcode 与 RightKit 开发环境

## 安装完整 Xcode

RightKit 包含 macOS App 和 Finder Sync App Extension，只有 Command Line Tools 不够，需要完整 Xcode。

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
cd RightKit
xcodegen generate
```

仓库提交了生成后的 `RightKit.xcodeproj`，但修改 `project.yml` 后必须重新生成。

## 配置签名

打开 `RightKit.xcodeproj`：

1. Xcode → Settings → Accounts，添加 Apple ID。
2. 在 Project Navigator 中选择项目，再选择 `RightKit` target。
3. Signing & Capabilities → Team，选择自己的 Team。
4. 对 `RightKitFinder` target 做相同设置。
5. 两个 target 必须使用同一个 Team 和同一个 App Group。

直接 fork 时请替换默认 Bundle Identifier 与 `group.io.github.rightkit`，否则无法在你的 Team 下创建匹配的 provisioning profile。README 列出了四个修改位置。

只验证编译、不运行扩展时，可以跳过签名：

```sh
xcodebuild \
  -project RightKit.xcodeproj \
  -scheme RightKit \
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

修改扩展后 Finder 没有刷新，可先退出正在运行的 RightKit，再在开发环境中重新运行；必要时重新开关扩展。不要把 `killall Finder` 放进安装脚本，避免突然关闭用户正在操作的 Finder 窗口。
