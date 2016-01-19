//
//  SecondViewController.swift
//  MultipeerFileShare
//
//  Created by Mark DiFranco on 2016-01-18.
//  Copyright © 2016 Test. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SecondViewController: UIViewController, MCNearbyServiceBrowserDelegate, MCSessionDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pandaImageView: UIImageView!

    var browser: MCNearbyServiceBrowser!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = "Browser"

        browser = MCNearbyServiceBrowser(peer: multipeerSession.localPeer, serviceType: Session.serviceType)
        browser.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        browser.startBrowsingForPeers()
        multipeerSession.session.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        browser.stopBrowsingForPeers()
        multipeerSession.session.disconnect()
    }

    // MARK: - MCNearbyServiceBrowserDelegate Methods

    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?) {
            browser.invitePeer(peerID, toSession: multipeerSession.session, withContext: nil, timeout: 5)
    }

    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer")
    }

    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print(error)
    }

    // MARK: - MCSessionDelegate Methods

    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        dispatch_async(dispatch_get_main_queue()) {
            switch state {
            case .Connected:
                self.statusLabel.text = "Connected to \(peerID.displayName)"
            case .Connecting:
                self.statusLabel.text = "Connecting to \(peerID.displayName)"
            case .NotConnected:
                self.statusLabel.text = "Not Connected to \(peerID.displayName)"
            }
        }
    }

    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {

    }

    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID,
        withProgress progress: NSProgress) {
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.text = "Started to receive \(resourceName)"
            }
    }

    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID,
        atURL localURL: NSURL, withError error: NSError?) {
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documents: NSString = paths.first!
            let photoPath = documents.stringByAppendingPathComponent(resourceName)
            let photoURL = NSURL(fileURLWithPath: photoPath)

            do {
                try NSFileManager.defaultManager().removeItemAtURL(photoURL)
            } catch { print(error) }
            do {
                try NSFileManager.defaultManager().moveItemAtURL(localURL, toURL: photoURL)
            } catch { print(error) }

            let image = UIImage(contentsOfFile: photoURL.absoluteString)

            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.text = "Received \(resourceName)!"
                self.pandaImageView.image = image
            }
    }

    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }

}

