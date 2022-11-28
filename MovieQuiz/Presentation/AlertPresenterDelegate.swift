import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func didReceiveAlert(alert: AlertControllerProtocol?)
}
