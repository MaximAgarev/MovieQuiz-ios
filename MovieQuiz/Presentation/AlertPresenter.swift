import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    var result: AlertModel
    
    weak var delegate: AlertPresenterDelegate?
    
    func requestAlert() {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default,
            handler: result.completion
        )
        
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "GameResult"
        
        delegate?.didReceiveAlert(alert: alert)
    }
    
    init(result: AlertModel, delegate: AlertPresenterDelegate?) {
        self.result = result
        self.delegate = delegate
    }
    
}
