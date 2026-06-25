// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-reference-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
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
                "Reference Primitives",
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
