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
            .schema(AcronymCategoryPivot.v20240125.schemaName)
            .id()
            .field(AcronymCategoryPivot.v20240125.acronymID, .uuid, .required,
                   .references(Acronym.v20240125.schemaName, Acronym.v20240125.id))
            .field(AcronymCategoryPivot.v20240125.categoryID, .uuid, .required, 
                .references(Category.v20240125.schemaName, Category.v20240125.id))
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(AcronymCategoryPivot.v20240125.schemaName)
            .delete()
    }
}

extension AcronymCategoryPivot {
    enum v20240125 {
        static let schemaName = "acronym-category-pivot"
        static let acronymID = FieldKey(stringLiteral: "acronymID")
        static let categoryID = FieldKey(stringLiteral: "categoryID")
    }
}
