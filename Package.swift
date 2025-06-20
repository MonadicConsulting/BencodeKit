// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "BencodeKit",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "BencodeKit",
            targets: ["BencodeKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "BencodeKit",
            dependencies: ["CryptoSwift"],
            path: "Sources"
        ),
        .testTarget(
            name: "BencodeKitTests",
            dependencies: ["BencodeKit"],
            path: "Tests",
            resources: [.copy("Torrents")]
        ),
    ]
)
