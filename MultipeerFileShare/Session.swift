//
//  Session.swift
//  MultipeerFileShare
//
//  Created by Mark DiFranco on 2016-01-18.
//  Copyright © 2016 Test. All rights reserved.
//

import Foundation
import MultipeerConnectivity

let multipeerSession = Session()

class Session {

    static let serviceType = "multifileshare"

    let localPeer = MCPeerID(displayName: UIDevice.currentDevice().name)
    let session: MCSession

    // MARK: - Constructors

    private init() {
        session = MCSession(peer: localPeer)
    }
}
