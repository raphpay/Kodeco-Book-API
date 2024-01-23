//
//  Category.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

final class Category: Model, Content {
    static let schema: String = "categories"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
