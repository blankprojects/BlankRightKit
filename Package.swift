// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BlankRightKit",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "BlankRightKitCore", targets: ["BlankRightKitCore"]),
        .library(name: "BlankRightKitActions", targets: ["BlankRightKitActions"])
    ],
    targets: [
        .target(
            name: "BlankRightKitCore",
            path: "Shared/Sources/BlankRightKitCore"
        ),
        .target(
            name: "BlankRightKitActions",
            dependencies: ["BlankRightKitCore"],
            path: "Shared/Sources/BlankRightKitActions"
        ),
        .testTarget(
            name: "BlankRightKitCoreTests",
            dependencies: ["BlankRightKitCore"],
            path: "Tests/BlankRightKitCoreTests"
        ),
        .testTarget(
            name: "BlankRightKitActionsTests",
            dependencies: ["BlankRightKitActions", "BlankRightKitCore"],
            path: "Tests/BlankRightKitActionsTests"
        )
    ],
    swiftLanguageModes: [.v5]
)
