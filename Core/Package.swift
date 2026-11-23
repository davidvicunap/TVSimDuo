// swift-tools-version: 6.0
// DuoCore — platform-agnostic engines for DuoTrade.
//
// Pure-Swift targets build and test on Linux (`swift test`) as well as on Apple
// platforms. Apple-only targets (Metal rendering, JavaScriptCore scripting) are
// declared only when the manifest is evaluated on an Apple host.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
]

var products: [Product] = [
    .library(name: "MarketData", targets: ["MarketData"]),
    .library(name: "QuantEngine", targets: ["QuantEngine"]),
    .library(name: "Trading", targets: ["Trading"]),
    .library(name: "ChartEngine", targets: ["ChartEngine"]),
    .library(name: "WorkspaceModel", targets: ["WorkspaceModel"]),
]

var targets: [Target] = [
    .target(name: "MarketData", swiftSettings: swiftSettings),
    .target(name: "QuantEngine", dependencies: ["MarketData"], swiftSettings: swiftSettings),
    .target(name: "Trading", dependencies: ["MarketData"], swiftSettings: swiftSettings),
    .target(name: "ChartEngine", dependencies: ["MarketData"], swiftSettings: swiftSettings),
    .target(
        name: "WorkspaceModel",
        dependencies: ["MarketData", "QuantEngine", "Trading", "ChartEngine"],
        swiftSettings: swiftSettings
    ),

    .testTarget(name: "MarketDataTests", dependencies: ["MarketData"], swiftSettings: swiftSettings),
    .testTarget(name: "QuantEngineTests", dependencies: ["QuantEngine"], swiftSettings: swiftSettings),
    .testTarget(name: "TradingTests", dependencies: ["Trading"], swiftSettings: swiftSettings),
    .testTarget(name: "ChartEngineTests", dependencies: ["ChartEngine"], swiftSettings: swiftSettings),
    .testTarget(name: "WorkspaceModelTests", dependencies: ["WorkspaceModel"], swiftSettings: swiftSettings),
]

#if !os(Linux)
products += [
    .library(name: "ChartRendering", targets: ["ChartRendering"]),
    .library(name: "ScriptRuntime", targets: ["ScriptRuntime"]),
]
targets += [
    .target(
        name: "ChartRendering",
        dependencies: ["ChartEngine", "MarketData"],
        swiftSettings: swiftSettings
    ),
    .target(
        name: "ScriptRuntime",
        dependencies: ["MarketData", "QuantEngine"],
        swiftSettings: swiftSettings
    ),
]
#endif

let package = Package(
    name: "DuoCore",
    platforms: [.iOS("27.1"), .macOS("26.0")],
    products: products,
    targets: targets,
    swiftLanguageModes: [.v6]
)
