//
//  AppDelegate.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 26.03.2021.
//

import UIKit
import Firebase
import GoogleSignIn
import netfox

let appDel = UIApplication.shared.delegate as! AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    final var userID: String? = ""
    final var splashVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Splash") as? SplashVC
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        startNetworkDebugger()
        FirebaseApp.configure()
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self = self else { return }
            self.userID = user?.userID
            if error != nil || user == nil {
                print("Signed out")
                self.splashVC?.openSignInPage()
            } else {
                print("Signed in")
                GoogleManager.shared.idToken = user?.authentication.idToken
                GoogleManager.shared.accessToken = user?.authentication.accessToken
                self.splashVC?.openMainPage()
            }
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    private func startNetworkDebugger() {
        #if DEBUG
        NFX.sharedInstance().start()
        #endif
    }
}

// MARK: UISceneSession Lifecycle
extension AppDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
