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
        .library(name: "Reference", targets: ["Reference"]),
        .library(name: "Reference Standard Library Integration", targets: ["Reference Standard Library Integration"]),
        .library(name: "Reference Foundation Library Integration", targets: ["Reference Foundation Library Integration"]),
        .library(name: "Reference Test Support", targets: ["Reference Test Support"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Reference",
            dependencies: [
            ],
            path: "Sources/Reference"
        ),
        .target(
            name: "Reference Standard Library Integration",
            dependencies: [
                .target(name: "Reference"),
            ],
            path: "Sources/Reference Standard Library Integration"
        ),
        .target(
            name: "Reference Foundation Library Integration",
            dependencies: [
                .target(name: "Reference"),
                .target(name: "Reference Standard Library Integration"),
            ],
            path: "Sources/Reference Foundation Library Integration"
        ),
        .target(
            name: "Reference Test Support",
            dependencies: [
                .target(name: "Reference"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Reference Tests",
            dependencies: [
                .target(name: "Reference"),
                .target(name: "Reference Test Support"),
                .target(name: "Reference Standard Library Integration"),
                .target(name: "Reference Foundation Library Integration"),
            ],
            path: "Tests/Reference Tests"
        ),
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
