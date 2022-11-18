import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - Lifecycle
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var bestResult: Int = 0
    private var gamesPlayed: Int = 1
    private let questionsAmount: Int = 3
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var resultAlert: UIAlertController?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderColor =  .none
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect { correctAnswers += 1 }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }

    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            if correctAnswers > bestResult { bestResult = correctAnswers }
            
            let result = AlertModel(
                title: "Раунд окончен!",
                message: """
Ваш результат: \(correctAnswers)/\(questionsAmount)
Количество сыгранных квизов: \(gamesPlayed)
Рекорд: \(bestResult)/\(questionsAmount) (03.07.22 03:22)
Средняя точность: 60.00%
""",
                buttonText: "Сыграть еще раз",
                completion: {[weak self] _ in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.gamesPlayed += 1
                    self.questionFactory?.requestNextQuestion()
                })

            show(quiz: result)
          
      } else {
          currentQuestionIndex += 1
          questionFactory?.requestNextQuestion()
          
      }
    }
    
    // MARK: - AlertPresenter
    
    
    private func show(quiz result: AlertModel) {
        
        alertPresenter = AlertPresenter(result: result, delegate: self)
        
        alertPresenter?.requestAlert()
        
        guard let resultAlert = resultAlert else { return }
        DispatchQueue.main.async { [weak self] in
                    self?.present(resultAlert, animated: true, completion: nil)
                }
        
    }

    
    func didReceiveAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        resultAlert = alert
    }

    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: (currentQuestion.correctAnswer == true))
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: (currentQuestion.correctAnswer == false))
    }
    
    
}
