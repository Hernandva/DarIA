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

    /// Registers the service of every provider.
    public convenience init() {
        self.init(services: Self.defaultServices)
    }

    /// Lets tests inject their own services.
    init(services: [ChatProvider.Kind: any ChatProviderService]) {
        self.services = services
    }

    public func send(_ request: some ChatRequestProtocol) async throws -> any ChatResponseProtocol {
        let start = ContinuousClock.now
        let provider = request.provider.kind.rawValue
        do {
            let requestDAO = try ChatRequestDAO(request)
            guard let service = services[requestDAO.provider.kind] else {
                throw ChatRepositoryError.unsupportedProvider(requestDAO.provider)
            }
            let response = try await service.send(requestDAO)
            Self.log.success("\(provider) replied in \(Self.elapsed(since: start)) · \(Self.summary(of: requestDAO))"
                + " · reply of \(response.text.count) characters")
            return response
        } catch {
            Self.log.failure("\(provider) failed after \(Self.elapsed(since: start))"
                + " · \(request.messages.count) messages", error: error)
            throw error
        }
    }
}

private extension ChatRepository {
    static let log = DataLogger(category: "chat")

    static func elapsed(since start: ContinuousClock.Instant) -> String {
        let duration = start.duration(to: .now)
        return duration.formatted(.units(allowed: [.seconds, .milliseconds], width: .narrow))
    }

    /// What was sent, without its content: the user's words never reach the log.
    static func summary(of request: ChatRequestDAO) -> String {
        "\(request.history.count + 1) messages" + (request.hasImages ? " with image" : "")
    }
}

extension ChatRepository {
    /// Add here the service of each new provider. Internal so tests can check every provider has one.
    static var defaultServices: [ChatProvider.Kind: any ChatProviderService] {
        [.appleIntelligence: AppleChatService(source: OnDeviceModelSource())]
    }
}
