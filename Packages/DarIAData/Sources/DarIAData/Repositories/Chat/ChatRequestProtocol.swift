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
    /// Image attached to the message (JPEG, PNG or HEIC data), or `nil`. Only messages of the user carry one.
    var imageData: Data? { get }
}

public extension ChatMessageProtocol {
    var imageData: Data? { nil }
}

/// Public data the app must provide to get a reply from the Chat repository.
public protocol ChatRequestProtocol: Sendable {
    /// Model that answers. The persona is the same for every provider.
    var provider: ChatProvider { get }
    /// Whole conversation, oldest first. The last message is the question of the user: text, an image or both.
    var messages: [any ChatMessageProtocol] { get }
}
