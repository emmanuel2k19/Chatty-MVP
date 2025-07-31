//
//  ChatCellView.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/23/25.
//
import UIKit

class ChatCell: UITableViewCell {

    let initialsView = UIView()
    let initialsLabel = UILabel()
    let nameLabel = UILabel()
    let messageLabel = UILabel()
    let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        initialsView.backgroundColor = .lightGray
        initialsView.layer.cornerRadius = 25
        initialsView.translatesAutoresizingMaskIntoConstraints = false

        initialsLabel.textColor = .white
        initialsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsView.addSubview(initialsLabel)

        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 1
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)

        contentView.addSubview(initialsView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            initialsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            initialsView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            initialsView.widthAnchor.constraint(equalToConstant: 50),
            initialsView.heightAnchor.constraint(equalToConstant: 50),

            initialsLabel.centerXAnchor.constraint(equalTo: initialsView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: initialsView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: initialsView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),

            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with chat: ChatModel) {
        initialsLabel.text = chat.initials
        nameLabel.text = chat.name
        messageLabel.text = chat.message
        timeLabel.text = chat.time
    }
}
