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

自用不需要付费开发者会员，但 Finder 扩展需要由免费 Apple ID 对应的 Xcode Personal Team 签名。先打开 Xcode 的 `Settings → Accounts` 登录 Apple ID，再为宿主和扩展选择同一个 Personal Team。

命令行构建时，将 `<YOUR_TEAM_ID>` 替换为 Personal Team 的 Team ID：

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
```

构建日志中的 Signing Identity 应显示 `Apple Development`，且宿主和扩展的 Team ID 必须一致。安装并启用：

```sh
# 升级时先退出并移走旧的 /Applications/BlankRightKit.app，避免合并不同构建的包内容。
ditto SignedDerivedData/Build/Products/Release/BlankRightKit.app /Applications/BlankRightKit.app
pluginkit -a /Applications/BlankRightKit.app/Contents/PlugIns/BlankRightKitFinder.appex
pluginkit -e use -i io.github.blankrightkit.BlankRightKit.FinderExtension
open /Applications/BlankRightKit.app
```

不要用 `Sign to Run Locally` 或 `CODE_SIGN_IDENTITY=-` 安装 Finder 扩展。在当前 macOS 上，宿主 App 可能能启动，但 AMFI 会拒绝临时签名的扩展，表现为菜单存在异常或功能完全不加载。

不要把 Debug 与 Release 构建直接合并覆盖到同一个 `.app`。旧 dylib 残留会破坏包的密封签名；升级前应先退出并移走旧 App，再复制完整的新 App。

准备对外发布时，才需要 Developer ID 或 Mac App Store 证书、替换默认 Bundle Identifier，并按发布方式配置 App Group。

### 自用文件权限

Finder Sync 扩展必须保持 App Sandbox，否则系统不会稳定注册和启动它。为了让“新建文件”“图片转换”“在终端/编辑器打开”等动作能处理 Finder 当前目录，自用工程为扩展声明：

```text
com.apple.security.temporary-exception.files.absolute-path.read-write = /
```

这表示在沙盒内沿用当前登录用户本来就有的文件访问范围，不是 root、提权或“完全磁盘访问”。文件的 POSIX/ACL 权限、SIP 和 macOS 隐私控制（TCC）仍会拒绝受保护目标；扩展会在失败时显示提示并记录底层错误。这个临时例外只适合本机自用开发签名，不应原样用于公开分发或 App Store 提交。

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
pluginkit -m -A -D -v -i io.github.blankrightkit.BlankRightKit.FinderExtension
```

输出应只有一个注册项，且路径应位于 `/Applications/BlankRightKit.app`。如果同时出现 Debug、DerivedData 或旧安装路径，先退出 App、注销旧扩展，再重新注册 `/Applications` 中的版本。

右键菜单和动作的本地诊断日志位于：

```text
~/Library/Containers/io.github.blankrightkit.BlankRightKit.FinderExtension/Data/Library/Application Support/BlankRightKit/trace.log
```

每次菜单生成、点击、目标路径、成功或失败都会追加 `BRKTRACE` 记录；日志不上传。可用 `tail -f` 实时查看。

修改扩展后 Finder 没有刷新，可先退出正在运行的 BlankRightKit，再在开发环境中重新运行；必要时重新开关扩展。不要把 `killall Finder` 放进安装脚本，避免突然关闭用户正在操作的 Finder 窗口。
