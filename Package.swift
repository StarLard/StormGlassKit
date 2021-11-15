// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StormGlassKit",
    platforms: [ .iOS(.v14), .macOS(.v11), .tvOS(.v14), .watchOS(.v7) ],
    products: [
        .library(
            name: "StormGlassKit",
            targets: ["StormGlassKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StormGlassKit",
            dependencies: []),
        .testTarget(
            name: "StormGlassKitTests",
            dependencies: ["StormGlassKit"]),
    ]
)
