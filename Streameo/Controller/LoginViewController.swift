//
//  LoginViewController.swift
//  Streameo
//
//  Created by Suraj Kumar on 03/07/24.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("Error restoring previous sign-in: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func onLoginBtnClick(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            
            guard let signInResult = signInResult else { return }
            let user = signInResult.user
            
            guard let idToken = user.idToken?.tokenString else { return }
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in error: \(error.localizedDescription)")
                    return
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let homeViewController = storyboard.instantiateViewController(withIdentifier: "homeVC") as? HomeViewController else {
                    print("Failed to instantiate RootViewController")
                    return
                }
                self.navigationController?.pushViewController(homeViewController, animated: false)
            }
        }
    }
}

