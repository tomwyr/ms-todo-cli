// swift-tools-version: 6.2-snapshot

import PackageDescription

let package = Package(
    name: "MsTodoCli",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "TodoCommon",
            swiftSettings: [.defaultIsolation(MainActor.self)],
        ),
        .target(
            name: "TodoAuth",
            dependencies: ["TodoCommon"],
            swiftSettings: [.defaultIsolation(MainActor.self)],
        ),
        
        .executableTarget(
            name: "MicrosoftTodoCli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)
