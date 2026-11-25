import DarIAUI
import SwiftUI

struct ChatView: View {
    @State private var viewModel: ChatViewModel

    /// Receives only the container and resolves the view model from it.
    init(dependencies: ChatDependencies) {
        _viewModel = State(initialValue: dependencies.resolveViewModel())
    }

    var body: some View {
        DSScreen {
            DSText(style: .largeTitle).localized("chat.title")

            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .loaded:
                // Compose the screen with DarIAUI components fed by `viewModel.viewData`.
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
        ChatCoordinator().start()
    }
}
