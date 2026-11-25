import Foundation

/// Request in the shape every provider service reads: the earlier messages and the question.
/// Internal to DarIAData: never exposed to the app.
struct ChatRequestDAO: Equatable, Sendable {
    struct Message: Equatable, Sendable {
        let role: ChatRole
        let text: String
    }

    let provider: ChatProvider
    /// Messages before the question, oldest first.
    let history: [Message]
    /// Last message of the user, the one to answer.
    let question: String

    /// Throws `ChatRepositoryError.missingQuestion` when the last message is not a non-empty message of the user.
    init(_ request: some ChatRequestProtocol) throws {
        let messages = request.messages
            .map { Message(role: $0.role, text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .filter { !$0.text.isEmpty }
        guard let last = messages.last, last.role == .user else { throw ChatRepositoryError.missingQuestion }
        self.provider = request.provider
        self.history = Array(messages.dropLast())
        self.question = last.text
    }
}
