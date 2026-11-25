import DarIAUI
import SwiftUI

struct ChatView: View {
    @State private var viewModel: ChatViewModel

    /// Receives only the container and resolves the view model from it.
    init(dependencies: ChatDependencies) {
        _viewModel = State(initialValue: dependencies.resolveViewModel())
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColor.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) {
                DSChatComposer(
                    message: $viewModel.draft,
                    texts: composerTexts,
                    onAttach: {},
                    onSend: { viewModel.send() }
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .task { await viewModel.load() }
    }
}

private extension ChatView {
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded:
            conversation
        case .failed(let message):
            DSText(message, style: .footnote, color: DSColor.destructive)
                .padding(DSSpacing.medium)
        }
    }

    var conversation: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.xSmall) {
                DSChatTimestamp(day: dayText, time: viewModel.startedAt.formatted(date: .omitted, time: .shortened))
                DSChatBubble(role: .incoming).localized("chat.greeting")
                ForEach(viewModel.messages) { message in
                    row(for: message)
                        .padding(.top, viewModel.startsGroup(message) ? DSSpacing.small : 0)
                }
            }
            .padding(.horizontal, DSSpacing.space3)
            .padding(.vertical, DSSpacing.medium)
        }
        .defaultScrollAnchor(.bottom)
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
        .scrollDismissesKeyboard(.interactively)
    }

    @ViewBuilder
    func row(for message: ChatViewData.Message) -> some View {
        let role: DSChatRole = message.sender == .user ? .outgoing : .incoming
        VStack(spacing: DSSpacing.xSmall) {
            if let attachmentName = message.attachmentName {
                DSChatAttachment(attachmentName, role: role)
            }
            if !message.text.isEmpty {
                DSChatBubble(message.text, role: role)
            }
            if message.id == viewModel.lastUserMessageID, message.isDelivered {
                DSChatStatus().localized("chat.status.delivered")
            }
        }
    }

    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            DSIconButton(systemImage: "line.3.horizontal") {}
                .localized("chat.menu")
        }
        .sharedBackgroundVisibility(.hidden)
        ToolbarItem(placement: .principal) {
            DSNavigationTitle(
                String(localized: "chat.title"),
                subtitle: connectionText,
                accessibilityLabel: connectionAccessibilityText
            ) {}
        }
        ToolbarItem(placement: .topBarTrailing) {
            DSIconButton(systemImage: "square.and.pencil") { viewModel.startNewChat() }
                .localized("chat.newChat")
        }
        .sharedBackgroundVisibility(.hidden)
    }

    var composerTexts: DSChatComposerTexts {
        DSChatComposerTexts(
            placeholder: String(localized: "chat.composer.placeholder"),
            attachLabel: String(localized: "chat.composer.attach"),
            sendLabel: String(localized: "chat.composer.send")
        )
    }

    var dayText: String {
        let date = viewModel.startedAt
        guard !Calendar.current.isDateInToday(date) else { return String(localized: "chat.today") }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    var connectionText: String {
        guard let connection = viewModel.connection else { return "" }
        let kind = switch connection.kind {
        case .cloud: String(localized: "chat.connection.cloud")
        case .local: String(localized: "chat.connection.local")
        }
        return "\(connection.name) · \(kind)"
    }

    var connectionAccessibilityText: String {
        let format = String(localized: "chat.connection.accessibility")
        return String(format: format, viewModel.connection?.name ?? "")
    }
}

#Preview {
    NavigationStack {
        ChatCoordinator().start()
    }
}
