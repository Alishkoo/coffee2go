import Foundation

class Service {
    static let shared = Service()

    func login(login: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://your-api.com/login") else {
            completion(false, "Неверный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["login": login, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, "Нет ответа от сервера")
                    return
                }

                completion(httpResponse.statusCode == 200, httpResponse.statusCode == 401 ? "Неверный логин или пароль" : nil)
            }
        }.resume()
    }
}
