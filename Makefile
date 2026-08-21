.PHONY: project test build clean

project:
	xcodegen generate

test:
	swift test

build: project
	xcodebuild -project BlankRightKit.xcodeproj -scheme BlankRightKit -configuration Debug CODE_SIGNING_ALLOWED=NO build

clean:
	swift package clean
	xcodebuild -project BlankRightKit.xcodeproj -scheme BlankRightKit clean
