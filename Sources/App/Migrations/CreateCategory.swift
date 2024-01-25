//
//  CreateCategory.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent

struct CreateCategory: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(Category.v20240125.schemaName)
            .id()
            .field(Category.v20240125.name, .string, .required)
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(Category.v20240125.schemaName)
            .delete()
    }
}

extension Category {
    enum v20240125 {
        static let schemaName = "categories"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
    }
}
