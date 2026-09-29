// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Spendot",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Spendot",
            path: "Sources/Spendot"
        )
    ]
)
