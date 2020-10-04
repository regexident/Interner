// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Interner",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "Interner",
            targets: [
                "Interner",
            ]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Interner",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "InternerBenchmarks",
            dependencies: [
                "Interner",
            ]
        ),
        .testTarget(
            name: "InternerTests",
            dependencies: [
                "Interner",
            ]
        ),
    ]
)
