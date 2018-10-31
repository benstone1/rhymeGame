import Foundation

struct RhymeWordPair {
    static var testWordPair: RhymeWordPair {
        let firstRhymeInfo = RhymeWordInfo(rhyme: "grape",
                                           definition: "Any of numerous woody vines of the genus Vitis, bearing clusters of edible berries and widely cultivated in many species and varieties.")
        let secondRhymeInfo = RhymeWordInfo(rhyme: "tape",
                                            definition: "A narrow strip of strong woven fabric, as that used in sewing or bookbinding.")
        return RhymeWordPair(firstRhymeInfo: firstRhymeInfo,
                             secondRhymeInfo: secondRhymeInfo)
    }
    let firstRhymeInfo: RhymeWordInfo
    let secondRhymeInfo: RhymeWordInfo    
}
