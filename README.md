# StormGlassKit

[![SwiftPM compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStarLard%2FStormGlassKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StarLard/StormGlassKit)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://github.com/StarLard/StormGlassKit/blob/main/LICENSE)

A pure Swift SDK for consuming the official [StormGlass API](https://docs.stormglass.io)

## Note

Currently only the Global & Marine Weather APIs are supported.

## Installation

StormGlassKit is available through [Swift Package Manager](https://swift.org/package-manager/), a dependency manager built into Xcode.

If you are using Xcode 11 or higher, go to **File / Swift Packages / Add Package Dependency...** and enter package repository URL **https://github.com/StarLard/StormGlassKit.git**, then follow the instructions.

To remove the dependency, select the project and open **Swift Packages** (which is next to **Build Settings**). You can add and remove packages from this tab.

> Swift Package Manager can also be used [from the command line](https://swift.org/package-manager/).

## Usage

1. In your application's `application(_:didFinishLaunchingWithOptions:)` method, configure `StormGlassKit` using one of the following methods:
    * Add a `StormGlassKit-Configuration.plist` file to your project that includes an "API_KEY" key with your API key as the value. You may then
    call `StormGlassKit.configure()`.
    * Create and configure a custom `StormGlassKit.Configuration` and use it to call `StormGlassKit.configure(with:)`.
2. Get weather forcasts using the `StormGlassKit.fetchWeather(...)` method. StormGlassKit provides APIs for both `Combine` and Swift concurrency's async/await pattern. The returned value will contain a `Weather` type which contains the requested forecast, organized by hour, and the associated meta data.

## Author

[@StarLard]([https://twitter.com/CalebFriden](https://bsky.app/profile/starlard.bsky.social))

## License

StormGlassKit is available under the Apache 2.0 license. See the LICENSE file for more info.
