import SwiftUI

/// Floating drop-down panel on `menu-surface` with the system's only shadow (`shadow-menu`).
public struct DSMenuPanel<Content: View>: View {
    private let width: CGFloat
    private let content: Content

    public init(width: CGFloat, @ViewBuilder content: () -> Content) {
        self.width = width
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(width: width)
        .background(DSPalette.menuSurface)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.radiusControl + 1, style: .continuous))
        // shadow-menu token: 0 10px 40px.
        .shadow(color: .black.opacity(0.22), radius: 20, x: 0, y: 10)
    }
}

/// Full-screen veil behind an open menu. Tapping it closes the menu.
public struct DSMenuScrim: View, DSLocalizableText {
    public var text: String
    private let onDismiss: @MainActor () -> Void

    public init(label: String = "", onDismiss: @escaping @MainActor () -> Void) {
        self.text = label
        self.onDismiss = onDismiss
    }

    public var body: some View {
        Button(action: onDismiss) {
            DSPalette.scrim
                .ignoresSafeArea()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
    }
}

/// Menu row with a title and a trailing icon.
public struct DSMenuRow: View, DSLocalizableText {
    public var text: String
    private let systemImage: String
    private let showsDivider: Bool
    private let action: @MainActor () -> Void

    public init(
        _ title: String = "",
        systemImage: String,
        showsDivider: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.text = title
        self.systemImage = systemImage
        self.showsDivider = showsDivider
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(DSFont.body)
                Spacer(minLength: DSSpacing.small)
                Image(systemName: systemImage)
                    .font(.system(size: 18))
            }
            .foregroundStyle(DSColor.textPrimary)
            .padding(.horizontal, DSSpacing.medium)
            .frame(minHeight: DSSpacing.tapMin)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle().fill(DSColor.separator).frame(height: 0.5)
            }
        }
    }
}

/// Selectable connection row: check mark, name, detail and identity badge.
public struct DSConnectionRow: View, DSLocalizableText {
    public var text: String
    private let detail: String
    private let initial: String
    private let identity: DSIdentity
    private let isSelected: Bool
    private let action: @MainActor () -> Void

    public init(
        _ name: String = "",
        detail: String,
        badge: (initial: String, identity: DSIdentity),
        isSelected: Bool,
        action: @escaping @MainActor () -> Void
    ) {
        self.text = name
        self.detail = detail
        self.initial = badge.initial
        self.identity = badge.identity
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.space3) {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DSColor.accent)
                    .opacity(isSelected ? 1 : 0)
                    .frame(width: 18)
                VStack(alignment: .leading, spacing: 2) {
                    Text(text)
                        .font(DSFont.body)
                        .foregroundStyle(DSColor.textPrimary)
                    Text(detail)
                        .font(DSFont.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                }
                Spacer(minLength: DSSpacing.small)
                DSIdentityBadge(initial, identity: identity)
            }
            .padding(.horizontal, DSSpacing.medium)
            .padding(.vertical, 6)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DSColor.separator).frame(height: 0.5)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ZStack(alignment: .top) {
        DSColor.background.ignoresSafeArea()
        DSMenuScrim {}
        DSMenuPanel(width: 290) {
            DSSectionHeader("Nube").padding(.top, DSSpacing.small)
            DSConnectionRow("Claude", detail: "Conectado", badge: ("C", .claude), isSelected: true) {}
            DSConnectionRow("Mac mini", detail: "Ollama", badge: ("M", .local), isSelected: false) {}
            DSMenuRow("Añadir conexión", systemImage: "plus.circle") {}
        }
        .padding(.top, DSSpacing.medium)
    }
}
