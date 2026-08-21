# GitHub 公开仓库发布清单

本清单用于首次把 BlankRightKit 推送到新的 GitHub 仓库。它不负责发布可下载的签名 App。

## 1. 本地检查

```sh
git status --short
git log --oneline --decorate
git log --format='%an <%ae>'
git remote -v
git ls-files | sort
```

确认：

- 工作区干净，默认分支为 `main`
- 提交身份只包含准备公开的名称和 noreply/占位地址
- 没有 Apple Team ID、证书哈希、Provisioning Profile、私钥、本机绝对路径或用户日志
- `SignedDerivedData/`、`work/`、`.DS_Store` 等均未被跟踪
- LICENSE、README、SECURITY、贡献指南、行为准则和 GitHub 模板存在

可运行以下辅助扫描；结果仍需人工判断：

```sh
rg -n --hidden \
  -g '!.git/**' \
  -g '!SignedDerivedData/**' \
  '/Users/|DEVELOPMENT_TEAM|CODE_SIGN_IDENTITY|BEGIN .*PRIVATE KEY|ghp_|github_pat_' .
```

## 2. 创建空仓库

在 GitHub 创建 `BlankRightKit` 空仓库。不要勾选自动生成 README、LICENSE 或 `.gitignore`，避免第一次推送产生无关合并提交。

## 3. 连接并推送

SSH：

```sh
git remote add origin git@github.com:<OWNER>/BlankRightKit.git
git push -u origin main
```

或 HTTPS：

```sh
git remote add origin https://github.com/<OWNER>/BlankRightKit.git
git push -u origin main
```

推送前用 `git remote -v` 再确认一次目标仓库。不要在命令、源码或聊天记录中粘贴 Personal Access Token。

## 4. GitHub 仓库设置

- About：填写简短描述、项目主页（如有）和 topics：`macos`、`finder`、`finder-sync`、`swift`、`swiftui`、`context-menu`
- Features：按需要开启 Issues、Discussions 和 Security Advisories
- Actions：确认 CI 能读取仓库内容；不需要写权限
- Branch protection：保护 `main`，要求 PR 和 CI 通过，禁止 force push/删除分支
- Security：开启 Dependabot alerts 和 private vulnerability reporting
- Social preview：可使用 `Resources/BlankRightKit-AppIcon-master.png` 制作 1280×640 社交预览图

## 5. 首个版本

当前 `0.1.0` 适合源码发布。可以创建 tag 并发布 GitHub Release，但不要附加由个人 Apple Development 证书签名的 App：

```sh
git tag -a v0.1.0 -m 'BlankRightKit 0.1.0'
git push origin v0.1.0
```

Release 内容可从 [CHANGELOG.md](../CHANGELOG.md) 摘取，并明确标注 source-build/personal-use MVP。

公开二进制发行需要先完成 [SECURITY.md](../SECURITY.md) 列出的权限重构、Developer ID 签名、公证和发布验证。
