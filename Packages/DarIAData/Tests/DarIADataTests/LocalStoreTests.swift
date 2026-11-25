import Foundation
@testable import DarIAData
import Testing

struct LocalStoreTests {
    @Test func userDefaultsStoreSavesReadsAndRemoves() async throws {
        let store = UserDefaultsStore(suiteName: "LocalStoreTests")
        try await store.write(Data("value".utf8), key: "sample")
        #expect(try await store.read(key: "sample") == Data("value".utf8))
        try await store.remove(key: "sample")
        #expect(try await store.read(key: "sample") == nil)
    }

    @Test func jsonFileStoreSavesReadsAndRemoves() async throws {
        let store = JSONFileStore(folder: "LocalStoreTests")
        try await store.write(Data("{}".utf8), key: "sample")
        #expect(try await store.read(key: "sample") == Data("{}".utf8))
        try await store.remove(key: "sample")
        #expect(try await store.read(key: "sample") == nil)
    }
}
