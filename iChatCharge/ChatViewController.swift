//
//  ViewController.swift
//  iChatCharge
//
//  Created by Chris Hahn on 3/23/18.
//  Copyright © 2018 Chris Hahn. All rights reserved.
//

import UIKit
import Firebase
import MessageKit

class ChatViewController: MessagesViewController {

    var messages: [MessageType] = []
    var ref: DatabaseReference!
    private var databaseHandle: DatabaseHandle!
    
    var FriendsArray : [Person]?
    var myUser : Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        ref = Database.database().reference()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        messages.removeAll()
        //load messages from Database, get id, text, and name values
        databaseHandle = ref.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
            if let value = snapshot.value as? [String:AnyObject] {
                let id = value["senderId"] as! String
                
                //Only show messages sent from friends and yourself
                if (self.myUser?.myFriends.contains(where: {$0.userID == id}))! || AuthenticationManager.sharedInstance.userID == id {
                    print("")
                    print(" ... friend fround in ChatVC ... ")
                    print("")
                    let text = value["text"] as! String
                    let name = value["senderDisplayName"] as! String
                    
                    let sender = Sender(id: id, displayName: name)
                    let message = UserMessage(text: text, sender: sender, messageId: id, date: Date())
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                    
                    //self.addMessage(id: id, text: text, name: name)
                    //self.finishReceivingMessage()
                }else{
                    print(" ... User not a friend & messages hidden from ChatVC ... ")
                }
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.ref.removeObserver(withHandle: databaseHandle)
    }
    
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        let senderID = AuthenticationManager.sharedInstance.userID!
        let senderDisplayName = AuthenticationManager.sharedInstance.userName!
        
        return Sender(id: senderID, displayName: senderDisplayName)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let messageRef = ref.child("messages").childByAutoId()
        let message = [
            "text": text,
            "senderId": currentSender().id,
            "senderDisplayName": currentSender().displayName
        ]
        
        messageRef.setValue(message)
        inputBar.inputTextView.text = String()
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            //return .orange
            return .green
        } else {
            return .lightGray
        }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            //return .white
            return .darkGray
        } else {
            return .darkText
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if isFromCurrentSender(message: message) {
            return .bubbleTail(.bottomRight, .curved)
        } else {
            return .bubbleTail(.bottomLeft, .curved)
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0.0
    }
    
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
}
