//
//  RegisterView.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 12.05.2025.
//


import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var router: AppRouter
    @State private var confirmPassword: String = ""
    @State private var isLoading = false
    @State private var agreedToTerms = false
    
    private let coffeeColor = Color(UIColor(red: 0.33, green: 0.2, blue: 0.08, alpha: 1.0)) // #542014
    private let creamColor = Color(UIColor(red: 0.96, green: 0.87, blue: 0.70, alpha: 1.0)) // #f5deb3
    private let bgColor = Color(UIColor(red: 0.98, green: 0.95, blue: 0.90, alpha: 1.0))    // #f7f1e6
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [bgColor, creamColor.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ZStack {
                ForEach(0..<6) { i in
                    Image(systemName: "drop.fill")
                        .rotationEffect(.degrees(Double(i * 60)))
                        .font(.system(size: 20))
                        .foregroundColor(coffeeColor.opacity(0.2))
                        .offset(
                            x: CGFloat.random(in: -180...180),
                            y: CGFloat.random(in: 100...400)
                        )
                }
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 8) {
                        Text("Регистрация")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(coffeeColor)
                        
                        Text("Создайте аккаунт для заказа кофе")
                            .font(.subheadline)
                            .foregroundColor(Color(.darkGray))
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Имя")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(coffeeColor)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(coffeeColor)
                                
                                TextField("Ваше имя", text: $authViewModel.userName)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(coffeeColor)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(coffeeColor)
                                
                                TextField("Ваш email", text: $authViewModel.email)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пароль")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(coffeeColor)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(coffeeColor)
                                
                                SecureField("Минимум 6 символов", text: $authViewModel.password)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
                        }
                        

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Подтвердите пароль")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(coffeeColor)
                            
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(coffeeColor)
                                
                                SecureField("Повторите пароль", text: $confirmPassword)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
                        }
                        
                        HStack(spacing: 10) {
                            Button {
                                agreedToTerms.toggle()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(coffeeColor, lineWidth: 2)
                                        .frame(width: 20, height: 20)
                                    
                                    if agreedToTerms {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(coffeeColor)
                                    }
                                }
                            }
                            
                            Text("Я согласен с [условиями использования](https://example.com)")
                                .font(.caption)
                                .foregroundColor(Color(.darkGray))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        
                        if authViewModel.showError {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button {
                        register()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(coffeeColor)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Создать аккаунт")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 55)
                        .shadow(color: coffeeColor.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 25)
                    .disabled(isLoading || !agreedToTerms)
                    .opacity(!agreedToTerms ? 0.6 : 1)
                    
                    Button {
                        router.goBack()
                    } label: {
                        HStack {
                            Text("Уже есть аккаунт?")
                                .foregroundColor(Color(.darkGray))
                            
                            Text("Войти")
                                .fontWeight(.bold)
                                .foregroundColor(coffeeColor)
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Регистрация", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
            .navigationBarItems(leading: Button(action: { router.goBack() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Назад")
                }
                .foregroundColor(coffeeColor)
            })
        }
    }
    
    private func register() {
        guard !authViewModel.userName.isEmpty else {
            authViewModel.errorMessage = "Пожалуйста, введите ваше имя"
            authViewModel.showError = true
            return
        }
        
        guard !authViewModel.email.isEmpty, isValidEmail(authViewModel.email) else {
            authViewModel.errorMessage = "Пожалуйста, введите корректный email"
            authViewModel.showError = true
            return
        }
        
        guard authViewModel.password.count >= 6 else {
            authViewModel.errorMessage = "Пароль должен содержать минимум 6 символов"
            authViewModel.showError = true
            return
        }
        
        guard authViewModel.password == confirmPassword else {
            authViewModel.errorMessage = "Пароли не совпадают"
            authViewModel.showError = true
            return
        }
        
        guard agreedToTerms else {
            authViewModel.errorMessage = "Пожалуйста, примите условия использования"
            authViewModel.showError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await authViewModel.signUp()
                
                await MainActor.run {
                    isLoading = false
                    authViewModel.isSignedIn = true
                    router.navigateTo(.map)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    authViewModel.errorMessage = "Ошибка регистрации: \(error.localizedDescription)"
                    authViewModel.showError = true
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
