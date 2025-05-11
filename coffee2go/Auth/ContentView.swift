import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isRegistering = false

    var body: some View {
        if viewModel.isLoggedIn {
            Text("Добро пожаловать, \(viewModel.login)!")
                .font(.title)
        } else {
            VStack(spacing: 16) {
                Text(isRegistering ? "Регистрация" : "Вход")
                    .font(.title2)
                    .bold()

                TextField("Логин", text: $viewModel.login)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                SecureField("Пароль", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }
// так как с регистром связано пока что неактивна
//                Button(action: {
//                    isRegistering ? viewModel.register() : viewModel.signIn()
//                }) {
//                    if viewModel.isLoading {
//                        ProgressView()
//                    } else {
//                        Text(isRegistering ? "Зарегистрироваться" : "Войти")
//                            .bold()
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.brown)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                }

//                Button(action: {
//                    isRegistering.toggle()
//                    viewModel.errorMessage = ""
//                }) {
//                    Text(isRegistering ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Зарегистрироваться")
//                        .font(.footnote)
//                        .foregroundColor(.blue)
//                        .padding(.top, 8)
//                }
            }
            .padding()
        }
    }
}
