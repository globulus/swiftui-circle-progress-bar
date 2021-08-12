// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUICircleProgressBar",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [

        .library(
            name: "SwiftUICircleProgressBar",
            targets: ["SwiftUICircleProgressBar"]),
    ],
    dependencies: [

    ],
    targets: [

        .target(
            name: "SwiftUICircleProgressBar",
            dependencies: []),
    ]
)
