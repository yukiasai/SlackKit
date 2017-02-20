//
// SlackKit.swift
//
// Copyright © 2016 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SKClient
import SKCommon
import SKServer

public final class SlackKit: OAuthDelegate {
    
    internal(set) public var rtm: RTMClient
    internal(set) public var server: Server?
    internal(set) public var clients: [String: RTMClient] = [:]
    private let options: ClientOptions
    
    // If you already have an API token
    public init(withAPIToken token: String, client: Client? = Client(), options: ClientOptions = ClientOptions(), rtm: RTM? = nil) {
        self.options = options
        self.rtm = RTMClient(token: token, rtm: rtm, options: options)
        self.rtm.client = client
        clients[token] = self.rtm
        self.rtm.connect()
    }

    // If you're going to be receiving and/or initiating OAuth requests, provide a client ID and secret
    public init(clientID: String, clientSecret: String, state: String? = nil, redirectURI: String? = nil, rtm: RTM? = nil, options: ClientOptions = ClientOptions(), notifications: [EventType] = [], port: in_port_t = 8080, forceIPV4: Bool = false) {
        self.options = options
        server = Server(clientID: clientID, clientSecret: clientSecret, state: state, redirectURI: redirectURI, delegate: self)
        server?.addEventsRoute()
        server?.start(port, forceIPV4: forceIPV4)
    }
    
    public func userAuthed(_ response: OAuthResponse) {
        // use team ids to add to clients array to prevent duplicate clients...
        // User auth
        if let token = response.accessToken {
            let client = RTMClient(apiToken: token)
            clients[token] = client
        }
        // Bot User
        if let token = response.bot?.botToken {
            let client = RTMClient(apiToken: token)
            clients[token] = client
            //connect, rtm or events
        }
    }
}
