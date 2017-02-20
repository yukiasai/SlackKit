//
// Server+MessageAction.swift
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

extension Server {
        
    public func addResponderWith(token: String, route: String, responder: MessageActionResponder) {
        tokens[route] = token
        responders[route] = responder
        addRoute(route)
    }
    
    internal func addRoute(_ route: String) {
        http.POST[route] = { request in
            let payload = request.parseUrlencodedForm()
            let actionRequest = MessageActionRequest(response: self.jsonFromRequest(payload[0].1))
            if let reply = self.responders[route]?.responseForRequest(actionRequest), actionRequest.token == self.tokens[request.path] {
                return self.request(actionRequest, reply: reply)
            } else {
                return .badRequest(.text("Bad request."))
            }
        }
    }
}
