// swift-tools-version: 6.2-snapshot

import PackageDescription

let package = Package(
    name: "MsTodoCli",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/thebarndog/swift-dotenv.git", from: "2.1.0"),
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
            name: "TodoCli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftDotenv", package: "swift-dotenv"),
                "TodoCommon", "TodoAuth",
            ],
            resources: [.copy(".env")],
            swiftSettings: [.defaultIsolation(MainActor.self)],
        ),
    ]
)
