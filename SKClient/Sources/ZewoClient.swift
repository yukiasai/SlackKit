//
//  ZewoClient.swift
//  SlackKit
//
//  Created by Peter Zignego on 2/20/17.
//  Copyright © 2017 Launch Software LLC. All rights reserved.
//

import Foundation

class ZewoClient {
    // MARK: - WebSocket
    private func setupSocket(_ socket: WebSocket) {
        socket.onText {(message) in
            self.websocketDidReceive(message: message)
        }
        socket.onClose{ (code: CloseCode?, reason: String?) in
            self.websocketDidDisconnect(closeCode: code, error: reason)
        }
        socket.onPing { (data) in try socket.pong() }
        socket.onPong { (data) in try socket.ping() }
        self.socket = socket
    }
    
    private func websocketDidReceive(message: String) {
        do {
            guard let message = message.data(using: .utf8) else {
                print("Failed to decode message")
                return
            }
            let json = try JSONSerialization.jsonObject(with: message, options: [])
            if let event = json as? [String: Any] {
                dispatch(event)
            }
        }
        catch let error {
            print("Failed to dispatch message: \(error)")
        }
    }
    
    private func websocketDidDisconnect(closeCode: CloseCode?, error: String?) {
        connected = false
        authenticated = false
        client = nil
        socket = nil
        authenticatedUser = nil
        connectionEventsDelegate?.disconnected(self)
        if reconnect == true {
            connect(pingInterval: pingInterval, timeout: timeout, reconnect: reconnect)
        }
    }
}
