//
//  CreateNewContactView.swift
//  Chatty
//
//  Created by Emmanuel Pena on 8/9/25.
//
import UIKit

class CreateNewContactView: UIView {

    let nameTextField = UITextField ()
    let phoneTextField = UITextField()
    let emailTextField = UITextField()
    let messageTextField = UITextField()
    let createButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupviews() {
        nameTextField.placeholder = "Full Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
    
        phoneTextField.placeholder = "Phone Number"
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .phonePad
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        
        emailTextField.placeholder = "Email (optional)"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        createButton.setTitle("Create Contact", for: .normal)
        createButton.backgroundColor = UIColor.systemGreen
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 8
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(nameTextField)
        addSubview(phoneTextField)
        addSubview(emailTextField)
        addSubview(messageTextField)
        addSubview(createButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),

            phoneTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 12),
            phoneTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            phoneTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            phoneTextField.heightAnchor.constraint(equalToConstant: 44),

            emailTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            messageTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            messageTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 44),

            createButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            createButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            createButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
