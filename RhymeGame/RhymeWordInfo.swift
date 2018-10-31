import Foundation

struct RhymeWordInfo {
    let rhyme: String
    let phrase: String
    let definition: String
    var phraseWithoutRhyme: String {
        return phrase.replacingOccurrences(of: rhyme, with: "")
                     .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    var definitionWithoutRhyme: String {
        let colonIndex = definition.index(before: definition.index(of: ":") ?? definition.endIndex)
        let periodIndex = definition.index(before: definition.index(of: ".") ?? definition.endIndex)
        let endIndex = min(colonIndex, periodIndex)
        return String(definition.replacingOccurrences(of: rhyme, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)[...endIndex])
    }
    var isValid: Bool {
        return definition.components(separatedBy: " ").first?.lowercased() != "see" &&
               definition.components(separatedBy: " ").first?.lowercased() != "simple"
    }
    init(rhyme: String, definition: String, phrase: String = "") {
        self.rhyme = rhyme
        self.definition = definition
        self.phrase = phrase
    }
}
