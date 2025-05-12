//
//  CameraController.swift
//  FourElements
//
//  Created by Alibek Baisholanov on 27.03.2025.
//

import SpriteKit

class CameraController {
    private var cameraNode: SKCameraNode
    private var target: SKNode?
    private var bounds: CGRect?
    private var lerpFactor: CGFloat = 0.1
    
    // Параметры для "мертвой зоны"
    private var deadzoneRect: CGRect
    
    init(cameraNode: SKCameraNode, lerpFactor: CGFloat = 0.1, deadzoneSize: CGSize = CGSize(width: 100, height: 80)) {
        self.cameraNode = cameraNode
        self.lerpFactor = lerpFactor
        
        // Создаем мертвую зону как прямоугольник вокруг центра камеры
        self.deadzoneRect = CGRect(
            x: -deadzoneSize.width/2,
            y: -deadzoneSize.height/2,
            width: deadzoneSize.width,
            height: deadzoneSize.height
        )
    }
    
    func setTarget(_ target: SKNode) {
        self.target = target
    }
    
    func setBounds(_ bounds: CGRect) {
        self.bounds = bounds
    }
    
    // Метод для настройки размера мертвой зоны
    func setDeadzone(width: CGFloat, height: CGFloat) {
        self.deadzoneRect = CGRect(
            x: -width/2,
            y: -height/2,
            width: width,
            height: height
        )
    }
    
    func update() {
        guard let target = target else { return }
        
        // Определяем относительную позицию цели к камере
        let relativePosition = CGPoint(
            x: target.position.x - cameraNode.position.x,
            y: target.position.y - cameraNode.position.y
        )
        
        // Вычисляем новую позицию камеры с учетом мертвой зоны
        var deltaX: CGFloat = 0
        var deltaY: CGFloat = 0
        
        // Если игрок вышел за левую границу мертвой зоны
        if relativePosition.x < deadzoneRect.minX {
            deltaX = relativePosition.x - deadzoneRect.minX
        }
        // Если игрок вышел за правую границу мертвой зоны
        else if relativePosition.x > deadzoneRect.maxX {
            deltaX = relativePosition.x - deadzoneRect.maxX
        }
        
        // Если игрок вышел за нижнюю границу мертвой зоны
        if relativePosition.y < deadzoneRect.minY {
            deltaY = relativePosition.y - deadzoneRect.minY
        }
        // Если игрок вышел за верхнюю границу мертвой зоны
        else if relativePosition.y > deadzoneRect.maxY {
            deltaY = relativePosition.y - deadzoneRect.maxY
        }
        
        // Применяем плавность движения (lerp)
        var newPosition = CGPoint(
            x: cameraNode.position.x + deltaX * lerpFactor,
            y: cameraNode.position.y + deltaY * lerpFactor
        )
        
        // Ограничиваем позицию камеры в пределах bounds
        if let bounds = bounds {
            newPosition.x = max(bounds.minX, min(newPosition.x, bounds.maxX))
            newPosition.y = max(bounds.minY, min(newPosition.y, bounds.maxY))
        }
        
        cameraNode.position = newPosition
    }
    
    // Метод для визуализации мертвой зоны (для отладки)
    func drawDeadzone(scene: SKScene) {
        let deadzoneVisual = SKShapeNode(rect: deadzoneRect)
        deadzoneVisual.strokeColor = .red
        deadzoneVisual.lineWidth = 2
        deadzoneVisual.fillColor = .clear
        deadzoneVisual.zPosition = 100
        deadzoneVisual.alpha = 0.5
        cameraNode.addChild(deadzoneVisual)
    }
}
