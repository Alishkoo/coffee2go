//
//  WebsocketModels.swift
//  FourElements
//
//  Created by Alibek Baisholanov on 08.04.2025.
//

import Foundation

// MARK: - Общий тип сообщения
enum WebSocketMessage: Codable {
    case input(InputMessage)
    case sync(SyncMessage)
    case spawn(SpawnMessage)
    case disconnect(DisconnectMessage)
    case existingPlayers(ExistingPlayersMessage)
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    private enum MessageType: String, Codable {
        case input
        case sync
        case spawn
        case disconnect
        case existing_players
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)
        
        switch type {
        case .input:
            self = .input(try InputMessage(from: decoder))
        case .sync:
            self = .sync(try SyncMessage(from: decoder))
        case .spawn:
            self = .spawn(try SpawnMessage(from: decoder))
        case .disconnect:
            self = .disconnect(try DisconnectMessage(from: decoder))
        case .existing_players:
            self = .existingPlayers(try ExistingPlayersMessage(from: decoder))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .input(let message):
            try message.encode(to: encoder)
        case .sync(let message):
            try message.encode(to: encoder)
        case .spawn(let message):
            try message.encode(to: encoder)
        case .disconnect(let message):
            try message.encode(to: encoder)
        case .existingPlayers(let message):
            try message.encode(to: encoder)
        }
        
    }
}

// MARK: - InputMessage
struct InputMessage: Codable {
    let type: String = "input"
    let playerID: String
    let action: String
    let pressed: Bool
    let timestamp: Int64 
}

// MARK: - ExistingPlayersMessage
struct ExistingPlayersMessage: Codable {
    let type: String = "existing_players"
    let players: [SpawnMessage] // Список игроков, представленных как `SpawnMessage`
}

// MARK: - SyncMessage
struct SyncMessage: Codable {
    let type: String = "sync"
    let playerID: String
    let position: Position
    let velocity: Velocity
}

// MARK: - SpawnMessage
struct SpawnMessage: Codable {
    let type: String = "spawn"
    let playerID: String
    let character: String
    let position: Position
}

// MARK: - DisconnectMessage
struct DisconnectMessage: Codable {
    let type: String = "disconnect"
    let playerID: String
}

// MARK: - Position
struct Position: Codable {
    let x: Double
    let y: Double
}

// MARK: - Velocity
struct Velocity: Codable {
    let dx: Double
    let dy: Double
}
