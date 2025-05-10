//
//  GameScene.swift
//  FourElements
//
//  Created by Alibek Baisholanov on 24.03.2025.
//

import SpriteKit

class GameScene: SKScene {
    
    var player: Player!
    var playerName: String?
    var characterName: String?
    
    // Словарь для хранения других игроков
    var otherPlayers: [String: Player] = [:]
    
    // Websocket and Timer (таймер для синхронизации данных)
    var webSocketManager: WebSocketManager!
    var syncTimer: Timer?
    
    var cameraController: CameraController!
    
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var jumpButton: SKSpriteNode!
    var damageButton: SKSpriteNode!
    
    var isHoldingLeft = false
    var isHoldingRight = false
    
    override func didMove(to view: SKView) {
//        self.physicsWorld.contactDelegate = self
        
        // Создаем физику для TileMap
        for node in self.children {
            if node.name == "TileMap", let tileMap = node as? SKTileMapNode {
                print("✅ Tile Map найден!")
                setupTileMapPhysics(tileMap) // Добавляем физику
                break // Останавливаем цикл, когда нашли `TileMap`
            }
        }
        setupBackground()
        setupButtons()
        
        // Создаем игрока
        player = Player(characterName: characterName ?? "finn", playerName: playerName ?? "Test")
        player.position = CGPoint(x: 0, y: 0)
        player.zPosition = 20
        addChild(player)
        
        
        //MARK: - CameraController
        // Создаем камеру
        let cameraNode = SKCameraNode()
        self.camera = cameraNode
        addChild(cameraNode)
        
        // Настраиваем CameraController
        cameraController = CameraController(
                cameraNode: cameraNode,
                lerpFactor: 0.07,
                deadzoneSize: CGSize(width: 150, height: 100) // Размер мертвой зоны
            )
        cameraController.setTarget(player)
        cameraController.setBounds(CGRect(x: -1000, y: -1000, width: 3000, height: 3000))
//        cameraController.drawDeadzone(scene: self) для отладки мертвой зоны
        
        cameraNode.addChild(leftButton)
        cameraNode.addChild(rightButton)
        cameraNode.addChild(jumpButton)
        cameraNode.addChild(damageButton)

        // Привязываем кнопки к камере
        leftButton.position = CGPoint(x: -300, y: -140) // Слева внизу
        rightButton.position = CGPoint(x: -200, y: -140) // Справа от левой кнопки
        jumpButton.position = CGPoint(x: 250, y: -140) // Справа внизу
        damageButton.position = CGPoint(x: 350, y: -140) // Справа от кнопки прыжка
//        self.view?.showsPhysics = true
        
        
        
        //MARK: - Настраиваем WebSocketManager
        webSocketManager = WebSocketManager(playerID: playerName ?? "player1tester")
        
        webSocketManager.onConnect = {
            print("✅ Connected to WebSocket server")
            self.sendSpawnMessage() // Отправляем сообщение `spawn` при подключении
        }
        
        webSocketManager.onDisconnect = { error in
            if let error = error {
                print("❌ Disconnected with error: \(error.localizedDescription)")
            } else {
                print("❌ Disconnected gracefully")
            }
        }
        
        webSocketManager.onMessageReceived = { message in
            print("📥 Received message: \(message)")
        }
        
        webSocketManager.connect()
        
        webSocketManager.onMessageReceived = { [weak self] message in
            switch message {
            case .input(let inputMessage):
                    self?.handleInputMessage(inputMessage)
            case .spawn(let spawnMessage):
                self?.handleSpawnMessage(spawnMessage)
            case .sync(let syncMessage):
                self?.handleSyncMessage(syncMessage)
            case .disconnect(let disconnectMessage):
                self?.handleDisconnectMessage(disconnectMessage)
            case .existingPlayers(let existingPlayersMessage):
                    self?.handleExistingPlayersMessage(existingPlayersMessage)
            default:
                break
            }
        }
        
        
        // Запускаем таймер для синхронизации
        syncTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.sendSyncMessage()
        }
        
    }
    
    // MARK: - Закрытие GameScene
    override func willMove(from view: SKView) {
        // Останавливаем таймер при выходе из сцены
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    
    //MARK: Для обработки нажатий
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node.name == "left" {
                isHoldingLeft = true
                sendInputMessage(action: "moveLeft", pressed: true)
            } else if node.name == "right" {
                isHoldingRight = true
                sendInputMessage(action: "moveRight", pressed: true)
            } else if node.name == "jump" {
                if !player.isJumping {
                    player.jump()
                    sendInputMessage(action: "jump", pressed: true)
                } else if player.canDoubleJump {
                    player.performDoubleJump()
                    sendInputMessage(action: "doubleJump", pressed: true)
                }
            } else if node.name == "restart" {
                restartGame()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node.name == "left" {
                isHoldingLeft = false
                sendInputMessage(action: "moveLeft", pressed: false)
            } else if node.name == "right" {
                isHoldingRight = false
                sendInputMessage(action: "moveRight", pressed: false)
            }
        }
        player.stopMoving()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // При отмене касаний (что происходит при системном жесте) - сбрасываем все движения
        isHoldingLeft = false
        isHoldingRight = false
        player.stopMoving()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Обновляем движение основного игрока
        if isHoldingLeft {
            player.moveLeft()
        } else if isHoldingRight {
            player.moveRight()
        }
        
        // Если персонаж приземлился, включаем Idle
        if let physicsBody = player.physicsBody, physicsBody.velocity.dy == 0, player.isJumping {
            player.isJumping = false
            player.startIdle()
        }
        
        // Обновляем движение других игроков
        for (_, otherPlayer) in otherPlayers {
            if otherPlayer.isMovingLeft {
                otherPlayer.moveLeft()
            } else if otherPlayer.isMovingRight {
                otherPlayer.moveRight()
            }
            
            // Сбрасываем состояние прыжка для других игроков
            if let physicsBody = otherPlayer.physicsBody, physicsBody.velocity.dy == 0, otherPlayer.isJumping {
                otherPlayer.isJumping = false
                otherPlayer.startIdle()
            }
        }
        
        // Обновляем камеру
        cameraController.update()
        
    }
    
    
    
    //MARK: Кнопки
    func setupButtons() {
        leftButton = createButton(named: "left", position: CGPoint(x: -300, y: -140), textureName: "left")
        rightButton = createButton(named: "right", position: CGPoint(x: -200, y: -140), textureName: "right")
        jumpButton = createButton(named: "jump", position: CGPoint(x: 250, y: -140), textureName: "up")
        damageButton = createButton(named: "restart", position: CGPoint(x: 350, y: -140), textureName: "damage")
    }
    
    func createButton(named: String, position: CGPoint, textureName: String) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: textureName) // Загружаем текстуру
        let button = SKSpriteNode(texture: texture, size: CGSize(width: 60, height: 60)) // Используем текстуру
        button.position = position
        button.name = named
        button.zPosition = 10
        return button
    }
    
    
    //MARK: Рестарт игры
    func restartGame() {
        // Удаляем текущего игрока
        player.removeFromParent()
        
        // Создаем нового игрока
        player = Player(characterName: characterName ?? "frog", playerName: playerName ?? "Aza Rychit")
        player.position = CGPoint(x: 0, y: 0) // Начальная позиция
        player.zPosition = 20
        addChild(player)
        
        // Обновляем цель для камеры
        cameraController.setTarget(player)
    }
    
    
    // MARK: - WebSocket Messages SEND
    func sendSpawnMessage() {
        guard let player = player else { return }
        
        let position = Position(x: Double(player.position.x), y: Double(player.position.y))
        let spawnMessage = SpawnMessage(
            playerID: playerName ?? "player1",
            character: characterName ?? "frog",
            position: position
        )
        
        webSocketManager.sendMessage(spawnMessage)
    }
    
    func sendInputMessage(action: String, pressed: Bool) {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let inputMessage = InputMessage(
            playerID: playerName ?? "player1",
            action: action,
            pressed: pressed,
            timestamp: timestamp
        )
        webSocketManager.sendMessage(inputMessage)
    }
    
    func sendSyncMessage() {
        guard let player = player else { return }
        
        let position = Position(x: Double(player.position.x), y: Double(player.position.y))
        let velocity = Velocity(dx: Double(player.physicsBody?.velocity.dx ?? 0), dy: Double(player.physicsBody?.velocity.dy ?? 0))
        
        let syncMessage = SyncMessage(
            playerID: playerName ?? "player1",
            position: position,
            velocity: velocity
        )
        
        webSocketManager.sendMessage(syncMessage)
    }
    
    // MARK: - WebSocket Messages HANDLE
    
    func handleInputMessage(_ inputMessage: InputMessage) {
        guard let player = otherPlayers[inputMessage.playerID] else {
            print("⚠️ Player with ID \(inputMessage.playerID) not found.")
            return
        }
        
        switch inputMessage.action {
        case "moveLeft":
            if inputMessage.pressed {
                player.isMovingLeft = true
                player.moveLeft()
            } else {
                player.isMovingLeft = false
                player.stopMoving()
            }
        case "moveRight":
            if inputMessage.pressed {
                player.isMovingRight = true
                player.moveRight()
            } else {
                player.isMovingRight = false
                player.stopMoving()
            }
        case "jump":
            if inputMessage.pressed {
                player.jump()
            }
        case "doubleJump":
            if inputMessage.pressed {
                player.performDoubleJump()
            }
        default:
            break
        }
    }
    
    func handleSpawnMessage(_ spawnMessage: SpawnMessage) {
        guard otherPlayers[spawnMessage.playerID] == nil else {
            print("⚠️ Player with ID \(spawnMessage.playerID) already exists.")
            return
        }
        
        let newPlayer = Player(characterName: spawnMessage.character, playerName: spawnMessage.playerID)
        newPlayer.position = CGPoint(x: spawnMessage.position.x, y: spawnMessage.position.y)
        newPlayer.zPosition = 20
        addChild(newPlayer)
        otherPlayers[spawnMessage.playerID] = newPlayer
        print("✅ Player \(spawnMessage.playerID) spawned at position \(spawnMessage.position.x), \(spawnMessage.position.y)")
    }

    func handleSyncMessage(_ syncMessage: SyncMessage) {
        guard let player = otherPlayers[syncMessage.playerID] else {
            print("⚠️ Player with ID \(syncMessage.playerID) not found.")
            return
        }
        
        player.position = CGPoint(x: syncMessage.position.x, y: syncMessage.position.y)
        player.physicsBody?.velocity = CGVector(dx: syncMessage.velocity.dx, dy: syncMessage.velocity.dy)
        print("🔄 Updated player \(syncMessage.playerID) to position \(syncMessage.position.x), \(syncMessage.position.y)")
    }

    func handleDisconnectMessage(_ disconnectMessage: DisconnectMessage) {
        guard let player = otherPlayers[disconnectMessage.playerID] else {
            print("⚠️ Player with ID \(disconnectMessage.playerID) not found.")
            return
        }
        
        player.removeFromParent()
        otherPlayers.removeValue(forKey: disconnectMessage.playerID)
        print("❌ Player \(disconnectMessage.playerID) disconnected.")
    }
    
    func handleExistingPlayersMessage(_ message: ExistingPlayersMessage) {
        for spawnMessage in message.players {
            guard otherPlayers[spawnMessage.playerID] == nil else {
                print("⚠️ Player with ID \(spawnMessage.playerID) already exists.")
                continue
            }
            
            let newPlayer = Player(characterName: spawnMessage.character, playerName: spawnMessage.playerID)
            newPlayer.position = CGPoint(x: spawnMessage.position.x, y: spawnMessage.position.y)
            newPlayer.zPosition = 20
            addChild(newPlayer)
            otherPlayers[spawnMessage.playerID] = newPlayer
            print("✅ Player \(spawnMessage.playerID) added from existing players.")
        }
    }
    
    //MARK: Физика для TileMap
    func setupTileMapPhysics(_ tileMap: SKTileMapNode) {
        let tileSize = tileMap.tileSize
        var physicsBodies: [SKPhysicsBody] = []

        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if tileMap.tileDefinition(atColumn: col, row: row) != nil {
                    let tilePosition = tileMap.centerOfTile(atColumn: col, row: row)
                    let physicsBody = SKPhysicsBody(rectangleOf: tileSize, center: tilePosition)
                    physicsBody.isDynamic = false // Статичные платформы
                    physicsBodies.append(physicsBody)
                }
            }
        }

        let combinedPhysicsBody = SKPhysicsBody(bodies: physicsBodies)
        combinedPhysicsBody.isDynamic = false
        combinedPhysicsBody.categoryBitMask = 2
        combinedPhysicsBody.collisionBitMask = 1
        combinedPhysicsBody.contactTestBitMask = 1
        tileMap.physicsBody = combinedPhysicsBody
    }
    
    //MARK: Фон
    func setupBackground() {
        let texture = SKTexture(imageNamed: "Blue") // 64x64 фон
        let tileSize = texture.size()
        
        // Используем те же границы, что и для камеры, но с запасом
        let cameraBounds = CGRect(x: -1000, y: -1000, width: 3000, height: 3000)
        
        // Добавляем запас по краям для случаев, когда карта выходит за пределы
        let extendedBounds = CGRect(
            x: cameraBounds.minX - 500,
            y: cameraBounds.minY - 500,
            width: cameraBounds.width + 1000,
            height: cameraBounds.height + 1000
        )
        
        let cols = Int(ceil(extendedBounds.width / tileSize.width))
        let rows = Int(ceil(extendedBounds.height / tileSize.height))
        
        for row in 0..<rows {
            for col in 0..<cols {
                let tile = SKSpriteNode(texture: texture)
                tile.position = CGPoint(
                    x: CGFloat(col) * tileSize.width + extendedBounds.minX + tileSize.width / 2,
                    y: CGFloat(row) * tileSize.height + extendedBounds.minY + tileSize.height / 2
                )
                tile.zPosition = -1 // Фон должен быть позади всех объектов
                addChild(tile)
            }
        }
    }
}


extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        
        print("Contact between \(bodyA) and \(bodyB)")
        
        if (bodyA == 1 && bodyB == 2) || (bodyA == 2 && bodyB == 1) {
            print("Player collided with a tile!")
        }
    }
}


