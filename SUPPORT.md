# Support

BlankRightKit 是由社区维护的早期项目，目前不提供商业支持或响应时间保证。

## 获取帮助

1. 先查看 [README](README.md) 的环境要求和已知限制。
2. 安装、签名、扩展注册问题请查看 [docs/SETUP.zh-CN.md](docs/SETUP.zh-CN.md)。
3. 确认系统中只有一个 Finder 扩展注册项：

   ```sh
   pluginkit -m -A -D -v -i io.github.blankrightkit.BlankRightKit.FinderExtension
   ```

4. 复现问题后查看本地日志：

   ```text
   ~/Library/Containers/io.github.blankrightkit.BlankRightKit.FinderExtension/Data/Library/Application Support/BlankRightKit/trace.log
   ```

5. 搜索现有 Issue；没有重复问题时再使用 Bug report 或 Question 表单。

公开日志和截图之前，请移除用户名、私人路径、文件名和文件内容。安全敏感问题按 [SECURITY.md](SECURITY.md) 私下报告。

## Issue 不适合处理的事项

- Apple ID、证书或 Xcode 账号的私人凭据问题
- 未经授权访问第三方设备或数据
- 与 BlankRightKit 无关的通用 macOS/Xcode 教程
- 要求维护者远程执行未知脚本或接收私人文件
