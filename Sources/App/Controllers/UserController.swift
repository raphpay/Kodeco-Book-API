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
        let usersV2 = routes.grouped("api", "v2", "users")
        // Create
//        users.post(use: create)
        // Read
        users.get(use: getAll)
        users.get(":userID", use: getSingle)
        usersV2.get(":userID", use: getSingleV2)
        users.get(":userID", "acronyms", use: getAcronyms)
        // Protected
        let basicAuthMiddleware = User.authenticator()
        let basicAuthGroup = users.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: login)
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = users.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(use: create)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<User.Public> {
        let user = try req.content.decode(User.self)
        user.password = try Bcrypt.hash(user.password)

        return user
            .save(on: req.db)
            .map { user.convertToPublic() }
    }
    
    // MARK: - Read
    func getAll(req: Request) throws -> EventLoopFuture<[User.Public]> {
        User
            .query(on: req.db)
            .all()
            .convertToPublic()
    }
    
    func getSingle(req: Request) throws -> EventLoopFuture<User.Public> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .convertToPublic()
    }
    
    func getSingleV2(req: Request) throws -> EventLoopFuture<User.PublicV2> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .convertToPublicV2()
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
    // MARK: - Login
    func login(_ req: Request) throws -> EventLoopFuture<Token> {
        let user = try req.auth.require(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req.db).map { token }
    }
}
