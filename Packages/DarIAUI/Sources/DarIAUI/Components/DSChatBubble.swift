import SwiftUI

/// Who wrote a chat message. It decides the side and the colors of the bubble.
public enum DSChatRole: Sendable {
    /// Message of the assistant: on the left, on `surface`.
    case incoming
    /// Message of the user: on the right, on `accent`.
    case outgoing

    var alignment: Alignment {
        switch self {
        case .incoming: .leading
        case .outgoing: .trailing
        }
    }
}

/// Text message of a conversation. It takes at most 76 % of the width and aligns itself to its side.
public struct DSChatBubble: View, DSLocalizableText {
    public var text: String
    private let role: DSChatRole

    public init(_ text: String = "", role: DSChatRole = .incoming) {
        self.text = text
        self.role = role
    }

    public var body: some View {
        Text(text)
            .font(DSFont.body)
            .lineSpacing(DSSpacing.xSmall)
            .foregroundStyle(foreground)
            .textSelection(.enabled)
            .padding(.vertical, DSSpacing.small)
            .padding(.horizontal, DSSpacing.space3)
            .background(background, in: RoundedRectangle(cornerRadius: DSRadius.radiusBubble, style: .continuous))
            .containerRelativeFrame(.horizontal, alignment: role.alignment) { length, _ in
                length * Self.maxWidthRatio
            }
            .frame(maxWidth: .infinity, alignment: role.alignment)
    }
}

private extension DSChatBubble {
    static let maxWidthRatio: CGFloat = 0.76

    var foreground: Color {
        switch role {
        case .incoming: DSColor.textPrimary
        case .outgoing: DSColor.onAccent
        }
    }

    var background: Color {
        switch role {
        case .incoming: DSColor.surface
        case .outgoing: DSColor.accent
        }
    }
}

#Preview {
    VStack(spacing: DSSpacing.small) {
        DSChatBubble("Hola. Pregunta lo que quieras.")
        DSChatBubble("¿Qué planta es esta?", role: .outgoing)
    }
    .padding()
    .background(DSColor.background)
}
