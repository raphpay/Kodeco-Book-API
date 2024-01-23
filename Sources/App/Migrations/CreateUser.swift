//
//  CreateUser.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema("users")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema("users")
            .delete()
    }
    
    
}
