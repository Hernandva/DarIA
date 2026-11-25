import DarIAData
import Foundation

protocol ChatUseCaseProtocol: Sendable {
    /// Returns a new, empty conversation with the default provider.
    func execute() async throws -> ChatViewData.Conversation
    /// Returns the reply of the connection to the last message of `messages`.
    /// Throws `ChatViewData.ReplyFailure` when the model cannot answer.
    func reply(
        to messages: [ChatViewData.Message],
        connection: ChatViewData.Connection
    ) async throws -> ChatViewData.Message
}

/// Request sent to the Chat repository.
struct ChatRequest: ChatRequestProtocol {
    let provider: ChatProvider
    let messages: [any ChatMessageProtocol]
}

/// One message of `ChatRequest`.
struct ChatRequestMessage: ChatMessageProtocol {
    let role: ChatRole
    let text: String
}

/// Business logic of Chat: talks to the Chat repository through its public API. The screen never knows which
/// model answers: it only holds the connection, and this use case turns it into the provider of the request.
struct ChatUseCase: ChatUseCaseProtocol {
    private let repository: any ChatRepositoryProtocol

    /// Receives only the container and resolves what it needs from it.
    /// `ChatDependencies` lives on the main actor, so this init does too.
    @MainActor
    init(dependencies: ChatDependencies) {
        self.repository = dependencies.resolveRepository()
    }

    func execute() async throws -> ChatViewData.Conversation {
        ChatViewData.Conversation(
            connection: Self.connection(for: Self.defaultProvider),
            startedAt: Date(),
            messages: []
        )
    }

    func reply(
        to messages: [ChatViewData.Message],
        connection: ChatViewData.Connection
    ) async throws -> ChatViewData.Message {
        guard let kind = ChatProvider.Kind(rawValue: connection.providerID) else {
            throw ChatViewData.ReplyFailure.unknown
        }
        let request = ChatRequest(provider: ChatProvider(kind: kind), messages: Self.requestMessages(from: messages))
        do {
            let response = try await repository.send(request)
            return ChatViewData.Message(id: UUID(), sender: .assistant, text: response.text, isDelivered: true)
        } catch let error as ChatRepositoryError {
            throw Self.failure(from: error)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw ChatViewData.ReplyFailure.unknown
        }
    }
}

private extension ChatUseCase {
    /// Provider used when the app opens, until the providers screen lets the user choose another one.
    static let defaultProvider = ChatProvider.appleIntelligence

    static func connection(for provider: ChatProvider) -> ChatViewData.Connection {
        switch provider.kind {
        case .appleIntelligence:
            ChatViewData.Connection(providerID: provider.kind.rawValue, name: "Apple Intelligence", kind: .device)
        }
    }

    /// Text messages of the conversation, without failures or attachments without text.
    static func requestMessages(from messages: [ChatViewData.Message]) -> [any ChatMessageProtocol] {
        messages
            .filter { $0.failure == nil && !$0.text.isEmpty }
            .map { ChatRequestMessage(role: $0.sender == .user ? .user : .assistant, text: $0.text) }
    }

    static func failure(from error: ChatRepositoryError) -> ChatViewData.ReplyFailure {
        switch error {
        case .providerUnavailable(.deviceNotEligible): .deviceNotEligible
        case .providerUnavailable(.notEnabled): .modelDisabled
        case .providerUnavailable(.modelNotReady): .modelNotReady
        case .contentRejected: .contentRejected
        case .conversationTooLong: .conversationTooLong
        case .unsupportedLanguage: .unsupportedLanguage
        case .unsupportedProvider, .missingQuestion: .unknown
        }
    }
}
