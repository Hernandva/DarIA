import Foundation
import Security

/// Stores each key as a generic password in the Keychain. Meant for sensitive data such as tokens.
struct KeychainStore: LocalStore {
    let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "app") {
        self.service = service
    }

    func read(key: String) throws -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw LocalStoreError.keychain(status) }
        return item as? Data
    }

    func write(_ data: Data, key: String) throws {
        let query = baseQuery(for: key)
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecSuccess { return }
        guard status == errSecItemNotFound else { throw LocalStoreError.keychain(status) }
        var item = query
        item[kSecValueData as String] = data
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        let addStatus = SecItemAdd(item as CFDictionary, nil)
        guard addStatus == errSecSuccess else { throw LocalStoreError.keychain(addStatus) }
    }

    func remove(key: String) throws {
        let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw LocalStoreError.keychain(status)
        }
    }
}

private extension KeychainStore {
    func baseQuery(for key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecUseDataProtectionKeychain as String: true
        ]
    }
}
