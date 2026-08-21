# macOS 右键增强工具调研

更新时间：2026-08-21

## 范围说明

“市面上所有信息”无法被严格证明穷尽：Mac App Store 地区定价、独立站产品和新发布项目持续变化。本调研覆盖公开可发现的代表性商业产品、免费产品、开源实现、近期用户反馈和 Apple 官方技术边界，目标是指导 BlankRightKit 的产品与工程决策，而不是制作永久完整的产品目录。

价格均为调研时页面显示，税费、地区和促销会导致变化。

## 代表性产品

| 产品 | 模式/调研时价格 | 公开功能重点 | 观察 |
|---|---:|---|---|
| [iRightMouse](https://apps.apple.com/us/app/irightmouse/id1497428978?mt=12) | 免费下载 + 内购 | 新建文件、复制/移动、路径、哈希、图片转换、压缩、隐藏文件、翻译等 | 功能最广之一，但菜单和权限面也更大 |
| [iBoysoft MagicMenu](https://iboysoft.com/magic-menu/purchase.html) | US$19.95/年；US$59.95 买断 | 新建、复制/移动、快速访问、菜单编辑、扩展商店 | 商业化完整；订阅与买断并存 |
| [New File Menu](https://apps.apple.com/nz/app/new-file-menu/id1064959555?mt=12) | US$4.99（页面地区可能变化） | 30+ 模板、自定义模板、Finder 工具栏/右键/服务 | 单点需求做得深，范围聚焦 |
| [Menuist](https://apps.apple.com/fr/app/menuist-right-click-menubar/id6737160756?mt=12) | €0.99/月、€9.99/年、€29.99 买断（法国区） | 右键工具、收藏导航、开发者动作、菜单开关 | 右键与菜单栏导航结合；macOS 14+ |
| [Context Menu](https://apps.apple.com/us/app/context-menu/id1236813619) | US$6.99 | 将应用、Shell 脚本、服务和文本片段加入右键，可按 UTI 过滤 | 通用动作配置器；支持脚本交互输入 |
| [Service Station](https://apps.apple.com/us/app/service-station/id1503136033?mt=12) | 免费下载 + 内购 | 把应用和脚本加入 Finder 右键，Smart Search 条件过滤 | 自定义能力强，更接近动作配置器 |
| [Qmenu](https://apps.apple.com/us/app/qmenu/id1567442612?mt=12) | US$0.99 | 新建、收藏、复制路径、开发工具快速打开 | 价格低，支持大量编辑器与 IDE |
| [Wise Menu](https://apps.apple.com/us/app/wise-menu/id1479655979) | US$4.99 | 新建、复制/移动、终端和图片相关入口 | 部分媒体功能依赖开发者的其他 App |
| [ClickShelf](https://apps.apple.com/us/app/clickshelf-file-actions/id6766478836?mt=12) | US$1.99 | 文件、批量重命名、图片、OCR、归档、PDF、脚本 | 功能密度极高，也包含永久删除等高风险动作 |
| [QuickRight](https://apps.apple.com/us/app/quickright/id6763963598?mt=12) | 免费 | 新建、剪切粘贴、路径、终端、收藏目录、图片、哈希 | 2026 年新产品；功能面与商业工具接近 |
| [New File Menu Lite](https://apps.apple.com/us/app/new-file-menu-lite/id1066302071?mt=12) | 免费 | 与完整版相近，但限制最多 3 个模板 | 证明“新建文件”已有免费入口，但高级模板仍付费 |

## 已有开源实现

“右键增强大多收费”基本属实，但并非没有开源选择：

- [MenuMate](https://github.com/Hibrielle/menumate)：MIT，脚本优先，带社区扩展包，覆盖复制路径、新建、剪切粘贴、终端/编辑器和图片转换。
- [NewFile](https://github.com/mariusgm/newfile)：MIT，专注新建文件，自定义类型和模板，原生 Finder Sync。
- [RClick](https://github.com/wflixu/RClick)：Swift/SwiftUI，实现打开外部应用、路径、隐藏、AirDrop、新建文件和快速目录等。
- [MacTools](https://github.com/ggbond268/MacTools)：免费开源的多工具集合，其中包含可配置 Finder 右键模块。
- [MacNewFile](https://github.com/GarfieldFluffJr/MacNewFile)：开源的新建文件与路径复制实现。
- [FinderEx](https://github.com/yantoz/FinderEx)：较早的通用动作编辑器，可运行 AppleScript、Bash 和 Automator 工作流。

结论不是“市场缺少任何开源代码”，而是开源方案普遍存在以下一个或多个缺口：只解决单点需求、默认依赖任意脚本、UI/测试不足、系统版本兼容不清晰，或作为大型工具集的附属模块。

## 用户需求聚类

从产品功能清单、App Store 描述和社区讨论看，需求可分为五层：

1. **基础缺口**：新建文件、复制路径、打开终端/编辑器。
2. **文件流转**：剪切/粘贴、复制/移动到收藏目录、AirDrop。
3. **开发者工具**：Shell 转义路径、代码预览、Git/Xcode 动作、哈希。
4. **媒体与归档**：图片格式/尺寸/压缩、压缩包解压。
5. **高风险系统动作**：永久删除、隐藏、权限修改、任意脚本。

近期讨论反复出现三个痛点：

- Windows/Linux 转入用户最先寻找“右键新建文件”和鼠标可见的剪切/移动。
- 功能很多后，菜单过长；用户需要按上下文显示和独立开关。
- iCloud/File Provider 目录中扩展显示不稳定，容易被误认为产品故障。

## Apple 官方技术边界

Apple 的 [Finder Sync 指南](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Finder.html) 明确了以下事实：

- 扩展只能为注册的 managed directories 提供右键菜单、工具栏按钮和徽章。
- `targetedURL` 和 `selectedItemURLs` 只保证在菜单创建及其 action 执行期间有效。
- Finder、打开/保存面板可能启动多个扩展实例；扩展应保持轻量。
- 宿主 App 与扩展可通过同一个 App Group 的 shared user defaults 共享设置。
- Finder Sync 最初面向同步软件，Apple 明确说它不是通用 Finder UI 修改入口。BlankRightKit 因而必须保持 API 使用保守，并持续做系统版本回归测试。

Apple 的 [App Sandbox 文件访问文档](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox) 还要求：沙箱 App 只能访问容器或用户明确授予的文件范围；持久访问要使用 security-scoped bookmarks。BlankRightKit 不应通过 `Process` 绕过该边界。

macOS 15.0/15.1 曾出现 Finder Sync 管理 UI 不可见的问题，Apple 开发者论坛记录显示 15.2 beta 2 已恢复相关 UI：[讨论](https://developer.apple.com/forums/thread/756711)。

## BlankRightKit 0.1 的定位

BlankRightKit 选择“安全原生动作集”，而不是脚本市场：

| 原则 | 0.1 决策 |
|---|---|
| 免费与可审计 | MIT，全量源码，无付费墙 |
| 隐私 | 不申请网络权限，不接入账号、广告、遥测 |
| 避免数据损失 | 新建和转换永不覆盖；不提供永久删除 |
| 上下文整洁 | `MenuPlanner` 只显示当前选择适用的动作，每项可关闭 |
| 可测试 | 文件命名、菜单过滤、设置持久化、模板创建、Shell 转义和 SHA-256 有单元测试 |
| 原生集成 | SwiftUI + AppKit + FinderSync + ImageIO + CryptoKit |

## 优先级

### 已纳入 0.1

- 新建文件/文件夹
- 三种路径复制
- 终端和编辑器打开
- SHA-256
- PNG/JPEG 转换
- 菜单开关、模板和首选 App 设置

### 下一阶段

- 后台任务队列和取消
- 收藏目录复制/移动，但必须先设计冲突预览、权限书签与恢复机制
- 图片尺寸调整、WebP、更多哈希
- 国际化与可访问性

### 暂缓

- 永久删除、chmod/ACL、提权
- 无确认执行任意脚本
- 依赖私有 API 的 Finder 注入

这些决定牺牲了“功能数量”，换取更小的权限面和更清楚的开源维护边界。
