//
//  MessagesListView.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/13/25.
//
import UIKit

class MessagesListView: UIView {
    
    let tableView = UITableView()
    let emailField = UITextField()
    let messageField = UITextField()
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
        emailField.placeholder = "Recipient's email"
        emailField.borderStyle = .roundedRect
        emailField.autocapitalizationType = .none
        emailField.translatesAutoresizingMaskIntoConstraints = false

        messageField.placeholder = "Message"
        messageField.borderStyle = .roundedRect
        messageField.translatesAutoresizingMaskIntoConstraints = false

        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.layer.cornerRadius = 8
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(emailField)
        addSubview(messageField)
        addSubview(sendButton)
        addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emailField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            emailField.heightAnchor.constraint(equalToConstant: 40),

            messageField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 8),
            messageField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            messageField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            messageField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.topAnchor.constraint(equalTo: messageField.bottomAnchor, constant: 8),
            sendButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            sendButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
