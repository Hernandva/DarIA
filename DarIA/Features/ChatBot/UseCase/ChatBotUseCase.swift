import Foundation

protocol ChatBotUseCaseProtocol: Sendable {
    /// Opening state of the chat: the greeting and the connections the user can pick.
    func execute() async throws -> ChatBotViewData

    /// Sends a message through a connection and returns DarIA's answer.
    func reply(to message: String, connectionID: String) async throws -> String
}

/// Business logic of ChatBot.
/// The connections are placeholders until the provider repositories exist (`daria-new-repo`):
/// inject them through ChatBotDependencies and route `reply` to the selected one.
struct ChatBotUseCase: ChatBotUseCaseProtocol {
    func execute() async throws -> ChatBotViewData {
        ChatBotViewData(
            messages: [
                ChatMessageViewData(text: String(localized: "chatBot.greeting"), sender: .assistant)
            ],
            connections: Self.defaultConnections
        )
    }

    func reply(to message: String, connectionID: String) async throws -> String {
        String(localized: "chatBot.reply.notConnected")
    }

    private static var defaultConnections: [ConnectionViewData] {
        let notConfigured = String(localized: "chatBot.connection.notConfigured")
        return [
            ConnectionViewData(id: "claude", name: "Claude", detail: notConfigured, group: .cloud, provider: .claude),
            ConnectionViewData(id: "openai", name: "OpenAI", detail: notConfigured, group: .cloud, provider: .openAI),
            ConnectionViewData(id: "gemini", name: "Gemini", detail: notConfigured, group: .cloud, provider: .gemini),
            ConnectionViewData(id: "mac-mini", name: "Mac mini", detail: notConfigured, group: .local, provider: .local)
        ]
    }
}
