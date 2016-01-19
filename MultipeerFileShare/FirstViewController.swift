//
//  FirstViewController.swift
//  MultipeerFileShare
//
//  Created by Mark DiFranco on 2016-01-18.
//  Copyright © 2016 Test. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class FirstViewController: UIViewController, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pandaImageView: UIImageView!
    @IBOutlet weak var sendResourceButton: UIButton!
    @IBOutlet weak var sendDataButton: UIButton!

    private var advertiser: MCNearbyServiceAdvertiser!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = "Advertiser"

        advertiser = MCNearbyServiceAdvertiser(peer: multipeerSession.localPeer, discoveryInfo: nil, serviceType: Session.serviceType)
        advertiser.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        advertiser.startAdvertisingPeer()
        multipeerSession.session.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        advertiser.stopAdvertisingPeer()
        multipeerSession.session.disconnect()
    }

    // MARK: - Private Instance Methods

    private func sendPhotoToPeer() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documents: NSString = paths.first!
        let photoPath = documents.stringByAppendingPathComponent("panda.png")

        guard let data = UIImagePNGRepresentation(pandaImageView.image!) else {
            statusLabel.text = "Failed to get data from panda image."
            return
        }

        data.writeToFile(photoPath, atomically: true)

        let photoURL = NSURL(fileURLWithPath: photoPath)

        if let otherPeer = multipeerSession.session.connectedPeers.filter({ $0 != multipeerSession.localPeer }).first {
            statusLabel.text = "Sending image to \(otherPeer.displayName)"

            multipeerSession.session.sendResourceAtURL(photoURL, withName: "panda.png", toPeer: otherPeer) { error in
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusLabel.text = "Image sent!"
                }
            }
        } else {
            statusLabel.text = "No other peers to send data to."
        }
    }

    private func sendPhotoAsDataToPeer() {
        if let data = UIImagePNGRepresentation(pandaImageView.image!) {
            if let otherPeer = multipeerSession.session.connectedPeers.filter({ $0 != multipeerSession.localPeer }).first {
                do {
                    try multipeerSession.session.sendData(data, toPeers: [otherPeer], withMode: .Reliable)
                } catch { print(error) }
            } else {
                statusLabel.text = "No other peers to send data to."
            }
        } else {
            statusLabel.text = "Failed to get data from panda image."
        }
    }

    // MARK: - MCNearbyServiceAdvertiserDelegate Methods

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
            invitationHandler(true, multipeerSession.session)
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(error)
    }

    // MARK: - MCSessionDelegate Methods

    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        dispatch_async(dispatch_get_main_queue()) {
            self.sendResourceButton.enabled = state == .Connected
            self.sendDataButton.enabled = state == .Connected

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

    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {

    }

    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {

    }

    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }

    // MARK: - IBAction Methods

    @IBAction func sendButtonTapped(sender: AnyObject) {
        sendPhotoToPeer()
    }

    @IBAction func sendDataButtonTapped(sender: AnyObject) {
        sendPhotoAsDataToPeer()
    }
}

