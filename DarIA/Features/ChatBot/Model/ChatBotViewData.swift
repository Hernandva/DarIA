import Foundation

/// Display-ready data of ChatBot: the opening conversation and the available connections.
struct ChatBotViewData: Equatable, Sendable {
    let messages: [ChatMessageViewData]
    let connections: [ConnectionViewData]
}

/// One message of the conversation, ready to show.
struct ChatMessageViewData: Identifiable, Equatable, Sendable {
    enum Sender: Sendable {
        case assistant
        case user
    }

    let id: UUID
    let text: String
    let sender: Sender

    init(id: UUID = UUID(), text: String, sender: Sender) {
        self.id = id
        self.text = text
        self.sender = sender
    }
}

/// A model DarIA can talk through: a cloud provider or a machine on the local network.
struct ConnectionViewData: Identifiable, Equatable, Sendable {
    enum Group: CaseIterable, Sendable {
        case cloud
        case local
    }

    enum Provider: Sendable {
        case claude
        case openAI
        case gemini
        case local
    }

    let id: String
    let name: String
    let detail: String
    let group: Group
    let provider: Provider

    /// Letter shown in the identity badge.
    var initial: String {
        String(name.prefix(1)).uppercased()
    }
}
