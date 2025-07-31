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
        guard let name = registerView.nameTextField.text, !name.isEmpty,
              let email = registerView.emailTextField.text, !email.isEmpty,
              let password = registerView.passwordTextField.text, !password.isEmpty else {
            print("❌ Email or password empty")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let user = result?.user, error == nil else {
                print("Registration failed")
                return
            }

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if error == nil {
                    print("Display name set successfully")
                }
            }

            // Optional: Also store in Firestore if you use Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "name": name,
                "email": email
            ])
        }
                        // 🚀 Navigate to Messages screen
                        DispatchQueue.main.async {
                            let messagesListVC = MessagesListViewController()
                            self.navigationController?.pushViewController(messagesListVC, animated: true)
                        }
                    }
                }
            
