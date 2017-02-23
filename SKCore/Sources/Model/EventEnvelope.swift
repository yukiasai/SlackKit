//
//  EventEnvelope.swift
//  SlackKit
//
//  Created by Peter Zignego on 2/5/17.
//  Copyright © 2017 Launch Software LLC. All rights reserved.
//

import Foundation

enum EnvelopeType: String {
    case callback = "event_callback"
    case verification = "url_verification"
}

public class EventEnvelope {
    
    let token: String?
    let challenge: String?
    let teamID: String?
    let apiAppID: String?
    let event: Event?
    let type: EnvelopeType?
    let authedUsers: [String]?
    
    public init(_ eventEnvelope: [String: Any]) {
        token = eventEnvelope["token"] as? String
        challenge = eventEnvelope["challenge"] as? String
        teamID = eventEnvelope["team_id"] as? String
        apiAppID = eventEnvelope["api_app_id"] as? String
        event = Event(eventEnvelope["event"] as? [String: Any] ?? [:])
        type = EnvelopeType(rawValue: eventEnvelope["type"] as? String ?? "")
        authedUsers = eventEnvelope["authed_users"] as? [String]
    }
}
