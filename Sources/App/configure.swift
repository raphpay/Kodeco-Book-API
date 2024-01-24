import NIOSSL
import Fluent
import FluentMongoDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let connection: String
    
    if app.environment == .testing {
        connection = "mongodb://localhost:27017/vapor_test"
    } else {
        connection = "mongodb://localhost:27017/vapor_database"
    }
    
    try app.databases.use(DatabaseConfigurationFactory.mongo(
        connectionString: connection
    ), as: .mongo)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateAcronym())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot())
    app.migrations.add(CreateToken())
    
    app.logger.logLevel = .debug
    
    try await app.autoMigrate()
    
    app.views.use(.leaf)

    // register routes
    try routes(app)
}
