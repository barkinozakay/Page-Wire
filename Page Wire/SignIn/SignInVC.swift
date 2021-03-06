//
//  SignInVC.swift
//  Page Wire
//
//  Created by Barkın Özakay on 30.10.2021.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInVC: UIViewController {
    
    @IBOutlet private weak var googleSignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func onGoogleSignInButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(with: GoogleManager.shared.googleSignInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            appDel.userID = user?.userID
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Error occurs when authenticate with Firebase: \(error.localizedDescription)")
                    self.showErrorAlert()
                }
                appDel.splashVC?.openMainPage()
            }
        }
    }
}
