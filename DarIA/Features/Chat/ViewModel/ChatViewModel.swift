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

    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let message = ChatViewData.Message(id: UUID(), sender: .user, text: text, isDelivered: true)
        viewData.conversation?.messages.append(message)
        draft = ""
    }

    func startNewChat() {
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
