import PackageDescription

let package = Package(
    name: "SlackKit",
    targets: [
        Target(name: "SlackKit", dependencies: [
            "SKCore",
            "SKClient",
            "SKRTM",
            "SKServer"
        ]),
        Target(name: "SKCore", dependencies: []),
        Target(name: "SKRTM", dependencies: [
            "SKCore"
        ]),
        Target(name: "SKClient", dependencies: [
            "SKCore"
        ]),
        Target(name: "SKServer", dependencies: [
            "SKCore"
        ])
    ],
    dependencies: [
        .Package(url: "https://github.com/Zewo/WebSocketClient", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/HTTPServer", majorVersion: 0),
        .Package(url: "https://github.com/daltoniam/Starscream", majorVersion: 2),
        .Package(url: "https://github.com/pvzig/swifter.git", majorVersion: 3)
    ]
)
