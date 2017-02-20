//
//  Server+Event.swift
//  SlackKit
//
//  Created by Peter Zignego on 2/5/17.
//  Copyright © 2017 Launch Software LLC. All rights reserved.
//

import Foundation

extension Server {
    
    public func addEventsRoute() {
        http["/events"] = { request in
            dump(request)
            return .ok(.text("ok"))
        }
    }
}
