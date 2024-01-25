//
//  Acronym.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

final class Acronym: Model, Content {
    static let schema = Acronym.v20240125.schemaName
    
    @ID
    var id: UUID?
    
    @Field(key: Acronym.v20240125.short)
    var short: String
    
    @Field(key: Acronym.v20240125.long)
    var long: String
    
    @Parent(key: Acronym.v20240125.userID)
    var user: User
    
    @Siblings(through: AcronymCategoryPivot.self,
              from: \.$acronym,
              to: \.$category)
    var categories: [Category]
    
    init() {}
    
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}

struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
