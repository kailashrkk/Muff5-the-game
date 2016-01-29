//
//  MultiViewController.swift
//  Muff5
//
//  Created by Kailash Ramaswamy Krishna Kumar on 1/22/16.
//  Copyright © 2016 Kailash Ramaswamy Krishna Kumar. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AVFoundation

class MultiViewController: UIViewController, MCBrowserViewControllerDelegate {

    @IBOutlet weak var tapToWin: UITextField!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var tapCounter: UILabel!
    @IBOutlet weak var goImage: UIImageView!
    
    var currentTaps = 0
    var maxTaps = 0
    
    var sounder: AVAudioPlayer!
    var appdelegate: AppDelegate!
    var multi: Bool = false
    
    var timer: NSTimer!
    var climber: NSTimer!
    var win: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appdelegate.mpchandler.setupPeerIDWithDisplayName(UIDevice.currentDevice().name)
        appdelegate.mpchandler.setupSession()
        appdelegate.mpchandler.setupAdvertiser(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        titleTime()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func gameButtonPressed(sender: AnyObject) {
        currentTaps++
        gameLogic()
        prepareSounds("bass")
        checkresults()
            
            //send users an alert as who won
        if maxTaps == currentTaps && multi {
            
            let name = UIDevice.currentDevice().name as String
            let winning = 1
            let messageDict = ["win":winning]
            let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
            try! self.appdelegate.mpchandler.session.sendData(messageData, toPeers: self.appdelegate.mpchandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            
            checkresults()
        } else {
            
            checkresults()
        }
    }
    @IBAction func connectButtonPressed(sender: AnyObject) {
        
        if appdelegate.mpchandler.session != nil {
            appdelegate.mpchandler.setupBrowser()
            appdelegate.mpchandler.browser.delegate = self
            self.presentViewController(appdelegate.mpchandler.browser, animated: true, completion: nil)
            
        }
        
    }
    @IBAction func startButtonPressed(sender: AnyObject) {
        
        maxTaps = Int(tapToWin.text!)!
        //multiplayer should be connected
        if tapToWin.text?.isEmpty == true || tapToWin.text == "" {
            alerter("Taps to win number is missing", message: "Please enter the maximum taps and then hit Start")
        } else {
            if multi {
                    let name = UIDevice.currentDevice().name as String
                    let messageDict = ["maxtaps": self.maxTaps, "name": name]
                let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
                try! self.appdelegate.mpchandler.session.sendData(messageData, toPeers: self.appdelegate.mpchandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)

//                gametime()
//                gameLogic()
//                checkresults()
            } else {
            gametime()
                gameLogic()
                checkresults()
            }
        }
        
    }
    
    func peerChangedStateNotification(notification: NSNotification){
        let userinfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userinfo.objectForKey("state") as! Int
        
        if state != MCSessionState.Connected.rawValue{
            connectButton.imageView?.image = UIImage(named: "world1.png")
             multi = true
            prepareSounds("connected")
        }
    }
    
    func didReceiveDataNotification(notification:NSNotification){
       
        
//    let message = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
//        let senderpeerid = userinfo["peerID"] as! MCPeerID
        

        let userinfo = NSDictionary(dictionary: notification.userInfo!)
        let data: NSData = userinfo["data"] as! NSData
         let message = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        print("\(message)")
        
        let maxtaps:Int? = message.objectForKey("maxtaps")?.integerValue
        let player: String? = message.objectForKey("name") as? String
        let gameStarted: String? = message.objectForKey("play") as? String
        win = message.objectForKey("win")?.integerValue
        
        print("\(maxtaps)")
        print("\(player)")
        print("\(gameStarted)")
        
        if maxtaps != 0 && gameStarted == nil && win == nil {
            taunt(player!, taps: maxtaps!)
        }
        
        if gameStarted != nil{
            self.goImage.hidden = false
            self.tapToWin.hidden = true
            self.prepareSounds("tadaa")
            climber = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "removeGo", userInfo: nil, repeats: false)
        }
        
        if win != nil {
            alerter("You lose", message: "Hehe")
            prepareSounds("gameover")
            restartGamewithMulti()
        }

    }
    
    func gameLogic(){
        tapCounter.text = "\(currentTaps) taps"
    }
    
    func restartGamewithoutMulti(){
        currentTaps = 0
        maxTaps = 0
        tapToWin.text = ""
        tapCounter.text = ""
        titleTime()
    }
    
    func restartGamewithMulti(){
        currentTaps = 0
        maxTaps = 0
        tapToWin.text = ""
        tapCounter.text = ""
        win = nil
        titleTime()
    }
    
    func gametime(){
        gameButton.hidden = false
        startButton.hidden = true
        tapToWin.hidden = true
        tapCounter.hidden = false
    }

    func titleTime(){
        gameButton.hidden = true
        startButton.hidden = false
        tapToWin.hidden = false
        tapCounter.hidden = true
        goImage.hidden = true
    }
    
    func  checkresults(){
    if multi {
        if maxTaps == currentTaps {
            alerter("\(UIDevice.currentDevice().name) wins", message: "")
            prepareSounds("win")
            restartGamewithMulti()
        }
    } else {
        if maxTaps == currentTaps {
            alerter("\(UIDevice.currentDevice().name) wins", message: "")
            restartGamewithoutMulti()
        }
    }
    }
    
    func taunt(name:String,taps: Int){
        
        let alerta = UIAlertController(title: "A challenge has arrived", message:  "\(name) has challenged you to tap \(taps) times, faster than \(name)! Up for it?", preferredStyle: UIAlertControllerStyle.Alert)
        let okaya = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.tapToWin.hidden = true
           self.goImage.hidden = false
            let yessir = "yessir"
            let messageDict = ["play":yessir]
            let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
            try! self.appdelegate.mpchandler.session.sendData(messageData, toPeers: self.appdelegate.mpchandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            self.maxTaps = taps
            self.prepareSounds("tadaa")
            self.timer = NSTimer.scheduledTimerWithTimeInterval(3.025, target: self, selector: "removeGo", userInfo: nil, repeats: false)
           
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            self.titleTime()
        }
        
        alerta.addAction(okaya)
        alerta.addAction(cancel)
        
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    func multiGame(){
        gameButton.hidden = false
        startButton.hidden = true
        tapToWin.hidden = true
        tapCounter.hidden = false
        
    }

    
    func removeGo(){
        self.goImage.hidden = true
        //addmultiplayergamelogichere
        multiGame()
    }
    
    func alerter(title:String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okay = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okay)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appdelegate.mpchandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        appdelegate.mpchandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func prepareSounds(title:String){
        if title == "win" || title == "connected" || title == "airport" {
            let path = NSBundle.mainBundle().pathForResource(title, ofType: "wav")
            let soundURL = NSURL(fileURLWithPath: path!)
            sounder = try! AVAudioPlayer(contentsOfURL: soundURL)
            sounder.volume = 1.0
            sounder.prepareToPlay()
            sounder.play()
        } else {
            
        let path = NSBundle.mainBundle().pathForResource(title, ofType: "wav")
        let soundURL = NSURL(fileURLWithPath: path!)
        sounder = try! AVAudioPlayer(contentsOfURL: soundURL)
        sounder.volume = 0.5
        sounder.prepareToPlay()
            sounder.play()
    }
    }
   

}
