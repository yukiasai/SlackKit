//
//  ZewoServer.swift
//  SlackKit
//
//  Created by Peter Zignego on 2/21/17.
//
//

import Foundation
import HTTPServer

class ZewoServer: SlackKitServer {

    let server: Server
    
    init(host: String = "0.0.0.0", port: Int = 8080, responder: Responder) throws {
        do {
            server = try Server(host: host, port: port, responder: responder)
        } catch let error {
            throw error
        }
    }
    
    public func start() {
        do {
            try server.start()
        } catch let error {
            print("Server failed to start with error: \(error)")
        }
    }
    
    public func stop() {

    }
}
