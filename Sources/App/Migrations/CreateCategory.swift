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
            .schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema("categories")
            .delete()
    }
}
