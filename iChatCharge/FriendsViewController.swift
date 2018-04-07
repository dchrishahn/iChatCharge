//
//  FriendsViewController.swift
//  iChatCharge
//
//  Created by Chris Hahn on 3/23/18.
//  Copyright © 2018 Chris Hahn. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private var databaseHandle: DatabaseHandle!
    var ref : DatabaseReference!
    let myUser = Person()
    
    var FriendsArray = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ///get all users
        fetchUsers()
        
        //initialize local myUser with data from Firebase
        initializeMyUser()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? FriendsTableViewCell!
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? FriendsTableViewCell!
        cell?.emailLabel.text = FriendsArray[indexPath.row].email
        cell?.checkBoxButton.tag = indexPath.row
        
        if FriendsArray[indexPath.row].yourFriend == true {
            cell?.checkBoxButton.setImage(#imageLiteral(resourceName: "checkedBox"), for: .normal)
            myUser.myFriends.append(FriendsArray[indexPath.row])
        }else {
            cell?.checkBoxButton.setImage(#imageLiteral(resourceName: "openCheckBox"), for: .normal)
        }
        
        cell?.checkBoxButton.addTarget(self, action: #selector(checkBoxTapped(sender:)), for: .touchUpInside)
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func checkBoxTapped(sender: UIButton) {
        
        //if already friends, unfriend that user
        if myUser.myFriends.contains(FriendsArray[sender.tag]) {
            print(FriendsArray[sender.tag].email ?? "anything...")
            while myUser.myFriends.contains(FriendsArray[sender.tag]) {
                if let itemToRemoveIndex = myUser.myFriends.index(of: FriendsArray[sender.tag]) {
                    FriendsArray[sender.tag].yourFriend = false
                    myUser.myFriends.remove(at: itemToRemoveIndex)
                    removeFriends(userToRemove: FriendsArray[sender.tag])
                    print("")
                    print(" ... removing friend entry from FriendsVC ... ")
                    print("")
                }
            }
            //add a friend
        }else{
            myUser.myFriends.append(FriendsArray[sender.tag])
            FriendsArray[sender.tag].yourFriend = true
            addFriends(userToAdd: FriendsArray[sender.tag])
            print("")
            print(" ... adding friend entry from FriendsVC ... ")
            print("")
        }
        
    }
    
    func initializeMyUser(){
        myUser.name = AuthenticationManager.sharedInstance.userName
        myUser.email = AuthenticationManager.sharedInstance.email
        myUser.userID = AuthenticationManager.sharedInstance.userID
        Database.database().reference().child("users").child(AuthenticationManager.sharedInstance.userID!).child("friends").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = Person()
                user.email = dictionary["FriendEmail"] as? String
                user.name = (dictionary["FriendName"] as? String)
                user.userID = (dictionary["UID"] as? String)
                self.myUser.myFriends.append(user)
            }
        })
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ToChat", sender: FriendsArray)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToChat" {
            let chatVC = segue.destination as! ChatViewController
            let friends = sender as! [Person]
            let me = myUser
            chatVC.FriendsArray = friends
            chatVC.myUser = me
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            AuthenticationManager.sharedInstance.loggedIn = false
            let presentingViewController = self.presentingViewController
            self.dismiss(animated: false, completion: {
                presentingViewController!.dismiss(animated: true, completion: {})
            })
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
    }
    
    
}

//calls to Firebase
extension FriendsViewController {
    
    //get list of all users on the app
    func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = Person()
                if snapshot.key != AuthenticationManager.sharedInstance.userID {
                    user.email = dictionary["email"] as? String
                    user.name = (dictionary["name"] as? String)
                    user.userID = snapshot.key
                    
                    if self.myUser.myFriends.contains(where: {$0.email == user.email}) {
                        user.yourFriend = true
                    }
                    self.FriendsArray.append(user)
                    self.tableView.beginUpdates()
                    //print(self.FriendsArray[self.FriendsArray.count-1].email!)
                    self.tableView.insertRows(at: [IndexPath(row: self.FriendsArray.count-1, section: 0)], with: .bottom)
                    self.tableView.endUpdates()
                }
            }
        })
    }
    
    //Add friend to your friends list
    func addFriends(userToAdd: Person){
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(AuthenticationManager.sharedInstance.userID!).child("friends").childByAutoId()
        let values = ["FriendEmail": userToAdd.email, "FriendName": userToAdd.name, "UID": userToAdd.userID]
        
        usersReference.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: {
            (err, reff) in
            if err != nil {
                print(err ?? "no error print")
                return
            }
            print("")
            print("User Saved to DB from FiendsVC ... ")
            print("")
        })
        
    }
    
    //Remove friend from your friends list
    func removeFriends(userToRemove: Person){
        let ref = Database.database().reference()
        let userReference = ref.child("users").child(AuthenticationManager.sharedInstance.userID!).child("friends")
        
        userReference.observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    if dictionary["UID"] as? String == userToRemove.userID {
                        userReference.child(snapshot.key).removeValue()
                        print("")
                        print(" ... remove found in FiendsVC ... ")
                        print("")
                    }
                }
                
            }
        })
        
    }
    
    
    
}
