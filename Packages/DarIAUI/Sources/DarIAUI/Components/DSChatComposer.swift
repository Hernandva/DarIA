import SwiftUI

/// Texts of `DSChatComposer`, passed already localised.
public struct DSChatComposerTexts: Sendable {
    public let placeholder: String
    public let attachLabel: String
    public let sendLabel: String

    public init(placeholder: String, attachLabel: String, sendLabel: String) {
        self.placeholder = placeholder
        self.attachLabel = attachLabel
        self.sendLabel = sendLabel
    }
}

/// Image waiting to be sent, shown as a thumbnail inside the message field.
public struct DSChatComposerAttachment {
    public let image: Image
    /// Accessibility label of the button that removes the image, already localised.
    public let removeLabel: String
    public let onRemove: @MainActor () -> Void

    public init(image: Image, removeLabel: String, onRemove: @escaping @MainActor () -> Void) {
        self.image = image
        self.removeLabel = removeLabel
        self.onRemove = onRemove
    }
}

/// Bottom bar of a chat: an attach button and a growing message field with the send button inside.
/// An image waiting to be sent is set with `.attachment(_:)`. Send is disabled while there is neither text nor
/// an image, or while `isSendEnabled` is false (e.g. while the assistant answers).
public struct DSChatComposer: View {
    @Binding private var message: String
    private let texts: DSChatComposerTexts
    private let isSendEnabled: Bool
    private let onAttach: @MainActor () -> Void
    private let onSend: @MainActor () -> Void
    private var attachment: DSChatComposerAttachment?
    /// Changes after each send to rebuild the text field (see `send()`).
    @State private var fieldGeneration = 0
    @FocusState private var isFieldFocused: Bool

    public init(
        message: Binding<String>,
        texts: DSChatComposerTexts,
        isSendEnabled: Bool = true,
        onAttach: @escaping @MainActor () -> Void,
        onSend: @escaping @MainActor () -> Void
    ) {
        self._message = message
        self.texts = texts
        self.isSendEnabled = isSendEnabled
        self.onAttach = onAttach
        self.onSend = onSend
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: DSSpacing.small) {
            attachButton
            field
        }
        .padding(.horizontal, DSSpacing.space3)
        .padding(.vertical, DSSpacing.small)
        .background(DSColor.background)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(DSColor.separator)
                .frame(height: Self.hairline)
        }
    }

    /// Returns a copy that shows `attachment` inside the field, or no image when it is `nil`.
    public func attachment(_ attachment: DSChatComposerAttachment?) -> Self {
        var copy = self
        copy.attachment = attachment
        return copy
    }
}

private extension DSChatComposer {
    static let hairline: CGFloat = 0.5
    static let fieldHeight: CGFloat = 40
    static let attachSize: CGFloat = 36
    static let sendSize: CGFloat = 32
    static let maxLines = 5
    static let thumbnailSize: CGFloat = 64
    static let removeIconSize: CGFloat = 20

    /// The keyboard can commit a pending autocorrection right after the owner clears the message, which leaves
    /// the sent text on screen while the binding is empty. Rebuilding the field once the message is cleared keeps
    /// both in sync. If the field had the focus, it gets it back so the keyboard stays up.
    func send() {
        let wasFocused = isFieldFocused
        onSend()
        guard message.isEmpty else { return }
        fieldGeneration += 1
        guard wasFocused else { return }
        Task { @MainActor in
            isFieldFocused = true
        }
    }

    var canSend: Bool {
        isSendEnabled && (attachment != nil || !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    var attachButton: some View {
        Button(action: onAttach) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: Self.attachSize, height: Self.attachSize)
                .background(DSColor.fillSecondary, in: Circle())
                .frame(height: Self.fieldHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(texts.attachLabel)
    }

    var field: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let attachment {
                thumbnail(for: attachment)
                    .padding(.top, DSSpacing.small)
            }
            textRow
        }
        .padding(.leading, DSSpacing.space3)
        .padding(.trailing, DSSpacing.xSmall)
        .frame(minHeight: Self.fieldHeight)
        .background(DSColor.surface, in: RoundedRectangle(cornerRadius: DSRadius.radiusCapsule, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.radiusCapsule, style: .continuous)
                .strokeBorder(DSColor.separator, lineWidth: Self.hairline)
        }
    }

    func thumbnail(for attachment: DSChatComposerAttachment) -> some View {
        attachment.image
            .resizable()
            .scaledToFill()
            .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.radiusControl, style: .continuous))
            .overlay(alignment: .topTrailing) {
                Button(action: attachment.onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: Self.removeIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(DSColor.onAccent, DSColor.textPrimary)
                        .frame(width: DSSpacing.tapMin, height: DSSpacing.tapMin, alignment: .topTrailing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: DSSpacing.small, y: -DSSpacing.small)
                .accessibilityLabel(attachment.removeLabel)
            }
    }

    var textRow: some View {
        HStack(alignment: .bottom, spacing: DSSpacing.small) {
            TextField(
                text: $message,
                prompt: Text(texts.placeholder).foregroundStyle(DSColor.textSecondary),
                axis: .vertical
            ) {
                Text(texts.placeholder)
            }
            .font(DSFont.body)
            .foregroundStyle(DSColor.textPrimary)
            .lineLimit(1...Self.maxLines)
            .focused($isFieldFocused)
            .id(fieldGeneration)
            .padding(.vertical, DSSpacing.small)
            sendButton
        }
    }

    var sendButton: some View {
        Button(action: send) {
            Image(systemName: "arrow.up")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(DSColor.onAccent)
                .frame(width: Self.sendSize, height: Self.sendSize)
                .background(DSColor.accent, in: Circle())
                .frame(height: Self.fieldHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .opacity(canSend ? 1 : 0.5)
        .accessibilityLabel(texts.sendLabel)
    }
}

#Preview {
    @Previewable @State var message = ""
    VStack {
        Spacer()
        DSChatComposer(
            message: $message,
            texts: DSChatComposerTexts(placeholder: "Mensaje", attachLabel: "Adjuntar", sendLabel: "Enviar"),
            onAttach: {},
            onSend: {}
        )
        .attachment(DSChatComposerAttachment(image: Image(systemName: "photo"), removeLabel: "Quitar") {})
    }
    .background(DSColor.background)
}
