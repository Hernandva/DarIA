import SwiftUI

/// Image or file attached to a chat message, shown as a tile with its file name.
public struct DSChatAttachment: View, DSLocalizableText {
    /// File name shown under the icon.
    public var text: String
    private let role: DSChatRole

    public init(_ fileName: String = "", role: DSChatRole = .outgoing) {
        self.text = fileName
        self.role = role
    }

    public var body: some View {
        VStack(spacing: DSSpacing.small) {
            Image(systemName: "photo")
                .font(.system(size: Self.iconSize, weight: .light))
                .accessibilityHidden(true)
            Text(text)
                .font(DSFont.footnote)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal, DSSpacing.space3)
        }
        .foregroundStyle(DSPalette.onIdentity)
        .frame(width: Self.size.width, height: Self.size.height)
        .background(DSPalette.moss, in: RoundedRectangle(cornerRadius: DSRadius.radiusBubble, style: .continuous))
        .accessibilityElement(children: .combine)
        .frame(maxWidth: .infinity, alignment: role.alignment)
    }
}

private extension DSChatAttachment {
    static let size = CGSize(width: 210, height: 140)
    static let iconSize: CGFloat = 30
}

#Preview {
    DSChatAttachment("foto_planta.jpg")
        .padding()
        .background(DSColor.background)
}
