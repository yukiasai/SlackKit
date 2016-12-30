![SlackKit](https://cloud.githubusercontent.com/assets/8311605/10260893/5ec60f96-694e-11e5-91fd-da6845942201.png)![Swift Version](https://img.shields.io/badge/Swift-3.0-orange.svg) ![Plaforms](https://img.shields.io/badge/Platforms-Linux-lightgrey.svg) ![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg) [![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
##SlackKit: A Swift Slack Client Library
###Description
This is a Slack client library for Linux written in Swift. It's intended to expose all of the functionality of Slack's [Real Time Messaging API](https://api.slack.com/rtm) as well as the [web APIs](https://api.slack.com/web) that are accessible by [bot users](https://api.slack.com/bot-users).

###Installation

####Swift Package Manager
Add SlackKit to your Package.swift

```swift
import PackageDescription

let package = Package(
	name: "MySlackApp",
    dependencies: [
        .Package(url: "https://github.com/pvzig/SlackKit.git", majorVersion: 0, minor: 0)
    ]
)
```

####Development
To develop an application that uses SlackKit in Xcode, simply use SwiftPM:
```
swift package generate-xcodeproj
```


To use the library in your project import it:
```
import SlackKit
```

###Examples
See the [examples folder](https://github.com/pvzig/SlackKit/tree/linux/Examples) for a few examples of how you can use SlackKit.

###Deployment
Deploy your application to Heroku using [this buildpack](https://github.com/kylef/heroku-buildpack-swift). You can also deploy your application anywhere you can deploy a docker container. For more detailed instructions please see [this post](https://medium.com/@pvzig/building-slack-bots-in-swift-b99e243e444c).

###Usage
To use SlackKit you'll need a bearer token which identifies a single user. You can generate a [full access token or create one using OAuth 2](https://api.slack.com/web).

Once you have a token, initialize a client instance using it:
```swift
let client = SlackClient(apiToken: "YOUR_SLACK_API_TOKEN")
```

If you want to receive messages from the Slack RTM API, connect to it.
```swift
client.connect()
```

Once connected, the client will begin to consume any messages sent by the Slack RTM API.

####Web API Methods
SlackKit currently supports the a subset of the Slack Web APIs that are available to bot users:

- api.test
- auth.test
- channels.history
- channels.info
- channels.list
- channels.mark
- channels.setPurpose
- channels.setTopic
- chat.delete
- chat.postMessage
- chat.update
- emoji.list
- files.comments.add
- files.comments.edit
- files.comments.delete
- files.delete
- files.info
- files.upload
- groups.close
- groups.history
- groups.info
- groups.list
- groups.mark
- groups.open
- groups.setPurpose
- groups.setTopic
- im.close
- im.history
- im.list
- im.mark
- im.open
- mpim.close
- mpim.history
- mpim.list
- mpim.mark
- mpim.open
- pins.add
- pins.list
- pins.remove
- reactions.add
- reactions.get
- reactions.list
- reactions.remove
- rtm.start
- stars.add
- stars.remove
- team.info
- users.getPresence
- users.info
- users.list
- users.setActive
- users.setPresence

They can be accessed through a Client object’s `webAPI` property:
```swift
client.webAPI.authenticationTest({(authenticated) in
	print(authenticated)
}) {(error) in
	print(error)
}
```

####Delegate methods

To receive delegate callbacks for certain events, register an object as the delegate for those events:
```swift
client.connectionEventsDelegate = self
```

There are a number of delegates that you can set to receive callbacks for certain events.

##### ConnectionEventsDelegate
```swift
connected(_ client: Client)
disconnected(_ client: Client)
connectionFailed(_ client: Client, error: SlackError)
```
##### MessageEventsDelegate
```swift
sent(_ message: Message, client: Client)
received(_ message: Message, client: Client)
changed(_ message: Message, client: Client)
deleted(_ message: Message?, client: Client)
```
##### ChannelEventsDelegate
```swift
userTypingIn(_ channel: Channel, user: User, client: Client)
marked(_ channel: Channel, timestamp: String, client: Client)
created(_ channel: Channel, client: Client)
deleted(_ channel: Channel, client: Client)
renamed(_ channel: Channel, client: Client)
archived(_ channel: Channel, client: Client)
historyChanged(_ channel: Channel, client: Client)
joined(_ channel: Channel, client: Client)
left(_ channel: Channel, client: Client)
```
##### DoNotDisturbEventsDelegate
```swift
updated(_ status: DoNotDisturbStatus, client: Client)
userUpdated(_ status: DoNotDisturbStatus, user: User, client: Client)
```
##### GroupEventsDelegate
```swift
opened(_ group: Channel, client: Client)
```
##### FileEventsDelegate
```swift
processed(_ file: File, client: Client)
madePrivate(_ file: File, client: Client)
deleted(_ file: File, client: Client)
commentAdded(_ file: File, comment: Comment, client: Client)
commentEdited(_ file: File, comment: Comment, client: Client)
commentDeleted(_ file: File, comment: Comment, client: Client)
```
##### PinEventsDelegate
```swift
pinned(_ item: Item, channel: Channel?, client: Client)
unpinned(_ item: Item, channel: Channel?, client: Client)
```
##### StarEventsDelegate
```swift
starred(_ item: Item, starred: Bool, _ client: Client)
```
##### ReactionEventsDelegate
```swift
added(_ reaction: String, item: Item, itemUser: String, client: Client)
removed(_ reaction: String, item: Item, itemUser: String, client: Client)
```
##### SlackEventsDelegate
```swift
preferenceChanged(_ preference: String, value: Any?, client: Client)
userChanged(_ user: User, client: Client)
presenceChanged(_ user: User, presence: String, client: Client)
manualPresenceChanged(_ user: User, presence: String, client: Client)
botEvent(_ bot: Bot, client: Client)
```
##### TeamEventsDelegate
```swift
userJoined(_ user: User, client: Client)
planChanged(_ plan: String, client: Client)
preferencesChanged(_ preference: String, value: Any?, client: Client)
nameChanged(_ name: String, client: Client)
domainChanged(_ domain: String, client: Client)
emailDomainChanged(_ domain: String, client: Client)
emojiChanged(_ client: Client)
```
##### SubteamEventsDelegate
```swift
event(_ userGroup: UserGroup, client: Client)
selfAdded(_ subteamID: String, client: Client)
selfRemoved(_ subteamID: String, client: Client)
```
##### TeamProfileEventsDelegate
```swift
changed(_ profile: CustomProfile, client: Client)
deleted(_ profile: CustomProfile, client: Client)
reordered(_ profile: CustomProfile, client: Client)
```

###Get In Touch
[@pvzig](https://twitter.com/pvzig)

<peter@launchsoft.co>
