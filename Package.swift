import PackageDescription

let package = Package(
    name: "SlackKit",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/pvzig/swifter",
                 majorVersion: 1),
        .Package(url: "https://github.com/daltoniam/Starscream", majorVersion: 2)
    ]
)
