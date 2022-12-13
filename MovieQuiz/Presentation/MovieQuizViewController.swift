import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    // MARK: - Lifecycle
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenterProtocol?
    private var resultAlert: UIAlertController?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        
        presenter = MovieQuizPresenter(viewController: self)
        
//        statisticService = StatisticServiceImplementation()
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func enabledButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let error = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: {[weak self] _ in
                guard let self = self else { return }
                self.presenter.reloadData()
            })
        show(quiz: error)
        
    }
        
    
    func show(quiz step: QuizStepViewModel) {
        hideLoadingIndicator()
        imageView.image = step.image
        imageView.layer.borderColor =  .none
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    
    // MARK: - AlertPresenter
        
    func show(quiz result: AlertModel) {
        
        alertPresenter = AlertPresenter(result: result, delegate: self)
        
        alertPresenter?.requestAlert()
        
        guard let resultAlert = resultAlert else { return }
        DispatchQueue.main.async {
                    self.present(resultAlert, animated: true, completion: nil)
                }
    }
    
    func didReceiveAlert(alert: AlertControllerProtocol?) {
        guard let alert = alert else { return }
        resultAlert = alert as? UIAlertController
    }
    
    
    // MARK: - ButtonActions
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    
}
