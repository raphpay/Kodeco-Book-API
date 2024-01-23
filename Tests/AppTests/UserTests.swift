//
//  UserTests.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    let expectedName = "Alice"
    let expectedUsername = "alicemerveilles"
    let usersURI = "/api/users/"
    var app: Application!
    
    override func setUp() {
        super.setUp()
        // Set up code here
    }
    
    override func tearDown() {
        // Tear down code here
        app.shutdown()
        super.tearDown()
    }
    
    func testUsersCanBeRetrievedFromAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(name: expectedName, username: expectedUsername, on: app.db)
        let _ = try await User.create(on: app.db)
        
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
