// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WhereUAt",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        // Firebase for real-time database and authentication
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        
        // Networking and HTTP client
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
        
        // Map framework
        .package(url: "https://github.com/mapbox/mapbox-maps-ios.git", from: "11.0.0"),
        
        // Location services
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "WhereUAt",
            dependencies: [
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "MapboxMaps", package: "mapbox-maps-ios"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
            path: "WhereUAt",
            sources: [
                "App",
                "Models",
                "ViewModels",
                "Views",
                "Services",
                "Resources"
            ]
        ),
        .testTarget(
            name: "WhereUAtTests",
            dependencies: ["WhereUAt"],
            path: "Tests/WhereUAtTests"
        ),
        .testTarget(
            name: "WhereUAtIntegrationTests",
            dependencies: ["WhereUAt"],
            path: "Tests/WhereUAtIntegrationTests"
        ),
    ]
)
