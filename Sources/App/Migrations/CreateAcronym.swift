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
            .schema("acronyms")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema("acronyms")
            .delete()
    }    
}
