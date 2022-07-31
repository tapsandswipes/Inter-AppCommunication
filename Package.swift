// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Inter-AppCommunication",
    platforms: [.iOS(.v13), .macOS(.v10_13), .tvOS(.v13)],
    products: [
        .library(name: "IACCore", targets: ["IACCore"]),
        .library(name: "IACClients", targets: ["IACClients"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "IACCore"),
        .target(
            name: "IACClients",
            dependencies: ["IACCore"]),
        .testTarget(
            name: "IACTests",
            dependencies: ["IACCore"]),
    ]
)
