// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "CommuteAssistant",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "CommuteKit", targets: ["CommuteKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.28.0"),
    ],
    targets: [
        .target(
            name: "CommuteKit",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ],
            path: "CommuteKit"
        ),
        .testTarget(
            name: "CommuteKitTests",
            dependencies: ["CommuteKit"],
            path: "CommuteKitTests"
        ),
    ]
)
