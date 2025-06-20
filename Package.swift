// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "BencodeKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "BencodeKit",
            targets: ["BencodeKit"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BencodeKit",
            dependencies: [],
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
