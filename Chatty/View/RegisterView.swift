//
//  RegisterView.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/13/25.
//
import UIKit

class RegisterView: UIView {
    
    var backgroundView = UIView()
    var titleLabel = UILabel()
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var registerButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup
    private func setUpView() {
        
        backgroundView.backgroundColor = UIColor(red: 37/255, green: 211/255, blue: 102/255, alpha: 1)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "Register"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.backgroundColor = .white
        emailTextField.layer.cornerRadius = 8
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.backgroundColor = .white
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        registerButton.setTitle("Create Account", for: .normal)
        registerButton.backgroundColor = UIColor(named: "#25D366")
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        registerButton.layer.cornerRadius = 8
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundView)
        addSubview(titleLabel)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(registerButton)
        
    }
   
    func applyConstraints(){
        
        NSLayoutConstraint.activate([
            
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 30),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            registerButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
        
        ])
    }
    
    
    
}


