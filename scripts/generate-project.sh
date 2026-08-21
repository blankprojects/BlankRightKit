#!/bin/zsh
set -euo pipefail

cd "${0:A:h}/.."

if ! command -v xcodegen >/dev/null 2>&1; then
  print -u2 "缺少 XcodeGen。请先运行：brew install xcodegen"
  exit 1
fi

xcodegen generate
print "已生成 RightKit.xcodeproj"
