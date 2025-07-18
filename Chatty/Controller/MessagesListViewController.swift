//
//  MessagesListViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/10/25.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

struct Conversation {
    let id: String
    let otherUserEmail: String
    let lastMessage: String
    let timestamp: Date
}

class MessagesListViewController: UIViewController {
    let messagesListView = MessagesListView()
    let tableView = UITableView()
    var conversations: [Conversation] = []

    override func loadView() {
        self.view = messagesListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Messages"
        setupDelegates()
        setupActions()
        view.backgroundColor = .white
        loadConversations()
    }

    private func setupDelegates() {
        messagesListView.emailField.delegate = self
        messagesListView.tableView.dataSource = self
        messagesListView.tableView.delegate = self
    }
    
    private func setupActions() {
        messagesListView.sendButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
    }
    
    // 🔥 SEND A MESSAGE TO A USER BY EMAIL
    @objc func sendPressed() {
        guard
            let email = messagesListView.emailField.text?.lowercased(), !email.isEmpty,
            let message = messagesListView.messageField.text, !message.isEmpty,
            let currentUserID = Auth.auth().currentUser?.uid
        else { return }

        let db = Firestore.firestore()

        // 🔍 Find the recipient by email (case-sensitive in Firestore)
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error finding user:", error)
                    return
                }

                guard let doc = snapshot?.documents.first else {
                    print("❌ No user found with that email")
                    return
                }

                let receiverID = doc.documentID
                let receiverEmail = doc["email"] as? String ?? "Unknown"
                print("✅ Found recipient:", receiverEmail)

                // 🔗 Generate a consistent conversation ID (sorted UID)
                let conversationID = [currentUserID, receiverID].sorted().joined(separator: "_")
                let conversationRef = db.collection("conversations").document(conversationID)

                // 🔧 Save conversation metadata
                conversationRef.setData([
                    "userIDs": [currentUserID, receiverID], // IMPORTANT!
                    "lastMessage": message,
                    "timestamp": Timestamp(date: Date())
                ], merge: true)

                // 💬 Save message to subcollection
                conversationRef.collection("messages").addDocument(data: [
                    "text": message,
                    "senderID": currentUserID,
                    "timestamp": Timestamp(date: Date())
                ])

                DispatchQueue.main.async {
                    self.messagesListView.messageField.text = ""
                    self.loadConversations() // Refresh messages list
                }
            }
    }
    // ✅ LOAD CONVERSATIONS FOR CURRENT USER
    func loadConversations() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("conversations")
            .whereField("userIDs", arrayContains: currentUserID)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Failed to load conversations:", error)
                    return
                }

                self.conversations = []

                let group = DispatchGroup()

                snapshot?.documents.forEach { doc in
                    group.enter()

                    let data = doc.data()
                    let userIDs = data["userIDs"] as? [String] ?? []
                    let lastMessage = data["lastMessage"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()

                    let otherUserID = userIDs.first { $0 != currentUserID } ?? ""

                    db.collection("users").document(otherUserID).getDocument { userDoc, _ in
                        let email = userDoc?.data()?["email"] as? String ?? "Unknown"
                        let conversation = Conversation(id: doc.documentID, otherUserEmail: email, lastMessage: lastMessage, timestamp: timestamp)
                        self.conversations.append(conversation)
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.messagesListView.tableView.reloadData()
                }
            }
    }
}

// ✅ TABLE VIEW
extension MessagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = conversations.count
        if count == 0 {
            tableView.setEmptyMessage("No messages received.")
        } else {
            tableView.restore()
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let convo = conversations[indexPath.row]
            cell.textLabel?.text = convo.otherUserEmail
            cell.detailTextLabel?.text = convo.lastMessage
            return cell
        }
    }

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        backgroundView = messageLabel
        separatorStyle = .none
    }

    func restore() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}

extension MessagesListViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == messagesListView.emailField {
            let lowercaseString = string.lowercased()
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: lowercaseString)
            textField.text = newText
            return false
        }
        return true
    }
}
// 👇 New extension for delegate
extension MessagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        let chatVC = ChatViewController(conversationID: conversation.id, recipientEmail: conversation.otherUserEmail)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
