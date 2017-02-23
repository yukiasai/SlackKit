//
// IncrementalResponseMiddleware.swift
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

import HTTPServer

public struct IncrementalResponseMiddleware: Middleware {
    
    private let token: String
    private var responseURL: ((_ responseURL: String, _ request: Request) -> Void)

    public init(token: String, responseURL: @escaping ((_ responseURL: String, _ request: Request) -> Void)) {
        self.token = token
        self.responseURL = responseURL
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let respondable = Respondable(request: request), respondable.responseToken == token {
            responseURL(respondable.responseURL, request)
        }
        return Response(status: .ok)
    }

    private struct Respondable {
    
        let responseURL: String
        let responseToken: String
        
        init?(request: Request) {
            if let webhook = WebhookRequest(request: request), let url = webhook.responseURL, let token = webhook.token {
                responseURL = url
                responseToken = token
            } else if let action = MessageActionRequest(request: request), let url = action.responseURL, let token = action.token {
                responseURL = url
                responseToken = token
            } else {
                return nil
            }
        }
    }
}

