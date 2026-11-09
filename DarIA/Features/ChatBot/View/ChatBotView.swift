import DarIAUI
import SwiftUI

struct ChatBotView: View {
    @State private var viewModel: ChatBotViewModel

    init(viewModel: ChatBotViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ChatBotHeader(viewModel: viewModel)
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    content
                    composer
                }
                ChatBotOverlays(viewModel: viewModel)
            }
        }
        .background(DSColor.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            ChatBotMessageList(viewModel: viewModel)
        case .failed(let message):
            DSText(message, style: .footnote, color: DSColor.destructive)
                .padding(DSSpacing.medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var composer: some View {
        DSComposer(
            message: $viewModel.draft,
            canSend: viewModel.canSend,
            labels: (
                attach: String(localized: "chatBot.composer.attach"),
                send: String(localized: "chatBot.composer.send")
            ),
            onAttach: {},
            onSend: { Task { await viewModel.send() } }
        )
        .localized("chatBot.composer.placeholder")
    }
}

/// Bar with the menu, the title and active connection (opens the selector) and the new-chat button.
private struct ChatBotHeader: View {
    let viewModel: ChatBotViewModel

    var body: some View {
        HStack(spacing: 0) {
            DSIconButton(systemImage: "line.3.horizontal") { viewModel.toggleMenu() }
                .localized("chatBot.menu")
            Spacer(minLength: DSSpacing.small)
            connectionButton
            Spacer(minLength: DSSpacing.small)
            DSIconButton(systemImage: "square.and.pencil") { viewModel.startNewChat() }
                .localized("chatBot.newChat")
        }
        .padding(.horizontal, DSSpacing.small)
        .padding(.bottom, DSSpacing.small)
        .background(DSColor.background)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DSColor.separator).frame(height: 0.5)
        }
    }

    private var connectionButton: some View {
        Button { viewModel.toggleSelector() } label: {
            VStack(spacing: 1) {
                DSText(style: .headline).localized("chatBot.title")
                HStack(spacing: DSSpacing.xSmall) {
                    DSText(connectionSummary, style: .footnote)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            .padding(.horizontal, DSSpacing.small)
            .frame(minHeight: DSSpacing.tapMin)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "chatBot.changeConnection \(viewModel.selectedConnection?.name ?? "")"))
    }

    private var connectionSummary: String {
        guard let connection = viewModel.selectedConnection else { return "" }
        return "\(connection.name) · \(connection.group.kindLabel)"
    }
}

/// Scrollable conversation that follows the latest message.
private struct ChatBotMessageList: View {
    let viewModel: ChatBotViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: DSSpacing.small) {
                    DSText(style: .footnote).localized("chatBot.today")
                        .padding(.bottom, DSSpacing.small)
                    ForEach(viewModel.messages) { message in
                        row(for: message)
                    }
                    if viewModel.isSending {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, DSSpacing.medium)
                    }
                }
                .padding(.horizontal, DSSpacing.space3)
                .padding(.vertical, DSSpacing.medium)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) {
                guard let lastID = viewModel.messages.last?.id else { return }
                withAnimation { proxy.scrollTo(lastID, anchor: .bottom) }
            }
        }
    }

    private func row(for message: ChatMessageViewData) -> some View {
        VStack(alignment: .trailing, spacing: DSSpacing.xSmall) {
            DSChatBubble(message.text, sender: message.sender == .user ? .user : .assistant)
            if message.id == viewModel.lastUserMessageID {
                DSText(style: .caption).localized("chatBot.delivered")
                    .padding(.trailing, DSSpacing.xSmall)
            }
        }
        .id(message.id)
    }
}

/// Main menu and connection selector, drawn over the conversation.
private struct ChatBotOverlays: View {
    let viewModel: ChatBotViewModel

    var body: some View {
        if viewModel.isMenuOpen || viewModel.isSelectorOpen {
            ZStack(alignment: viewModel.isMenuOpen ? .topLeading : .top) {
                DSMenuScrim { viewModel.closeOverlays() }
                    .localized("chatBot.close")
                if viewModel.isMenuOpen {
                    mainMenu
                } else {
                    selector
                }
            }
            .transition(.opacity)
        }
    }

    private var mainMenu: some View {
        DSMenuPanel(width: 250) {
            // Routes to History and Connections arrive with their features (daria-new-feature).
            DSMenuRow(systemImage: "clock", showsDivider: true) { viewModel.closeOverlays() }
                .localized("chatBot.menu.history")
            DSMenuRow(systemImage: "plus.circle") { viewModel.closeOverlays() }
                .localized("chatBot.menu.addConnection")
        }
        .padding(.leading, DSSpacing.space3)
        .padding(.top, DSSpacing.small)
    }

    private var selector: some View {
        DSMenuPanel(width: 290) {
            ForEach(ConnectionViewData.Group.allCases, id: \.self) { group in
                let items = viewModel.connections(in: group)
                if !items.isEmpty {
                    DSSectionHeader(group.sectionTitle)
                        .padding(.top, DSSpacing.small)
                        .padding(.bottom, DSSpacing.xSmall)
                    ForEach(items) { connection in
                        connectionRow(connection)
                    }
                }
            }
            DSMenuRow(systemImage: "plus.circle") { viewModel.closeOverlays() }
                .localized("chatBot.menu.addConnection")
        }
        .padding(.top, DSSpacing.small)
    }

    private func connectionRow(_ connection: ConnectionViewData) -> some View {
        DSConnectionRow(
            connection.name,
            detail: connection.detail,
            badge: (initial: connection.initial, identity: connection.provider.identity),
            isSelected: connection.id == viewModel.selectedConnectionID
        ) {
            viewModel.selectConnection(connection.id)
        }
    }
}

private extension ConnectionViewData.Group {
    var sectionTitle: String {
        switch self {
        case .cloud: String(localized: "chatBot.selector.cloud")
        case .local: String(localized: "chatBot.selector.local")
        }
    }

    var kindLabel: String {
        switch self {
        case .cloud: String(localized: "chatBot.kind.cloud")
        case .local: String(localized: "chatBot.kind.local")
        }
    }
}

private extension ConnectionViewData.Provider {
    var identity: DSIdentity {
        switch self {
        case .claude: .claude
        case .openAI: .openAI
        case .gemini: .gemini
        case .local: .local
        }
    }
}

#Preview {
    NavigationStack {
        ChatBotCoordinator().start()
    }
}
