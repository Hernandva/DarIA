import CoreGraphics
import Foundation
import FoundationModels
import ImageIO

/// Answers with the on-device model of Apple Intelligence (Foundation Models framework), including questions
/// about images when the model can read them. Each call builds a new session from the conversation, so the
/// service keeps no state between calls.
struct AppleIntelligenceChatService: ChatProviderService {
    func send(_ request: ChatRequestDAO) async throws -> ChatResponseDAO {
        let model = SystemLanguageModel.default
        if case .unavailable(let reason) = model.availability {
            throw ChatRepositoryError.providerUnavailable(Self.unavailableReason(from: reason))
        }
        if request.hasImages, !model.capabilities.contains(.vision) {
            throw ChatRepositoryError.imagesNotSupported
        }
        let session = LanguageModelSession(model: model, transcript: Self.transcript(for: request))
        do {
            let response = try await session.respond(to: Self.prompt(for: request.question))
            return ChatResponseDAO(modelText: response.content)
        } catch {
            throw Self.repositoryError(from: error)
        }
    }
}

private extension AppleIntelligenceChatService {
    /// The on-device model has a small context window, so only the latest messages are sent.
    static let historyLimit = 12
    /// Longest side of the images sent to the model, in pixels.
    static let maxImageSide = 1024
    /// Takes the place of an older image, so the model knows there was one. Only the latest image is sent.
    static let omittedImageNote = "[The user attached an image here.]"

    static func transcript(for request: ChatRequestDAO) -> Transcript {
        let instructions = Transcript.Instructions(segments: [.text(.init(content: ChatPersona.instructions))],
                                                   toolDefinitions: [])
        let history = Array(request.history.suffix(historyLimit))
        // When the question has no image, the latest image of the history is the one the user is talking about.
        let imageIndex = request.question.imageData == nil ? history.lastIndex { $0.imageData != nil } : nil
        let entries: [Transcript.Entry] = history.enumerated().map { index, message in
            let segments = segments(for: message, includesImage: index == imageIndex)
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

    static func unavailableReason(
        from reason: SystemLanguageModel.Availability.UnavailableReason
    ) -> ChatUnavailableReason {
        switch reason {
        case .deviceNotEligible: .deviceNotEligible
        case .appleIntelligenceNotEnabled: .notEnabled
        case .modelNotReady: .modelNotReady
        @unknown default: .modelNotReady
        }
    }

    /// Maps the errors of the framework to `ChatRepositoryError`. Unknown errors are passed on as they are.
    static func repositoryError(from error: any Error) -> any Error {
        switch error {
        case let modelError as LanguageModelError:
            repositoryError(from: modelError) ?? error
        case is SystemLanguageModel.Error:
            ChatRepositoryError.providerUnavailable(.modelNotReady)
        default:
            error
        }
    }

    static func repositoryError(from error: LanguageModelError) -> ChatRepositoryError? {
        switch error {
        case .contextSizeExceeded: .conversationTooLong
        case .guardrailViolation, .refusal: .contentRejected
        case .unsupportedLanguageOrLocale: .unsupportedLanguage
        case .unsupportedCapability: .imagesNotSupported
        default: nil
        }
    }
}
