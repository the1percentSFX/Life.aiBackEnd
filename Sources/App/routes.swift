import Vapor
import Fluent

func routes(_ app: Application) throws {
    
    // Save (create) a journal entry
    app.post("journal") { req async throws -> JournalEntry in
        let entry = try req.content.decode(JournalEntry.self)
        try await entry.save(on: req.db)
        return entry
    }
    
    // Get all journal entries
    app.get("journal") { req async throws -> [JournalEntry] in
        try await JournalEntry.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .all()
    }

    // Update a journal entry
    app.put("journal", ":entryID") { req async throws -> JournalEntry in
        guard let entry = try await JournalEntry.find(req.parameters.get("entryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updatedEntry = try req.content.decode(JournalEntry.self)
        entry.content = updatedEntry.content
        try await entry.save(on: req.db)
        return entry
    }

    // Delete a journal entry by ID
    app.delete("journal", ":entryID") { req async throws -> HTTPStatus in
        guard let entry = try await JournalEntry.find(req.parameters.get("entryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await entry.delete(on: req.db)
        return .ok
    }
}

