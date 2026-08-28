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
            name: "Reference Test Support",
            targets: ["Reference Test Support"]
        ),
    ],
    targets: [
        .target(
            name: "Reference"
        ),
        .target(
            name: "Reference Test Support",
            dependencies: [
                "Reference"
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Reference Tests",
            dependencies: [
                "Reference",
                "Reference Test Support",
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
