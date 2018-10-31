import UIKit

class RhymingWordsViewController: UIViewController, UITextFieldDelegate {

    //MARK: Lifecycle overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNextRhymePair()
        rhymeOneTextField.delegate = self
        rhymeTwoTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
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

    private var score: Int = 0 {
        didSet {
            updateUI()
        }
    }

    //MARK: Private methods
    @IBAction func continueButtonPressed(_ sender: Any) {
        if userGuessIsCorrect() {
            let alertVC = UIAlertController(title: "Correct!", message: "", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.loadNextRhymePair()
                self.score += 1
            }))
            present(alertVC, animated: true, completion: nil)
        } else {
            let alertVC = UIAlertController(title: "Incorrect", message: "Guess again!", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.score = 0 }))
            present(alertVC, animated: true, completion: nil)
        }
    }

    private func updateUI() {
        phraseWordOneLabel.text = rhymePair?.firstRhymeInfo.definitionWithoutRhyme
        phraseWordTwoLabel.text = rhymePair?.secondRhymeInfo.definitionWithoutRhyme
        scoreLabel.text = "Current Streak: \(score)"
        rhymeOneTextField.text = ""
        rhymeTwoTextField.text = ""
    }

    private func userGuessIsCorrect() -> Bool {
        let rhymeOne = rhymeOneTextField.text
        let rhymeTwo = rhymeTwoTextField.text
        return rhymeOne?.lowercased() == rhymePair?.firstRhymeInfo.rhyme.lowercased() && rhymeTwo?.lowercased() == rhymePair?.secondRhymeInfo.rhyme.lowercased()
    }

    private func loadNextRhymePair() {
        WordnikAPIClient.manager.getNextRhymePair { [weak self] (pair, error) in
            DispatchQueue.main.async {
                self?.rhymePair = pair
                //To do: Persist
                print(pair.debugDescription)
                print(error.debugDescription)
                if let error = error as? WordnikError {
                    switch error {
                    case .noValidRymes, .badDefinition: self?.loadNextRhymePair()
                    }
                }
                if let error = error as? JSONError {
                    //To do: Handle this better
                    print(error)
                    self?.loadNextRhymePair()
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validateAnswer(in: textField)
        textField.resignFirstResponder()
        return true
    }
    func validateAnswer(in textField: UITextField) {

    }
}

extension RhymingWordsViewController {
    struct ViewModel {

    }
}

