import Vapor

func routes(_ app: Application) throws {
    
    // Save (create) a journal entry
    app.post("journal") { req -> EventLoopFuture<JournalEntry> in
        let entry = try req.content.decode(JournalEntry.self)
        return entry.save(on: req.db).map { entry }
    }
    
    // Get all journal entries with pagination
    app.get("journal") { req -> EventLoopFuture<Page<JournalEntry>> in
        let page = try req.query.decode(PageRequest.self)
        return JournalEntry.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .paginate(page)
    }

    // Update a journal entry
    app.put("journal", ":entryID") { req -> EventLoopFuture<JournalEntry> in
        let updatedEntry = try req.content.decode(JournalEntry.self)
        return JournalEntry.find(req.parameters.get("entryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { entry in
                entry.content = updatedEntry.content
                return entry.save(on: req.db).map { entry }
            }
    }

    // Delete a journal entry by ID
    app.delete("journal", ":entryID") { req -> EventLoopFuture<HTTPStatus> in
        JournalEntry.find(req.parameters.get("entryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}

