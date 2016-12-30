import Foundation
import SlackKit

class Echobot: MessageEventsDelegate {
    
    let client: SlackClient
    
    init(token: String) {
        client = SlackClient(apiToken: token)
        client.messageEventsDelegate = self
    }
    
    // MARK: MessageEventsDelegate
    func sent(_ message: Message, client: SlackClient) {}
    func changed(_ message: Message, client: SlackClient) {}
    func deleted(_ message: Message?, client: SlackClient) {}
    func received(_ message: Message, client: SlackClient) {
        listen(message: message)
    }
    
    // MARK: Echobot Internal Logic
    private func listen(message: Message) {
        if let channel = message.channel, let text = message.text, let id = client.authenticatedUser?.id {
            if id != message.user && message.user != nil {
                client.webAPI.sendMessage(channel:channel, text: text, linkNames: true, success: {(response) in
                }, failure: { (error) in
                    print("Echobot failed to reply due to error:\(error)")
                })
            }
        }
    }
}

let echobot = Echobot(token: "xoxb-SLACK_API_TOKEN")
echobot.client.connect()
