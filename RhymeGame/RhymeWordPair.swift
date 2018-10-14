import Foundation

struct RhymeWordPair {
    static var testWordPair: RhymeWordPair {
        let firstRhymeInfo = RhymeWordInfo(rhyme: "grape",
                                           phrase: "grape juice")
        let secondRhymeInfo = RhymeWordInfo(rhyme: "tape",
                                            phrase: "recorder")
        return RhymeWordPair(firstRhymeInfo: firstRhymeInfo,
                             secondRhymeInfo: secondRhymeInfo)
    }
    let firstRhymeInfo: RhymeWordInfo
    let secondRhymeInfo: RhymeWordInfo
}
