import Foundation

/// Stores each key as a JSON file in Application Support/`folder`.
struct JSONFileStore: LocalStore {
    let folder: String

    init(folder: String = "LocalStore") {
        self.folder = folder
    }

    func read(key: String) throws -> Data? {
        let url = try fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path()) else { return nil }
        return try Data(contentsOf: url)
    }

    func write(_ data: Data, key: String) throws {
        let url = try fileURL(for: key)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }

    func remove(key: String) throws {
        let url = try fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path()) else { return }
        try FileManager.default.removeItem(at: url)
    }
}

private extension JSONFileStore {
    func fileURL(for key: String) throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appending(path: folder, directoryHint: .isDirectory).appending(path: "\(key).json")
    }
}
