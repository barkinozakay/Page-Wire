//
//  SplashVC.swift
//  Page Wire
//
//  Created by Barkın Özakay on 2.12.2021.
//

import UIKit
import Lottie

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showLoadingAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideLoadingAnimaton()
    }
    
    public final func openSignInPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyboard.instantiateViewController(identifier: "SignIn")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController(signInVC, signedIn: false)
    }

    public final func openMainPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBarController") as! UITabBarController
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController(mainTabBarController)
    }
}
