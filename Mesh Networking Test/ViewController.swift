//
//  ViewController.swift
//  Mesh Networking Test
//
//  Created by Micah Burnside on 3/24/22.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate {

    var number = 0
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser!
    
    @IBOutlet weak var numberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
    }
    
// MARK: - Buttton Actions
    
    @IBAction func hostButtonAction(_ sender: UIButton) {
        startHosting()
    }
    
    @IBAction func guestButtonAction(_ sender: UIButton) {
        joinSession()
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        // send data to the other device
        number = number + 1
        sendData(data: "\(number)")
    }

// MARK: - Functions
    
    // send data to other users
    func sendData(data: String) {
        if mcSession.connectedPeers.count > 0 {
            if let textData = data.data(using: .utf8) {
                do {
                    //send data
                    try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    //error sending data
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // start hosting a new room
    func startHosting() {
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "mp-numbers")
        mcAdvertiserAssistant.delegate = self
        mcAdvertiserAssistant.startAdvertisingPeer()
    }
    
    // join session
    func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "mp-numbers", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    
// MARK: - MultiPeer Connectivity Delegate Functions

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            print("connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("not connected: \(peerID.displayName)")
        default:
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // data received
        if let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                ///display the text in the label
                self.numberLabel.text = text
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }

// MARK: - Browser Methods
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)

    }
    
// MARK: - Advertiser Methods
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //accept the connection or invitation
        invitationHandler(true, mcSession)
        
    }
    
    
}

