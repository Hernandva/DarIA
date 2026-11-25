import DarIAData
import Foundation
import ImageIO
import UniformTypeIdentifiers

protocol ChatUseCaseProtocol: Sendable {
    /// Returns a new, empty conversation with the default provider.
    func execute() async throws -> ChatViewData.Conversation
    /// Returns the reply of the connection to the last message of `messages`.
    /// Throws `ChatViewData.ReplyFailure` when the model cannot answer.
    func reply(
        to messages: [ChatViewData.Message],
        connection: ChatViewData.Connection
    ) async throws -> ChatViewData.Message
    /// Turns a picked image into the scaled-down JPEG the chat shows and sends.
    /// Throws `ChatViewData.ReplyFailure.imageUnreadable` when the data is not an image.
    func prepareImage(_ data: Data) async throws -> Data
}

/// Request sent to the Chat repository.
struct ChatRequest: ChatRequestProtocol {
    let provider: ChatProvider
    let messages: [any ChatMessageProtocol]
}

/// One message of `ChatRequest`.
struct ChatRequestMessage: ChatMessageProtocol {
    let role: ChatRole
    let text: String
    let imageData: Data?
}

/// Business logic of Chat: talks to the Chat repository through its public API. The screen never knows which
/// model answers: it only holds the connection, and this use case turns it into the provider of the request.
struct ChatUseCase: ChatUseCaseProtocol {
    private let repository: any ChatRepositoryProtocol

    /// Receives only the container and resolves what it needs from it.
    /// `ChatDependencies` lives on the main actor, so this init does too.
    @MainActor
    init(dependencies: ChatDependencies) {
        self.repository = dependencies.resolveRepository()
    }

    func execute() async throws -> ChatViewData.Conversation {
        ChatViewData.Conversation(
            connection: Self.connection(for: Self.defaultProvider),
            startedAt: Date(),
            messages: []
        )
    }

    func reply(
        to messages: [ChatViewData.Message],
        connection: ChatViewData.Connection
    ) async throws -> ChatViewData.Message {
        guard let kind = ChatProvider.Kind(rawValue: connection.providerID) else {
            throw ChatViewData.ReplyFailure.unknown
        }
        let request = ChatRequest(provider: ChatProvider(kind: kind), messages: Self.requestMessages(from: messages))
        do {
            let response = try await repository.send(request)
            return ChatViewData.Message(id: UUID(), sender: .assistant, text: response.text, isDelivered: true)
        } catch let error as ChatRepositoryError {
            throw Self.failure(from: error)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw ChatViewData.ReplyFailure.unknown
        }
    }

    func prepareImage(_ data: Data) async throws -> Data {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, Self.thumbnailOptions as CFDictionary),
              let jpeg = Self.jpegData(from: image) else {
            throw ChatViewData.ReplyFailure.imageUnreadable
        }
        return jpeg
    }
}

private extension ChatUseCase {
    /// Provider used when the app opens, until the providers screen lets the user choose another one.
    static let defaultProvider = ChatProvider.appleIntelligence
    /// Longest side of the images kept in the conversation, in pixels.
    static let maxImageSide = 1024
    static let jpegQuality = 0.8

    static var thumbnailOptions: [CFString: Any] {
        [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxImageSide
        ]
    }

    static func jpegData(from image: CGImage) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)
        else { return nil }
        let options = [kCGImageDestinationLossyCompressionQuality: jpegQuality] as CFDictionary
        CGImageDestinationAddImage(destination, image, options)
        return CGImageDestinationFinalize(destination) ? data as Data : nil
    }

    static func connection(for provider: ChatProvider) -> ChatViewData.Connection {
        switch provider.kind {
        case .appleIntelligence:
            ChatViewData.Connection(providerID: provider.kind.rawValue, name: "Apple Intelligence", kind: .device)
        }
    }

    /// Messages of the conversation with text or an image, without failures.
    static func requestMessages(from messages: [ChatViewData.Message]) -> [any ChatMessageProtocol] {
        messages
            .filter { $0.failure == nil && (!$0.text.isEmpty || $0.imageData != nil) }
            .map {
                ChatRequestMessage(
                    role: $0.sender == .user ? .user : .assistant,
                    text: $0.text,
                    imageData: $0.imageData
                )
            }
    }

    static func failure(from error: ChatRepositoryError) -> ChatViewData.ReplyFailure {
        switch error {
        case .providerUnavailable(.deviceNotEligible): .deviceNotEligible
        case .providerUnavailable(.notEnabled): .modelDisabled
        case .providerUnavailable(.modelNotReady): .modelNotReady
        case .contentRejected: .contentRejected
        case .conversationTooLong: .conversationTooLong
        case .unsupportedLanguage: .unsupportedLanguage
        case .imagesNotSupported: .imagesNotSupported
        case .unsupportedProvider, .missingQuestion: .unknown
        }
    }
}
