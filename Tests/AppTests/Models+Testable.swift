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
        let user = User(name: name, username: username)
        try await user.save(on: database)
        
        return user
    }
}
