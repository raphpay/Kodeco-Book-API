//
//  Acronym.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

final class Acronym: Model, Content {
    static let schema = "acronyms"
    
    @ID
    var id: UUID?
    
    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String
    
    @Parent(key: "userID")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}

final class CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
