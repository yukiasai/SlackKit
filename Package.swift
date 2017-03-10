import PackageDescription

let package = Package(
    name: "SlackKit",
    targets: [
        Target(name: "SlackKit", dependencies: [
            "SKCore",
            "SKClient",
            "SKRTMAPI",
            "SKServer"
        ]),
        Target(name: "SKCore", dependencies: []),
        Target(name: "SKRTMAPI", dependencies: [
            "SKCore",
            "SKWebAPI"
        ]),
        Target(name: "SKWebAPI", dependencies: [
            "SKCore"
        ]),
        Target(name: "SKClient", dependencies: [
            "SKCore"
        ]),
        Target(name: "SKServer", dependencies: [
            "SKCore",
            "SKWebAPI"
        ])
    ],
    dependencies: [
        .Package(url: "https://github.com/Zewo/WebSocketClient", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/HTTPServer", majorVersion: 0)
    ]
)

#if os(macOS) || os(iOS) || os(tvOS)
let dependencies: [Package.Dependency] = [
    .Package(url: "https://github.com/daltoniam/Starscream", majorVersion: 2),
    .Package(url: "https://github.com/pvzig/swifter.git", majorVersion: 3)
]
package.dependencies.append(contentsOf: dependencies)
#endif
