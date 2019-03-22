//
//  GameViewController.swift
//  FlapFlap
//
//  Created by Ivan Caldwell on 3/19/19.
//  Copyright © 2019 Ivan Caldwell. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation


class GameViewController: UIViewController {

    var backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "BackgroundMusic", ofType: "mp3")!))
    // Call can throw, but errors cannot be thrown out of a property initializer (ENGLISH PLEASE!) I
    // resolve this by putting try in front of call.
    
    @IBOutlet weak var backgroundView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                backgroundAudio.play()
                // This is how I get the music to play in a loop.
                backgroundAudio.numberOfLoops = -1
                // I can set the VOLUME!!!!
                backgroundAudio.volume = 0.1
                // FEATURES TOO ADD == A volume custom control
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
//            view.ignoresSiblingOrder = true
//            view.showsFPS = true
//            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
}
