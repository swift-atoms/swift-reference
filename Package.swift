// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-reference",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Reference",
            targets: ["Reference"]
        ),
        .library(
            name: "Reference Standard Library Integration",
            targets: ["Reference Standard Library Integration"]
        ),
        .library(
            name: "Reference Apple Foundation Integration",
            targets: ["Reference Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Reference",
            dependencies: []
        ),
        .target(
            name: "Reference Standard Library Integration",
            dependencies: ["Reference"]
        ),
        .target(
            name: "Reference Apple Foundation Integration",
            dependencies: [
                "Reference",
                "Reference Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Reference Tests",
            dependencies: ["Reference"],
            path: "Tests/Reference Tests"
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
