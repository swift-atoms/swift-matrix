// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-matrix",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Matrix", targets: ["Matrix"]),

        .library(name: "Matrix Foundation Integration", targets: ["Matrix Foundation Integration"]),
        .library(name: "Matrix Test Support", targets: ["Matrix Test Support"]),
    ],
    traits: [
        .trait(name: "Projection", description: "Projection integration"),
        .trait(name: "Quaternion", description: "Quaternion integration"),
        .trait(name: "Rotation", description: "Rotation integration", enabledTraits: ["Trigonometry"]),
        .trait(name: "Scale", description: "Scale integration"),
        .trait(name: "Shear", description: "Shear integration"),
        .trait(name: "Trigonometry", description: "Circular trigonometry for rotation matrices"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-projection.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-quaternion.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-rotation.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-trigonometry.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-scale.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-shear.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-vector.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Matrix",
            dependencies: [
                .product(name: "Projection", package: "swift-projection", condition: .when(traits: ["Projection"])),
                .product(name: "Quaternion", package: "swift-quaternion", condition: .when(traits: ["Quaternion"])),
                .product(name: "Rotation", package: "swift-rotation", condition: .when(traits: ["Rotation"])),
                .product(name: "Trigonometry", package: "swift-trigonometry", condition: .when(traits: ["Trigonometry", "Rotation"])),
                .product(name: "Scale", package: "swift-scale", condition: .when(traits: ["Scale"])),
                .product(name: "Shear", package: "swift-shear", condition: .when(traits: ["Shear"])),

                .product(
                    name: "Vector",
                    package: "swift-vector"
                ),
            ],
            path: "Sources/Matrix"
        ),
        .target(
            name: "Matrix Foundation Integration",
            dependencies: [
                .target(
                    name: "Matrix"
                )
            ],
            path: "Sources/Matrix Foundation Integration"
        ),
        .target(
            name: "Matrix Test Support",
            dependencies: [
                .target(
                    name: "Matrix"
                )
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Matrix Tests",
            dependencies: [
                .target(
                    name: "Matrix"
                ),
                .target(
                    name: "Matrix Test Support"
                ),
                .product(name: "Projection", package: "swift-projection", condition: .when(traits: ["Projection"])),
                .product(name: "Quaternion", package: "swift-quaternion", condition: .when(traits: ["Quaternion"])),
                .product(name: "Rotation", package: "swift-rotation", condition: .when(traits: ["Rotation"])),
                .product(name: "Trigonometry", package: "swift-trigonometry", condition: .when(traits: ["Trigonometry", "Rotation"])),
                .product(name: "Scale", package: "swift-scale", condition: .when(traits: ["Scale"])),
                .product(name: "Shear", package: "swift-shear", condition: .when(traits: ["Shear"])),
            ],
            path: "Tests/Matrix Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
