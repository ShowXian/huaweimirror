// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "HuaweiMirror",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "HuaweiMirror",
            dependencies: [],
            path: "Sources",
            swiftSettings: [
                .unsafeFlags([
                    "-framework", "IOKit",
                    "-framework", "AppKit",
                    "-framework", "SwiftUI"
                ])
            ]
        )
    ]
)