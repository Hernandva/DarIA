import SwiftUI

/// Icon-only button with a 44 pt tap area, tinted with `accent`. `.localized(_:)` localises its accessibility label.
public struct DSIconButton: View, DSLocalizableText {
    /// Accessibility label: the button shows no text.
    public var text: String
    private let systemImage: String
    private let action: @MainActor () -> Void

    public init(systemImage: String, label: String = "", action: @escaping @MainActor () -> Void) {
        self.systemImage = systemImage
        self.text = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: Self.iconSize, weight: .regular))
                .foregroundStyle(DSColor.accent)
                .frame(width: DSSpacing.tapMin, height: DSSpacing.tapMin)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
    }
}

private extension DSIconButton {
    static let iconSize: CGFloat = 20
}

#Preview {
    HStack {
        DSIconButton(systemImage: "line.3.horizontal", label: "Menu") {}
        DSIconButton(systemImage: "square.and.pencil", label: "New chat") {}
    }
    .padding()
    .background(DSColor.background)
}
