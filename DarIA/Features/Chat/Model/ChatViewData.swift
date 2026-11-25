import Foundation

/// Display-ready data of Chat. The view model owns it as a variable and adds each use case result
/// to its own field, so a new result never erases the rest of the data.
struct ChatViewData: Equatable, Sendable {
    /// Where the model of a connection runs.
    enum ConnectionKind: Equatable, Sendable {
        case cloud
        case local
        case device
    }

    /// Who wrote a message.
    enum Sender: Equatable, Sendable {
        case assistant
        case user
    }

    /// Why the model of the connection cannot answer right now, whatever the question.
    enum ModelUnavailability: Equatable, Sendable {
        case deviceNotEligible
        case modelDisabled
        case modelNotReady
    }

    /// Why the assistant could not answer. Shown in the conversation instead of a reply.
    enum ReplyFailure: Error, Equatable, Sendable {
        case modelUnavailable(ModelUnavailability)
        case contentRejected
        case conversationTooLong
        case unsupportedLanguage
        case imagesNotSupported
        case imageUnreadable
        case unknown
    }

    /// Model the conversation is held with. The view only shows its name and kind.
    struct Connection: Equatable, Sendable {
        /// Identifier of the provider, which the use case passes back to the repository.
        var providerID: String
        var name: String
        var kind: ConnectionKind
    }

    /// One message of the conversation.
    struct Message: Identifiable, Equatable, Sendable {
        let id: UUID
        var sender: Sender
        var text: String
        /// Attached image (JPEG, already scaled down), if any.
        var imageData: Data?
        var isDelivered: Bool
        /// Set when the assistant could not answer: the message shows the failure instead of `text`.
        var failure: ReplyFailure?
    }

    /// Conversation returned by `ChatUseCase`.
    struct Conversation: Equatable, Sendable {
        var connection: Connection
        var startedAt: Date
        var messages: [Message]
    }

    /// Result of `ChatUseCase.execute()`, or `nil` until it loads. Replies are added to its messages.
    var conversation: Conversation?
}
