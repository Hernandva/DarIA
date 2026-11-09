import SwiftUI

/// Entry point of the ChatBot feature.
/// Builds the view through `ChatBotDependencies` and resolves the routes to the features opened from it.
@MainActor
final class ChatBotCoordinator: Coordinator {
    /// One case per feature that can be opened from ChatBot.
    enum Route: Hashable {
        // @codegen:routes
    }

    private let dependencies: ChatBotDependencies

    init(dependencies: ChatBotDependencies = ChatBotDependencies()) {
        self.dependencies = dependencies
    }

    func start() -> some View {
        ChatBotView(viewModel: dependencies.makeViewModel())
            .navigationDestination(for: Route.self) { route in
                self.destination(for: route)
            }
    }

    func destination(for route: Route) -> AnyView {
        switch route {
        // @codegen:destinations
        }
    }
}
