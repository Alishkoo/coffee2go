//
//  WebSocketManager.swift
//  FourElements
//
//  Created by Alibek Baisholanov on 08.04.2025.
//

import Foundation

class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession: URLSession
    private let serverURL: URL
    private let playerID: String
    
    // Замыкания для обработки событий
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var onMessageReceived: ((WebSocketMessage) -> Void)?
    
    // Лимит попыток подключения
    private let maxRetryAttempts = 10
    private var currentRetryAttempts = 0
    private var shouldReconnect = true // Флаг для контроля повторных подключений
    
    init(playerID: String) {
        self.playerID = playerID
        let serverAddress = "wss://duo-elements-backend.onrender.com" // Адрес сервера
        self.serverURL = URL(string: "\(serverAddress)/ws?playerID=\(playerID)")!
        self.urlSession = URLSession(configuration: .default)
    }
    
    // Подключение к серверу
    func connect() {
        guard shouldReconnect else {
            print("❌ Reconnection disabled. Aborting connection attempt.")
            return
        }
        
        guard currentRetryAttempts < maxRetryAttempts else {
            print("❌ Maximum retry attempts reached. Connection aborted.")
            shouldReconnect = false // Отключаем повторные попытки
            return
        }
        
        currentRetryAttempts += 1
        print("🔄 Attempting to connect (\(currentRetryAttempts)/\(maxRetryAttempts))...")
        
        webSocketTask = urlSession.webSocketTask(with: serverURL)
        webSocketTask?.resume()
        
        listenForMessages()
        onConnect?()
        print("✅ WebSocket connected to \(serverURL)")
    }
    
    // Отключение от сервера
    func disconnect() {
        shouldReconnect = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        onDisconnect?(nil)
        print("❌ WebSocket disconnected")
    }
    
    // Отправка сообщения
    func sendMessage<T: Codable>(_ message: T) {
        guard let jsonData = try? JSONEncoder().encode(message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Failed to encode message")
            return
        }
        
        let webSocketMessage = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(webSocketMessage) { error in
            if let error = error {
                print("❌ Error sending message: \(error.localizedDescription)")
            } else {
                print("📤 Message sent: \(jsonString)")
            }
        }
    }
    
    // Прослушивание входящих сообщений
    private func listenForMessages() {
        // Если WebSocketTask равен nil или не должен переподключаться, прекращаем прослушивание
        guard let task = webSocketTask, shouldReconnect else {
            return
        }
        
        task.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("❌ Error receiving message: \(error.localizedDescription)")
                self.handleConnectionError(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleIncomingMessage(text)
                case .data(let data):
                    print("📥 Binary data received: \(data)")
                @unknown default:
                    print("❌ Unknown message type received")
                }
                
                // Продолжаем слушать сообщения только если соединение активно
                if self.shouldReconnect {
                    self.listenForMessages()
                }
            }
        }
    }
    
    // Обработка ошибок подключения
    private func handleConnectionError(_ error: Error) {
        print("❌ Connection error: \(error.localizedDescription)")
        
        // Проверяем оба условия: shouldReconnect и maxRetryAttempts
        if shouldReconnect && currentRetryAttempts < maxRetryAttempts {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.connect()
            }
        } else {
            shouldReconnect = false
            print("❌ Maximum retry attempts reached or reconnection disabled. Connection aborted.")
            
            // Отключаем задачу WebSocket, чтобы прекратить попытки
            webSocketTask?.cancel(with: .goingAway, reason: nil)
            
            // Вызываем колбэк для оповещения о разрыве соединения
            onDisconnect?(error)
        }
    }
    
    // Обработка входящих сообщений
    private func handleIncomingMessage(_ text: String) {
        guard let jsonData = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(WebSocketMessage.self, from: jsonData) else {
            print("❌ Failed to decode incoming message")
            return
        }
        
        print("📥 Message received: \(message)")
        onMessageReceived?(message)
    }
}
