import Foundation

/// Request in the shape every provider service reads: the earlier messages and the question.
/// Internal to DarIAData: never exposed to the app.
struct ChatRequestDAO: Equatable, Sendable {
    struct Message: Equatable, Sendable {
        let role: ChatRole
        let text: String
        let imageData: Data?

        init(role: ChatRole, text: String, imageData: Data? = nil) {
            self.role = role
            self.text = text
            self.imageData = imageData
        }
    }

    let provider: ChatProvider
    /// Messages before the question, oldest first.
    let history: [Message]
    /// Last message of the user, the one to answer. It has text, an image or both.
    let question: Message

    /// Whether any message of the conversation carries an image.
    var hasImages: Bool {
        question.imageData != nil || history.contains { $0.imageData != nil }
    }

    /// Throws `ChatRepositoryError.missingQuestion` when the last message is not a message of the user
    /// with text or an image.
    init(_ request: some ChatRequestProtocol) throws {
        let messages = request.messages
            .map {
                Message(
                    role: $0.role,
                    text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines),
                    imageData: $0.imageData
                )
            }
            .filter { !$0.text.isEmpty || $0.imageData != nil }
        guard let last = messages.last, last.role == .user else { throw ChatRepositoryError.missingQuestion }
        self.provider = request.provider
        self.history = Array(messages.dropLast())
        self.question = last
    }
}
