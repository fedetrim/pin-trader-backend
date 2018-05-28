import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a MySQL database
    let mySQL: MySQLDatabase = {
        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
        let username = Environment.get("DATABASE_USER") ?? "root"
        let password = Environment.get("DATABASE_PASSWORD") ?? "root"
        let database = Environment.get("DATABASE_DB") ?? "pintrader"

        let config = MySQLDatabaseConfig(hostname: hostname,
                                         username: username,
                                         password: password,
                                         database: database)
        
        return MySQLDatabase(config: config)
    }()

    /// Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mySQL, as: .mysql)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    services.register(migrations)
}
