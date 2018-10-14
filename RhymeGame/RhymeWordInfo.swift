import Foundation

struct RhymeWordInfo {
    let rhyme: String
    let phrase: String
    var phraseWithoutRhyme: String {
        return phrase.replacingOccurrences(of: rhyme, with: "")
                     .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
