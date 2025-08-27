//
//  Model.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/9/25.
//
import Foundation

struct Message {
    let text: String
    let senderID: String
    let timestamp: Date
}

struct ChatModel {
    let initials: String
    let name: String
    let message: String
    let time: String
}

struct Conversations {
    let id: String
    let otherUserUID: String
    let otherUserName: String   // was otherUserEmail in your code
    let otherUserEmail: String
    let lastMessage: String
    let timestamp: Date
}
