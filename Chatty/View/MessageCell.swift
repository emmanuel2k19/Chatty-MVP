//
//  MessageCell.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/9/25.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class MessageCell: UITableViewCell {
    
    let bubbleView = UIView()
    let messageLabel = UILabel()

    var isFromCurrentUser: Bool = false {
        didSet {
            bubbleView.backgroundColor = isFromCurrentUser ? UIColor.systemGreen : UIColor(white: 0.9, alpha: 1)
            messageLabel.textColor = isFromCurrentUser ? .white : .black
            updateConstraintsForSide()
        }
    }

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)

        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)

        // Constraints
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
        ])

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    }

    func configure(with message: Message) {
        messageLabel.text = message.text
        let currentUID = Auth.auth().currentUser?.uid ?? ""
        isFromCurrentUser = (message.senderID == currentUID)
    }

    private func updateConstraintsForSide() {
        if isFromCurrentUser {
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        } else {
            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
