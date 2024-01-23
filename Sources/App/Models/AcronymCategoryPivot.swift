//
//  AcronymCategoryPivot.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

final class AcronymCategoryPivot: Model, Content {
    static let schema: String = "acronym-category-pivot"
    
    @ID
    var id: UUID?
    
    @Parent(key: "acronymID")
    var acronym: Acronym
    
    @Parent(key: "categoryID")
    var category: Category
    
    init() {}
    
    init(id: UUID? = nil, acronym: Acronym, category: Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
}
