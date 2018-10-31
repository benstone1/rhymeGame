import Foundation

enum JSONError: Error {
    case noData
    case parseError
    case noPhraseInfo
    case noDefinition
}

enum WordnikError: Error {
    case noValidRymes
    case badDefinition
}

enum Endpoint {
    case relatedWords(to: String)
    case randomWord
    case phrases(including: String)
    case definitions(of: String)
    func toString() -> String {
        switch self {
        case .relatedWords(let word):
            return "\(word)/relatedWords"
        case .randomWord:
            return "randomWord"
        case .phrases(let word):
            return "\(word)/phrases"
        case .definitions(let word):
            return "\(word)/definitions"
        }
    }
}

enum Resource: String {
    case word = "word.json/"
    case words = "words.json/"
}

struct Params {
    static let randomWordParams = ["hasDictionaryDef=true",
                                   "maxCorpusCount=-1",
                                   "minDictionaryCount=50",
                                   "maxDictionaryCount=-1",
                                   "minLength=5",
                                   "maxLength=-1"]

    static let rhymeParams = ["useCanonical=false",
                              "relationshipTypes=rhyme",
                              "limitPerRelationshipType=10"]

    static let phraseParams = ["limit=1","wlmi=10","useCanonical=false"]
}

class WordnikAPIClient {
    static let manager = WordnikAPIClient()
    private init() {}

    private let baseUrl = "http://api.wordnik.com/v4/"
    private let randomWordEndpoint = "randomWord"
    private let relatedWordsEndpoint = "relatedWords"
    private let apiKey = Secrets.wordkinsAPIKey

    func getNextRhymePair(completionHandler: @escaping (RhymeWordPair?, Error?) -> Void) {
        getRandomWord { [weak self] (str, error) in
            if let error = error { completionHandler(nil, error); return }
            guard let firstWord = str else { completionHandler(nil, JSONError.noData); return }

            self?.getWordRhyming(with: firstWord, completionHandler: { (str, error) in
                if let error = error { completionHandler(nil, error); return }
                guard let secondWord = str else { completionHandler(nil, JSONError.noData); return }
                self?.getDefinition(for: firstWord, completionHandler: { (firstInfo, error) in
                    guard let firstInfo = firstInfo else { return }
                    self?.getDefinition(for: secondWord, completionHandler: { (secondInfo, error) in
                        guard let secondInfo = secondInfo else { return }
                        let pair = RhymeWordPair(firstRhymeInfo: firstInfo, secondRhymeInfo: secondInfo)
                        completionHandler(pair, nil)
                    })
                })
            })
        }
    }

    private func getRandomWord(completionHandler: @escaping (String?, Error?) -> Void) {
        let randomWordEndpoint = createUrl(baseUrl: baseUrl,
                                           resource: .words,
                                           endpoint: Endpoint.randomWord,
                                           key: apiKey,
                                           params: Params.randomWordParams)
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
        let rhymingWordEndpoint = createUrl(baseUrl: baseUrl,
                                            resource: .word,
                                            endpoint: Endpoint.relatedWords(to: word),
                                            key: apiKey,
                                            params: Params.rhymeParams)

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
                let filteredRhymes = rhymingWords.filter{ $0 == $0.lowercased() && !($0.contains(word) || word.contains($0)) }
                guard !filteredRhymes.isEmpty else { completionHandler(nil, WordnikError.noValidRymes); return }
                let randomRhyme = filteredRhymes[Int(arc4random_uniform(UInt32(filteredRhymes.count)))]
                completionHandler(randomRhyme, nil)
            }
            catch {
                completionHandler(nil, error)
            }
        }
    }

    private func getDefinition(for word: String, completionHandler: @escaping (RhymeWordInfo?, Error?) -> Void) {
        let definitionUrl = createUrl(baseUrl: baseUrl,
                                      resource: .word,
                                      endpoint: .definitions(of: word),
                                      key: Secrets.wordkinsAPIKey)
        NetworkHelper.manager.getData(from: definitionUrl) { (data, error) in
            if let error = error { completionHandler(nil, error); return }
            guard let data = data else { completionHandler(nil, JSONError.noData); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictArr = json as? [[String: Any]],
                    let jsonDict = jsonDictArr.first,
                    let definitionText = jsonDict["text"] as? String else { completionHandler(nil, JSONError.noDefinition); return }

                let rhymeWordInfo = RhymeWordInfo(rhyme: word, definition: definitionText)
                guard rhymeWordInfo.isValid else { completionHandler(nil, WordnikError.badDefinition); return }
                completionHandler(rhymeWordInfo, nil)
            }
            catch {
                completionHandler(nil, JSONError.parseError)
            }
        }
    }

    private func createUrl(baseUrl: String,
                           resource: Resource,
                           endpoint: Endpoint,
                           key: String,
                           params: [String] = []) -> URL {

        let params = (params + ["api_key=\(key)"]).joined(separator: "&")
        let strEndpoint = "\(baseUrl)\(resource.rawValue)\(endpoint.toString())?\(params)"
        return URL(string: strEndpoint)!
    }

    /*
    private func getPhrase(for word: String, completionHandler: @escaping (RhymeWordInfo?,Error?) -> Void) {
        let phraseUrl = createUrl(baseUrl: baseUrl,
                                  resource: .word,
                                  endpoint: .phrases(including: word),
                                  key: Secrets.wordkinsAPIKey)
        NetworkHelper.manager.getData(from: phraseUrl) { (data, error) in
            if let error = error { completionHandler(nil, error); return }
            guard let data = data else { completionHandler(nil, JSONError.noData); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictArr = json as? [[String: Any]],
                    let jsonDict = jsonDictArr.first,
                    let gramOne = jsonDict["gram1"] as? String,
                    let gramTwo = jsonDict["gram2"] as? String else {
                        completionHandler(nil, JSONError.noPhraseInfo)
                        return
                }
                completionHandler(RhymeWordInfo(rhyme: word, definition: "", phrase: "\(gramOne) \(gramTwo)"), nil)
            }
            catch {
                completionHandler(nil, JSONError.parseError)
            }
        }
    }
 */
}
