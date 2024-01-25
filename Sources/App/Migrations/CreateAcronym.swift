//
//  CreateAcronym.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent

struct CreateAcronym: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(Acronym.v20240125.schemaName)
            .id()
            .field(Acronym.v20240125.id, .string, .required)
            .field(Acronym.v20240125.long, .string, .required)
            .field(Acronym.v20240125.userID, .uuid, .required, .references(User.v20240125.schemaName, User.v20240125.id))
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(Acronym.v20240125.schemaName)
            .delete()
    }    
}

extension Acronym {
    enum v20240125 {
        static let schemaName = "acronyms"
        static let id = FieldKey(stringLiteral: "id")
        static let short = FieldKey(stringLiteral: "short")
        static let long = FieldKey(stringLiteral: "long")
        static let userID = FieldKey(stringLiteral: "userID")
    }
}
