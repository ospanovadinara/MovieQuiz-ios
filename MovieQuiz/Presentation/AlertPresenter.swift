//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dinara on 11.07.2023.
//

import Foundation
import UIKit

class AlertPresenter {
    
    private let viewController: UIViewController

    init(viewController: UIViewController) {
            self.viewController = viewController
        }
    
     func presentAlert(with model: AlertModel) {
        let alertController = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        
        alertController.addAction(action)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
