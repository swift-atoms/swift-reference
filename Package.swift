// swift-tools-version: 6.2

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
    ],
    dependencies: [
        .package(path: "../swift-ownership-primitives"),
    ],
    targets: [
        .target(
            name: "Reference Primitives",
            dependencies: [
                .product(name: "Ownership Primitives", package: "swift-ownership-primitives"),
            ],
            swiftSettings: [
                .strictMemorySafety()
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
