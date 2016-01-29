//
//  ViewController.swift
//  Muff5
//
//  Created by Kailash Ramaswamy Krishna Kumar on 1/22/16.
//  Copyright © 2016 Kailash Ramaswamy Krishna Kumar. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var titleLabel: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var singlePlayer: UIButton!
    @IBOutlet weak var multiPlayer: UIButton!
    @IBOutlet weak var tapCounter: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var hand2: UIImageView!
    @IBOutlet weak var hand1: UIImageView!
    @IBOutlet weak var bolter: UIImageView!
    @IBOutlet weak var fire: UIImageView!
    
    var single:Bool = false
    var mutliple:Bool = false
    var upLevel: Bool = false
    
    var maxTaps = 0
    var timerCount:Int = 15
    var timerStarted: Bool = false
    var timer = NSTimer()
    var sounder: AVAudioPlayer = AVAudioPlayer()
    
    let score = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
   
        super.viewDidLoad()
        titleTime()
       let mess: Int = score.integerForKey("hs")

           scoreLabel.text = "High Score: \(mess)"
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func gameButtonPressed(sender: AnyObject) {
        timerStarted = true
        if timerStarted {
               maxTaps++
                tapCounter.text = "\(maxTaps) taps"
            if upLevel{
                prepareSounds("bass")
            } else{
            
              prepareSounds("button")
            }
        }
        
        if maxTaps == 75 && timerCount > 5 {
            levelUP()
        }

    }
    
    
    @IBAction func singlePlayerPressed(sender: AnyObject) {
         prepareSounds("one")
        if single == false {
        single = true
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.singlePlayer.imageView?.image = UIImage(named: "one1.png")
        }
        } else{
            titleTime()
        }
    }
   
    @IBAction func multiPlayerSelected(sender: AnyObject) {
        prepareSounds("double")
        if mutliple == false {
        mutliple = true
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.multiPlayer.imageView?.image = UIImage(named: "multi1.png")
        }
        } else {
            titleTime()
        }
    }

    @IBAction func playButtonPressed(sender: AnyObject) {
    
        
        if single && mutliple == false {
            gametime()
            timerLabel.text = "\(timerCount)"
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "secondEnded", userInfo: nil, repeats: true)
        } else if mutliple && single == false {
            performSegueWithIdentifier("multi", sender: self)
        }else {
            alerter("Player mode not selected", message: "Please select single or multiplayer above, and then tap play")
        }
    }
    func secondEnded(){
        if timerCount != 0 {
        timerCount--
        timerLabel.text = "00:\(timerCount)"
            
        } else {
            let oldscore: Int = score.integerForKey("hs")
            if maxTaps > oldscore {
                alerter("High score!", message: "Your new high score is \(maxTaps)")
                score.removeObjectForKey("hs")
                score.setInteger(maxTaps, forKey: "hs")
                scoreLabel.text = "High Score: \(maxTaps)"
                prepareSounds("highscore")
                timer.invalidate()
                restartGame()
            } else {
             self.alerter("15 seconds have ended", message: "You tapped \(self.maxTaps) times")
                prepareSounds("gameover")
            timer.invalidate()
            
          restartGame()
            }
        }
    }
    
    func gametime() {
        gameButton.hidden = false
        timerLabel.hidden = false
        tapCounter.hidden = false
        scoreLabel.hidden = false
        
        titleLabel.hidden = true
        singlePlayer.hidden = true
        multiPlayer.hidden = true
        playButton.hidden = true
    }
    
    func restartGame(){
        titleTime()
        maxTaps = 0
        timerCount = 15
        single = false
        mutliple = false
        timerStarted = false
        upLevel = false
        bg.alpha = 1.0
        hand1.hidden = true
        hand2.hidden = true
        fire.hidden = true
        bolter.hidden = true
        bg.subviews.forEach { (vaew) -> () in
            vaew.removeFromSuperview()
        }
        timerLabel.font = UIFont(name: "Trebuchet MS", size: 40)
        self.singlePlayer.imageView?.image = UIImage(named: "one0.png")
        
        self.multiPlayer.imageView?.image = UIImage(named: "multi0.png")
    }
    
    func titleTime(){
    
        gameButton.hidden = true
        timerLabel.hidden = true
        tapCounter.hidden = true
        scoreLabel.hidden = true
        hand1.hidden = true
        hand2.hidden = true
        bolter.hidden = true
        fire.hidden = true
        
        titleLabel.hidden = false
        singlePlayer.hidden = false
        multiPlayer.hidden = false
        playButton.hidden = false
        
        mutliple = false
        single = false
    }
    
    func alerter(title:String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okay = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okay)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
    }
    
    func prepareSounds(title:String){
        if title == "win" || title == "connected" || title == "highscore"{
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
            sounder.volume = 0.4
            sounder.prepareToPlay()
            sounder.play()
        }
    }
    
    func levelUP(){
        upLevel = true
        let blur = UIBlurEffect(style: UIBlurEffectStyle.init(rawValue: 2)!)
        let blurview = UIVisualEffectView(effect: blur)
        
        blurview.frame = bg.bounds
        hand1.hidden = false
        hand2.hidden = false
        bolter.hidden = false
        fire.hidden = false
        timerLabel.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1.0)
        timerLabel.font = UIFont(name: "Thintel", size: 100)
        let misser = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("levelup", ofType: "wav")!))
        misser.prepareToPlay()
        misser.play()
        bg.addSubview(blurview)
//bg.alpha = 0.5
    }
}

