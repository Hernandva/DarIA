import SwiftUI

/// Icon-only bar button with a 44 pt touch target, tinted with `accent`.
/// `text` is the accessibility label, so `.localized(_:)` localises it.
public struct DSIconButton: View, DSLocalizableText {
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
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(DSColor.accent)
                .frame(width: DSSpacing.tapMin, height: DSSpacing.tapMin)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
    }
}

#Preview {
    HStack {
        DSIconButton(systemImage: "line.3.horizontal", label: "Menú") {}
        DSIconButton(systemImage: "square.and.pencil", label: "Nuevo chat") {}
    }
}
