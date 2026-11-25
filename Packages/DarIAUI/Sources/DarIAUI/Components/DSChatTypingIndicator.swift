import SwiftUI

/// Incoming bubble with three pulsing dots, shown while the assistant is writing.
/// `.localized(_:)` localises its accessibility label.
public struct DSChatTypingIndicator: View, DSLocalizableText {
    /// Accessibility label, e.g. «DarIA is typing».
    public var text: String

    public init(_ label: String = "") {
        self.text = label
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: Self.frameInterval)) { context in
            HStack(spacing: DSSpacing.xSmall) {
                ForEach(0..<Self.dotCount, id: \.self) { index in
                    Circle()
                        .fill(DSColor.textSecondary)
                        .frame(width: Self.dotSize, height: Self.dotSize)
                        .opacity(Self.opacity(of: index, at: context.date))
                }
            }
        }
        .padding(.vertical, DSSpacing.space3)
        .padding(.horizontal, DSSpacing.medium)
        .background(DSColor.surface, in: RoundedRectangle(cornerRadius: DSRadius.radiusBubble, style: .continuous))
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

private extension DSChatTypingIndicator {
    static let dotCount = 3
    static let dotSize: CGFloat = 7
    static let period: TimeInterval = 1.2
    static let frameInterval: TimeInterval = 1 / 30

    /// Each dot fades in and out in turn, one third of a period after the one before.
    static func opacity(of index: Int, at date: Date) -> Double {
        let phase = date.timeIntervalSinceReferenceDate / period - Double(index) / Double(dotCount)
        let wave = (sin(phase * 2 * .pi) + 1) / 2
        return 0.3 + 0.7 * wave
    }
}

#Preview {
    DSChatTypingIndicator("DarIA is typing")
        .padding()
        .background(DSColor.background)
}
