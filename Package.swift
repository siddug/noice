// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Noice",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Noice",
            path: "Sources/Noice",
            resources: [
                .copy("Resources/Sounds")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
