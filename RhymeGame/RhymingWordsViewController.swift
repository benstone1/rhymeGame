import UIKit

class RhymingWordsViewController: UIViewController {

    //MARK: Lifecycle overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNextRhymePair()
    }

    //MARK: Private properies
    @IBOutlet private weak var phraseWordOneLabel: UILabel!
    @IBOutlet private weak var rhymeOneTextField: UITextField!
    @IBOutlet private weak var phraseWordTwoLabel: UILabel!
    @IBOutlet private weak var rhymeTwoTextField: UITextField!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var scoreLabel: UILabel!

    private var rhymePair: RhymeWordPair? {
        didSet {
            updateUI()
        }
    }

    //MARK: Private methods
    @IBAction func continueButtonPressed(_ sender: Any) {
        loadNextRhymePair()
    }

    private func updateUI() {
        phraseWordOneLabel.text = rhymePair?.firstRhymeInfo.phraseWithoutRhyme
        phraseWordTwoLabel.text = rhymePair?.secondRhymeInfo.phraseWithoutRhyme
        rhymeOneTextField.text = ""
        rhymeTwoTextField.text = ""
    }

    private func loadNextRhymePair() {
        rhymePair = RhymeWordPair.testWordPair
    }
}

