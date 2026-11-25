import SwiftUI

/// Centered date stamp above a group of chat messages: the day in semibold, then the time.
/// Both texts are passed already localised.
public struct DSChatTimestamp: View {
    private let day: String
    private let time: String

    public init(day: String, time: String) {
        self.day = day
        self.time = time
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xSmall) {
            Text(day)
                .fontWeight(.semibold)
            Text(time)
        }
        .font(DSTypeScale.sectionHeader)
        .foregroundStyle(DSColor.textSecondary)
        .frame(maxWidth: .infinity)
        .padding(.bottom, DSSpacing.small)
        .accessibilityElement(children: .combine)
    }
}

/// Small status under the last message of the user, such as «Delivered».
public struct DSChatStatus: View, DSLocalizableText {
    public var text: String

    public init(_ text: String = "") {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(DSFont.caption)
            .foregroundStyle(DSColor.textSecondary)
            .padding(.trailing, DSSpacing.xSmall)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

/// Centered notice inside a conversation, such as an error of the model.
public struct DSChatNotice: View, DSLocalizableText {
    public var text: String

    public init(_ text: String = "") {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(DSFont.footnote)
            .foregroundStyle(DSColor.destructive)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DSSpacing.medium)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        DSChatTimestamp(day: "Hoy", time: "12:52")
        DSChatStatus("Entregado")
        DSChatNotice("El modelo no está disponible.")
    }
    .padding()
    .background(DSColor.background)
}
