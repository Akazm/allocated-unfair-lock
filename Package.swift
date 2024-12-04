// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "OSAllocatedUnfairLockShim",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "AllocatedUnfairLock",
            targets: ["AllocatedUnfairLock"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.54.0"),
    ],
    targets: [
        .target(
            name: "AllocatedUnfairLock"
        ),
        .testTarget(
            name: "AllocatedUnfairLockShimTests",
            dependencies: ["AllocatedUnfairLock"]
        ),
        .testTarget(
            name: "AllocatedUnfairLockShimTestsWithDisabledConcurrencyChecks",
            dependencies: ["AllocatedUnfairLock"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
          ]
        ),
        .executableTarget(
            name: "CmdLineAllocatedUnfairLockTests",
            dependencies: ["AllocatedUnfairLock"]
        )
    ]
)
