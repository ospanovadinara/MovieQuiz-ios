import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        alertPresenter = AlertPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
        questionFactory?.loadData()
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
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.questionFactory?.loadData()
        }
        alertPresenter?.presentAlert(with: model)
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
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let usersAnswer = true
        showAnswerResult(isCorrect: usersAnswer == currentQuestion.correctAnswer)
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let usersAnswer = false
        showAnswerResult(isCorrect: usersAnswer == currentQuestion.correctAnswer)
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    private func showNextQuestionOrResults() {
        
    
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let accuracyText = String(format: "Средняя точность: %.2f%%", statisticService.totalAccuracy)
            let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let bestGameText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
            let messageText = "\(gamesCountText)\n\(bestGameText)\n\(accuracyText)"
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: "Ваш результат: \(correctAnswers)/10\n\(messageText)",
                buttonText: "Сыграть еще раз",
                completion: {
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            )
            alertPresenter?.presentAlert(with: alertModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.hideAnswerResult()            
            self.showNextQuestionOrResults()
        }
    }
    
    private func hideAnswerResult() {
        imageView.layer.borderWidth = 0
    }
}





