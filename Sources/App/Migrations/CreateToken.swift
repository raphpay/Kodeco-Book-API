//
//  CreateToken.swift
//
//
//  Created by Raphaël Payet on 24/01/2024.
//

import Fluent

struct CreateToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.v20240125.schemaName)
            .id()
            .field(Token.v20240125.value, .string, .required)
            .field(Token.v20240125.userID, .uuid, .required,
                   .references(User.v20240125.schemaName, User.v20240125.id, onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tokens").delete()
    }
}

extension Token {
    enum v20240125 {
        static let schemaName = "tokens"
        static let value = FieldKey(stringLiteral: "value")
        static let userID = FieldKey(stringLiteral: "userID")
    }
}
