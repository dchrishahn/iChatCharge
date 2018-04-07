//
//  AuthenticationManager.swift
//  iChatCharge
//
//  Created by Chris Hahn on 3/23/18.
//  Copyright © 2018 Chris Hahn. All rights reserved.
//

import Foundation
import Firebase


class AuthenticationManager: NSObject {
    static let sharedInstance = AuthenticationManager()
    
    var loggedIn = false
    var userName : String?
    var userID : String?
    var email: String?
    
    func didLogin(user: User){
        AuthenticationManager.sharedInstance.userName = user.displayName
        AuthenticationManager.sharedInstance.userID = user.uid
        AuthenticationManager.sharedInstance.loggedIn = true
        AuthenticationManager.sharedInstance.email = email
    }
    
}
