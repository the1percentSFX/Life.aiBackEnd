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
    let databaseHost = Environment.get("DATABASE_HOST") ?? "localhost"
    let databasePort = Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432 // Default to 5432 if not specified
    let databaseName = Environment.get("DATABASE_NAME") ?? "vapor_database"
    let databaseUsername = Environment.get("DATABASE_USERNAME") ?? "vapor_username"
    let databasePassword = Environment.get("DATABASE_PASSWORD") ?? "vapor_password"

    let databaseConfig = SQLPostgresConfiguration(
        hostname: databaseHost,
        port: databasePort,
        username: databaseUsername,
        password: databasePassword,
        database: databaseName,
        tls: .prefer(try .init(configuration: .clientDefault))
    )

    app.databases.use(.postgres(configuration: databaseConfig), as: .psql)

    app.migrations.add(CreateJournalEntry())

    try await app.autoMigrate()

    // Log configuration details (for debugging)
    app.logger.info("Server will run on port: \(app.http.server.configuration.port)")
    app.logger.info("Database Configuration:")
    app.logger.info("Host: \(databaseHost)")
    app.logger.info("Port: \(databasePort)")
    app.logger.info("Database: \(databaseName)")
    app.logger.info("Username: \(databaseUsername)")
    // Do not log the password for security reasons
}


