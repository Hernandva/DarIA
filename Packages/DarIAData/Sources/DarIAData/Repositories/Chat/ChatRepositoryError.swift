import Foundation

/// Why a provider cannot answer right now.
public enum ChatUnavailableReason: Equatable, Sendable {
    /// The device cannot run the model.
    case deviceNotEligible
    /// The model is turned off in the settings of the device (e.g. Apple Intelligence).
    case notEnabled
    /// The model is still downloading or getting ready.
    case modelNotReady
}

public enum ChatRepositoryError: Error, Equatable, Sendable {
    /// No service is registered for the provider.
    case unsupportedProvider(ChatProvider)
    /// The provider exists but cannot answer on this device right now.
    case providerUnavailable(ChatUnavailableReason)
    /// The request has no question: its last message is not a message of the user with text or an image.
    case missingQuestion
    /// The conversation has an image, but the model of the provider cannot read images.
    case imagesNotSupported
    /// The model refused the question or its answer, for safety reasons.
    case contentRejected
    /// The conversation no longer fits in the context of the model.
    case conversationTooLong
    /// The model does not support the language of the conversation.
    case unsupportedLanguage
}
