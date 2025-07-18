//
//  LoginViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/9/25.
//
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    let loginView = LoginView()

    override func loadView() {
        self.view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpActions()
    }

    private func setUpActions() {
        loginView.loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginView.registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }

    @objc private func handleLogin() {
        guard let email = loginView.emailTextField.text, !email.isEmpty,
              let password = loginView.passwordTextField.text, !password.isEmpty else {
            print("❌ Email or password empty")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ Login failed:", error.localizedDescription)
            } else {
                print("✅ Logged in as:", result?.user.email ?? "")
                let messagesListVC = MessagesListViewController()
                self.navigationController?.pushViewController(messagesListVC, animated: true)
            }
        }
    }

    @objc private func handleRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
}
