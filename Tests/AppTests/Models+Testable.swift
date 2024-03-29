//
//  File.swift
//  
//
//  Created by Raphaël Payet on 23/01/2024.
//

@testable import App
import Fluent

extension User {
    static func create(name: String = "Luke", 
                       username: String = "luckyluke",
                       on database: Database) async throws -> User {

        let user = User(name: name, username: username, password: "password")
        try await user.save(on: database)
        
        return user
    }
}

enum CreationError: Error {
    case badUserID, badAcronymID, badCategoryID
}

extension Acronym {
    static func create(short: String = "OMG",
                       long: String = "Oh my god",
                       user: User? = nil,
                       on database: Database) async throws -> Acronym {
        var acronymsUser = user
        if acronymsUser == nil {
            acronymsUser = try await User.create(on: database)
        }
        
        guard let userID = acronymsUser?.id else { throw CreationError.badUserID }
        
        let acronym = Acronym(short: short, long: long, userID: userID)
        try await acronym.save(on: database)
        
        return acronym
    }
}

extension App.Category {
    static func create(name: String = "Random", on database: Database) async throws -> App.Category {
        let category = App.Category(name: name)
        try await category.save(on: database)
        
        return category
    }
}
