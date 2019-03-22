//
//  GameScene.swift
//  FlapFlap
//
//  Created by Ivan Caldwell on 3/19/19.
//  Copyright © 2019 Ivan Caldwell. All rights reserved.
//
//  https://www.raywenderlich.com/71-spritekit-tutorial-for-beginners
//  https://www.udemy.com/creating-iphone-and-ipad-apps-no-coding-required/learn/v4/content
//  http://spritekitlessons.com/
//  https://learnappmaking.com/random-numbers-swift/
//  http://sweettutos.com/2017/03/09/build-your-own-flappy-bird-game-with-swift-3-and-spritekit/
//  https://www.youtube.com/watch?v=mYCHW9gwmnw -> raywnederlich spritekit animation
//  Figure out to change the background color...
//  https://www.makeschool.com/academy/track/build-ios-games/build-hoppy-bunny-with-spritekit-in-swift/setup-gameplay
//  How to add background music to xcode project
//  https://www.youtube.com/watch?v=HZNa5mT3piY
//  https://stackoverflow.com/questions/30776458/call-can-throw-but-errors-can-not-be-thrown-out-of-a-global-variable-initialize
//  http://sweettutos.com/2017/03/09/build-your-own-flappy-bird-game-with-swift-3-and-spritekit/


import SpriteKit
import GameplayKit
import CoreGraphics

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Variables and Properties
    var ground = SKSpriteNode()
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var grass = SKSpriteNode()
    // I'm building an object to hold two separate SKSpriteNodes
    // The top and bottom walls
    var wallPair = SKNode()
    var restartNode = SKNode()
    var gameScore = 0
    var highGameScore = 0
    var highScore = Int()
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    // Status of the bird
    var died = Bool()
    // Restart button
    var restartButton = SKSpriteNode()
    
    
    // This is a common practice. The name "PysicsCategory" seems weird to me...
    struct PhysicsCategory {
        //static let bird: UInt32 = 0b1
        static let bird: UInt32 = 0x1 << 1
        //static let wall: UInt32 = 0b10
        static let wall: UInt32 = 0x1 << 2
        //static let ground: UInt32 = 0b11
        static let ground: UInt32 = 0x1 << 3
        //static let score: UInt32 = 0b100
        static let score: UInt32 = 0x1 << 4
        // Okay this is some lazy coding maybe...
        // I should find out what needs PhysicsCategory and why?
        //static let background: UInt32 = 0b101
        static let background: UInt32 = 0x1 << 5
    }
    
    // Create setup
    override func didMove(to view: SKView) {
        createScene()
    }
    
    // Scene setup
    func createScene() {
        restartNode.removeFromParent()
        
        
        
        // GameScene is now a SKPhysicContactDelegate it will handle contact events.
        self.physicsWorld.contactDelegate = self
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 0.9)
        scoreLabel.text = "Score: \(gameScore)"
        /*
         // Turns out I couldn't change the font name... sad panda
         for family in UIFont.familyNames.sorted() {
         let names = UIFont.fontNames(forFamilyName: family)
         //print("Family: \(family) Font names: \(names)")
         }
         */
        scoreLabel.fontName = "04b19"
        scoreLabel.fontSize = 70
        scoreLabel.zPosition = 8
        
        var textures: [SKTexture] = []
        for i in 0 ... 7 {
            textures.append(SKTexture(imageNamed: "frame_\(i)_delay-0.1s"))
        }
        let birdAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        // GROUND
        grass = SKSpriteNode(imageNamed: "")
        ground = SKSpriteNode(imageNamed: "BWGround")
        // Setting the scale of the ground image
        ground.setScale(1.0)
        // Setting the ground image to the bottom of the view
        // and centering in the middle of the screen. In skview (0,0) is at the bottom of
        // the screen. I set that by moving the GameScene in Scene Editor.
        ground.position = CGPoint(x: self.frame.width / 2, y: 0 + ground.frame.height * 0.5)
        // Didn't use...
        grass.position = CGPoint(x: self.frame.width / 2, y: 0 + grass.frame.height / 2)
        
        // Creating/Adding the physic attributes
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        // The ground needs to know if it has into contact with the bird. I don't care about
        // the contacts between the ground and wall.
        ground.physicsBody?.collisionBitMask = PhysicsCategory.bird
        // This will test if the wall and the bird have collided.
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        // The ground shouldn't be effected by gravity, else it would just fall out of the view
        ground.physicsBody?.affectedByGravity = false
        // The ground will move if it come into contact with another. It's isDynamic should be
        // set to false to prevent the ground from moving at all
        ground.physicsBody?.isDynamic = false
        // The way to order the object screen. (Set to the front or back view) I'm guessing this
        // step would be necessary if I add the objects to screen in order that I want them to be
        // build. The highest number is in the front and lowest number is in the back.
        ground.zPosition = 3
        grass.zPosition = 6
        // add the ground to the skview
        self.addChild(ground)
        //self.addChild(grass)
        
        
        // BIRD
        // Add the bird image
        bird = SKSpriteNode(imageNamed: "frame_1_delay-0.1s")
        // Scale the bird image
        bird.size = CGSize(width: 150, height: 150)
        // Set the bird position
        bird.position = CGPoint(x: self.frame.width / 2 - bird.frame.width,
                                y: self.frame.height / 2)
        // Set the radius of physic body to half the length of the height
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.frame.height / 2)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        // The bird needs to know if it collided with the wall or the ground
        bird.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.score
        // CHANGE MAYBE: I think the gravity and dynamic is set to true by default
        // This is helpful for testing...
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        bird.zPosition = 2
        self.addChild(bird)
        
        bird.run(SKAction.repeatForever(birdAnimation))
        
        // BACKGROUND
        background = SKSpriteNode(imageNamed: "frame_00_delay-0.04s" )
        background.size = CGSize(width: self.frame.width, height: self.frame.height * 1.5)
        background.position = CGPoint(x: self.frame.width / 2,
                                      y: self.frame.height / 2)
        var moretextures: [SKTexture] = []
        for i in 0 ... 24 {
            moretextures.append(SKTexture(imageNamed: String(format: "frame_%02d_delay-0.04s", i)))
            //print(String(format: "frame_%02d_delay-0.04s", i))
        }
        let backgroundAnimation = SKAction.animate(with: moretextures, timePerFrame: 0.1)
        
        background.zPosition = -1
        self.addChild(background)
        background.run(SKAction.repeatForever(backgroundAnimation))
    }
    
    // This comes from the SKContactDelegatee....
    // I do all the coding for contact here.
    func didBegin(_ contact: SKPhysicsContact) {
        // I have no idea why their are extra restart nodes....
        if !died {
            let firstBody = contact.bodyA
            let secondBody = contact.bodyB
            
            if (firstBody.categoryBitMask == PhysicsCategory.score && secondBody.categoryBitMask == PhysicsCategory.bird) || (firstBody.categoryBitMask == PhysicsCategory.bird && secondBody.categoryBitMask == PhysicsCategory.score)  {
                //print("HEllo")
                gameScore += 1
                scoreLabel.text = "Score: \(gameScore)"
                firstBody.node?.removeFromParent()
            }
            
            
            // DO STUFF BEFORE RESTARTING SCENE ///
            // I DIED HERE
            // RESTARTING RESTARTING RESTARTING.....
            if (firstBody.categoryBitMask == PhysicsCategory.wall && secondBody.categoryBitMask == PhysicsCategory.bird) || (firstBody.categoryBitMask == PhysicsCategory.bird && secondBody.categoryBitMask == PhysicsCategory.wall)  {
                died = true
                print("WALL Contact!!!!")
                self.removeAllActions()
                bird.removeAllActions()
                
                // CREATE USER DEFAULT FOR HIGHSCORE ATTEMPT
                if gameScore > highGameScore {
                    highGameScore = gameScore
//                var highScoreDefault = UserDefaults.standard
//                highScoreDefault.set(highGameScore, forKey: "highGameScore")
//                highScoreDefault.synchronize()
                }
                let restartLabel = SKLabelNode()
                restartLabel.name = "restart"
                restartLabel.position = CGPoint(x: self.frame.width / 2,
                                                y: self.frame.height * 0.5)
                restartLabel.text = "Restart"
                restartLabel.fontName = "04b19"
                restartLabel.fontSize = 90
                restartLabel.zPosition = 8
                //restartNode.addChild(restartLabel)
                self.addChild(restartLabel)
                
                
                
                // Stopping all the pipes on scene from moving
                enumerateChildNodes(withName: "wallPair") { (node, error) in
                    node.speed = 0
                }
                highScoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 0.8)
                highScoreLabel.text = "High Score: \(highGameScore)"
                highScoreLabel.name = "high-score?"
                highScoreLabel.fontName = "04b19"
                highScoreLabel.fontSize = 70
                highScoreLabel.zPosition = 8
                //restartNode.addChild(highScoreLabel)
                self.addChild(highScoreLabel)
                print("ADDED RESTART NODE")
                //self.addChild(restartNode)
                self.removeAllActions()
                createRestartButton()
            }
        }
    }
    
    // Building the Walls in the game
    func buildWalls(){
        // WALL PAIR
        // Building a node to hold the top and bottom wall
        wallPair = SKNode()
        // Give the wallPair SKNode a name
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Top_Pipe")
        let bottomWall = SKSpriteNode(imageNamed: "Bottom_Pipe")
        
        let randomWallSpace = CGFloat.random(in: -200 ... 200)
        
        // Position the walls where they are off scene and move in.
        topWall.position = CGPoint(x: self.frame.width,
                                   y: self.frame.height / 2 + 800)
        
        // Playing around with the vertical space between the top and bottom walls...
        bottomWall.position = CGPoint(x: self.frame.width,
                                      y: self.frame.height / 2 - 800)
       // topWall.zRotation = .pi
        topWall.xScale = 0.6
        topWall.yScale = 1.5
//        bottomWall.setScale(0.85)
        bottomWall.xScale = 0.6
        bottomWall.yScale = 1.5
        
        // CHANGE MAYBE: This is super repettitive maybe I could make a function to reduce
        // the repetitiveness...
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.bird
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.bird
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.affectedByGravity = false
        
        // Adding the two walls to the SKNode()
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.zPosition = 1
        wallPair.position.y = wallPair.position.y + randomWallSpace
        
        // SCORE NODE
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 5, height: 300)
        scoreNode.position = CGPoint(x: self.frame.width, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        // The scoreNode should collide with anything.
        scoreNode.physicsBody?.collisionBitMask = 0
        // The scoreNode should know when the bird has come into contact with. That way
        // the score can be updated in the game
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        //scoreNode.color = SKColor.blue
        
        // Adding score to wallPair
        wallPair.addChild(scoreNode)
        
        // Need to add the action to remove and add walls
        wallPair.run(moveAndRemove)
        // Adding the SKNode() to game scene
        self.addChild(wallPair)
    }
    
    // CREATING RESTART BUTTON
    func createRestartButton() {
        restartButton = SKSpriteNode(color: SKColor.black,
                                     size: CGSize(width: self.frame.width * 0.60,
                                                  height: self.frame.height * 0.15))
        restartButton.position = CGPoint(x: self.frame.width / 2,
                                         y: self.frame.height * 0.525)
        restartButton.zPosition = 7
        self.addChild(restartButton)
    }
    
    // START OF THE GAME
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            self.addChild(scoreLabel)
            gameStarted = true
            bird.physicsBody?.affectedByGravity = true
            let spawn = SKAction.run {
                // Maybe a bad choice of words...
                self.buildWalls()
            }
            
            // Setting a delay time to build walls in game
            // CHANGE MAYBE: Spawn name
            // Time between spawning each pipe
            let delay = SKAction.wait(forDuration: 2.5)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            
            // This line would not work for some reason. If I swap this one out the
            // let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let distance = CGFloat(self.frame.width + 50)
            // Change how far apart the pipes are
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.004 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            bird.physicsBody?.velocity = CGVector(dx:0, dy:0)
            // Impulses are used for one-time changes to a body's velocity
            bird.physicsBody?.applyImpulse(CGVector(dx:0, dy:250))
            
        } else {
            if !died {
                bird.physicsBody?.velocity = CGVector(dx:0, dy:0)
                // Impulses are used for one-time changes to a body's velocity
                bird.physicsBody?.applyImpulse(CGVector(dx:0, dy:250))
            }
        }
        
        // Check if restart button was tapped
        for touch in touches {
            let location =  touch.location(in: self)
            if died {
                if restartButton.contains(location) {
                    restartScene()
                }
            }
        }
    }
    
    // RESTART SCENE
    func restartScene() {
        died = false
        gameStarted = false
        gameScore = 0
        self.removeAllActions()
        print("I REMOVED ALL CHILDREN HERE!")
        self.removeAllChildren()
        createScene()
    }
    
    // Don't know what this is for...
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
