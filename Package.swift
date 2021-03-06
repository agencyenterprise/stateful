// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stateful",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Stateful",
            targets: ["Stateful"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Stateful",
            exclude: ["../../Example"]
        ),
        .testTarget(
            name: "StatefulTests",
            dependencies: ["Stateful"]
        ),
    ]
)
