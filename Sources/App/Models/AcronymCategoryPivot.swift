//
//  AcronymCategoryPivot.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

final class AcronymCategoryPivot: Model, Content {
    static let schema: String = AcronymCategoryPivot.v20240125.schemaName
    
    @ID
    var id: UUID?
    
    @Parent(key: AcronymCategoryPivot.v20240125.acronymID)
    var acronym: Acronym
    
    @Parent(key: AcronymCategoryPivot.v20240125.categoryID)
    var category: Category
    
    init() {}
    
    init(id: UUID? = nil, acronym: Acronym, category: Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
}
