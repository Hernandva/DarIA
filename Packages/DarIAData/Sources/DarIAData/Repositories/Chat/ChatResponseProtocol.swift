import Foundation

/// Public data the Chat repository returns to the app: the reply of the model.
public protocol ChatResponseProtocol: Sendable {
    var text: String { get }
}
