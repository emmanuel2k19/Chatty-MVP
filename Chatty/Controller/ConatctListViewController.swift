//
//  ConatctListViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/29/25.
//
import UIKit
import Contacts
import FirebaseAuth
import Firebase

class ContactListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private var contacts: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        view.backgroundColor = .systemBackground
        setupTableView()
        fetchContacts()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "contactCell")
    }
    
    private func fetchContacts() {
        ContactManager.shared.requestAccess { [weak self] granted in
            guard granted else {
                self?.showPermissionAlert()
                return
            }
            ContactManager.shared.fetchContacts { contacts in
                self?.contacts = contacts
                self?.tableView.reloadData()
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "Permission Denied", message: "Please allow contact access in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let fullName = "\(contact.givenName) \(contact.familyName)"
        let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
        
        cell.textLabel?.text = "\(fullName)\n\(phone)"
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        
        return cell
    }
    private func generateConversationID(with recipientID: String, currentUserID: String) -> String {
        // Create a unique, consistent ID for this chat
        // Sort the IDs so both users get the same conversation ID no matter who starts
        let sortedIDs = [recipientID, currentUserID].sorted()
        return sortedIDs.joined(separator: "_")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = contacts[indexPath.row]
        
        // Get full name and a contact identifier (phone or email)
        let fullName = "\(selectedContact.givenName) \(selectedContact.familyName)"
        let phone = selectedContact.phoneNumbers.first?.value.stringValue ?? ""
        let email = selectedContact.emailAddresses.first?.value as String? ?? ""
        
        // Pick either phone or email as the unique recipient UID for now
        let recipientUID = !email.isEmpty ? email : phone
        
        // Generate conversation ID
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let conversationID = generateConversationID(with: recipientUID, currentUserID: currentUserID)
        
        // Go to chat
        let chatVC = ChatViewController(
            conversationID: conversationID,
            recipientEmail: recipientUID,
            recipientUID: recipientUID // For now, we can use email or phone until you map it to Firebase UID
        )
        
        // Create the conversation in Firestore if it doesn't exist
        let db = Firestore.firestore()
        let conversationRef = db.collection("conversations").document(conversationID)
        conversationRef.getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                // Conversation already exists, just push
                self.navigationController?.pushViewController(chatVC, animated: true)
            } else {
                // Conversation doesn't exist, create it
                conversationRef.setData([
                    "userIDs": [currentUserID, recipientUID],
                    "lastMessage": "",
                    "timestamp": Timestamp(date: Date())
                ]) { _ in
                    self.navigationController?.pushViewController(chatVC, animated: true)
                }
            }
        }
    }
}
