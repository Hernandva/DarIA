import Foundation

/// Who wrote a message of the conversation.
public enum ChatRole: Sendable {
    case user
    case assistant
}

/// One message of the conversation sent to the model.
public protocol ChatMessageProtocol: Sendable {
    var role: ChatRole { get }
    var text: String { get }
}

/// Public data the app must provide to get a reply from the Chat repository.
public protocol ChatRequestProtocol: Sendable {
    /// Model that answers. The persona is the same for every provider.
    var provider: ChatProvider { get }
    /// Whole conversation, oldest first. The last message is the question of the user.
    var messages: [any ChatMessageProtocol] { get }
}
