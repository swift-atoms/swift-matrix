// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-matrix-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Matrix Primitives",
            targets: ["Matrix Primitives"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-linear-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-vector-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-dimension-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-index-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Matrix Primitives",
            dependencies: [
                .product(name: "Linear Primitives", package: "swift-linear-primitives"),
                .product(name: "Vector Primitives", package: "swift-vector-primitives"),
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),
        .testTarget(
            name: "Matrix Primitives Tests",
            dependencies: [
                "Matrix Primitives"
            ]
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
