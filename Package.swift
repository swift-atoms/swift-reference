// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-reference-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Reference Primitives",
            targets: ["Reference Primitives"]
        ),
        .library(
            name: "Reference Primitives Test Support",
            targets: ["Reference Primitives Test Support"]
        ),
    ],
    targets: [
        .target(
            name: "Reference Primitives"
        ),
        .target(
            name: "Reference Primitives Test Support",
            dependencies: [
                "Reference Primitives"
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Reference Primitives Tests",
            dependencies: [
                "Reference Primitives",
                "Reference Primitives Test Support",
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
