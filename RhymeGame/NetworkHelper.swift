import Foundation

struct NetworkHelper {
    private init() {}
    static let manager = NetworkHelper()
    func getData(from url: URL, with completionHandler: @escaping (Data?, Error?) -> Void) {
        let urlSession = URLSession(configuration: .default)
        urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard let data = data else { return }
            completionHandler(data, nil)
        }.resume()
    }
}
