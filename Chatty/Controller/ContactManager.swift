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
        let keys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [CNKeyDescriptor]
        
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

extension ContactManager {
    func saveContact(name: String, phone: String?, email: String?, completion: @escaping (Bool) -> Void) {
        let newContact = CNMutableContact()
        
        // Name
        let nameParts = name.split(separator: " ", maxSplits: 1).map { String($0) }
        newContact.givenName = nameParts.first ?? ""
        newContact.familyName = nameParts.count > 1 ? nameParts[1] : ""
        
        // Phone
        if let phone = phone, !phone.isEmpty {
            let phoneValue = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: phone))
            newContact.phoneNumbers = [phoneValue]
        }
        
        // Email
        if let email = email, !email.isEmpty {
            let emailValue = CNLabeledValue(label: CNLabelWork, value: email as NSString)
            newContact.emailAddresses = [emailValue]
        }
        
        // Save to store
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.store.execute(saveRequest)
                DispatchQueue.main.async { completion(true) }
            } catch {
                print("❌ Failed to save contact:", error)
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
}
 
