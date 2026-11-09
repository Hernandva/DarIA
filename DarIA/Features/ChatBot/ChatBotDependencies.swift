import Foundation

/// Dependency injection container of ChatBot: the only place where its concrete types are built.
@MainActor
final class ChatBotDependencies {
    init() {}

    func makeUseCase() -> any ChatBotUseCaseProtocol {
        ChatBotUseCase()
    }

    func makeViewModel() -> ChatBotViewModel {
        ChatBotViewModel(useCase: makeUseCase())
    }
}
