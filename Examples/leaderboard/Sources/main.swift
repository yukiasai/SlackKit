import Foundation
import SlackKit

class Leaderboard: MessageEventsDelegate {
    
    var leaderboard: [String: Int] = [String: Int]()
    let atSet = CharacterSet(charactersIn: "@")
    
    let client: SlackClient
    
    init(token: String) {
        client = SlackClient(apiToken: token)
        client.messageEventsDelegate = self
    }
    
    enum Command: String {
        case leaderboard = "leaderboard"
    }
    
    enum Trigger: String {
        case plusPlus = "++"
        case minusMinus = "--"
    }
    
    // MARK: MessageEventsDelegate
    func sent(_ message: Message, client: SlackClient) {}
    func changed(_ message: Message, client: SlackClient) {}
    func deleted(_ message: Message?, client: SlackClient) {}
    func received(_ message: Message, client: SlackClient) {
        listen(message: message)
    }
    
    // MARK: Leaderboard Internal Logic
    private func listen(message: Message) {
        if let id = client.authenticatedUser?.id, let text = message.text {
            if text.lowercased().contains(Command.leaderboard.rawValue) && text.contains(id) {
                handleCommand(command: .leaderboard, channel: message.channel)
            }
        }
        if message.text?.contains(Trigger.plusPlus.rawValue) == true {
            handleMessageWithTrigger(message: message, trigger: .plusPlus)
        }
        if message.text?.contains(Trigger.minusMinus.rawValue) == true {
            handleMessageWithTrigger(message: message, trigger: .minusMinus)
        }
    }
    
    private func handleMessageWithTrigger(message: Message, trigger: Trigger) {
        if let text = message.text, let start = text.range(of: "@")?.lowerBound, let end = text.range(of: trigger.rawValue)?.lowerBound {
            let string = String(text.characters[start...end].dropLast().dropFirst())
            let users = client.users.values.filter{$0.id == self.userID(string: string)}
            if users.count > 0 {
                let idString = userID(string: string)
                initalizationForValue(dictionary: &leaderboard, value: idString)
                scoringForValue(dictionary: &leaderboard, value: idString, trigger: trigger)
            } else {
                initalizationForValue(dictionary: &leaderboard, value: string)
                scoringForValue(dictionary: &leaderboard, value: string, trigger: trigger)
            }
        }
    }
    
    private func handleCommand(command: Command, channel:String?) {
        switch command {
        case .leaderboard:
            if let id = channel {
                client.webAPI.sendMessage(channel:id, text: "Leaderboard", linkNames: true, attachments: [constructLeaderboardAttachment()], success: {(response) in
                    print(response)
                }, failure: { (error) in
                    print("Leaderboard failed to post due to error:\(error)")
                })
            }
        }
    }
    
    private func initalizationForValue( dictionary: inout [String: Int], value: String) {
        if dictionary[value] == nil {
            dictionary[value] = 0
        }
    }
    
    private func scoringForValue( dictionary: inout [String: Int], value: String, trigger: Trigger) {
        switch trigger {
        case .plusPlus:
            dictionary[value]?+=1
        case .minusMinus:
            dictionary[value]?-=1
        }
    }
    
    // MARK: Leaderboard Interface
    private func constructLeaderboardAttachment() -> Attachment? {
        let 💯 = AttachmentField(title: "💯", value: swapIDsForNames(string: topItems(dictionary: &leaderboard)), short: true)
        let 💩 = AttachmentField(title: "💩", value: swapIDsForNames(string: bottomItems(dictionary: &leaderboard)), short: true)
        return Attachment(fallback: "Leaderboard", title: "Leaderboard", colorHex: AttachmentColor.good.rawValue, text: "", fields: [💯, 💩])
    }
    
    private func topItems(dictionary: inout [String: Int]) -> String {
        let sortedKeys = dictionary.keys.sorted(by: { (k1: String, k2: String) -> Bool in
            return dictionary[k1]! > dictionary[k2]!
        }).filter({ dictionary[$0]! > 0})
        let sortedValues = dictionary.values.sorted(by: {$0 > $1}).filter({$0 > 0})
        return leaderboardString(keys: sortedKeys, values: sortedValues)
    }
    
    private func bottomItems( dictionary: inout [String: Int]) -> String {
        let sortedKeys = dictionary.keys.sorted(by: { (k1: String, k2: String) -> Bool in
            return dictionary[k1]! < dictionary[k2]!
        }).filter({ dictionary[$0]! < 0})
        let sortedValues = dictionary.values.sorted(by: {$0 < $1}).filter({$0 < 0})
        return leaderboardString(keys: sortedKeys, values: sortedValues)
    }
    
    private func leaderboardString(keys: [String], values: [Int]) -> String {
        var returnValue = ""
        for i in 0..<values.count {
            returnValue += keys[i] + " (" + "\(values[i])" + ")\n"
        }
        return returnValue
    }
    
    // MARK: - Utilities
    private func swapIDsForNames(string: String) -> String {
        var returnString = string
        for key in client.users.keys {
            if let name = client.users[key]?.name {
                if returnString.contains(key) {
                    returnString = returnString.replacingOccurrences(of: key, with: "@"+name)
                }
            }
        }
        return returnString
    }
    
    private func userID(string: String) -> String {
        return string.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    }
}

let leaderboard = Leaderboard(token: "xoxb-SLACK_API_TOKEN")
leaderboard.client.connect()
