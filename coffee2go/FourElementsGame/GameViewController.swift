//
//  GameViewController.swift
//  FourElements
//
//  Created by Alibek Baisholanov on 24.03.2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    private var nameTextField: UITextField!
    private var startButton: UIButton!
    private var playerName: String?
    private var characterName: String?
    private var characterButtons: [UIButton] = []
    
    override func loadView() {
        self.view = SKView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupUI()
        
        // Добавляем распознавание касания для скрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Перезагружаем UI при каждом изменении ориентации
        updateUIForCurrentOrientation()
    }
    
    private func setupUI() {
        // Поле для ввода имени
        nameTextField = UITextField(frame: CGRect(x: view.frame.width / 2 - 120,
                                                  y: view.frame.height / 2 - 150,
                                                  width: 240,
                                                  height: 40))
        nameTextField.placeholder = "Enter your nickname"
        nameTextField.borderStyle = .roundedRect
        nameTextField.textAlignment = .center
        nameTextField.autocapitalizationType = .none
        nameTextField.font = UIFont(name: "Minecraft", size: 18)
        view.addSubview(nameTextField)
        
        // Кнопки для выбора персонажа
        let characters = ["finn", "frog", "virtualGuy", "mask"]
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        let spacing: CGFloat = 20
        let totalWidth = CGFloat(characters.count) * buttonWidth + CGFloat(characters.count - 1) * spacing
        let startX = (view.frame.width - totalWidth) / 2
        
        for (index, character) in characters.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(character, for: .normal)
            button.titleLabel?.font = UIFont(name: "Minecraft", size: 18)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .darkGray
            button.layer.cornerRadius = 8
            button.frame = CGRect(x: startX + CGFloat(index) * (buttonWidth + spacing),
                                  y: view.frame.height / 2 - 80,
                                  width: buttonWidth,
                                  height: buttonHeight)
            button.addTarget(self, action: #selector(selectCharacter(_:)), for: .touchUpInside)
            button.tag = index // Используем индекс как идентификатор
            view.addSubview(button)
            characterButtons.append(button)
        }
        
        
        // Кнопка для старта игры
        startButton = UIButton(type: .system)
        startButton.setTitle("Start Game", for: .normal)
        startButton.titleLabel?.font = UIFont(name: "Minecraft", size: 22)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.layer.cornerRadius = 8
        startButton.frame = CGRect(x: view.frame.width / 2 - 100,
                                   y: view.frame.height / 2 + 20,
                                   width: 200,
                                   height: 50)
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        startButton.isEnabled = false // Отключаем кнопку, пока не выбран персонаж
        startButton.alpha = 0.5 // Делаем кнопку полупрозрачной
        view.addSubview(startButton)
    }
    
    @objc private func selectCharacter(_ sender: UIButton) {
        let characters = ["finn", "frog", "virtualGuy", "mask"]
        characterName = characters[sender.tag] // Сохраняем выбранного персонажа
        
        // Обновляем UI кнопок
        for button in characterButtons {
            button.backgroundColor = .darkGray
        }
        sender.backgroundColor = .systemGreen // Подсвечиваем выбранную кнопку
        
        // Активируем кнопку старта
        startButton.isEnabled = true
        startButton.alpha = 1.0
    }
    
    @objc private func startGame() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        guard let character = characterName else { return }
        
        self.playerName = name
        // Удаляем элементы интерфейса
        nameTextField.removeFromSuperview()
        startButton.removeFromSuperview()
        characterButtons.forEach { $0.removeFromSuperview() }
        
        // Удаляем распознавание касания для скрытия клавиатуры
        if let gestures = view.gestureRecognizers {
            for gesture in gestures {
                if let tapGesture = gesture as? UITapGestureRecognizer {
                    view.removeGestureRecognizer(tapGesture)
                }
            }
        }
        
        if let skView = self.view as? SKView {
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                scene.scaleMode = .aspectFill
                scene.playerName = playerName
                scene.characterName = character
                skView.presentScene(scene)
            }
            
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }
    
    private func updateUIForCurrentOrientation() {
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        
     
        nameTextField?.frame = CGRect(x: screenWidth / 2 - 120,
                                     y: screenHeight / 2 - 150,
                                     width: 240,
                                     height: 40)
        

        let characters = ["finn", "frog", "virtualGuy", "mask"]
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        let spacing: CGFloat = 20
        let totalWidth = CGFloat(characters.count) * buttonWidth + CGFloat(characters.count - 1) * spacing
        let startX = (screenWidth - totalWidth) / 2
        

        for (index, button) in characterButtons.enumerated() {
            button.frame = CGRect(x: startX + CGFloat(index) * (buttonWidth + spacing),
                                  y: screenHeight / 2 - 80,
                                  width: buttonWidth,
                                  height: buttonHeight)
        }
        

        startButton?.frame = CGRect(x: screenWidth / 2 - 100,
                                   y: screenHeight / 2 + 20,
                                   width: 200,
                                   height: 50)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) // Скрывает клавиатуру
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
