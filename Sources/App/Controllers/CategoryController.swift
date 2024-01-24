//
//  CategoryController.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

struct CategoryController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let categories = routes.grouped("api", "categories")
        // Create
//        categories.post(use: create)
        // Read
        categories.get(use: getAll)
        categories.get(":categoryID", use: getSingle)
        categories.get(":categoryID", "acronyms", use: getAcronyms)
        // Update
        // Delete
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = categories.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(use: create)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        
        return category
            .save(on: req.db)
            .map { category }
    }
    
    // MARK: - Read
    func getAll(req: Request) throws -> EventLoopFuture<[Category]> {
        Category
            .query(on: req.db)
            .all()
    }
    
    func getSingle(req: Request) throws -> EventLoopFuture<Category> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAcronyms(req: Request) throws -> EventLoopFuture<[Acronym]> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                category.$acronyms
                    .get(on: req.db)
            }
    }
    
    // MARK: - Update
    // MARK: - Delete
}
