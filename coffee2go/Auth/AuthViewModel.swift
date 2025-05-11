import Foundation
//import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var login: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false

    func signIn() {
        isLoading = true
        errorMessage = ""

        Service.shared.login(login: login, password: password) { success, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.isLoggedIn = true
                } else {
                    self.errorMessage = error ?? "Ошибка входа"
                }
            }
        }
    }
//    подключить когда уже файрбейз настроен будет
//    func register() {
//        isLoading = true
//        errorMessage = ""
//        
//        Service.shared.register(login: login, password: password) { success, error in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                if success {
//                    self.isLoggedIn = true
//                } else {
//                    self.errorMessage = error ?? "Ошибка регистрации"
//                }
//            }
//        }
//    }
//}
