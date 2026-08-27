// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-matrix",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Matrix",
            targets: ["Matrix"]
        ),
        .library(
            name: "Matrix Standard Library Integration",
            targets: ["Matrix Standard Library Integration"]
        ),
        .library(
            name: "Matrix Apple Foundation Integration",
            targets: ["Matrix Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Matrix",
            dependencies: []
        ),
        .target(
            name: "Matrix Standard Library Integration",
            dependencies: ["Matrix"]
        ),
        .target(
            name: "Matrix Apple Foundation Integration",
            dependencies: [
                "Matrix",
                "Matrix Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Matrix Tests",
            dependencies: ["Matrix"],
            path: "Tests/Matrix Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
