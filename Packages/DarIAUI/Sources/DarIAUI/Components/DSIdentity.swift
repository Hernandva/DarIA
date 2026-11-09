import SwiftUI

/// Identity colors of a connection (provider or local machine), from the palette tokens.
public enum DSIdentity: Sendable {
    case claude
    case openAI
    case gemini
    case local

    /// Background of the identity badge.
    public var tint: Color {
        switch self {
        case .claude: DSPalette.mustard
        case .openAI: DSPalette.cobalt
        case .gemini: DSPalette.moss
        case .local: DSPalette.mahogany
        }
    }

    /// Glyph color on top of `tint`.
    public var ink: Color {
        switch self {
        case .claude: DSPalette.onMustard
        case .openAI, .gemini, .local: DSPalette.onIdentity
        }
    }
}

/// Small square badge with the initial of a connection, tinted with its identity color.
public struct DSIdentityBadge: View {
    private let initial: String
    private let identity: DSIdentity
    private let size: CGFloat

    public init(_ initial: String, identity: DSIdentity, size: CGFloat = 24) {
        self.initial = initial
        self.identity = identity
        self.size = size
    }

    public var body: some View {
        Text(initial)
            .font(DSTypeScale.navTitle)
            .minimumScaleFactor(0.4)
            .lineLimit(1)
            .foregroundStyle(identity.ink)
            .padding(DSSpacing.xSmall)
            .frame(width: size, height: size)
            .background(identity.tint, in: RoundedRectangle(cornerRadius: DSRadius.radiusIcon, style: .continuous))
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        DSIdentityBadge("C", identity: .claude)
        DSIdentityBadge("O", identity: .openAI)
        DSIdentityBadge("G", identity: .gemini)
        DSIdentityBadge("M", identity: .local)
    }
    .padding()
}
