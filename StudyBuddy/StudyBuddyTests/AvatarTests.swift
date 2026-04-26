import XCTest
import SwiftData
@testable import StudyBuddy

@MainActor
final class AvatarTests: XCTestCase {

    func test_defaultHasNonEmptyFields() {
        let avatar = Avatar.default

        XCTAssertFalse(avatar.hairStyle.isEmpty)
        XCTAssertFalse(avatar.outfit.isEmpty)
        XCTAssertFalse(avatar.accentColorHex.isEmpty)
    }

    func test_persistsThroughInMemoryContainer() throws {
        let schema = Schema([Avatar.self, Pet.self, FocusSession.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        let avatar = Avatar(hairStyle: "Long", outfit: "Hoodie", accentColorHex: "#AABBCC")
        context.insert(avatar)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Avatar>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.hairStyle, "Long")
        XCTAssertEqual(fetched.first?.outfit, "Hoodie")
        XCTAssertEqual(fetched.first?.accentColorHex, "#AABBCC")
    }
}
