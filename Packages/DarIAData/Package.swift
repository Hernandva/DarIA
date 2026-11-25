// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "DarIAData",
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "DarIAData", targets: ["DarIAData"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0")
    ],
    targets: [
        .target(
            name: "DarIAData",
            dependencies: [.product(name: "Alamofire", package: "Alamofire")]
        ),
        .testTarget(
            name: "DarIADataTests",
            dependencies: ["DarIAData"]
        )
    ],
    swiftLanguageModes: [.v6]
)
