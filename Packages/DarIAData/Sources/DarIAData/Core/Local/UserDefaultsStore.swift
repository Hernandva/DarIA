import Foundation

/// Stores each key in UserDefaults. Meant for small values such as settings or flags.
struct UserDefaultsStore: LocalStore {
    /// `nil` uses `UserDefaults.standard`; an app group name shares the data with extensions.
    let suiteName: String?

    init(suiteName: String? = nil) {
        self.suiteName = suiteName
    }

    func read(key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func write(_ data: Data, key: String) {
        defaults.set(data, forKey: key)
    }

    func remove(key: String) {
        defaults.removeObject(forKey: key)
    }
}

private extension UserDefaultsStore {
    var defaults: UserDefaults {
        suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }
}
