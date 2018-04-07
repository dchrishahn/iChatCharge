//
//  LoginViewController.swift
//  iChatCharge
//
//  Created by Chris Hahn on 3/23/18.
//  Copyright © 2018 Chris Hahn. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let alertVC = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(_ sender: Any) {
    
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            email.count > 0,
            password.count > 0
        else{
            alertVC.showAlert(title: "iChat", message: "Enter a valid email and password", actionTitle: "Ok")
            return
        }
     
        Auth.auth().signIn(withEmail: email, password: password) {(user, error) in
            if let error = error {
                //error codes found using Firebase
                if error._code == AuthErrorCode.userNotFound.rawValue {
                    self.alertVC.showAlert(title: "iChat", message: "There are no users with the specified account", actionTitle: "Ok")
                } else if error._code == AuthErrorCode.wrongPassword.rawValue {
                    self.alertVC.showAlert(title: "iChat", message: "Incorrect username or password.", actionTitle: "Ok")
                } else {
                    self.alertVC.showAlert(title: "iChat", message: "Error: \(error.localizedDescription)", actionTitle: "Ok")
                }
                print(error.localizedDescription)
                return
            }
     
            if let user = user {
                AuthenticationManager.sharedInstance.didLogin(user: user)
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                print("")
                print(" ... Login Successful from LoginVC ... ")
                print("")
            }
     
        }
    }


}
