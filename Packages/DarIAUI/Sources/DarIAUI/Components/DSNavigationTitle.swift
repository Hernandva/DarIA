import SwiftUI

/// Tappable title of a navigation bar: the title in the display font and, under it, a subtitle with
/// an up-down chevron that tells the user it opens a picker. Every text is passed already localised.
public struct DSNavigationTitle: View {
    private let title: String
    private let subtitle: String
    private let accessibilityText: String
    private let action: @MainActor () -> Void

    public init(
        _ title: String,
        subtitle: String,
        accessibilityLabel: String? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accessibilityText = accessibilityLabel ?? "\(title), \(subtitle)"
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .font(DSTypeScale.navTitle)
                    .foregroundStyle(DSColor.textPrimary)
                HStack(spacing: DSSpacing.xSmall) {
                    Text(subtitle)
                        .font(DSTypeScale.sectionHeader)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: Self.chevronSize, weight: .bold))
                }
                .foregroundStyle(DSColor.textSecondary)
            }
            .padding(.horizontal, DSSpacing.small)
            .frame(minHeight: DSSpacing.tapMin)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(.isButton)
    }
}

private extension DSNavigationTitle {
    static let chevronSize: CGFloat = 9
}

#Preview {
    DSNavigationTitle("DarIA", subtitle: "Claude · nube") {}
        .padding()
        .background(DSColor.background)
}
