//
//  ChatView.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/13/25.
//
import UIKit

class ChatView: UIView {

    let tableView = UITableView()
    let messageInputContainer = UIView()
    let messageTextField = UITextField()
    let sendButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainer.backgroundColor = UIColor(white: 0.95, alpha: 1)
        messageInputContainer.translatesAutoresizingMaskIntoConstraints = false

        messageTextField.placeholder = "Type a message"
        messageTextField.borderStyle = .roundedRect
        messageTextField.translatesAutoresizingMaskIntoConstraints = false

        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.systemBlue, for: .normal)
        sendButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(tableView)
        addSubview(messageInputContainer)
        messageInputContainer.addSubview(messageTextField)
        messageInputContainer.addSubview(sendButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputContainer.topAnchor),

            messageInputContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageInputContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageInputContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            messageInputContainer.heightAnchor.constraint(equalToConstant: 60),

            messageTextField.leadingAnchor.constraint(equalTo: messageInputContainer.leadingAnchor, constant: 16),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: messageInputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),

            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
        ])
    }
}
