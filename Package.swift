// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "VPNClient",
    platforms: [
        .iOS(.v15)
    ],
    targets: [
        .executableTarget(
            name: "VPNClient",
            path: "Sources/VPNClient"
        )
    ]
)
