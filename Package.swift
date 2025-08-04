// swift-tools-version: 6.2-snapshot

import PackageDescription

let package = Package(
    name: "MicrosoftTodoCli",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
    ],
    targets: [
        .executableTarget(
            name: "MicrosoftTodoCli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
