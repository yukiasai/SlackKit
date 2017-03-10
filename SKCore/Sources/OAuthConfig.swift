//
//  OAuthConfig.swift
//  SlackKit
//
//  Created by Peter Zignego on 3/7/17.
//
//

import Foundation

public struct OAuthConfig {
    
    public let clientID: String
    public let clientSecret: String
    public let state: String
    public let redirectURI: String?

    public init(clientID: String, clientSecret: String, state: String = "", redirectURI: String? = nil) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.state = state
        self.redirectURI = redirectURI
    }
}
