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
    let otherUserEmail: String
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
        loadConversations()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,target: self,action: #selector(didTapPlus))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(didTapSignOut))
        
    }
    
    private func setupDelegates() {
        messagesListView.tableView.delegate = self
        messagesListView.tableView.dataSource = self
        messagesListView.tableView.delegate = self
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
                        let name = userDoc?.data()?["name"] as? String ?? "Unknown"
                        let conversation = Conversation(id: doc.documentID, otherUserEmail: name, lastMessage: lastMessage, timestamp: timestamp)
                        self.conversations.append(conversation)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.messagesListView.tableView.reloadData()
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
        alert.addAction(UIAlertAction(title: "Start New Chat", style: .default) { _ in
            self.presentManualChatEntry()
        })
        alert.addAction(UIAlertAction(title: "Browse Contacts", style: .default) { _ in
            let vc = ContactListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    func startNewConversation(with email: String, message: String, senderID: String) {
        let db = Firestore.firestore()
        
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
                let conversationID = [senderID, receiverID].sorted().joined(separator: "_")
                let conversationRef = db.collection("conversations").document(conversationID)
                
                // Save conversation metadata
                conversationRef.setData([
                    "userIDs": [senderID, receiverID],
                    "lastMessage": message,
                    "timestamp": Timestamp(date: Date())
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
        
        let name = convo.otherUserEmail.components(separatedBy: "@").first ?? convo.otherUserEmail
        let initials = name.prefix(2).uppercased()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: convo.timestamp)
        
        let model = ChatModel(initials: String(initials), name: name.capitalized, message: convo.lastMessage, time: timeString)
        
        cell.configure(with: model)
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
    
    // 👇 New extension for delegate
    extension MessagesListViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let conversation = conversations[indexPath.row]
            let chatVC = ChatViewController(conversationID: conversation.id, recipientEmail: conversation.otherUserEmail)
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    

