import Foundation

enum JSONError: Error {
    case noData
    case parseError
}

enum Endpoint {
    case relatedWords(to: String)
    case randomWord
    func toString() -> String {
        switch self {
        case .relatedWords(let word):
            return "\(word)/relatedWords"
        case .randomWord:
            return "randomWord"
        }
    }
}

enum Resource: String {
    case word = "word.json/"
    case words = "words.json/"
}

class WordnikAPIClient {
    static let manager = WordnikAPIClient()
    private init() {}

    private let baseUrl = "http://api.wordnik.com/v4/"
    private let randomWordEndpoint = "randomWord"
    private let relatedWordsEndpoint = "relatedWords"
    private let apiKey = Secrets.wordkinsAPIKey

    private let randomWordParams = ["hasDictionaryDef=true",
                                    "maxCorpusCount=-1",
                                    "minDictionaryCount=100",
                                    "maxDictionaryCount=-1",
                                    "minLength=5&maxLength=-1"]

    private let rhymeParams = ["useCanonical=false",
                               "relationshipTypes=rhyme",
                               "limitPerRelationshipType=10"]

    func getNextRhymePair(completionHandler: @escaping (RhymeWordPair?, Error?) -> Void) {
        getRandomWord { [weak self] (str, error) in
            if let error = error { completionHandler(nil, error); return }
            guard let firstWord = str else { completionHandler(nil, JSONError.noData); return }

            self?.getWordRhyming(with: firstWord, completionHandler: { (str, error) in
                if let error = error { completionHandler(nil, error); return }
                guard let secondWord = str else { completionHandler(nil, JSONError.noData); return }
                let pair = RhymeWordPair(firstRhymeInfo: RhymeWordInfo(rhyme: firstWord, phrase: "n/a"),
                                         secondRhymeInfo: RhymeWordInfo(rhyme: secondWord, phrase: "n/a"))
                completionHandler(pair, nil)
            })
        }
    }

    private func getRandomWord(completionHandler: @escaping (String?, Error?) -> Void) {
        let randomWordEndpoint = createEndpoint(baseUrl: baseUrl,
                                                resource: .words,
                                                endpoint: Endpoint.randomWord,
                                                key: apiKey,
                                                params: randomWordParams)
        NetworkHelper.manager.getData(from: randomWordEndpoint) { (data, error) in
            if let error = error { completionHandler(nil, error); return }
            guard let data = data else { completionHandler(nil, JSONError.noData); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDict = json as? [String: Any],
                    let word = jsonDict["word"] as? String else {
                    completionHandler(nil, JSONError.parseError)
                    return
                }
                completionHandler(word, nil)
            }
            catch {
                completionHandler(nil, error)
            }
        }
    }

    private func getWordRhyming(with word: String, completionHandler: @escaping (String?, Error?) -> Void) {
        let rhymingWordEndpoint = createEndpoint(baseUrl: baseUrl,
                                                 resource: .word,
                                                 endpoint: Endpoint.relatedWords(to: word),
                                                 key: apiKey,
                                                 params: rhymeParams)

        NetworkHelper.manager.getData(from: rhymingWordEndpoint) { (data, error) in
            if let error = error { completionHandler(nil, error); return }
            guard let data = data else { completionHandler(nil, JSONError.noData); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictArr = json as? [[String: Any]],
                    let jsonDict = jsonDictArr.first,
                    let rhymingWords = jsonDict["words"] as? [String] else {
                        completionHandler(nil, JSONError.parseError)
                        return
                }
                let filteredRhymes = rhymingWords.filter{ $0 == $0.lowercased() }
                let randomRhyme = filteredRhymes[Int(arc4random_uniform(UInt32(filteredRhymes.count)))]
                completionHandler(randomRhyme, nil)
            }
            catch {
                completionHandler(nil, error)
            }
        }
    }

    private func createEndpoint(baseUrl: String, resource: Resource, endpoint: Endpoint, key: String, params: [String] = []) -> URL {
        let params = (params + ["api_key=\(key)"]).joined(separator: "&")
        let strEndpoint = "\(baseUrl)\(resource.rawValue)\(endpoint.toString())?\(params)"
        return URL(string: strEndpoint)!
    }
}
