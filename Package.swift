// swift-tools-version:5.5
import PackageDescription
import Foundation

let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let headerPath = currentDirectory.appendingPathComponent("node-addon/eventkit_node-Swift.h").path

let package = Package(
    name: "eventkit_node",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "EventKitBridge",
            type: .static,
            targets: ["EventKitBridge"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "EventKitBridge",
            dependencies: [],
            path: "node-addon",
            sources: ["EventKitBridge.swift"],
            swiftSettings: [
                .unsafeFlags(["-emit-objc-header", "-emit-objc-header-path", "node-addon/eventkit_node-Swift.h"])
            ]
        )
    ]
) 