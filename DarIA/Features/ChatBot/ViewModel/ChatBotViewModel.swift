import Foundation
import Observation

@MainActor
@Observable
final class ChatBotViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: State = .idle
    private(set) var messages: [ChatMessageViewData] = []
    private(set) var connections: [ConnectionViewData] = []
    private(set) var selectedConnectionID: String?
    private(set) var isSending = false
    private(set) var isMenuOpen = false
    private(set) var isSelectorOpen = false
    var draft = ""

    private var openingMessages: [ChatMessageViewData] = []
    private let useCase: any ChatBotUseCaseProtocol

    init(useCase: any ChatBotUseCaseProtocol) {
        self.useCase = useCase
    }

    var selectedConnection: ConnectionViewData? {
        connections.first { $0.id == selectedConnectionID }
    }

    var canSend: Bool {
        !trimmedDraft.isEmpty && !isSending && selectedConnection != nil
    }

    /// Identifier of the last message sent by the user, which shows the "delivered" mark.
    var lastUserMessageID: UUID? {
        messages.last { $0.sender == .user }?.id
    }

    func connections(in group: ConnectionViewData.Group) -> [ConnectionViewData] {
        connections.filter { $0.group == group }
    }

    func load() async {
        guard state == .idle else { return }
        state = .loading
        do {
            let data = try await useCase.execute()
            openingMessages = data.messages
            messages = data.messages
            connections = data.connections
            selectedConnectionID = data.connections.first?.id
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func toggleMenu() {
        isSelectorOpen = false
        isMenuOpen.toggle()
    }

    func toggleSelector() {
        isMenuOpen = false
        isSelectorOpen.toggle()
    }

    func closeOverlays() {
        isMenuOpen = false
        isSelectorOpen = false
    }

    func selectConnection(_ connectionID: String) {
        selectedConnectionID = connectionID
        closeOverlays()
    }

    func startNewChat() {
        closeOverlays()
        draft = ""
        messages = openingMessages
    }

    func send() async {
        guard canSend, let connection = selectedConnection else { return }
        let text = trimmedDraft
        draft = ""
        messages.append(ChatMessageViewData(text: text, sender: .user))
        isSending = true
        defer { isSending = false }
        do {
            let answer = try await useCase.reply(to: text, connectionID: connection.id)
            messages.append(ChatMessageViewData(text: answer, sender: .assistant))
        } catch {
            messages.append(ChatMessageViewData(text: error.localizedDescription, sender: .assistant))
        }
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
