//
//  SwifterServer.swift
//  SlackKit
//
//  Created by Peter Zignego on 2/21/17.
//
//

import Foundation
import HTTP
import Swifter

class SwifterServer: SKServer {
    
    let server = HttpServer()
    let port: in_port_t
    let forceIPV4: Bool
    
    init(port: in_port_t = 8080, forceIPV4: Bool = false, responder: SlackKitResponder) {
        self.port = port
        self.forceIPV4 = forceIPV4
        
        for route in responder.routes {
            server[route.path] = { request in
                do {
                    return try route.middleware.respond(to: request.request, chainingTo: responder).httpResponse
                } catch let error {
                    print(error)
                    return .badRequest(.text(error.localizedDescription))
                }
            }
        }
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

extension Response {

    public var httpResponse: HttpResponse {
        switch self.status {
        case .ok where contentType == nil:
            do {
                var req = self
                let text = try String(buffer: try req.body.becomeBuffer(deadline: 3.seconds))
                return .ok(.text(text))
            } catch let error {
                print(error)
                return .badRequest(.text(error.localizedDescription))
            }
        case .ok where contentType == MediaType(type: "application", subtype: "json"):
            do {
                var req = self
                let data = Data(try req.body.becomeBuffer(deadline: 3.seconds).bytes)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return .ok(.json(json as AnyObject))
            } catch let error {
                print(error)
                return .badRequest(.text(error.localizedDescription))
            }
        case .badRequest:
            return .badRequest(.text("Bad request."))
        default:
            return .ok(.text("ok"))
        }
    }
}

extension HttpRequest: RequestRepresentable {

    public var request: Request {
        let method = Request.Method(self.method)
        let url = URL(string:self.path)
        var headers = [CaseInsensitiveString: String]()
        _ = self.headers.map{headers[CaseInsensitiveString($0.key)] = $0.value}
        let body = Body.buffer(Buffer(self.body))
        return Request(method: method, url: url!, headers: Headers(headers), body: body)
    }
}

extension Request.Method {
    init(_ rawValue: String) {
        let method = rawValue.uppercased()
        switch method {
        case "DELETE":  self = .delete
        case "GET":     self = .get
        case "HEAD":    self = .head
        case "POST":    self = .post
        case "PUT":     self = .put
        case "CONNECT": self = .connect
        case "OPTIONS": self = .options
        case "TRACE":   self = .trace
        case "PATCH":   self = .patch
        default:        self = .other(method: method)
        }
    }
}
