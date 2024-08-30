import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Add logging for database configuration
    app.logger.info("Database Configuration:")
    app.logger.info("Host: \(Environment.get("DATABASE_HOST") ?? "localhost")")
    app.logger.info("Port: \(Environment.get("DATABASE_PORT") ?? "5432")")
    app.logger.info("Database: \(Environment.get("DATABASE_NAME") ?? "vapor_database")")
    app.logger.info("Username: \(Environment.get("DATABASE_USERNAME") ?? "vapor_username")")
    // Do not log the password for security reasons

    app.databases.use(.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault))
    )), as: .psql)

    app.migrations.add(CreateJournalEntry())

    try await app.autoMigrate()
}

