//
//  Category.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

final class Category: Model, Content {
    static let schema: String = Category.v20240125.schemaName
    
    @ID
    var id: UUID?
    
    @Field(key: Category.v20240125.name)
    var name: String
    
    @Siblings(through: AcronymCategoryPivot.self,
              from: \.$category,
              to: \.$acronym)
    var acronyms: [Acronym]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
