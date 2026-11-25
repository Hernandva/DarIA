import Foundation

/// Display-ready data of Chat. The view model owns it as a variable and adds each use case result
/// to its own field, so a new result never erases the rest of the data.
struct ChatViewData: Equatable, Sendable {
    /// Where the model of a connection runs.
    enum ConnectionKind: Equatable, Sendable {
        case cloud
        case local
    }

    /// Who wrote a message.
    enum Sender: Equatable, Sendable {
        case assistant
        case user
    }

    /// Model the conversation is held with.
    struct Connection: Equatable, Sendable {
        var name: String
        var kind: ConnectionKind
    }

    /// One message of the conversation.
    struct Message: Identifiable, Equatable, Sendable {
        let id: UUID
        var sender: Sender
        var text: String
        /// File name of an attached image or file, if any.
        var attachmentName: String?
        var isDelivered: Bool
    }

    /// Conversation returned by `ChatUseCase`.
    struct Conversation: Equatable, Sendable {
        var connection: Connection
        var startedAt: Date
        var messages: [Message]
    }

    /// Result of `ChatUseCase`, or `nil` until it loads.
    var conversation: Conversation?
}
