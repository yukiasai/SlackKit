import PackageDescription

let package = Package(
    name: "SlackKit",
    targets: [
        Target(name: "SlackKit", dependencies: [
            "SKCommon",
            "SKClient",
            "SKServer"
        ]),
        Target(name: "SKCommon", dependencies: []),
        Target(name: "SKClient", dependencies: [
            "SKCommon"
        ]),
        Target(name: "SKServer", dependencies: [
            "SKCommon"
        ])
    ],
    dependencies: [
        .Package(url: "https://github.com/Zewo/WebSocketClient", majorVersion: 0),
        .Package(url: "https://github.com/daltoniam/Starscream", majorVersion: 2),
        .Package(url: "https://github.com/pvzig/swifter.git", majorVersion: 3)
    ]
)
