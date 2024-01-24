//
//  AcronymController.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

final class AcronymController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let acronyms = routes.grouped("api", "acronyms")
        // Create
        acronyms.post(use: create)
        acronyms.post(":acronymID", "categories", ":categoryID", use: addCategory)
        // Read
        acronyms.get(use: getAll)
        acronyms.get(":acronymID", use: getSingle)
        acronyms.get(":acronymID", "user", use: getUser)
        acronyms.get(":acronymID", "categories", use: getCategories)
        // Update
        acronyms.put(":acronymID", use: update)
        // Delete
        acronyms.delete(":acronymID", use: delete)
        acronyms.delete(":acronymID", "categories", ":categoryID", use: removeCategory)
        // Queries
        acronyms.get("search", use: search)
        acronyms.get("first", use: first)
        acronyms.get("sorted", use: sorted)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        
        return acronym
            .save(on: req.db)
            .map { acronym }
    }
    
    func addCategory(req: Request) throws -> EventLoopFuture<Category> {
        let acronymQuery = Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let categoryQuery = Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym
                    .$categories
                    .attach(category, on: req.db)
                    .map { category }
            }
    }
    
    // MARK: - Read
    func getAll(req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym
            .query(on: req.db)
            .all()
    }
    
    func getSingle(req: Request) throws -> EventLoopFuture<Acronym> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getUser(req: Request) throws -> EventLoopFuture<User.Public> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user
                    .get(on: req.db)
                    .convertToPublic()
            }
    }
    
    func getCategories(req: Request) throws -> EventLoopFuture<[Category]> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$categories
                    .get(on: req.db)
            }
    }
    
    // MARK: - Update
    func update(req: Request) throws -> EventLoopFuture<Acronym> {
        let updatedData = try req.content.decode(CreateAcronymData.self)
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updatedData.short
                acronym.long = updatedData.long
                return acronym
                    .save(on: req.db)
                    .map { acronym }
            }
    }
    
    // MARK: - Delete
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym
                    .delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func removeCategory(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let categoryQuery = Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym.$categories
                    .detach(category, on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    // MARK: - Queries
    func search(req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else { throw Abort(.badRequest) }
        
        return Acronym
            .query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }
            .all()
    }
    
    func first(req: Request) throws -> EventLoopFuture<Acronym> {
        Acronym.query(on: req.db)
          .first()
          .unwrap(or: Abort(.notFound))
    }
    
    func sorted(req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym
            .query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
}
