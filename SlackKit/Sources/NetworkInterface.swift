//
// NetworkInterface.swift
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
import HTTPClient
import WebSocketClient

internal struct NetworkInterface {
    
    private let apiUrl = "https://slack.com/api/"
    private let client: HTTPClient.Client?
    
    init() {
        do {
            self.client = try Client(url: URL(string: "https://slack.com")!)
        } catch {
            self.client = nil
        }
    }
    
    internal func request(_ endpoint: Endpoint, token: String, parameters: [String: Any]?, successClosure: ([String: Any])->Void, errorClosure: (SlackError)->Void) {
        var requestString = "\(apiUrl)\(endpoint.rawValue)?token=\(token)"
        if let params = parameters {
            requestString += params.requestStringFromParameters
        }
        
        do {
            let contentNegotiation = ContentNegotiationMiddleware(mediaTypes: [.json, .urlEncodedForm], mode: .client)
            var response = try client?.get(requestString, middleware: [contentNegotiation])
            if let buffer = try response?.body.becomeBuffer(deadline: 3.seconds.fromNow()) {
                let data = Data(bytes: buffer.bytes)
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let result = json as? [String: Any] {
                    if (result["ok"] as? Bool == true) {
                        successClosure(result)
                    } else {
                        if let errorString = result["error"] as? String {
                            throw SlackError(rawValue: errorString) ?? SlackError.unknownError
                        } else {
                            throw SlackError.unknownError
                        }
                    }
                }
            }
        } catch let error {
            if let slackError = error as? SlackError {
                errorClosure(slackError)
            } else {
                errorClosure(SlackError.unknownError)
            }
        }
    }
    
    internal func uploadRequest(token: String, data: Data, parameters: [String: Any]?, successClosure: ([String: Any])->Void, errorClosure: (SlackError)->Void) {
        var requestString = "\(apiUrl)\(Endpoint.filesUpload.rawValue)?token=\(token)"
        if let params = parameters {
            requestString = requestString + params.requestStringFromParameters
        }
    
        let boundaryConstant = randomBoundary()
        let boundaryStart = "--\(boundaryConstant)\r\n"
        let boundaryEnd = "\r\n--\(boundaryConstant)--\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"file\"; filename=\"\(parameters!["filename"])\"\r\n"
        let contentTypeString = "Content-Type: \(parameters!["filetype"])\r\n\r\n"
        
        guard let boundaryStartData = boundaryStart.data(using: .utf8), let dispositionData = contentDispositionString.data(using: .utf8), let contentTypeData = contentTypeString.data(using: .utf8), let boundaryEndData = boundaryEnd.data(using: .utf8) else {
            errorClosure(SlackError.clientNetworkError)
            return
        }
        var requestBodyData = Data()
        requestBodyData.append(contentsOf: boundaryStartData)
        requestBodyData.append(contentsOf: dispositionData)
        requestBodyData.append(contentsOf: contentTypeData)
        requestBodyData.append(contentsOf: data)
        requestBodyData.append(contentsOf: boundaryEndData)
        
        let header: Headers = ["Content-Type":"multipart/form-data; boundary=\(boundaryConstant)"]
        
        do {
            let body = Buffer([UInt8](requestBodyData))
            var response = try client?.post(requestString, headers: header, body: body)
            if let buffer = try response?.body.becomeBuffer(deadline: 3.seconds.fromNow()) {
                let data = Data(bytes: buffer.bytes)
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let result = json as? [String: Any] {
                    if (result["ok"] as? Bool == true) {
                        successClosure(result)
                    } else {
                        if let errorString = result["error"] as? String {
                            throw SlackError(rawValue: errorString) ?? SlackError.unknownError
                        } else {
                            throw SlackError.unknownError
                        }
                    }
                }
            }

        } catch let error {
            if let slackError = error as? SlackError {
                errorClosure(slackError)
            } else {
                errorClosure(SlackError.unknownError)
            }
        }
    }
    
    private func randomBoundary() -> String {
        #if os(Linux)
            return "slackkit.boundary.\(Int(random()))\(Int(random()))"
        #else
            return "slackkit.boundary.\(arc4random())\(arc4random())"
        #endif
    }
}
