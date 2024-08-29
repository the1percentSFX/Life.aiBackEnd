import Fluent

struct CreateJournalEntry: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("journal_entries")
            .id()
            .field("content", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("journal_entries").delete()
    }
}

