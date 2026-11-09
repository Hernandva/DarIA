import Foundation
import Observation

@MainActor
@Observable
final class ChatBotViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(ChatBotViewData)
        case failed(String)
    }

    private(set) var state: State = .idle

    private let useCase: any ChatBotUseCaseProtocol

    init(useCase: any ChatBotUseCaseProtocol) {
        self.useCase = useCase
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await useCase.execute())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
