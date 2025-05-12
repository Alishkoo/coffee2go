//
//  LoginView.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 12.05.2025.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var router: AppRouter
    @State private var isLoading = false
    @State private var showForgotPassword = false
    @State private var forgotPasswordEmail = ""
    
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
            
            VStack {
                ForEach(0..<8) { i in
                    Circle()
                        .fill(coffeeColor.opacity(Double.random(in: 0.1...0.2)))
                        .frame(width: CGFloat.random(in: 10...25))
                        .offset(
                            x: CGFloat.random(in: -180...180),
                            y: CGFloat.random(in: -300...300)
                        )
                }
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 10) {
                        Image("starbucks")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .shadow(color: coffeeColor.opacity(0.3), radius: 10)
                        
                        Text("Coffee2Go")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(coffeeColor)
                        
                        Text("Ваш любимый кофе с доставкой")
                            .font(.subheadline)
                            .foregroundColor(Color(.darkGray))
                    }
                    .padding(.top, 30)
                    
                    VStack(spacing: 20) {
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
                                
                                SecureField("Ваш пароль", text: $authViewModel.password)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
                        }
                        
                        Button(action: {
                            showForgotPassword = true
                        }) {
                            Text("Забыли пароль?")
                                .font(.footnote)
                                .foregroundColor(coffeeColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 5)
                        
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
                        login()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(coffeeColor)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Войти")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 55)
                        .shadow(color: coffeeColor.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 25)
                    .disabled(isLoading)
                    
                    Button {
                        router.navigateTo(.register, backButtonMode: .show)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(coffeeColor, lineWidth: 2)
                            
                            Text("Создать аккаунт")
                                .font(.headline)
                                .foregroundColor(coffeeColor)
                        }
                        .frame(height: 55)
                    }
                    .padding(.horizontal, 25)
                    .disabled(isLoading)
                    
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .alert("Восстановление пароля", isPresented: $showForgotPassword) {
                TextField("Введите ваш email", text: $forgotPasswordEmail)
                Button("Отмена", role: .cancel) {}
                Button("Сбросить") {
                    forgotPasswordEmail = ""
                }
            } message: {
                Text("На указанный email будут отправлены инструкции по сбросу пароля")
            }
        }
        .navigationBarHidden(true)
    }
    
    private func login() {
        guard !authViewModel.email.isEmpty && !authViewModel.password.isEmpty else {
            authViewModel.errorMessage = "Пожалуйста, заполните все поля"
            authViewModel.showError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await authViewModel.signIn()
                                
                await MainActor.run {
                    isLoading = false
                    authViewModel.isSignedIn = true
                    router.navigateTo(.map)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    authViewModel.errorMessage = "Ошибка авторизации: \(error.localizedDescription)"
                    authViewModel.showError = true
                }
            }
        }
    }
}
