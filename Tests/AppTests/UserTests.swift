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
    let expectedShort = "WTF"
    let expectedLong = "What The Flip"
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
    
    func testUserCanBeCreatedOnAPI() async throws {
        app = try await Application.testable()
        
        let user = User(name: expectedName, username: expectedUsername)
        
        try app.test(.POST, usersURI) { req in
            try req.content.encode(user)
        } afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedUser = try response.content.decode(User.self)
            XCTAssertEqual(receivedUser.name, expectedName)
            XCTAssertEqual(receivedUser.username, expectedUsername)
            XCTAssertNotNil(receivedUser.id)
        }

    }
    
    func testUsersCanBeRetrievedFromAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(name: expectedName, username: expectedUsername, on: app.db)
        let _ = try await User.create(on: app.db)
        
        try app.test(.GET, usersURI) { response in
            XCTAssertEqual(response.status, .ok)
            
            let users = try response.content.decode([User].self)
            
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, expectedName)
            XCTAssertEqual(users[0].username, expectedUsername)
            XCTAssertEqual(users[0].id, user.id)
        }
    }
    
    func testGetSingleUserFromAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(name: expectedName, username: expectedUsername, on: app.db)
        let _ = try await User.create(on: app.db)
        
        guard let userID = user.id else { return }
        
        try app.test(.GET, "\(usersURI)/\(userID)") { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedUser = try response.content.decode(User.self)
            
            XCTAssertEqual(receivedUser.name, expectedName)
            XCTAssertEqual(receivedUser.username, expectedUsername)
            XCTAssertEqual(receivedUser.id, userID)
        }
    }
    
    func testGetUsersAcronyms() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(on: app.db)
        let acronym = try await Acronym.create(short: expectedShort, long: expectedLong, user: user, on: app.db)
        let _ = try await Acronym.create(short: "LOL", long: "Laug Out Loud", user: user, on: app.db)
        
        guard let userID = user.id else { return }
        
        try app.test(.GET, "\(usersURI)/\(userID)/acronyms") { response in
            XCTAssertEqual(response.status, .ok)
            
            let acronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(acronyms.count, 2)
            XCTAssertEqual(acronyms[0].short, expectedShort)
            XCTAssertEqual(acronyms[0].long, expectedLong)
            XCTAssertEqual(acronyms[0].id, acronym.id)
            XCTAssertEqual(acronyms[0].user.id, userID)
        }
    }
}
