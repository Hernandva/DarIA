import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: State = .idle
    /// Data of the screen. Each use case result updates only its own field.
    private(set) var viewData = ChatViewData()
    /// Text being written in the composer.
    var draft = ""
    /// True while the assistant is answering the last message.
    private(set) var isReplying = false
    /// Request of the reply in progress. Starting a new chat cancels it.
    private(set) var replyTask: Task<Void, Never>?

    private let useCase: any ChatUseCaseProtocol

    /// Receives only the container and resolves what it needs from it.
    init(dependencies: ChatDependencies) {
        self.useCase = dependencies.resolveUseCase()
    }

    var messages: [ChatViewData.Message] {
        viewData.conversation?.messages ?? []
    }

    var connection: ChatViewData.Connection? {
        viewData.conversation?.connection
    }

    var startedAt: Date {
        viewData.conversation?.startedAt ?? Date()
    }

    var canSend: Bool {
        !isReplying && connection != nil
    }

    /// The last message of the user, which shows the delivery status under it.
    var lastUserMessageID: UUID? {
        messages.last { $0.sender == .user }?.id
    }

    func load() async {
        state = .loading
        do {
            viewData.conversation = try await useCase.execute()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Adds the draft to the conversation and asks the model for a reply.
    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard canSend, !text.isEmpty, let connection else { return }
        let message = ChatViewData.Message(id: UUID(), sender: .user, text: text, isDelivered: false)
        viewData.conversation?.messages.append(message)
        draft = ""
        isReplying = true
        let conversation = messages
        replyTask = Task { await self.requestReply(to: conversation, messageID: message.id, connection: connection) }
    }

    func startNewChat() {
        replyTask?.cancel()
        replyTask = nil
        isReplying = false
        viewData.conversation?.messages.removeAll()
        viewData.conversation?.startedAt = Date()
        draft = ""
    }

    /// Whether the message starts a new group of the same sender, which is separated from the one before.
    /// The conversation always opens with the greeting of the assistant.
    func startsGroup(_ message: ChatViewData.Message) -> Bool {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return false }
        let previousSender = index > 0 ? messages[index - 1].sender : .assistant
        return previousSender != message.sender
    }
}

private extension ChatViewModel {
    func requestReply(
        to conversation: [ChatViewData.Message],
        messageID: UUID,
        connection: ChatViewData.Connection
    ) async {
        let reply: ChatViewData.Message
        do {
            reply = try await useCase.reply(to: conversation, connection: connection)
        } catch {
            let failure = error as? ChatViewData.ReplyFailure ?? .unknown
            reply = ChatViewData.Message(id: UUID(), sender: .assistant, text: "", isDelivered: true, failure: failure)
        }
        // A new chat started while waiting: the reply belongs to the old conversation.
        guard !Task.isCancelled else { return }
        if reply.failure == nil {
            markDelivered(messageID)
        }
        viewData.conversation?.messages.append(reply)
        isReplying = false
        replyTask = nil
    }

    func markDelivered(_ messageID: UUID) {
        guard let index = viewData.conversation?.messages.firstIndex(where: { $0.id == messageID }) else { return }
        viewData.conversation?.messages[index].isDelivered = true
    }
}
