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
        // Read
        acronyms.get(use: getAll)
        acronyms.get(":acronymID", use: getSingle)
        // Update
        acronyms.put(":acronymID", use: update)
        // Delete
        acronyms.delete(":acronymID", use: delete)
        // Queries
        acronyms.get("search", use: search)
        acronyms.get("first", use: first)
        acronyms.get("sorted", use: sorted)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<Acronym> {
        let acronym = try req.content.decode(Acronym.self)
        return acronym
            .save(on: req.db)
            .map { acronym }
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
    
    // MARK: - Update
    func update(req: Request) throws -> EventLoopFuture<Acronym> {
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
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
