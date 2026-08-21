<p align="center">
  <img src="Resources/BlankRightKit-AppIcon-master.png" width="128" height="128" alt="BlankRightKit icon">
</p>

<h1 align="center">BlankRightKit</h1>

<p align="center">A free, open-source, native Finder context-menu toolkit for macOS.</p>

<p align="center">
  <img alt="macOS 13+" src="https://img.shields.io/badge/macOS-13%2B-black?logo=apple">
  <img alt="Swift 5" src="https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white">
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
</p>

<p align="center"><a href="README.md">简体中文</a> · English</p>

> [!IMPORTANT]
> Version `0.1.0` is a source-build, personal-use MVP. Its Finder extension currently relies on development signing and a temporary file-access exception. Do not publish a build signed with a personal development certificate as an official binary release.

BlankRightKit uses Apple's Finder Sync API. It does not inject into Finder, execute arbitrary shell scripts, depend on cloud services, or include accounts, ads, or telemetry.

## Features

- Create text, Markdown, JSON files, and folders without overwriting existing items.
- Copy full paths, file names, and safely single-quoted shell paths.
- Open targets in Terminal, iTerm2, Ghostty, Visual Studio Code, Cursor, Zed, or Xcode.
- Stream SHA-256 calculation for one or more files.
- Convert common images to PNG or JPEG without replacing the source.
- Enable actions individually and use either a grouped `BlankRightKit` submenu or a flat menu.
- Configure new-file names, extensions, and initial contents.
- Keep local diagnostic traces for menu callbacks and action results; nothing is uploaded.

## Requirements

- macOS 13 Ventura or later
- Xcode 16 or later
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.43 or later
- A free Xcode Personal Team to run the Finder extension locally

## Build and test

```sh
git clone <your-fork-url>
cd BlankRightKit
brew install xcodegen
make project
swift test
open BlankRightKit.xcodeproj
```

For local signing, installation, Finder extension registration, and diagnostics, see the [Chinese setup guide](docs/SETUP.zh-CN.md).

## Security model

- Both targets remain App Sandbox enabled.
- The personal-use Finder extension declares `com.apple.security.temporary-exception.files.absolute-path.read-write = /` so native actions inherit the current user's existing file access.
- This is not root access and does not bypass POSIX/ACL permissions, SIP, or macOS TCC protections.
- The project requests no network entitlement and never executes copied shell paths.
- Public distribution requires a redesigned, reviewable permission model, Developer ID signing, notarization, and release testing.

Read [SECURITY.md](SECURITY.md) and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) before changing file or permission behavior.

## Contributing

Issues and pull requests are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), and [SUPPORT.md](SUPPORT.md). Report security-sensitive issues privately according to [SECURITY.md](SECURITY.md).

## License

BlankRightKit is available under the [MIT License](LICENSE).
