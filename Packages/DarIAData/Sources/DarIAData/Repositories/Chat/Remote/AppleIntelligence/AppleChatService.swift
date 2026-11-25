import CoreGraphics
import Foundation
import FoundationModels
import ImageIO

/// What changes between Apple models: which model to use, how much history it takes and how its own errors map
/// to `ChatRepositoryError`. Today there is one, the on-device model (`OnDeviceModelSource`).
protocol AppleChatModelSource: Sendable {
    associatedtype Model: LanguageModel

    /// Number of earlier messages sent with each question.
    var historyLimit: Int { get }

    /// Returns the model, or throws `ChatRepositoryError.providerUnavailable` when it cannot answer now.
    func availableModel() throws -> Model

    /// Maps an error only this model throws, or returns `nil` to let the common mapping handle it.
    func repositoryError(from error: any Error) -> ChatRepositoryError?
}

/// Answers with an Apple model through the Foundation Models framework, including questions about images when
/// the model can read them. Each call builds a new session from the conversation, so it keeps no state.
struct AppleChatService<Source: AppleChatModelSource>: ChatProviderService {
    let source: Source

    func send(_ request: ChatRequestDAO) async throws -> ChatResponseDAO {
        let model = try source.availableModel()
        if request.hasImages, !model.capabilities.contains(.vision) {
            throw ChatRepositoryError.imagesNotSupported
        }
        let session = LanguageModelSession(model: model, transcript: transcript(for: request))
        do {
            let response = try await session.respond(to: Self.prompt(for: request.question))
            return ChatResponseDAO(modelText: response.content)
        } catch {
            throw source.repositoryError(from: error) ?? Self.repositoryError(from: error) ?? error
        }
    }
}

private extension AppleChatService {
    /// Longest side of the images sent to the model, in pixels.
    static var maxImageSide: Int { 1024 }
    /// Takes the place of an older image, so the model knows there was one. Only the latest image is sent.
    static var omittedImageNote: String { "[The user attached an image here.]" }

    func transcript(for request: ChatRequestDAO) -> Transcript {
        let instructions = Transcript.Instructions(segments: [.text(.init(content: ChatPersona.instructions))],
                                                   toolDefinitions: [])
        let history = Array(request.history.suffix(source.historyLimit))
        // When the question has no image, the latest image of the history is the one the user is talking about.
        let imageIndex = request.question.imageData == nil ? history.lastIndex { $0.imageData != nil } : nil
        let entries: [Transcript.Entry] = history.enumerated().map { index, message in
            let segments = Self.segments(for: message, includesImage: index == imageIndex)
            return switch message.role {
            case .user: .prompt(Transcript.Prompt(segments: segments))
            case .assistant: .response(Transcript.Response(assetIDs: [], segments: segments))
            }
        }
        return Transcript(entries: [.instructions(instructions)] + entries)
    }

    static func segments(for message: ChatRequestDAO.Message, includesImage: Bool) -> [Transcript.Segment] {
        var segments: [Transcript.Segment] = []
        if let imageData = message.imageData {
            if includesImage, let image = cgImage(from: imageData) {
                segments.append(.attachment(.init(content: .image(.init(image)))))
            } else {
                segments.append(.text(.init(content: omittedImageNote)))
            }
        }
        if !message.text.isEmpty {
            segments.append(.text(.init(content: message.text)))
        }
        return segments
    }

    static func prompt(for question: ChatRequestDAO.Message) -> Prompt {
        Prompt {
            if let imageData = question.imageData, let image = cgImage(from: imageData) {
                Attachment(image)
                question.text.isEmpty ? ChatPersona.imageOnlyPrompt : question.text
            } else {
                question.text
            }
        }
    }

    /// Decodes the image already scaled down, which is faster and uses less memory than decoding it whole.
    static func cgImage(from data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxImageSide
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    /// Errors every Apple model can throw.
    static func repositoryError(from error: any Error) -> ChatRepositoryError? {
        guard let modelError = error as? LanguageModelError else { return nil }
        return switch modelError {
        case .contextSizeExceeded: .conversationTooLong
        case .guardrailViolation, .refusal: .contentRejected
        case .unsupportedLanguageOrLocale: .unsupportedLanguage
        case .unsupportedCapability: .imagesNotSupported
        default: nil
        }
    }
}
