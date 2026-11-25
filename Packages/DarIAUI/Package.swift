// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "DarIAUI",
    defaultLocalization: "en",
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "DarIAUI", targets: ["DarIAUI"])
    ],
    targets: [
        .target(
            name: "DarIAUI",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "DarIAUITests",
            dependencies: ["DarIAUI"]
        )
    ],
    swiftLanguageModes: [.v6]
)
