//
//  OAuthDelegate.swift
//  SlackKit
//
//  Created by Peter Zignego on 2/4/17.
//  Copyright © 2017 Launch Software LLC. All rights reserved.
//

public protocol OAuthDelegate {
    func userAuthed(_ response: OAuthResponse)
}
