//
//  UserMessage.swift
//  iChatCharge
//
//  Created by Chris Hahn on 3/26/18.
//  Copyright © 2018 Chris Hahn. All rights reserved.
//

import Foundation
import MessageKit

class UserMessage: MessageType {
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var data: MessageData
    
    init(data: MessageData, sender: Sender, messageId: String, date: Date) {
        self.data = data
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    
    convenience init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(data: .text(text), sender: sender, messageId: messageId, date: date)
    }
}
