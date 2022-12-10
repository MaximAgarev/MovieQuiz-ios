import Foundation

enum ImdbError: Error {
    case errorMessage(String)
}

extension ImdbError: LocalizedError {
    public var errorDescription: String? {
            switch self {
            case .errorMessage(let text):
                return NSLocalizedString(text, comment: "IMDB returns error")
            }
        }
}

class QuestionFactory: QuestionFactoryProtocol {
    
    //    private let questions: [QuizQuestion] = [
    //            QuizQuestion(
    //                image: "The Godfather",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "The Dark Knight",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "Kill Bill",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "The Avengers",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "Deadpool",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "The Green Knight",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "Old",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: false),
    //            QuizQuestion(
    //                image: "The Ice Age Adventures of Buck Wild",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: false),
    //            QuizQuestion(
    //                image: "Tesla",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: false),
    //            QuizQuestion(
    //                image: "Vivarium",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: false)
    //        ]
    
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.errorMessage != "" {
                        let error = ImdbError.errorMessage(mostPopularMovies.errorMessage)
                        self.delegate?.didFailToLoadData(with: error)
                        return
                    }
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
        
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
           do {
               imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                let error = ImdbError.errorMessage("Failed to load image")
                self.delegate?.didFailToLoadData(with: error)
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
        
        init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
            self.delegate = delegate
            self.moviesLoader = moviesLoader
        }
    }
