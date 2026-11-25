import SwiftUI

public extension Text {
    /// Text with the localised value of `key`, looked up with `Bundle.localizedString(forKey:value:table:)`.
    ///
    ///     Text(forKey: "profile.title", value: "Profile")
    ///
    /// - Parameters:
    ///   - key: Key in the String Catalog (`Localizable.xcstrings` of the app by default).
    ///   - value: Text shown when the key is not in the catalog. `nil` shows the key itself.
    ///   - table: String table name. `nil` uses `Localizable`.
    ///   - bundle: Bundle that holds the catalog. Defaults to the app bundle.
    init(forKey key: String, value: String? = nil, table: String? = nil, bundle: Bundle = .main) {
        self.init(verbatim: bundle.localizedString(forKey: key, value: value, table: table))
    }
}
