//
//  UIViewController+Extensions.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 28.03.2021.
//

import Foundation
import UIKit
import SafariServices


extension UIViewController {
    
    // MARK: - GENERAL -
    final func asyncOperation(operation: @escaping () -> Void) {
        DispatchQueue.main.async {
            operation()
        }
    }
    
    // MARK: - Alerts -
    func showAlert(title: String?, message: String?, okTitle: String?, cancelTitle: String?,okAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let _okTitle = okTitle {
            let alertOkAction = UIAlertAction(title: _okTitle, style: .default) { (_) in
                okAction?()
            }
            alert.addAction(alertOkAction)
        }
        if let _cancelTitle = cancelTitle {
            let alertCancelAction = UIAlertAction(title: _cancelTitle, style: .destructive) { (_) in
                cancelAction?()
            }
            alert.addAction(alertCancelAction)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Safari -
    func presentSafariViewController(with url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = .systemGreen
        safariViewController.modalPresentationStyle = .pageSheet
        present(safariViewController, animated: true, completion: nil)
    }
    
}
