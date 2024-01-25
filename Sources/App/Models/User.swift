//
//  User.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema: String = User.v20240125.schemaName
    
    @ID
    var id: UUID?
    
    @Field(key: User.v20240125.name)
    var name: String
    
    @Field(key: User.v20240125.username)
    var username: String
    
    @Field(key: User.v20240125.password)
    var password: String
    
    @Children(for: \.$user)
    var acronyms: [Acronym]
    
    @OptionalField(key: User.v20240125b.twitterURL)
    var twitterURL: String?
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String, password: String, twitterURL: String? = nil) {
        self.id = id
        self.name = name
        self.username = username
        self.password = password
        self.twitterURL = twitterURL
    }
    
    final class Public: Content {
        var id: UUID?
        var name: String
        var username: String
        
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username)
    }
}

extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}


extension Collection where Element: User {
    func convertToPublic() -> [User.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<User> {
    func convertToPublic() -> EventLoopFuture<[User.Public]> {
        return self.map { $0.convertToPublic() }
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
