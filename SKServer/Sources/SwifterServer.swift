//
//  SwifterServer.swift
//  SlackKit
//
//  Created by Peter Zignego on 2/21/17.
//
//

import Foundation
import Swifter

class SwifterServer: SKServer {
    
    let server = HttpServer()
    let port: in_port_t
    let forceIPV4: Bool
    
    init(port: in_port_t = 8080, forceIPV4: Bool = false) {
        self.port = port
        self.forceIPV4 = forceIPV4
    }
    
    public func start() {
        do {
            try server.start(port, forceIPv4: forceIPV4)
        } catch let error as NSError {
            print("Server failed to start with error: \(error)")
        }
    }
    
    public func stop() {
        server.stop()
    }
}
