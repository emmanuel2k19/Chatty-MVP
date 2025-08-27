//
//  CreateNewContactViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 8/9/25.
//
import UIKit
import Firebase

class CreateContactViewController: UIViewController {
    
    private let createContactView = CreateNewContactView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Contact"
        view.backgroundColor = .systemBackground
        view.addSubview(createContactView)
        createContactView.frame = view.bounds
        
        createContactView.createButton.addTarget(self, action: #selector(saveContactTapped), for: .touchUpInside)
    }
    
    @objc private func saveContactTapped() {
        let name = createContactView.nameTextField.text ?? ""
        let phone = createContactView.phoneTextField.text ?? ""
        let email = createContactView.emailTextField.text ?? ""

        guard !name.isEmpty else {
            showAlert(message: "Please enter a name.")
            return
        }

        guard !phone.isEmpty || !email.isEmpty else {
            showAlert(message: "Please enter either a phone or email.")
            return
        }

        ContactManager.shared.requestAccess { granted in
            guard granted else {
                self.showAlert(message: "Access to contacts denied.")
                return
            }

            // Save to device contacts
            ContactManager.shared.saveContact(name: name, phone: phone, email: email) { success in
                if success {
                    // Save to Firestore
                    self.saveToFirestore(name: name, phone: phone, email: email) {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.showAlert(message: "Failed to save contact.")
                }
            }
        }
    }
    
    private func saveToFirestore(name: String, phone: String?, email: String?, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(UUID().uuidString) // unique ID

        var data: [String: Any] = ["name": name]
        if let phone = phone, !phone.isEmpty { data["phone"] = phone }
        if let email = email, !email.isEmpty { data["email"] = email }

        docRef.setData(data) { error in
            if let error = error {
                print("❌ Failed to save to Firestore:", error)
            }
            completion()
        }
    }
    
    private func createFirestoreUser(name: String, email: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        guard !email.isEmpty else {
            // If no email, you can use phone as a unique ID instead
            completion()
            return
        }
        
        // Check if user already exists
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error checking user:", error)
                completion()
                return
            }
            
            if let doc = snapshot?.documents.first {
                // User already exists
                completion()
            } else {
                // Create new user
                db.collection("users").document().setData([
                    "name": name,
                    "email": email
                ]) { error in
                    if let error = error {
                        print("❌ Failed to create user:", error)
                    }
                    completion()
                }
            }
        }
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
