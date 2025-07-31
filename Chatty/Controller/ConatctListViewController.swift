//
//  ConatctListViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/29/25.
//
import UIKit
import Contacts

class ContactListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private var contacts: [CNContact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        view.backgroundColor = .systemBackground
        setupTableView()
        fetchContacts()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "contactCell")
    }

    private func fetchContacts() {
        ContactManager.shared.requestAccess { [weak self] granted in
            guard granted else {
                self?.showPermissionAlert()
                return
            }
            ContactManager.shared.fetchContacts { contacts in
                self?.contacts = contacts
                self?.tableView.reloadData()
            }
        }
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(title: "Permission Denied", message: "Please allow contact access in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)

        let fullName = "\(contact.givenName) \(contact.familyName)"
        let phone = contact.phoneNumbers.first?.value.stringValue ?? ""

        cell.textLabel?.text = "\(fullName)\n\(phone)"
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none

        return cell
    }

    // MARK: - Optional: On Tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = contacts[indexPath.row]
        print("Tapped: \(selected.givenName) \(selected.familyName)")
        // You could start a new chat with selected contact here
    }
}
