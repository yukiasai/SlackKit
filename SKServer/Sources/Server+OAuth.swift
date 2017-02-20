//
// Server+OAuth.swift
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
import Swifter

public protocol OAuthDelegate {
    func userAuthed(_ response: OAuthResponse)
}

extension Server {
    
    internal func oauthRoute() {
        http["/oauth"] = { request in
            guard let response = AuthorizeResponse(queryParameters: request.queryParams), response.state == self.state else {
                return .badRequest(.text("Bad request."))
            }
            WebAPI.oauthAccess(clientID: self.clientID, clientSecret: self.clientSecret, code: response.code, redirectURI: self.redirectURI, success: {(response) in
                self.delegate?.userAuthed(OAuthResponse(response: response))
            }, failure: {(error) in
                print("Authorization failed")
            })
            if let redirect = self.redirectURI {
                return .movedPermanently(redirect)
            }
            return .ok(.text("Authentication successful."))
        }
    }
    
    private func oauthURLRequest(_ authorize: AuthorizeRequest) -> URLRequest? {
        var components = URLComponents(string: "\(oauthURL)")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: "\(authorize.clientID)"),
            URLQueryItem(name: "scope", value: "\(authorize.scope)"),
        ]
        guard let url = components?.url else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    public func authorizeRequest(scope: [Scope], redirectURI: String, state: String = "slackkit", team: String? = nil) -> URLRequest? {
        let request = AuthorizeRequest(clientID: clientID, scope: scope, redirectURI: redirectURI, state: state, team: team)
        return oauthURLRequest(request)
    }
}
