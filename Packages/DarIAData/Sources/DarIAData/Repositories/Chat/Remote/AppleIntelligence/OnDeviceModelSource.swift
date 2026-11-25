import Foundation
import FoundationModels

/// On-device model of Apple Intelligence. It works offline, but its context window is small.
struct OnDeviceModelSource: AppleChatModelSource {
    let historyLimit = 12

    func availableModel() throws -> SystemLanguageModel {
        let model = SystemLanguageModel.default
        if case .unavailable(let reason) = model.availability {
            throw ChatRepositoryError.providerUnavailable(Self.unavailableReason(from: reason))
        }
        return model
    }

    func repositoryError(from error: any Error) -> ChatRepositoryError? {
        error is SystemLanguageModel.Error ? .providerUnavailable(.modelNotReady) : nil
    }
}

private extension OnDeviceModelSource {
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
}
