import SwiftUI

/// Message bar: attach button, capsule text field and send button.
/// `text` is the placeholder, so `.localized(_:)` localises it.
public struct DSComposer: View, DSLocalizableText {
    public var text: String
    @Binding private var message: String
    private let canSend: Bool
    private let attachLabel: String
    private let sendLabel: String
    private let onAttach: @MainActor () -> Void
    private let onSend: @MainActor () -> Void

    public init(
        _ placeholder: String = "",
        message: Binding<String>,
        canSend: Bool,
        labels: (attach: String, send: String),
        onAttach: @escaping @MainActor () -> Void,
        onSend: @escaping @MainActor () -> Void
    ) {
        self.text = placeholder
        self._message = message
        self.canSend = canSend
        self.attachLabel = labels.attach
        self.sendLabel = labels.send
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
            Rectangle().fill(DSColor.separator).frame(height: 0.5)
        }
    }

    private var attachButton: some View {
        Button(action: onAttach) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 36, height: 36)
                .background(DSColor.fillSecondary, in: Circle())
        }
        .buttonStyle(.plain)
        .padding(.bottom, 2)
        .accessibilityLabel(attachLabel)
    }

    private var field: some View {
        HStack(alignment: .bottom, spacing: DSSpacing.xSmall) {
            TextField(text, text: $message, axis: .vertical)
                .textFieldStyle(.plain)
                .font(DSFont.body)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1...5)
                .padding(.vertical, 9)
                .submitLabel(.send)
                .onSubmit { if canSend { onSend() } }
            sendButton
        }
        .padding(.leading, DSSpacing.space3)
        .padding(.trailing, DSSpacing.xSmall)
        .frame(minHeight: 40)
        .background(DSColor.surface, in: RoundedRectangle(cornerRadius: DSRadius.radiusCapsule, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.radiusCapsule, style: .continuous)
                .stroke(DSColor.separator, lineWidth: 0.5)
        }
    }

    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(DSColor.onAccent)
                .frame(width: 32, height: 32)
                .background(DSColor.accent, in: Circle())
        }
        .buttonStyle(.plain)
        .padding(.bottom, DSSpacing.xSmall)
        .disabled(!canSend)
        .opacity(canSend ? 1 : 0.4)
        .accessibilityLabel(sendLabel)
    }
}

#Preview {
    VStack {
        Spacer()
        DSComposer(
            "Mensaje",
            message: .constant(""),
            canSend: false,
            labels: (attach: "Adjuntar", send: "Enviar"),
            onAttach: {},
            onSend: {}
        )
    }
    .background(DSColor.background)
}
