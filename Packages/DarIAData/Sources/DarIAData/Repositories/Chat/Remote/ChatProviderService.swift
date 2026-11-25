import Foundation

/// Service of one provider. `ChatRepository` registers one per `ChatProvider.Kind` and forwards each request to it.
/// Every service sends `ChatPersona.instructions` to its model, so all of them answer with the same personality.
protocol ChatProviderService: Sendable {
    func send(_ request: ChatRequestDAO) async throws -> ChatResponseDAO
}
