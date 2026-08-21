# Changelog

BlankRightKit 的重要变化记录在此文件中。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### Planned

- Intel、Apple Silicon 与主流 macOS 版本的真机兼容性矩阵
- 后台任务队列、进度和取消
- 面向公开分发的权限、Developer ID 签名与公证流程

## [0.1.0] - 2026-08-21

### Added

- 原生 Finder Sync 右键扩展与 SwiftUI 设置应用
- 新建文本、Markdown、JSON 和文件夹
- 路径、文件名和安全 Shell 路径复制
- Terminal/iTerm2/Ghostty 与 VS Code/Cursor/Zed/Xcode 打开方式
- SHA-256 计算与 PNG/JPEG 图片转换
- 功能开关、首选应用和新建文件模板
- `BlankRightKit` 折叠菜单与可选扁平菜单
- App 图标、MIT License、单元测试、XcodeGen 工程和 GitHub CI
- 本地 `BRKTRACE` 诊断日志及同步/异步错误提示

### Fixed

- 使用独立 Objective-C selector 路由 Finder 菜单回调，修复点击无反应
- 使用 Apple Development 签名，避免 AMFI 拒绝 Finder 扩展
- 修复 App 图标资源打包
- 修复沙盒内 Finder 目标的新建和外部应用打开权限
