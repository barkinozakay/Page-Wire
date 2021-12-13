//
//  UIViewController+Extensions.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 28.03.2021.
//

import Foundation
import UIKit
import Lottie
import SafariServices

extension UIViewController {
    
    // MARK: - GENERAL -
    final func asyncOperation(operation: @escaping () -> Void) {
        DispatchQueue.main.async {
            operation()
        }
    }
    
    final func delayOperation(delayTime: Double, _ operation: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            operation()
        }
    }
    
    final func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc final func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Alerts -
    final func showAlert(title: String?, message: String?, okTitle: String?, cancelTitle: String?,okAction: (() -> Void)?, cancelAction: (() -> Void)?) {
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
        alert.view.tintColor = #colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1)
        self.present(alert, animated: true, completion: nil)
    }
    
    final func showErrorAlert() {
        showAlert(title: "", message: "An error occured.", okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
    }
    
    // MARK: - Loading Animation -
    final func showLoadingAnimation() {
        // Animation
        let animationView = AnimationView(name: "searching_books_animation")
        let size = view.frame.width + 100
        animationView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        animationView.center = view.center
        animationView.backgroundColor = .clear
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.tag = 24011994
        animationView.play()
        // Blur
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 24011995
        blurEffectView.alpha = 0.75
        view.isUserInteractionEnabled = false
        view.addSubview(blurEffectView)
        view.addSubview(animationView)
    }

    final func hideLoadingAnimaton() {
        view.isUserInteractionEnabled = true
        let animationView = view.viewWithTag(24011994)
        let blurView = view.viewWithTag(24011995)
        if let animation = animationView {
            DispatchQueue.main.async {
                animation.removeFromSuperview()
            }
        }
        if let blur = blurView {
            DispatchQueue.main.async {
                blur.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Safari -
    final func presentSafariViewController(with url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor(red: 148.0/255.0, green: 23.0/255.0, blue: 81.0/255.0, alpha: 1.0)
        safariViewController.modalPresentationStyle = .pageSheet
        present(safariViewController, animated: true, completion: nil)
    }
    
}
