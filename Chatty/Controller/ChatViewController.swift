//
//  ChatViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/9/25.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    let chatView = ChatView()
    var conversationID: String
    var recipientEmail: String
    var messages: [Message] = []
    var recipientUID: String
    
    init(conversationID: String, recipientEmail: String, recipientUID: String) {
        self.conversationID = conversationID
        self.recipientEmail = recipientEmail
        self.recipientUID = recipientUID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = chatView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = recipientEmail
        chatView.tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        observeMessages()
        chatView.sendButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        chatView.tableView.dataSource = self
    }
    
    @objc func sendPressed() {
        guard let text = chatView.messageTextField.text,
              !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            return
        }
        
        let db = Firestore.firestore()
        let timestamp = Timestamp(date: Date())
        
        // 1️⃣ Append the message locally for instant UI update
        let newMessage = Message(text: text, senderID: currentUserID, timestamp: timestamp.dateValue())
        messages.append(newMessage)
        
        DispatchQueue.main.async {
            self.chatView.tableView.reloadData()
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            self.chatView.messageTextField.text = ""
        }
        
        // 2️⃣ Send the message to Firestore
        let messageData: [String: Any] = [
            "text": text,
            "senderID": currentUserID,
            "timestamp": timestamp
        ]
        
        db.collection("conversations")
            .document(conversationID)
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("❌ Failed to send message:", error)
                }
            }
        
        // 3️⃣ Update conversation metadata
        db.collection("conversations")
            .document(conversationID)
            .setData([
                "userIDs": [currentUserID, recipientUID],
                "lastMessage": text,
                "timestamp": timestamp
            ], merge: true)
    }
    
    
@objc func dismissKeyboard() {
    chatView.messageTextField.resignFirstResponder()
}

    func observeMessages() {
        let db = Firestore.firestore()
        db.collection("conversations")
            .document(conversationID)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Error fetching messages:", error)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // Map Firestore documents to Message objects
                self.messages = documents.compactMap { doc in
                    let data = doc.data()
                    let text = data["text"] as? String ?? ""
                    let senderID = data["senderID"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    return Message(text: text, senderID: senderID, timestamp: timestamp)
                }
                
                DispatchQueue.main.async {
                    self.chatView.tableView.reloadData()
                    if !self.messages.isEmpty {
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
    }
}

// MARK: - TableView Data Source
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            let message = messages[indexPath.row]
            cell.configure(with: message)
            return cell
        
    }
}

