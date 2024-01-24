//
//  WebsiteController.swift
//
//
//  Created by Raphaël Payet on 24/01/2024.
//

import Vapor
import Leaf

enum RouteCollectionError: Error {
    case wrongAcronyms
}

struct WebsiteController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get(use: index)
        routes.get("acronyms", ":acronymID", use: acronymHandler)

    }
    
    // MARK: - Read
    func index(req: Request) throws -> EventLoopFuture<View> {
        Acronym
            .query(on: req.db)
            .all()
            .flatMap { acronyms in
                let acronymsData = acronyms.isEmpty ? nil : acronyms
                let context = IndexContext(title: "Home page", acronyms: acronymsData)
                return req.view.render("index", context)
            }
    }
    
    // 1
    func acronymHandler(_ req: Request) -> EventLoopFuture<View> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db).flatMap { user in
                    let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                    return req.view.render("acronym", context)
                }
            }
    }

}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}
