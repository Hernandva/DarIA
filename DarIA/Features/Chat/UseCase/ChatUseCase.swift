import Foundation

protocol ChatUseCaseProtocol: Sendable {
    /// Returns only the data of the response. The view model adds it to its `ChatViewData`.
    func execute() async throws -> ChatViewData.Content
}

/// Business logic of Chat.
/// When the feature needs a DarIAData repository, add a `resolve<Name>()` function to ChatDependencies,
/// resolve it in `init(dependencies:)` and map its public response protocol into the type this use case returns.
struct ChatUseCase: ChatUseCaseProtocol {
    /// Receives only the container and resolves what it needs from it.
    /// `ChatDependencies` lives on the main actor, so this init does too.
    @MainActor
    init(dependencies: ChatDependencies) {}

    func execute() async throws -> ChatViewData.Content {
        ChatViewData.Content()
    }
}
