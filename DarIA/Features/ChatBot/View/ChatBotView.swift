import DarIAUI
import SwiftUI

struct ChatBotView: View {
    @State private var viewModel: ChatBotViewModel

    init(viewModel: ChatBotViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        DSScreen {
            DSText(style: .largeTitle).localized("chatBot.title")

            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .loaded:
                // Compose the screen with DarIAUI components fed by ChatBotViewData.
                EmptyView()
            case .failed(let message):
                DSText(message, style: .footnote, color: DSColor.destructive)
            }
        }
        .task { await viewModel.load() }
    }
}

#Preview {
    NavigationStack {
        ChatBotCoordinator().start()
    }
}
