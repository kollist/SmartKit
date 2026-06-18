// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SmartKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SmartKit", targets: ["SmartKit"])
    ],
    targets: [
        .target(name: "SmartKit"),
        .testTarget(name: "SmartKitTests", dependencies: ["SmartKit"])
    ]
)
