import Foundation

/// Reply of a provider service. Internal to DarIAData: the app only sees ChatResponseProtocol.
struct ChatResponseDAO: Equatable, Sendable, ChatResponseProtocol {
    let text: String

    init(text: String) {
        self.text = text
    }

    /// Reply as the model wrote it. Some models break the line after every sentence even when told not to,
    /// so single line breaks become spaces. Blank lines (paragraphs) and list items are kept.
    init(modelText: String) {
        self.text = Self.joiningLineBreaks(in: modelText)
    }
}

extension ChatResponseDAO {
    static func joiningLineBreaks(in text: String) -> String {
        let lines = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        var result = ""
        for line in lines {
            if result.isEmpty {
                result = line
            } else if line.isEmpty || isListItem(line) || result.hasSuffix("\n") {
                result += "\n" + line
            } else {
                result += " " + line
            }
        }
        return result
    }
}

private extension ChatResponseDAO {
    static func isListItem(_ line: String) -> Bool {
        ["- ", "• ", "* "].contains { line.hasPrefix($0) } || line.firstMatch(of: /^\d+[.)]\s/) != nil
    }
}
