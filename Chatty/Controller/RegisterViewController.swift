//
//  RegisterViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/9/25.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    let registerView = RegisterView()
    override func loadView() {
        self.view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpActions()
    }
    
    private func setUpActions() {
        registerView.registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    
    @objc private func handleRegister() {
        guard let email = registerView.emailTextField.text, !email.isEmpty,
              let password = registerView.passwordTextField.text, !password.isEmpty else {
            print("❌ Email or password empty")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ Registration failed:", error.localizedDescription)
            } else if let user = result?.user {
                print("✅ User registered:", user.uid)
                
                // SAVE USER TO FIRESTORE
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "email": email.lowercased()
                ]) { error in
                    if let error = error {
                        print("❌ Failed to save user to Firestore:", error.localizedDescription)
                    } else {
                        print("✅ User saved to Firestore")
                        
                        // 🚀 Navigate to Messages screen
                        DispatchQueue.main.async {
                            let messagesListVC = MessagesListViewController()
                            self.navigationController?.pushViewController(messagesListVC, animated: true)
                        }
                    }
                }
            }
        }
    }
}
