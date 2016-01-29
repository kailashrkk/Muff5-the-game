//
//  MPCHandler.swift
//  Muff5
//
//  Created by Kailash Ramaswamy Krishna Kumar on 1/25/16.
//  Copyright © 2016 Kailash Ramaswamy Krishna Kumar. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MPCHandler: NSObject, MCSessionDelegate {
    
    var peerID: MCPeerID!
    var session:MCSession!
    var browser: MCBrowserViewController!
    var advertiser: MCAdvertiserAssistant? = nil
    
    func setupPeerIDWithDisplayName(displayName:String){
         peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession(){
        session = MCSession(peer: peerID)
        session.delegate = self
    }
    
    func setupAdvertiser(advertise:Bool){
        if advertise{
            advertiser = MCAdvertiserAssistant(serviceType: "mygame", discoveryInfo: nil, session: session)
            advertiser?.start()
        }else{
            advertiser?.stop()
            advertiser = nil
        }
    }
    func setupBrowser(){
    browser = MCBrowserViewController(serviceType: "mygame", session: session)
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        let userinfo = ["peerID":peerID, "state": state.rawValue]
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_DidChangeStateNotification", object: nil, userInfo: userinfo)
        })
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let userinfo = ["data":data, "peerID": peerID]
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_DidReceiveDataNotification", object: nil, userInfo: userinfo)
        })
    }

    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
}
