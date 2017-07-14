import PackageDescription

let package = Package(
    name: "SlackKit",
    targets: [
        Target(name: "SlackKit")
    ],
    dependencies: [
        .Package(url: "https://github.com/SlackKit/SKCore", majorVersion: 4),
        .Package(url: "https://github.com/SlackKit/SKClient", majorVersion: 4),
        .Package(url: "https://github.com/SlackKit/SKRTMAPI", majorVersion: 4),
        .Package(url: "https://github.com/SlackKit/SKServer", majorVersion: 4)
    ]
)
