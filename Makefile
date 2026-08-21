.PHONY: project test build clean

project:
	xcodegen generate

test:
	swift test

build: project
	xcodebuild -project RightKit.xcodeproj -scheme RightKit -configuration Debug CODE_SIGNING_ALLOWED=NO build

clean:
	swift package clean
	xcodebuild -project RightKit.xcodeproj -scheme RightKit clean
