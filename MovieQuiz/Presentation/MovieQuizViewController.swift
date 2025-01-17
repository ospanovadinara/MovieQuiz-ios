import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResult(quiz result: QuizResultsViewModel)

    func highlightImageBorder(isCorrectAnswer: Bool)

    func showLoadingIndicator()
    func hideLoadingIndicator()

    func showNetworkError(message: String)
    func hideAnswerResult()
}

final class MovieQuizViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //MARK: - UI Components
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
    }

    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func showResult(quiz result: QuizResultsViewModel) {
        let resultMessage = presenter.makeResultsMessage()

        let model = AlertModel(title: result.title,
                               message: resultMessage,
                               buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.presenter.restartGame()
        }
        alertPresenter.presentAlert(in: self, with: model)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
    }

    //MARK: - Loading Indicator
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }

    func hideAnswerResult() {
        imageView.layer.borderWidth = 0
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            self?.presenter.restartGame()
        }
        alertPresenter.presentAlert(in: self, with: model)
    }
}




