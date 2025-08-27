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
import ContactsUI

struct Conversation {
    let id: String
    let otherUserUID: String
    let otherUserName: String
    let lastMessage: String
    let timestamp: Date
}
class MessagesListViewController: UIViewController, CNContactPickerDelegate {
    
    let messagesListView = MessagesListView()
    let tableView = UITableView()
    var conversations: [Conversation] = []
    
    override func loadView() {
        self.view = messagesListView
        messagesListView.tableView.register(ChatCell.self, forCellReuseIdentifier: "ChatCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Messages"
        setupDelegates()
        view.backgroundColor = .white
        backfillConversationNames()
        loadConversations()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,target: self,action: #selector(didTapPlus))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(didTapSignOut))
        
    }
    
    private func setupDelegates() {
        messagesListView.tableView.delegate = self
        messagesListView.tableView.dataSource = self
        messagesListView.tableView.delegate = self
    }
    
    
    func loadConversations() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("conversations")
            .whereField("userIDs", arrayContains: currentUserID)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Failed to load conversations:", error)
                    return
                }

                self.conversations = []

                snapshot?.documents.forEach { doc in
                    let data = doc.data()
                    let userIDs = data["userIDs"] as? [String] ?? []
                    let lastMessage = data["lastMessage"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let userNames = data["userNames"] as? [String: String] ?? [:]

                    // Find the other user's UID
                    let otherUserID = userIDs.first { $0 != currentUserID } ?? ""
                    // Get the other user's name from userNames dictionary
                    let otherUserName = userNames[otherUserID] ?? "Unknown"

                    let conversation = Conversation(
                        id: doc.documentID,
                        otherUserUID: otherUserID,
                        otherUserName: otherUserName,
                        lastMessage: lastMessage,
                        timestamp: timestamp
                    )

                    self.conversations.append(conversation)
                }

                DispatchQueue.main.async {
                    self.messagesListView.tableView.reloadData()
                }
            }
    }
    func backfillConversationNames() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("conversations")
            .whereField("userIDs", arrayContains: currentUserID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch conversations for backfill:", error)
                    return
                }
                
                snapshot?.documents.forEach { doc in
                    let data = doc.data()
                    let userIDs = data["userIDs"] as? [String] ?? []
                    let userNames = data["userNames"] as? [String: String] ?? [:]
                    
                    // Skip if the other user already has a name stored
                    let otherUserID = userIDs.first { $0 != currentUserID } ?? ""
                    if userNames[otherUserID] != nil { return }
                    
                    // Fetch name from users collection
                    db.collection("users").document(otherUserID).getDocument { userDoc, _ in
                        guard let name = userDoc?.data()?["name"] as? String else { return }
                        
                        // Update conversation with the correct name
                        doc.reference.setData([
                            "userNames": [otherUserID: name]
                        ], merge: true)
                    }
                }
            }
    }
    func presentManualChatEntry() {
        
    }
    
    func requestAndShowContacts(){
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // Handle selected contact here
        print("Selected contact: \(contact.givenName) \(contact.familyName)")
    }
    
    
    @objc func didTapPlus() {
        let alert = UIAlertController(title: "New Chat", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Create New Contact", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let createContactVC = CreateContactViewController()
            self.navigationController?.pushViewController(createContactVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Browse Contacts", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let vc = ContactListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func startNewConversation(with email: String, name: String, message: String, senderID: String) {
        let db = Firestore.firestore()
        
        // Check if user exists
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error finding user:", error)
                    return
                }
                
                var receiverID: String
                if let doc = snapshot?.documents.first {
                    // User exists
                    receiverID = doc.documentID
                } else {
                    // User doesn't exist → create them
                    let newDoc = db.collection("users").document()
                    newDoc.setData([
                        "name": name,
                        "email": email
                    ])
                    receiverID = newDoc.documentID
                }
                
                let conversationID = [senderID, receiverID].sorted().joined(separator: "_")
                let conversationRef = db.collection("conversations").document(conversationID)
                
                // Save conversation metadata
                conversationRef.setData([
                    "userIDs": [senderID, receiverID],
                    "lastMessage": message,
                    "timestamp": Timestamp(date: Date()),
                    "userNames": [senderID: "Me", receiverID: name] // store the contact’s name here
                ], merge: true)
                
                // Save message to subcollection
                conversationRef.collection("messages").addDocument(data: [
                    "text": message,
                    "senderID": senderID,
                    "timestamp": Timestamp(date: Date())
                ])
                
                DispatchQueue.main.async {
                    self.loadConversations()
                }
            }
    }
    @objc func didTapSignOut() {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "Do you really want to sign out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                
                // Navigate back to Login or Register screen
                let loginVC = LoginViewController()
                let navVC = UINavigationController(rootViewController: loginVC)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true)
                
            } catch let signOutError as NSError {
                print("❌ Error signing out: \(signOutError.localizedDescription)")
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }
        
        let convo = conversations[indexPath.row]
        
        let name = convo.otherUserName.components(separatedBy: "@").first ?? convo.otherUserName
        let initials = name.prefix(2).uppercased()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: convo.timestamp)
        
        let model = ChatModel(initials: String(initials), name: name.capitalized, message: convo.lastMessage, time: timeString)
        
        cell.configure(with: model)
        return cell
    }
    
    private func deleteConversation(convoID: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("conversations").document(convoID).delete { error in
            if let error = error {
                print("❌ Error deleting conversation: \(error.localizedDescription)")
            } else {
                print("✅ Conversation deleted")
                completion()
            }
        }
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
    
    // 👇 New extension for delegate
extension MessagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        let chatVC = ChatViewController(conversationID: conversation.id, recipientEmail: conversation.otherUserName, recipientUID: conversation.otherUserUID)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            
            guard let self = self else { return }
            let convo = self.conversations[indexPath.row]
            
            self.deleteConversation(convoID: convo.id) {
                self.conversations.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
        
    }
}
