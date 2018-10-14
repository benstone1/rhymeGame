import Foundation

struct WordnikAPIClient {
    static let manager = WordnikAPIClient()
    private init() {}

    func getNextRhymePair(completionHandler: @escaping (RhymeWordPair?, Error?) -> Void) {

    }
}
