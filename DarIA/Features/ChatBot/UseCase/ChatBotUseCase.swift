import Foundation

protocol ChatBotUseCaseProtocol: Sendable {
    func execute() async throws -> ChatBotViewData
}

/// Business logic of ChatBot.
/// When the feature needs remote data, inject a repository from Networking through
/// ChatBotDependencies and map its public response protocol into ChatBotViewData.
struct ChatBotUseCase: ChatBotUseCaseProtocol {
    func execute() async throws -> ChatBotViewData {
        ChatBotViewData()
    }
}
