//
//  MakeCateroiesUnique.swift
//
//
//  Created by Raphaël Payet on 25/01/2024.
//

import Fluent

struct MakeCateroiesUnique: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(Category.v20240125.schemaName)
            .unique(on: Category.v20240125.name)
            .update()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(Category.v20240125.schemaName)
            .deleteUnique(on: Category.v20240125.name)
            .delete()
    }
}
