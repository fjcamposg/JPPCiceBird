//
//  GameScene.swift
//  JPPCiceBird
//
//  Created by cice on 10/4/17.
//  Copyright © 2017 empresa. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Variables locales
    var background = SKSpriteNode()
    var bird = SKSpriteNode()
    var pipeFinal1 = SKSpriteNode()
    var pipeFinal2 = SKSpriteNode()
    var limitLAnd = SKNode()
    var timer = Timer()
    
    
    // GRupos de colision
    
    let birdGroup : UInt32 = 1
    let objectsGroup : UInt32 = 2
    let gapGroup : UInt32 = 4
    let movinGroup = SKNode()
    
    
    
    // Labels
    
    var score = 0
    var score_label = SKLabelNode()
    var gameoverLabel = SKLabelNode()
    var gameover = false
    
    
    
    
    
    
    
    //MARK: - movimientos
    override func didMove(to view: SKView) {
        // definimos quien es el delegado para tener en cuenta las colisiones
        self.physicsWorld.contactDelegate = self
        
        // manipulamos la gravedad
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        self.addChild(movinGroup)
        
        
        makeLimitLand()
        makeBackground()
        makeLoopPipe1AnPipe2()
        makeBird()
        makeLabel()
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup{
            score+=1
            score_label.text = "\(score)"
        } else if !gameover{
            gameover = true
            movinGroup.speed = 0
            timer.invalidate()
            makeLabelGameOver()
        }
    }
    
    //MARK: - inicio de toques en la pantalla
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !gameover{
        
        // Hacemos un reset de la velocidad, paramos la velocidad 
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
        } else {
            resetGame()
        }
        
        
    }
    
    
    //MARK: - actualizacion de la vista
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func makeBird(){
        // Creacion de texturas
        let birdTexture1 = SKTexture(imageNamed: "flappy1")
        let birdTexture2 = SKTexture(imageNamed: "flappy2")
        
        // creacion de accion
        let animationBird = SKAction.animate(with: [birdTexture1,birdTexture2], timePerFrame: 0.1)
        
        // accion por siempre
        let makeAnimationForever = SKAction.repeatForever(animationBird)
        
        // asignamos al pajaro la accion
        bird = SKSpriteNode(texture: birdTexture1)
        
        // colocarlo en el espacio
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        // ejecutar la animacion
        bird.run(makeAnimationForever)
        
        // establecer la posicion espacial profundidad
        bird.zPosition = 15
        
        // Grupo de fisicas....
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        //bird.physicsBody = SKPhysicsBody(texture: birdTexture1, alphaThreshold: 0.5, size: CGSize(width: bird.size.width, height: bird.size.height))
        bird.physicsBody?.isDynamic = true // asume la fuerza de la gravedad
        
        
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.collisionBitMask = objectsGroup
        bird.physicsBody?.contactTestBitMask = objectsGroup | gapGroup
        
        
        
        bird.physicsBody?.allowsRotation = false
        
        
        
        
        
        
        // añadirlo a la vista
        self.addChild(bird)
        
        
    }
    
    func makeBackground(){
        // Creamos textura
        let backgroundFinal = SKTexture(imageNamed: "bg")
        // movimiento
        let moveBackground = SKAction.moveBy(x: -backgroundFinal.size().width, y: 0, duration: 6)
        let replaceBackground = SKAction.moveBy(x: backgroundFinal.size().width, y: 0, duration: 0)
        let moveBackgroundForever = SKAction.repeatForever(SKAction.sequence([moveBackground, replaceBackground]))
        for CadaImagen in 0..<3{
            background = SKSpriteNode(texture: backgroundFinal)
            background.position = CGPoint(x: -(backgroundFinal.size().width / 2) + (backgroundFinal.size().width * CGFloat(CadaImagen)), y: self.frame.midY)
            background.zPosition = 1
            background.size.height = self.frame.height
            background.run(moveBackgroundForever)
            // self.addChild(background)
            self.movinGroup.addChild(background)
        }
    }
    
    func makeLimitLand(){
        limitLAnd.position = CGPoint(x: 0, y: -(self.frame.height / 2))
        limitLAnd.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        limitLAnd.physicsBody?.isDynamic = false
        limitLAnd.physicsBody?.categoryBitMask = objectsGroup
        limitLAnd.zPosition = 2
        self.addChild(limitLAnd)
    }
    
    func makePipesFinal(){
        // calculamos el hueco entre tuberia de arriba y abajo
        let gapheight = bird.size.height * 4
        
        // cuando aparece la tuberia esta es la posicion donde va a aparecer, tanto para arriba como para abajo entre 0 y la mitad de la pantalla
        let movementAmount = arc4random_uniform(UInt32(self.frame.height / 2))
        
        
        //creamos un desplazamiento de la tuberia entre 0 y la mitad de la pantalla y resto 1/4 de ésta
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        
        // movemos tuberias
        let movePipes = SKAction.moveBy(x: -self.frame.width - 200, y: 0, duration: TimeInterval(self.frame.width / 200))
        
        
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes,removePipes])
        
        // creamos la textura
        let pipeTextura1 = SKTexture(imageNamed: "pipe1")
        pipeFinal1 = SKSpriteNode(texture: pipeTextura1)
        pipeFinal1.position = CGPoint(x: self.frame.width - self.frame.width / 2, y: self.frame.midY + (pipeFinal1.size.height / 2) + (gapheight / 2) + pipeOffset)
        pipeFinal1.physicsBody = SKPhysicsBody(rectangleOf: pipeFinal1.size)
        pipeFinal1.physicsBody?.isDynamic = false
        
        pipeFinal1.physicsBody?.categoryBitMask = objectsGroup
        
        pipeFinal1.run(moveAndRemovePipes)
        pipeFinal1.zPosition = 5
        //self.addChild(pipeFinal1)
        self.movinGroup.addChild(pipeFinal1)
        
        let pipeTextura2 = SKTexture(imageNamed: "pipe2")
        pipeFinal2 = SKSpriteNode(texture: pipeTextura2)
        pipeFinal2.position = CGPoint(x: self.frame.width - self.frame.width / 2, y: self.frame.midY - (pipeFinal2.size.height / 2) - (gapheight / 2) + pipeOffset)
        pipeFinal2.physicsBody = SKPhysicsBody(rectangleOf: pipeFinal2.size)
        pipeFinal2.physicsBody?.isDynamic = false
        
        pipeFinal2.physicsBody?.categoryBitMask = objectsGroup
        
        pipeFinal2.run(moveAndRemovePipes)
        pipeFinal2.zPosition = 5
        //self.addChild(pipeFinal2)
        self.movinGroup.addChild(pipeFinal2)

        // grupo de colision que atraviesa el hueco
        makeGapNode(pipeOffset, gapHeight: gapheight, moveAndRemovePipes: moveAndRemovePipes)
        
        
        
    }
    
    func makeGapNode(_ pipeOffset : CGFloat, gapHeight : CGFloat, moveAndRemovePipes : SKAction){
        // objeto que suma puntos al colisionar
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.width - self.frame.width / 2, y: self.frame.midY + pipeOffset )
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeFinal1.size.width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        gap.run(moveAndRemovePipes)
        gap.zPosition = 7
        gap.physicsBody?.categoryBitMask = gapGroup
        self.movinGroup.addChild(gap)
        
    }
    
    
    
    func makeLoopPipe1AnPipe2(){
        // Usamos timer, cada cuanto tiempo debe crearse una tuberia
        timer = Timer.scheduledTimer(timeInterval: 3,
                                     target: self,
                                     selector: #selector(makePipesFinal),
                                     userInfo: nil,
                                     repeats: true)
        
        
    }

    func makeLabel(){
        score_label.fontName = "Helvetica"
        score_label.fontSize = 60
        score_label.text = "0"
        score_label.position = CGPoint(x: 0, y: self.frame.size.height / 2 - 90)
        score_label.zPosition = 10
        self.addChild(score_label)
    }
    
    func makeLabelGameOver(){
        gameoverLabel.fontName = "Helvetica"
        gameoverLabel.fontSize = 30
        gameoverLabel.text = "GAME OVER :("
        gameoverLabel.position = CGPoint(x: 0, y: 0)
        gameoverLabel.zPosition = 10
        self.addChild(gameoverLabel)
    }
    
    func resetGame(){
        score = 0
        score_label.text = "0"
        movinGroup.removeAllChildren()
        makeBackground()
        makeLoopPipe1AnPipe2()
        bird.position = CGPoint(x: 0, y: 0)
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        gameoverLabel.removeFromParent()
        movinGroup.speed = 1
        gameover = false
    }
    
    
    
    
}
