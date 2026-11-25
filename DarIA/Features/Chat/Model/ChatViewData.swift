import Foundation

/// Display-ready data of Chat. The view model owns it as a variable and adds each use case result
/// to its own field, so a new result never erases the rest of the data.
struct ChatViewData: Equatable, Sendable {
    /// Data returned by `ChatUseCase`. Rename it after what it holds and add one type and one field
    /// per use case, with the properties the view needs.
    struct Content: Equatable, Sendable {}

    /// Result of `ChatUseCase`, or `nil` until it loads.
    var content: Content?
}
