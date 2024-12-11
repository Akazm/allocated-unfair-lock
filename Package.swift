// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "allocated-unfair-lock-shim",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "AllocatedUnfairLockShim",
            targets: ["AllocatedUnfairLockShim"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.54.0"),
    ],
    targets: [
        .target(
            name: "AllocatedUnfairLockShim"
        ),
        .testTarget(
            name: "AllocatedUnfairLockShimTests",
            dependencies: ["AllocatedUnfairLockShim"]
        ),
        .testTarget(
            name: "AllocatedUnfairLockShimTestsWithDisabledConcurrencyChecks",
            dependencies: ["AllocatedUnfairLockShim"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .executableTarget(
            name: "CmdLineAllocatedUnfairLockTests",
            dependencies: ["AllocatedUnfairLockShim"]
        )
    ]
)
