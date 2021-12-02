//
//  SettingsVC.swift
//  Page Wire
//
//  Created by Barkın Özakay on 2.12.2021.
//

import UIKit
import GoogleSignIn

class SettingsVC: UIViewController {

    @IBOutlet private weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func onSignOutButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signOut()
        appDel.splashVC?.openSignInPage()
    }
}
