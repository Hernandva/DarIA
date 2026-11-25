import Foundation
import OSLog

/// Logs of the data layer, shown in the Xcode console and in Console.app under the app's subsystem.
/// They exist only in Debug builds: in Release every call compiles to nothing.
/// Never log what the user wrote or private data: only what helps to follow a request.
struct DataLogger: Sendable {
    #if DEBUG
    private let logger: Logger
    #endif

    /// - Parameter category: Name of the repository, e.g. "chat". It lets Console.app filter its logs.
    init(category: String) {
        #if DEBUG
        logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DarIAData", category: category)
        #endif
    }

    /// A request that ended well.
    func success(_ message: @autoclosure () -> String) {
        #if DEBUG
        let text = message()
        logger.info("✓ \(text, privacy: .public)")
        #endif
    }

    /// A request that failed, with the error it threw.
    func failure(_ message: @autoclosure () -> String, error: any Error) {
        #if DEBUG
        let text = message()
        logger.error("✗ \(text, privacy: .public): \(String(describing: error), privacy: .public)")
        #endif
    }
}
