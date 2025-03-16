// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "StormGlassKit",
    platforms: [ .iOS(.v15), .macOS(.v12), .tvOS(.v16), .watchOS(.v8) ],
    products: [
        .library(
            name: "StormGlassKit",
            targets: ["StormGlassKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StormGlassKit",
            dependencies: []
        ),
        .testTarget(
            name: "StormGlassKitTests",
            dependencies: ["StormGlassKit"]
        ),
    ]
)
