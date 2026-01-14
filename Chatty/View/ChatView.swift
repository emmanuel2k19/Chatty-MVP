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

    // This constraint will move up/down with the keyboard
    private var bottomConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupSubviews()
        setupConstraints()
        setupKeyboardObservers()
        setupTapToDismissKeyboard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .interactive

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
        bottomConstraint = messageInputContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputContainer.topAnchor),

            messageInputContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageInputContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomConstraint,
            messageInputContainer.heightAnchor.constraint(equalToConstant: 60),

            messageTextField.leadingAnchor.constraint(equalTo: messageInputContainer.leadingAnchor, constant: 16),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: messageInputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),

            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8)
        ])
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        bottomConstraint.constant = -keyboardFrame.height + safeAreaInsets.bottom

        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }

        // Optional: Scroll to bottom if needed
        if let tableView = self.tableView as? UITableView, tableView.numberOfRows(inSection: 0) > 0 {
            let lastRow = tableView.numberOfRows(inSection: 0) - 1
            tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        bottomConstraint.constant = 0
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }

    // MARK: - Tap to dismiss keyboard
    private func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        messageTextField.resignFirstResponder()
    }
}

 
