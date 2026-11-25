import Foundation

/// Byte storage used by the local repositories. Each backend (JSON files, UserDefaults, Keychain) implements it,
/// and repositories receive one in their initialiser so tests can inject an in-memory store.
protocol LocalStore: Sendable {
    /// Returns the stored data, or `nil` when nothing is stored under `key`.
    func read(key: String) async throws -> Data?
    /// Stores `data` under `key`, replacing any previous value.
    func write(_ data: Data, key: String) async throws
    /// Removes the value stored under `key`. Does nothing when there is none.
    func remove(key: String) async throws
}

public enum LocalStoreError: Error, Equatable, Sendable {
    /// Nothing has been saved yet under this key.
    case notFound(String)
    /// A Keychain call failed with this `OSStatus`.
    case keychain(Int32)
}
