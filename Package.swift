// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProcessPretty",
    products: [
        .library(name: "ProcessPretty", targets: ["ProcessPretty"])
    ],
    dependencies: [
        .package(name: "swift-tools-support-core", url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMajor(from: "0.1.12"))
    ],
    targets: [
        .target(name: "main", dependencies: ["ProcessPretty"]),
        .target(
            name: "ProcessPretty",
            dependencies: [.product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core")]),
        .testTarget(
            name: "ProcessPrettyTests",
            dependencies: ["ProcessPretty"]),
    ]
)
