//
//  CreateAcronymCategoryPivot.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent

struct CreateAcronymCategoryPivot: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema("acronym-category-pivot")
            .id()
            .field("acronymID", .uuid, .required, .references("acronyms", "id"))
            .field("categoryID", .uuid, .required, .references("categories", "id"))
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema("acronym-category-pivot")
            .delete()
    }
    
    
}
