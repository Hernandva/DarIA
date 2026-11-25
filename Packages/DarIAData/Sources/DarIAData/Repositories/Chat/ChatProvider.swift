import Foundation

/// Language model a conversation is held with. Every provider answers with the same persona, so the app only
/// chooses which one to use and passes it in the request.
public struct ChatProvider: Hashable, Sendable {
    /// Family of the provider. `ChatRepository` routes each request to the service registered for its kind.
    public enum Kind: String, Hashable, Sendable, CaseIterable {
        /// On-device model of Apple Intelligence, through the Foundation Models framework.
        case appleIntelligence
    }

    public let kind: Kind

    public init(kind: Kind) {
        self.kind = kind
    }

    /// Provider used when the app opens.
    public static let appleIntelligence = ChatProvider(kind: .appleIntelligence)
}
