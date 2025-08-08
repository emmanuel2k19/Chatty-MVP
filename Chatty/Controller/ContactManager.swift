//
//  ContactManager.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/26/25.
//
// ContactManager.swift
import Contacts

class ContactManager {
    
    static let shared = ContactManager()
    private let store = CNContactStore()

    private init() {}

    /// Request access to contacts
    func requestAccess(completion: @escaping (Bool) -> Void) {
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// Fetch contacts (full name + phone numbers)
    func fetchContacts(completion: @escaping ([CNContact]) -> Void) {
        let keys = [CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        var contacts: [CNContact] = []

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.store.enumerateContacts(with: request) { contact, _ in
                    contacts.append(contact)
                }
                DispatchQueue.main.async {
                    completion(contacts)
                }
            } catch {
                print("Failed to fetch contacts:", error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
} 
