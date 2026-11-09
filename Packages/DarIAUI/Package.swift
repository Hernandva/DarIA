// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DarIAUI",
    defaultLocalization: "en",
    platforms: [.iOS("18.0"), .macOS("15.0")],
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
