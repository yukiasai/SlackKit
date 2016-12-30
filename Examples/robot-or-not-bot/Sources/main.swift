import Foundation
import SlackKit

class RobotOrNotBot: MessageEventsDelegate {
    
    let verdicts: [String:Bool] = [
        "Mr. Roboto" : false,
        "Service Kiosks": false,
        "Darth Vader": false,
        "K-9": true,
        "Emotions": false,
        "Self-Driving Cars": false,
        "Telepresence Robots": false,
        "Roomba": true,
        "Assembly-Line Robot": false,
        "ASIMO": false,
        "KITT": false,
        "USS Enterprise": false,
        "Transformers": true,
        "Jaegers": false,
        "The Major": false,
        "Siri": false,
        "The Terminator": true,
        "Commander Data": false,
        "Marvin the Paranoid Android": true,
        "Pinocchio": false,
        "Droids": true,
        "Hitchbot": false,
        "Mars Rovers": false,
        "Space Probes": false,
        "Sasquatch": false,
        "Toaster": false,
        "Toaster Oven": false,
        "Cylons": false,
        "V'ger": true,
        "Ilia Robot": false,
        "The TARDIS": false,
        "Johnny 5": true,
        "Twiki": true,
        "Dr. Theopolis": false,
        "robots.txt": false,
        "Lobot": false,
        "Vicki": true,
        "GlaDOS": false,
        "Turrets": true,
        "Wheatley": true,
        "Herbie the Love Bug": false,
        "Iron Man": false,
        "Ultron": false,
        "The Vision": false,
        "Clockwork Droids": false,
        "Podcasts": false,
        "Cars": false,
        "Swimming Pool Cleaners": false,
        "Burritos": false,
        "Prince Robot IV": false,
        "Daleks": false,
        "Cybermen": false,
        "The Internet of Things": false,
        "Nanobots": true,
        "Two Intermeshed Gears": false,
        "Crow T. Robot": true,
        "Tom Servo": true,
        "Thomas and Friends": false,
        "Replicants": false,
        "Chatbots": false,
        "Agents": false,
        "Lego Simulated Worm Toy": true,
        "Ghosts": false,
        "Exos": true,
        "Rasputin": false,
        "Tamagotchi": false,
        "T-1000": true,
        "The Tin Woodman": false,
        "Mic N. The Robot": true,
        "Robot Or Not Bot": false
    ]
    
    let client: SlackClient
    
    init(token: String) {
        client = SlackClient(apiToken: token)
        client.messageEventsDelegate = self
    }
    
    // MARK: MessageEventsDelegate
    func received(_ message: Message, client: SlackClient) {
        if let id = client.authenticatedUser?.id {
            if message.text?.contains(id) == true {
                handleMessage(message: message)
            }
        }
    }
    func changed(_ message: Message, client: SlackClient) {}
    func deleted(_ message: Message?, client: SlackClient) {}
    func sent(_ message: Message, client: SlackClient) {}
    
    private func handleMessage(message: Message) {
        if let text = message.text?.lowercased(), let channel = message.channel {
            for (robot, verdict) in verdicts {
                let lowerbot = robot.lowercased()
                if text.contains(lowerbot) {
                    if verdict == true {
                        client.webAPI.addReaction(name: "robot_face", channel: channel, timestamp: message.ts, success: nil, failure: nil)
                    } else {
                        client.webAPI.addReaction(name: "no_entry_sign", channel: channel, timestamp: message.ts, success: nil, failure: nil)
                    }
                    return
                }
            }
            client.webAPI.addReaction(name: "question", channel: channel, timestamp: message.ts, success: nil, failure: nil)
        }
    }
}

let slackbot = RobotOrNotBot(token: "xoxb-SLACK_API_TOKEN")
slackbot.client.connect()
