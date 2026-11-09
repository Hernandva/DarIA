import SwiftUI

/// Chat message bubble. The assistant's bubbles sit on the left on `surface`;
/// the user's sit on the right on `accent`.
public struct DSChatBubble: View, DSLocalizableText {
    public enum Sender: Sendable {
        case assistant
        case user
    }

    public var text: String
    private let sender: Sender

    public init(_ text: String = "", sender: Sender) {
        self.text = text
        self.sender = sender
    }

    public var body: some View {
        HStack(spacing: 0) {
            if sender == .user {
                Spacer(minLength: DSSpacing.tapMin + DSSpacing.medium)
            }
            Text(text)
                .font(DSFont.body)
                .foregroundStyle(sender == .user ? DSColor.onAccent : DSColor.textPrimary)
                .padding(.horizontal, DSSpacing.space3)
                .padding(.vertical, DSSpacing.small)
                .background(background, in: RoundedRectangle(cornerRadius: DSRadius.radiusBubble, style: .continuous))
                .textSelection(.enabled)
            if sender == .assistant {
                Spacer(minLength: DSSpacing.tapMin + DSSpacing.medium)
            }
        }
    }

    private var background: Color {
        sender == .user ? DSColor.accent : DSColor.surface
    }
}

#Preview {
    VStack(spacing: DSSpacing.small) {
        DSChatBubble("Hola. Pregunta lo que quieras.", sender: .assistant)
        DSChatBubble("¿Qué planta es esta?", sender: .user)
    }
    .padding()
    .background(DSColor.background)
}
