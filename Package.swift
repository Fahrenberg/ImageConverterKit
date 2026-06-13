// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ImageCompressionKit",
    platforms: [.iOS(.v15), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ImageCompressionKit",
            targets: ["ImageCompressionKit"])
    ],
    
    dependencies: [
        .package(url: "https://github.com/JohnSundell/CollectionConcurrencyKit.git", from: "0.1.0"),
        .package(url: "https://github.com/Fahrenberg/Extensions.git", from: "5.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Spikes",
            dependencies: ["ImageCompressionKit", "Extensions"],
            path: "Spikes",
            resources: [
                .process("Ressources"),
            ]
        ),
        .target(
            name: "ImageCompressionKit",
            dependencies: ["Extensions"]
        ),
        .testTarget(
            name: "ImageCompressionKitTests",
            dependencies: [
                "ImageCompressionKit",
                "CollectionConcurrencyKit"
            ],
            resources: [
                //                .process("Images.xcassets"),
                .process("TestRessources")
            ]
        ),
    ]
)
