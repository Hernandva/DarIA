#if canImport(FoundationModels)
import Foundation
import FoundationModels

/// Answers with the on-device model of Apple Intelligence (Foundation Models framework).
/// Each call builds a new session from the conversation, so the service keeps no state between calls.
@available(iOS 26.0, macOS 26.0, *)
struct AppleIntelligenceChatService: ChatProviderService {
    func send(_ request: ChatRequestDAO) async throws -> ChatResponseDAO {
        let model = SystemLanguageModel.default
        if case .unavailable(let reason) = model.availability {
            throw ChatRepositoryError.providerUnavailable(Self.unavailableReason(from: reason))
        }
        let session = LanguageModelSession(model: model, transcript: Self.transcript(for: request))
        do {
            let response = try await session.respond(to: request.question)
            return ChatResponseDAO(modelText: response.content)
        } catch {
            throw Self.repositoryError(from: error)
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
private extension AppleIntelligenceChatService {
    /// The on-device model has a small context window, so only the latest messages are sent.
    static let historyLimit = 12

    static func transcript(for request: ChatRequestDAO) -> Transcript {
        let instructions = Transcript.Instructions(segments: [segment(ChatPersona.instructions)], toolDefinitions: [])
        let history: [Transcript.Entry] = request.history.suffix(historyLimit).map { message in
            switch message.role {
            case .user: .prompt(Transcript.Prompt(segments: [segment(message.text)]))
            case .assistant: .response(Transcript.Response(assetIDs: [], segments: [segment(message.text)]))
            }
        }
        return Transcript(entries: [.instructions(instructions)] + history)
    }

    static func segment(_ text: String) -> Transcript.Segment {
        .text(Transcript.TextSegment(content: text))
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
        if #available(iOS 27.0, macOS 27.0, *), let modelError = error as? LanguageModelError {
            return repositoryError(from: modelError) ?? error
        }
        if let generationError = error as? LanguageModelSession.GenerationError {
            return repositoryError(from: generationError) ?? error
        }
        return error
    }

    static func repositoryError(from error: LanguageModelSession.GenerationError) -> ChatRepositoryError? {
        switch error {
        case .exceededContextWindowSize: .conversationTooLong
        case .guardrailViolation, .refusal: .contentRejected
        case .unsupportedLanguageOrLocale: .unsupportedLanguage
        case .assetsUnavailable: .providerUnavailable(.modelNotReady)
        default: nil
        }
    }

    @available(iOS 27.0, macOS 27.0, *)
    static func repositoryError(from error: LanguageModelError) -> ChatRepositoryError? {
        switch error {
        case .contextSizeExceeded: .conversationTooLong
        case .guardrailViolation, .refusal: .contentRejected
        case .unsupportedLanguageOrLocale: .unsupportedLanguage
        default: nil
        }
    }
}
#endif
