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
        // Create
        users.post(use: create)
        // Read
        users.get(use: getAll)
        users.get(":userID", use: getSingle)
        users.get(":userID", "acronyms", use: getAcronyms)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        user.password = try Bcrypt.hash(user.password)

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
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAcronyms(req: Request) throws -> EventLoopFuture<[Acronym]> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms
                    .get(on: req.db)
            }
    }
    
    // MARK: - Update
    // MARK: - Delete
}
