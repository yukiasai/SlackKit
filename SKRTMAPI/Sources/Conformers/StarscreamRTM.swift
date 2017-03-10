//
//  StarscreamClient.swift
//  SlackKit
//
//  Created by Peter Zignego on 2/19/17.
//  Copyright © 2017 Launch Software LLC. All rights reserved.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import SKCore
import Starscream

public class StarscreamRTM: RTMWebSocket, WebSocketDelegate {

    public var delegate: RTMDelegate?
    private var webSocket: WebSocket?
    
    public required init() {}
    
    //MARK: - RTM
    public func connect(url: URL) {
        self.webSocket = WebSocket(url: url)
        self.webSocket?.delegate = self
        self.webSocket?.connect()
    }
    
    public func disconnect() {
        webSocket?.disconnect()
    }
    
    public func sendMessage(_ message: String) throws {
        guard webSocket != nil else {
            throw SlackError.rtmConnectionError
        }
        webSocket?.write(string: message)
    }
    
    public func ping() {
        webSocket?.write(ping: Data())
    }
    
    // MARK: - WebSocketDelegate
    public func websocketDidConnect(socket: WebSocket) {
        delegate?.didConnect()
    }
    
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        webSocket = nil
        delegate?.disconnected()
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        delegate?.receivedMessage(text)
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data) {}
}
#endif
