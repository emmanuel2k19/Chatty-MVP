//
//  LoginViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/9/25.
//
import UIKit
import FirebaseAuth
import SVProgressHUD

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
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: loginView.emailTextField.text ?? "",
                           password: loginView.passwordTextField.text ?? "") { (result, error) in
            
            if let error = error {
                // Dismiss the HUD
                SVProgressHUD.dismiss()
                
                print("Login failed: \(error.localizedDescription)")
                
                // Optional: Show an error HUD
                SVProgressHUD.showError(withStatus: "Login failed")
                
            } else {
                print("Login Successful")
                SVProgressHUD.dismiss()
                
                let messagesVC = MessagesListViewController()
                self.navigationController?.pushViewController(messagesVC, animated: true)
            }
        }
    }

    @objc private func handleRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
}
