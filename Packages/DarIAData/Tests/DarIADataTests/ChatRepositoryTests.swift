@testable import DarIAData
import Foundation
import Testing

struct ChatRepositoryTests {
    @Test func forwardsTheRequestToTheServiceOfItsProvider() async throws {
        let service = ChatServiceSpy(reply: "Fascinating.")
        let repository = ChatRepository(services: [.appleIntelligence: service])
        let request = ChatRequestStub(messages: [
            ChatMessageStub(role: .user, text: "Hi"),
            ChatMessageStub(role: .assistant, text: "Hello."),
            ChatMessageStub(role: .user, text: "  How are you?  ")
        ])

        let response = try await repository.send(request)

        #expect(response.text == "Fascinating.")
        let received = try #require(await service.received)
        #expect(received.question == "How are you?")
        #expect(received.history.map(\.text) == ["Hi", "Hello."])
    }

    @Test func throwsWhenTheProviderHasNoService() async {
        let repository = ChatRepository(services: [:])
        let request = ChatRequestStub(messages: [ChatMessageStub(role: .user, text: "Hi")])

        await #expect(throws: ChatRepositoryError.unsupportedProvider(.appleIntelligence)) {
            try await repository.send(request)
        }
    }

    @Test func throwsWhenTheLastMessageIsNotAQuestion() async {
        let repository = ChatRepository(services: [.appleIntelligence: ChatServiceSpy(reply: "")])
        let request = ChatRequestStub(messages: [
            ChatMessageStub(role: .user, text: "Hi"),
            ChatMessageStub(role: .assistant, text: "Hello.")
        ])

        await #expect(throws: ChatRepositoryError.missingQuestion) {
            try await repository.send(request)
        }
    }
}

private struct ChatMessageStub: ChatMessageProtocol {
    let role: ChatRole
    let text: String
}

private struct ChatRequestStub: ChatRequestProtocol {
    var provider = ChatProvider.appleIntelligence
    let messages: [any ChatMessageProtocol]
}

private actor ChatServiceSpy: ChatProviderService {
    private let reply: String
    private(set) var received: ChatRequestDAO?

    init(reply: String) {
        self.reply = reply
    }

    func send(_ request: ChatRequestDAO) async throws -> ChatResponseDAO {
        received = request
        return ChatResponseDAO(text: reply)
    }
}

struct ChatPersonaTests {
    @Test func endsWithTheFallbackLanguage() {
        let instructions = ChatPersona.instructions(fallbackLanguage: "Spanish")

        #expect(instructions.hasPrefix("You are DarIA"))
        #expect(instructions.hasSuffix("answer in Spanish."))
    }
}

struct ChatResponseDAOTests {
    @Test func joinsSentencesBrokenIntoLines() {
        let text = ChatResponseDAO.joiningLineBreaks(in: "Hola.\nComo si eso\nimportara.\n")

        #expect(text == "Hola. Como si eso importara.")
    }

    @Test func keepsParagraphsAndLists() {
        let text = ChatResponseDAO.joiningLineBreaks(in: "Dos cosas:\n- una\n- otra\n\nY ya.")

        #expect(text == "Dos cosas:\n- una\n- otra\n\nY ya.")
    }
}
