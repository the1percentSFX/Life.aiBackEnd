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
    app.logger.info("Host: \(Environment.get("DATABASE_HOST") ?? Environment.get("PGHOST") ?? "localhost")")
    app.logger.info("Port: \(Environment.get("DATABASE_PORT") ?? Environment.get("PGPORT") ?? "5432")")
    app.logger.info("Database: \(Environment.get("DATABASE_NAME") ?? Environment.get("PGDATABASE") ?? "vapor_database")")
    app.logger.info("Username: \(Environment.get("DATABASE_USERNAME") ?? Environment.get("PGUSER") ?? "vapor_username")")
    // Do not log the password for security reasons

    let databaseHost = Environment.get("DATABASE_HOST") ?? Environment.get("PGHOST") ?? "localhost"
    let databasePort = Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? Environment.get("PGPORT").flatMap(Int.init(_:)) ?? 5432
    let databaseName = Environment.get("DATABASE_NAME") ?? Environment.get("PGDATABASE") ?? "vapor_database"
    let databaseUsername = Environment.get("DATABASE_USERNAME") ?? Environment.get("PGUSER") ?? "vapor_username"
    let databasePassword = Environment.get("DATABASE_PASSWORD") ?? Environment.get("PGPASSWORD") ?? "vapor_password"

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
}


