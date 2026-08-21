// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RightKit",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "RightKitCore", targets: ["RightKitCore"]),
        .library(name: "RightKitActions", targets: ["RightKitActions"])
    ],
    targets: [
        .target(
            name: "RightKitCore",
            path: "Shared/Sources/RightKitCore"
        ),
        .target(
            name: "RightKitActions",
            dependencies: ["RightKitCore"],
            path: "Shared/Sources/RightKitActions"
        ),
        .testTarget(
            name: "RightKitCoreTests",
            dependencies: ["RightKitCore"],
            path: "Tests/RightKitCoreTests"
        ),
        .testTarget(
            name: "RightKitActionsTests",
            dependencies: ["RightKitActions", "RightKitCore"],
            path: "Tests/RightKitActionsTests"
        )
    ],
    swiftLanguageModes: [.v5]
)
