//
//  GoogleManager.swift
//  Page Wire
//
//  Created by Barkın Özakay on 2.12.2021.
//

import Foundation
import Firebase
import GoogleSignIn

class GoogleManager {
    
    private init() { }
    
    static var shared = GoogleManager()
    
    let googleSignInConfig = GIDConfiguration.init(clientID: FirebaseApp.app()?.options.clientID ?? "")
    var idToken: String? = ""
    var accessToken: String? = ""
}
