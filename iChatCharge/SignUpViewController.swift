//
//  SignUpViewController.swift
//  iChatCharge
//
//  Created by Chris Hahn on 3/23/18.
//  Copyright © 2018 Chris Hahn. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let AlertVC = Alerts()
    var myFriends = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        guard let name = nameTextField.text,
            let password = passwordTextField.text,
            let email = emailTextField.text,
            name.count > 0,
            email.count > 0,
            password.count > 0
            else {
                // self.showAlert(message: "Enter a name, an email and a password.")
                return
        }
     
        //create username using email and pasword
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                //error codes given from Firebase
                if error._code == AuthErrorCode.invalidEmail.rawValue {
                    self.AlertVC.showAlert(title: "iChat", message: "Enter a valid email.", actionTitle: "Ok")
                } else if error._code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.AlertVC.showAlert(title: "iChat", message: "Email already in use.", actionTitle: "Ok")
                } else {
                    self.AlertVC.showAlert(title: "iChat", message: "Error: \(error.localizedDescription)", actionTitle: "Ok")
                }
                print(error.localizedDescription)
                return
            }
            //if we get a user and there is no error set new username
            if let user = user {
                self.setUserName(user: user, name: name)
     
                //add user to database (Firebase Authentication is separate)
                let ref = Database.database().reference()
                let usersReference = ref.child("users").child(user.uid)
                let values = ["name": name, "email": email, "friends": "Friend1"]
                usersReference.updateChildValues(values, withCompletionBlock: {
                    (err, reff) in
                    if err != nil {
                        print(err ?? "no error print")
                        return
                    }
                    print("User Saved to DB from signup view controller ...")
                })
            }
        }
     
    }
 
    
    //sets user's name (not username)
    func setUserName(user: User, name: String) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            //login through AuthenticationManager
            AuthenticationManager.sharedInstance.didLogin(user: user)
            self.performSegue(withIdentifier: "signUpSegue", sender: nil)
        }
    }
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
