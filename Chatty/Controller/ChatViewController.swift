//
//  ChatViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/9/25.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController{
    
    let tableView = UITableView()
    let messageInputContainer = UIView()
    let messageTextField = UITextField()
    let sendButton = UIButton(type: .system)
    var conversationID: String
    var recipientEmail: String
    var messages: [Message] = []
    init(conversationID: String, recipientEmail: String) {
            self.conversationID = conversationID
            self.recipientEmail = recipientEmail
            super.init(nibName: nil, bundle: nil)
        }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = recipientEmail
        setupTableView()
        setupInputComponents()
        setupKeyboardObservers()
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        observeMessages()
    }

    // MARK: - Table View Setup
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        view.addSubview(tableView)
        view.addSubview(messageInputContainer)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputContainer.topAnchor)
        ])
    }

    // MARK: - Input View Setup
    func setupInputComponents() {
        // Container view
        messageInputContainer.backgroundColor = UIColor(white: 0.95, alpha: 1)
        messageInputContainer.translatesAutoresizingMaskIntoConstraints = false
        

        // Text field
        messageTextField.placeholder = "Type a message"
        messageTextField.borderStyle = .roundedRect
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainer.addSubview(messageTextField)

        // Send button
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.systemBlue, for: .normal)
        sendButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        messageInputContainer.addSubview(sendButton)

        NSLayoutConstraint.activate([
            // Container constraints
            messageInputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputContainer.heightAnchor.constraint(equalToConstant: 60),

            // TextField constraints
            messageTextField.leadingAnchor.constraint(equalTo: messageInputContainer.leadingAnchor, constant: 16),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),

            // Send button
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: messageInputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),

            // TextField trailing limited by button
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
        ])
    }
    @objc func sendPressed() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            return
        }

        let db = Firestore.firestore()
        let messageData: [String: Any] = [
            "text": text,
            "senderID": currentUserID,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("conversations")
            .document(conversationID)
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("❌ Failed to send message:", error)
                    return
                }

                self.messageTextField.text = ""
            }

        // Update conversation metadata (last message & timestamp)
        db.collection("conversations")
            .document(conversationID)
            .setData([
                "lastMessage": text,
                "timestamp": Timestamp(date: Date())
            ], merge: true)
    }
    
    func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // MARK: - Keyboard Handling
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            view.frame.origin.y = -keyboardFrame.height + view.safeAreaInsets.bottom
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
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
                
                self.messages = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    let text = data["text"] as? String ?? ""
                    let senderID = data["senderID"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    return Message(text: text, senderID: senderID, timestamp: timestamp)
                } ?? []
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom()
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

