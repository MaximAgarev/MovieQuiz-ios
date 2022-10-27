import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    struct QuizStepViewModel {
      let image: UIImage
      let question: String
      let questionNumber: String
    }

    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
        
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
        
    }
    
    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var bestResult: Int = 0
    private var gamesPlayed: Int = 1
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions[currentQuestionIndex] ))
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            if correctAnswers > bestResult { bestResult = correctAnswers }
            
            let result = QuizResultsViewModel(
            title: "Раунд окончен!",
            text: """
Ваш результат: \(correctAnswers)/\(questions.count)
Количество сыгранных квизов: \(gamesPlayed)
Рекорд: \(bestResult)/\(questions.count) (03.07.22 03:22)
Средняя точность: 60.00%
""",
            buttonText: "Сыграть еще раз")
          show(quiz: result)
          
      } else {
          currentQuestionIndex += 1
          show(quiz: convert(model: questions[currentQuestionIndex] ))
      }
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default, handler: { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.gamesPlayed += 1
            
            self.show(quiz: self.convert(model: self.questions[self.currentQuestionIndex] ))
        })
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        showAnswerResult(isCorrect: (questions[currentQuestionIndex].correctAnswer == true))
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        showAnswerResult(isCorrect: (questions[currentQuestionIndex].correctAnswer == false))
    }
    
    
}
