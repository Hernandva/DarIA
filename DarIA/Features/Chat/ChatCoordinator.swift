import SwiftUI

/// Entry point of the Chat feature.
/// Builds the view through `ChatDependencies` and resolves the routes to the features opened from it.
@MainActor
final class ChatCoordinator: Coordinator {
    /// One case per feature that can be opened from Chat.
    enum Route: Hashable {
        // @codegen:routes
    }

    private let dependencies: ChatDependencies

    init(dependencies: ChatDependencies = ChatDependencies()) {
        self.dependencies = dependencies
    }

    func start() -> some View {
        ChatView(dependencies: dependencies)
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
