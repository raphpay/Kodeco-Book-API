//
//  UserTests.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    func testUsersCanBeRetrievedFromAPI() async throws {
        let expectedName = "Alice"
        let expectedUsername = "alicemerveilles"
        
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
        
        let user = User(name: expectedName, username: expectedUsername)
        try await user.save(on: app.db)
        try await User(name: "Luke", username: "luckyluke").save(on: app.db)
        
        try app.test(.GET, "/api/users") { response in
            XCTAssertEqual(response.status, .ok)
            
            let users = try response.content.decode([User].self)
            
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, expectedName)
            XCTAssertEqual(users[0].username, expectedUsername)
            XCTAssertEqual(users[0].id, user.id)
        }
    }
}
