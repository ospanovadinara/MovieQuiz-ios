import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()

    }
    
    //MARK: - QuestionFactoryDelegate
    
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
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
            return questionStep
        }
        
        private func show(quiz step: QuizStepViewModel) {
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
                let text = "Ваш результат: \(correctAnswers)/10"
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть еще раз")
                show(quiz: viewModel)
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
        
        private func show(quiz result: QuizResultsViewModel) {
            let alert = UIAlertController(
                title: result.title,
                message: result.text,
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                questionFactory?.requestNextQuestion()
                
            }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }





