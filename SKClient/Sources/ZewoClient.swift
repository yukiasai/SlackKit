//
//  ZewoClient.swift
//  SlackKit
//
//  Created by Peter Zignego on 2/20/17.
//  Copyright © 2017 Launch Software LLC. All rights reserved.
//

import Foundation
import SKCommon
import WebSocketClient

public class ZewoClient: RTM {
    
    public var delegate: RTMDelegate?
    internal var client: WebSocketClient?
    internal var webSocket: WebSocket?
    
    public required init() {}

    //MARK: - RTM
    public func connect(url: URL) {
        do {
            self.client = try WebSocketClient(url: url, didConnect: { (webSocket) in
                self.setupSocket(webSocket)
            })
            try self.client?.connect()
        } catch let error {
            print("WebSocket client could not connect: \(error)")
        }
    }
    
    public func disconnect() {
        try? webSocket?.close()
    }
    
    public func sendMessage(_ message: String) throws {
        guard webSocket != nil else {
            throw SlackError.rtmConnectionError
        }
        do {
            try webSocket?.send(message)
        } catch let error {
            throw error
        }
    }
    
    // MARK: - WebSocket
    private func setupSocket(_ webSocket: WebSocket) {
        webSocket.onText { (message) in
            self.delegate?.receivedMessage(message)
        }
        webSocket.onClose { (code: CloseCode?, reason: String?) in
            self.delegate?.disconnected()
        }
        webSocket.onPing { (data) in try webSocket.pong() }
        webSocket.onPong { (data) in try webSocket.ping() }
        self.webSocket = webSocket
    }
}
