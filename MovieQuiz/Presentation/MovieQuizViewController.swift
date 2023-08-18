import UIKit

final class MovieQuizViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    //MARK: - UI Components
    private var statisticService: StatisticService?
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!

    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    //MARK: - Loading Indicator
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
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
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    func showResult(quiz result: QuizResultsViewModel) {
        var resultMessage = result.text
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)

            let message = "Ваш результат: \(presenter.correctAnswers)/10"
            let accuracyText = String(format: "Средняя точность: %.2f%%", statisticService.totalAccuracy)
            let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let bestGameText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
            let messageText = "\(message)\n\(gamesCountText)\n\(bestGameText)\n\(accuracyText)"

            resultMessage = messageText
        }
        
        let model = AlertModel(title: result.title, message: resultMessage, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.presenter.restartGame()
        }
        alertPresenter.presentAlert(in: self, with: model)
    }

    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20

        presenter.didAnswer(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.hideAnswerResult()
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    private func hideAnswerResult() {
        imageView.layer.borderWidth = 0
    }
}





