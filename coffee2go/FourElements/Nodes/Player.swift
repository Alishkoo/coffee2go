//
//  Player.swift
//  FourElements
//
//  Created by Alibek Baisholanov on 24.03.2025.
//

import SpriteKit

class Player: SKSpriteNode {
    
    // Храним все анимации
    private var idleFrames: [SKTexture] = []
    private var runFrames: [SKTexture] = []
    private var jumpFrame: SKTexture!
    private var doubleJumpFrames: [SKTexture] = []
    private var hurtFrames: [SKTexture] = []
    
    // Имя персонажа
    private var characterName: String
    
    // Имя игрока
    private var playerNameLabel: SKLabelNode!
    
    // Текущее состояние анимации
    private var currentAnimation: String = "idle"
    
    // Текущее состояние анимации
    var isJumping = false
    var canDoubleJump = false
    var isMovingLeft = false
    var isMovingRight = false
    
    init(characterName: String, playerName: String){
        self.characterName = characterName
        
        // Грузим текстуры
        let texture = SKTexture(imageNamed: "\(characterName)_fall")
        super.init(texture: texture, color: .clear, size: CGSize(width: 32, height: 32))
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = 1 // Категория игрока
        self.physicsBody?.collisionBitMask = 1 | 2 | 4 // Столкновения с другими игроками, платформами и другими объектами
        self.physicsBody?.contactTestBitMask = 1 | 2 | 4 // Для отслеживания контактов
        self.physicsBody?.restitution = 0.0 // Без отскоковkfl
        self.physicsBody?.friction = 0.2
        
        // Грузим анимации
        loadAnimations()
        startIdle()
//        self.setScale(2.0)
        
        // Добавляем имя игрока
        setupPlayerNameLabel(playerName: playerName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Фукнции персонажа
    // Функция загрузки анимаций
    private func loadAnimations() {
        idleFrames = loadAnimation(from: "\(characterName)_idle", frameCount: 11, spriteWidth: 32, spriteHeight: 32)
        runFrames = loadAnimation(from: "\(characterName)_run", frameCount: 12, spriteWidth: 32, spriteHeight: 32)
        jumpFrame = SKTexture(imageNamed: "\(characterName)_jump")
        doubleJumpFrames = loadAnimation(from: "\(characterName)_double_jump", frameCount: 6, spriteWidth: 32, spriteHeight: 32)
        hurtFrames = loadAnimation(from: "\(characterName)_hit", frameCount: 7, spriteWidth: 32, spriteHeight: 32)
    }
    
    
    //MARK: - Функция для загрузки анимации из текстуры
    private func loadAnimation(from imageName: String, frameCount: Int, spriteWidth: Int, spriteHeight: Int) -> [SKTexture] {
        let texture = SKTexture(imageNamed: imageName)
        var frames: [SKTexture] = []
        
        let frameWidth = CGFloat(spriteWidth) / texture.size().width
        let frameHeight = CGFloat(spriteHeight) / texture.size().height
        
        for i in 0..<frameCount {
            let rect = CGRect(x: CGFloat(i) * frameWidth,
                              y: 0,
                              width: frameWidth,
                              height: frameHeight)
            frames.append(SKTexture(rect: rect, in: texture))
        }
        
        return frames
    }
    
    
    //MARK: - Анимации
    // Анимация ожидания (Idle)
    func startIdle() {
        isJumping = false
        canDoubleJump = false
        if action(forKey: "idle") == nil {
            removeAllActions() // Убираем старые анимации
            let idleAction = SKAction.animate(with: idleFrames, timePerFrame: 0.1)
            self.run(SKAction.repeatForever(idleAction), withKey: "idle")
        }
    }
    
    
    func moveLeft() {
        self.xScale = -abs(self.xScale)
        self.playerNameLabel.xScale = -abs(playerNameLabel.xScale) // гениальные идеи приходят рандомно бро
//        self.physicsBody?.applyImpulse(CGVector(dx: -0.7, dy: 0))
        self.physicsBody?.velocity = CGVector(dx: -100, dy: self.physicsBody!.velocity.dy)
        startRunning()
    }
    
    
    func moveRight() {
        self.xScale = abs(self.xScale)
        self.playerNameLabel.xScale = abs(playerNameLabel.xScale)
//        self.physicsBody?.applyImpulse(CGVector(dx: 0.7, dy: 0))
        self.physicsBody?.velocity = CGVector(dx: 100, dy: self.physicsBody!.velocity.dy)
        startRunning()
    }
    
    
    func stopMoving() {
        if let physicsBody = self.physicsBody, physicsBody.velocity.dy == 0 {
            self.physicsBody?.velocity.dx *= 0.8 // Плавное замедление вместо резкой остановки
            startIdle()
        }
        
        if action(forKey: "idle") == nil {
            removeAllActions() // Убираем старые анимации
            let idleAction = SKAction.animate(with: idleFrames, timePerFrame: 0.1)
            self.run(SKAction.repeatForever(idleAction), withKey: "idle")
        }
    }
    
    
    //MARK: - Прыжок
    
    // Первый прыжок
    func jump() {
        if !isJumping {
            isJumping = true
            canDoubleJump = true
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 12))
            playJumpAnimation()
        }
    }
    
    // Двойной прыжок
    func performDoubleJump() {
        if isJumping && canDoubleJump {
            canDoubleJump = false
            self.physicsBody?.velocity.dy = 0
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
            playDoubleJumpAnimation()
        }
    }
    
    private func playJumpAnimation() {
        if action(forKey: "jump") == nil {
            let jumpAction = SKAction.animate(with: [jumpFrame], timePerFrame: 0.05)
            self.run(jumpAction, withKey: "jump")
        }
    }

    private func playDoubleJumpAnimation() {
        if action(forKey: "doubleJump") == nil {
            let doubleJumpAction = SKAction.animate(with: doubleJumpFrames, timePerFrame: 0.05)
            self.run(doubleJumpAction, withKey: "doubleJump")
        }
    }
    
    
    
    //MARK: - Получение урона
    func takeDamage() {
        if action(forKey: "takeHit") == nil {
            let hitAction = SKAction.animate(with: hurtFrames, timePerFrame: 0.05)
            self.run(hitAction, withKey: "takeHit")
        }
    }
    
    
    //MARK: - Анимация бега
    private func startRunning() {
        if action(forKey: "running") == nil {
            removeAllActions() // Убираем другие анимации
            let walkAction = SKAction.animate(with: runFrames, timePerFrame: 0.05)
            self.run(SKAction.repeatForever(walkAction), withKey: "running")
        }
    }
    
    // MARK: - Настройка имени игрока
    private func setupPlayerNameLabel(playerName: String) {
        playerNameLabel = SKLabelNode(text: playerName)
        playerNameLabel.fontName = "Minecraft" // Укажите шрифт, если он добавлен
        playerNameLabel.fontSize = 11
        playerNameLabel.fontColor = .white
        playerNameLabel.position = CGPoint(x: 0, y: self.size.height / 2 + 8) // Над персонажем
        playerNameLabel.zPosition = 31
        playerNameLabel.xScale = 1
        playerNameLabel.yScale = 1
        addChild(playerNameLabel)
        
        // Создаём фон для текста
        let background = SKShapeNode(rectOf: CGSize(width: playerNameLabel.frame.width + 5, height: playerNameLabel.frame.height + 2))
        background.fillColor = .black // Цвет фона
        background.alpha = 0.35 // Прозрачность
        background.zPosition = 25 // Под текстом
        background.position = CGPoint(x: 0, y: self.size.height / 2 + 11)
        addChild(background)
    }
    
    // Обновление позиции имени игрока
    func updatePlayerNamePosition() {
        playerNameLabel.position = CGPoint(x: 0, y: self.size.height / 2 + 8)
    }
}
