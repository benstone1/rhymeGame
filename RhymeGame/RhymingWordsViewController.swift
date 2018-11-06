import UIKit
import RxSwift

class RhymingWordsViewController: UIViewController, UITextFieldDelegate {

    //MARK: Lifecycle overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUItoViewModel()
        viewModel.getNextRhymePair()
        rhymeOneTextField.delegate = self
        rhymeTwoTextField.delegate = self
    }

    //MARK: Private properies
    @IBOutlet private weak var phraseWordOneLabel: UILabel!
    @IBOutlet private weak var rhymeOneTextField: UITextField!
    @IBOutlet private weak var phraseWordTwoLabel: UILabel!
    @IBOutlet private weak var rhymeTwoTextField: UITextField!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var leftStackView: UIStackView!
    @IBOutlet private weak var rightStackView: UIStackView!

    let viewModel = ViewModel()
    let disposeBag = DisposeBag()

    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    //MARK: Private methods
    @IBAction func continueButtonPressed(_ sender: Any) {
        if userGuessIsCorrect() {
            let alertVC = UIAlertController(title: "Correct!", message: "", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.viewModel.getNextRhymePair()
                self.score += 1
            }))
            present(alertVC, animated: true, completion: nil)
        } else {
            let alertVC = UIAlertController(title: "Incorrect", message: "Guess again!", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.score = 0 }))
            present(alertVC, animated: true, completion: nil)
        }
    }

    private func bindUItoViewModel() {
        viewModel.rhymePair.observeOn(MainScheduler.instance)
                            .subscribe(onNext: { [weak self] pair in self?.updateUI(with: pair) })
                            .disposed(by: disposeBag)

        viewModel.guessStatus.observeOn(MainScheduler.instance)
                             .subscribe(onNext: { [weak self] status in self?.updateUI(with: status) } )
                             .disposed(by: disposeBag)
    }

    private func updateUI(with rhymePair: RhymeWordPair?) {
        guard let rhymePair = rhymePair else { spin(); return }
        stopSpin()
        phraseWordOneLabel.text = rhymePair.firstRhymeInfo.definitionWithoutRhyme
        phraseWordTwoLabel.text = rhymePair.secondRhymeInfo.definitionWithoutRhyme
        rhymeOneTextField.text = ""
        rhymeTwoTextField.text = ""
    }

    private func updateUI(with guessStatus: ViewModel.GuessStatus) {
        let leftColor: UIColor
        let rightColor: UIColor
        switch guessStatus {
        case .noneCorrect:
            leftColor = .red
            rightColor = .red
        case .leftCorrect:
            rightColor = .red
            leftColor = .green
        case .rightCorrect:
            rightColor = .green
            leftColor = .red
        case .bothCorrect:
            leftColor = .green
            rightColor = .green
        }
        leftStackView.backgroundColor = leftColor
        rightStackView.backgroundColor = rightColor
    }

    private func spin() {
        print("loading...")
    }

    private func stopSpin() {
        print("done loading")
    }

    private func userGuessIsCorrect() -> Bool {
        let rhymeOne = rhymeOneTextField.text
        let rhymeTwo = rhymeTwoTextField.text
        return true
        //return rhymeOne?.lowercased() == rhymePair?.firstRhymeInfo.rhyme.lowercased() && rhymeTwo?.lowercased() == rhymePair?.secondRhymeInfo.rhyme.lowercased()
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
    class ViewModel {
        enum GuessStatus {
            case noneCorrect
            case leftCorrect
            case rightCorrect
            case bothCorrect
        }

        var rhymePair: Observable<RhymeWordPair?> { return rhymePairSubject.asObservable() }
        var guessStatus: Observable<GuessStatus> { return guessStatusSubject.asObservable() }

        private var currentRhymePair: RhymeWordPair? {
            didSet {
                self.rhymePairSubject.onNext(currentRhymePair)
            }
        }

        func getNextRhymePair() {
            WordnikAPIClient.manager.getNextRhymePair { [weak self] (pair, error) in
                self?.handle(error: error, pair: pair)
            }
        }

        func checkAnswers(leftGuess: String, rightGuess: String) -> GuessStatus {
            guard let pair = currentRhymePair else { return .noneCorrect }

            let leftRhyme = pair.firstRhymeInfo.rhyme
            let righthRhyme = pair.secondRhymeInfo.rhyme

            switch (leftGuess == leftRhyme, rightGuess == righthRhyme) {
            case (false, false): return .noneCorrect
            case (false, true): return .rightCorrect
            case (true, false): return .leftCorrect
            case (true, true): return .bothCorrect
            }
        }

        private func handle(error: Error?, pair: RhymeWordPair?) {
            if let error = error as? WordnikError {
                switch error {
                case .badDefinition, .noValidRymes: self.getNextRhymePair()
                }
            }
            if let error = error as? JSONError {
                switch error {
                case .noDefinition, .noPhraseInfo: self.getNextRhymePair()
                case .noData: self.getNextRhymePair() //Fallback on saved pair?
                case .parseError: fatalError("Developer Error: Unable to parse JSON")
                }
            }
            self.currentRhymePair = pair
        }

        lazy private var rhymePairSubject: BehaviorSubject<RhymeWordPair?> = {
            return BehaviorSubject(value: nil)
        }()

        lazy private var guessStatusSubject: BehaviorSubject<GuessStatus> = {
            return BehaviorSubject(value: .noneCorrect)
        }()
    }
}

