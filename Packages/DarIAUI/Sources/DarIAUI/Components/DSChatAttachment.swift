import SwiftUI

/// Image attached to a chat message. It keeps its aspect ratio inside a 210 × 280 pt box and aligns itself
/// to its side. `.localized(_:)` localises its accessibility label.
public struct DSChatAttachment: View, DSLocalizableText {
    /// Accessibility label, e.g. «Attached image».
    public var text: String
    private let image: Image
    private let role: DSChatRole

    public init(image: Image, label: String = "", role: DSChatRole = .outgoing) {
        self.image = image
        self.text = label
        self.role = role
    }

    public var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(maxWidth: Self.maxSize.width, maxHeight: Self.maxSize.height)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.radiusBubble, style: .continuous))
            .accessibilityLabel(text)
            .frame(maxWidth: .infinity, alignment: role.alignment)
    }
}

private extension DSChatAttachment {
    static let maxSize = CGSize(width: 210, height: 280)
}

#Preview {
    DSChatAttachment(image: Image(systemName: "photo"), label: "Imagen adjunta")
        .padding()
        .background(DSColor.background)
}
