// swift-tools-version: 6.4
import PackageDescription
let package = Package(
    name: "swift-matrix",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Matrix", targets: ["Matrix"]),
        .library(name: "Matrix Standard Library Integration", targets: ["Matrix Standard Library Integration"]),
        .library(name: "Matrix Foundation Library Integration", targets: ["Matrix Foundation Library Integration"]),
        .library(name: "Matrix Test Support", targets: ["Matrix Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-vector.git", branch: "main"),
    ],
    targets: [
        .target(name: "Matrix", dependencies: [.product(name: "Vector", package: "swift-vector")], path: "Sources/Matrix"),
        .target(name: "Matrix Standard Library Integration", dependencies: ["Matrix"], path: "Sources/Matrix Standard Library Integration"),
        .target(name: "Matrix Foundation Library Integration", dependencies: ["Matrix", "Matrix Standard Library Integration"], path: "Sources/Matrix Foundation Library Integration"),
        .target(name: "Matrix Test Support", dependencies: ["Matrix"], path: "Tests/Support"),
        .testTarget(name: "Matrix Tests", dependencies: ["Matrix", "Matrix Test Support", "Matrix Standard Library Integration", "Matrix Foundation Library Integration"], path: "Tests/Matrix Tests"),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
