import DarIAData
import Foundation

/// Dependency injection container of Chat: the only place where its concrete types are built.
/// View, ViewModel and UseCase receive it in their `init(dependencies:)` and call the `resolve` functions they need.
@MainActor
final class ChatDependencies {
    private let repository: any ChatRepositoryProtocol

    init(repository: any ChatRepositoryProtocol = ChatRepository()) {
        self.repository = repository
    }

    func resolveRepository() -> any ChatRepositoryProtocol {
        repository
    }

    func resolveUseCase() -> any ChatUseCaseProtocol {
        ChatUseCase(dependencies: self)
    }

    func resolveViewModel() -> ChatViewModel {
        ChatViewModel(dependencies: self)
    }
}
