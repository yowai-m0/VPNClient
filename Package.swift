// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "VPNClient",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "VPNClient",
            targets: ["VPNClient"]
        ),
    ],
    targets: [
        .target(
            name: "VPNClient",
            path: "Sources/VPNClient"
        )
    ]
)