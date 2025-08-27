//
//  ConctCell.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/29/25.
//
import UIKit
import Contacts
import FirebaseFirestore

class ContactCell: UITableViewCell {
    
    private let avatarView = UIView()
    private let initialsLabel = UILabel()
    private let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        avatarView.backgroundColor = .systemGray5
        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        initialsLabel.font = UIFont.boldSystemFont(ofSize: 16)
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false

        avatarView.addSubview(initialsLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)

        avatarView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor).isActive = true
        initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    func configure(with contact: CNContact) {
        let fullName = "\(contact.givenName) \(contact.familyName)"
        nameLabel.text = fullName
        
        let initials = "\(contact.givenName.first ?? "?" )\(contact.familyName.first ?? "?")"
        initialsLabel.text = initials
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

