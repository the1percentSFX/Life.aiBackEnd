@testable import App
import XCTVapor
import Fluent


final class AppTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }
    
    override func tearDown() async throws {
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testCreateJournalEntry() async throws {
        let entry = JournalEntry(content: "Test entry")
        
        try await self.app.test(.POST, "journal", beforeRequest: { req async in
            try req.content.encode(entry)
        }, afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            let createdEntry = try? res.content.decode(JournalEntry.self)
            XCTAssertNotNil(createdEntry)
            XCTAssertNotNil(createdEntry?.id)
            XCTAssertEqual(createdEntry?.content, entry.content)
        })
    }
    
    func testGetJournalEntries() async throws {
        let entries = [
            JournalEntry(content: "Entry 1"),
            JournalEntry(content: "Entry 2")
        ]
        try await entries.create(on: app.db)
        
        try await self.app.test(.GET, "journal", afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            let page = try? res.content.decode(Page<JournalEntry>.self)
            XCTAssertNotNil(page)
            XCTAssertEqual(page?.items.count, 2)
        })
    }
    
    func testUpdateJournalEntry() async throws {
        let entry = JournalEntry(content: "Original content")
        try await entry.create(on: app.db)
        
        let updatedContent = "Updated content"
        try await self.app.test(.PUT, "journal/\(entry.id!)", beforeRequest: { req async in
            try req.content.encode(JournalEntry(content: updatedContent))
        }, afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            let updatedEntry = try? res.content.decode(JournalEntry.self)
            XCTAssertNotNil(updatedEntry)
            XCTAssertEqual(updatedEntry?.content, updatedContent)
        })
    }
    
    func testDeleteJournalEntry() async throws {
        let entry = JournalEntry(content: "Entry to delete")
        try await entry.create(on: app.db)
        
        try await self.app.test(.DELETE, "journal/\(entry.id!)", afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
        })
        
        let deletedEntry = try await JournalEntry.find(entry.id, on: app.db)
        XCTAssertNil(deletedEntry)
    }
}


extension TodoDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}


