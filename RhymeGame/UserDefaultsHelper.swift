import Foundation

struct UserDefaultsHelper {
    private init() {}
    static let manager = UserDefaultsHelper()
    func addWordPair(_ pair: RhymeWordPair) {
        var arr = UserDefaults.standard.array(forKey: "pairs") ?? []
        arr.append(pair)
        UserDefaults.standard.set(arr, forKey: "pairs")
    }
    func getWordPairs() -> [RhymeWordPair] {
        return UserDefaults.standard.array(forKey: "pairs") as? [RhymeWordPair] ?? []
    }
}
