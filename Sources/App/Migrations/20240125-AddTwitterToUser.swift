//
//  AddTwitterToUser.swift
//
//
//  Created by Raphaël Payet on 25/01/2024.
//

import Fluent

struct AddTwitterToUser: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(User.v20240125.schemaName)
            .field(User.v20240125b.twitterURL, .string)
            .update()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(User.v20240125.schemaName)
            .deleteField(User.v20240125b.twitterURL)
            .delete()
    }
}
