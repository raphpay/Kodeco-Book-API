//
//  UserController.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        users.post(use: create)
        users.get(use: getAll)
        users.get(":acronymID", use: getSingle)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        
        return user
            .save(on: req.db)
            .map { user }
    }
    
    // MARK: - Read
    func getAll(req: Request) throws -> EventLoopFuture<[User]> {
        User
            .query(on: req.db)
            .all()
    }
    
    func getSingle(req: Request) throws -> EventLoopFuture<User> {
        User
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    // MARK: - Update
    // MARK: - Delete
}
