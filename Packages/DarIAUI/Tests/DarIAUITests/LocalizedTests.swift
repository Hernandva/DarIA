import SwiftUI
@testable import DarIAUI
import Testing

@MainActor
struct LocalizedTests {
    @Test func returnsTheKeyWhenItIsNotInTheCatalog() {
        let text = DSText(style: .title).localized("missing.key")
        #expect(text.text == "missing.key")
    }

    @Test func keepsTheOriginalComponentUnchanged() {
        let original = DSButton("Original") {}
        _ = original.localized("missing.key")
        #expect(original.text == "Original")
    }

    @Test func textShowsTheDefaultValueWhenTheKeyIsNotInTheCatalog() {
        #expect(Text(forKey: "missing.key", value: "Default") == Text(verbatim: "Default"))
    }

    @Test func textShowsTheKeyWhenItHasNoDefaultValue() {
        #expect(Text(forKey: "missing.key") == Text(verbatim: "missing.key"))
    }
}
