import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


//MARK: - UI Components 
//    private var correctAnswers: Int = 0
    private var statisticService: StatisticService?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter = AlertPresenter()
    private let presenter = MovieQuizPresenter()

    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
        questionFactory?.loadData()
        presenter.viewController = self
    }
    
    //MARK: - Loading Indicator
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
    
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            self?.presenter.restartGame()
            self?.presenter.restartGame()
            self?.questionFactory?.loadData()
        }
        alertPresenter.presentAlert(in: self, with: model)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }


    func show(quiz step: QuizStepViewModel) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        
//        noButton.isEnabled = false
//        yesButton.isEnabled = false
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()

//        noButton.isEnabled = false
//        yesButton.isEnabled = false
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

            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.presentAlert(in: self, with: model)
    }

//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            let message = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
//
//            let viewModel = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: message,
//                buttonText: "Сыграть еще раз")
//            show(quiz: viewModel)
//        }  else {
//            presenter.switchToNextQuestion()
//            self.questionFactory?.requestNextQuestion()
//        }
//        noButton.isEnabled = true
//        yesButton.isEnabled = true
//    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20

        presenter.didAnswer(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
//            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.hideAnswerResult()            
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    private func hideAnswerResult() {
        imageView.layer.borderWidth = 0
    }
}





