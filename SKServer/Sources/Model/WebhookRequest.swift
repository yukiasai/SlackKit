//
// WebhookRequest.swift
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

internal struct WebhookRequest: Request {
    
    let token: String?
    let teamID: String
    let teamDomain: String
    let channelID: String
    let channelName: String
    let userID: String
    let userName: String
    let command: String
    let text: String
    let responseURL: String
    
    init(request: [URLQueryItem]?) {
        token = request?.first(where: { $0.name == "token" })?.value
        teamID = request?.first(where: { $0.name == "team_id" })?.value ?? ""
        teamDomain = request?.first(where: { $0.name == "team_domain" })?.value ?? ""
        channelID = request?.first(where: { $0.name == "channel_id" })?.value ?? ""
        channelName = request?.first(where: { $0.name == "channel_name" })?.value ?? ""
        userID = request?.first(where: { $0.name == "user_id" })?.value ?? ""
        userName = request?.first(where: { $0.name == "user_name" })?.value ?? ""
        command = request?.first(where: { $0.name == "command" })?.value ?? ""
        text = request?.first(where: { $0.name == "text" })?.value ?? ""
        responseURL = request?.first(where: { $0.name == "response_url" })?.value ?? ""
    }
}
