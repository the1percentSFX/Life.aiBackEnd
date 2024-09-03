import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // Configure the port for the application
    if let portString = Environment.get("PORT"), let port = Int(portString) {
        app.http.server.configuration.port = port
    }

    // Database configuration
    let databaseURL = Environment.get("DATABASE_URL") ?? "postgresql://vapor_username:vapor_password@localhost:5432/vapor_database"

    app.logger.info("Using Database URL: \(databaseURL)")

    try app.databases.use(.postgres(url: databaseURL), as: .psql)

    app.migrations.add(CreateJournalEntry())

    // Log configuration details (for debugging)
    app.logger.info("Server will run on port: \(app.http.server.configuration.port)")
    app.logger.info("Database URL: \(databaseURL)")

    // Run migrations
    try await app.autoMigrate()
}


