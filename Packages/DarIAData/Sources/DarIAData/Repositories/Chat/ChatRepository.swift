import Foundation

/// Public API of the Chat repository. Features depend on this protocol, never on the concrete class.
public protocol ChatRepositoryProtocol: Sendable {
    /// Returns the reply of `request.provider` to the last message of the conversation.
    /// Throws `ChatRepositoryError` when the provider is unknown, unavailable or cannot answer.
    func send(_ request: some ChatRequestProtocol) async throws -> any ChatResponseProtocol
}

/// Gets replies from language models. It holds no model code: it forwards each request to the service of its
/// provider, in `Remote/<Provider>/`, and every service answers with the same persona (`ChatPersona`).
/// Flow: ChatRequestProtocol -> ChatRequestDAO -> provider service -> ChatResponseDAO -> ChatResponseProtocol.
public final class ChatRepository: ChatRepositoryProtocol {
    private let services: [ChatProvider.Kind: any ChatProviderService]

    /// Registers the service of every provider available on this platform.
    public convenience init() {
        self.init(services: Self.defaultServices)
    }

    /// Lets tests inject their own services.
    init(services: [ChatProvider.Kind: any ChatProviderService]) {
        self.services = services
    }

    public func send(_ request: some ChatRequestProtocol) async throws -> any ChatResponseProtocol {
        let requestDAO = try ChatRequestDAO(request)
        guard let service = services[requestDAO.provider.kind] else {
            throw ChatRepositoryError.unsupportedProvider(requestDAO.provider)
        }
        return try await service.send(requestDAO)
    }
}

private extension ChatRepository {
    /// Add here the service of each new provider.
    static var defaultServices: [ChatProvider.Kind: any ChatProviderService] {
        [.appleIntelligence: AppleIntelligenceChatService()]
    }
}
