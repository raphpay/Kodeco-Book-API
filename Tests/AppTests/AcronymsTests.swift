//
//  AcronymsTests.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

@testable import App
import XCTVapor

final class AcronymsTests: XCTestCase {
    let expectedShort = "WTF"
    let expectedLong = "What The Flip"
    let expectedName = "Alice"
    let expectedUsername = "alicemerveilles"
    let expectedCategoryName = "Teenager"
    let acronymsURI = "/api/acronyms/"
    var app: Application!
    
    override func tearDown() {
        // Tear down code here
        app.shutdown()
        super.tearDown()
    }
    
    func testAcronymCanBeSavedWithAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(on: app.db)
        guard let userID = user.id else { throw CreationError.badUserID }
        
        let acronymData = CreateAcronymData(short: expectedShort, long: expectedLong, userID: userID)
        
        try app.test(.POST, acronymsURI) { req in
            try req.content.encode(acronymData)
        } afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedAcronym = try response.content.decode(Acronym.self)
            XCTAssertEqual(receivedAcronym.short, expectedShort)
            XCTAssertEqual(receivedAcronym.long, expectedLong)
            XCTAssertNotNil(receivedAcronym.id)
        }
    }
    
    func testAcronymsCategories() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(on: app.db)
        guard let userID = user.id else { throw CreationError.badUserID }
        
        let acronym = try await Acronym.create(on: app.db)
        guard let acronymID = acronym.id else { throw CreationError.badAcronymID }
        
        let category = try await Category.create(name: expectedCategoryName, on: app.db)
        let categoryTwo = try await Category.create(on: app.db)
        guard let categoryID = category.id,
              let categoryTwoID = categoryTwo.id else { throw CreationError.badCategoryID }
        
        try await app.test(.POST, "\(acronymsURI)/\(acronymID)/categories/\(categoryID)")
        try await app.test(.POST, "\(acronymsURI)/\(acronymID)/categories/\(categoryTwoID)")
    
        try app.test(.GET, "\(acronymsURI)/\(acronymID)/categories") { response in
            XCTAssertEqual(response.status, .ok)
            
            let categories = try response.content.decode([App.Category].self)
            XCTAssertEqual(categories.count, 2)
            XCTAssertEqual(categories[0].name, expectedCategoryName)
            XCTAssertEqual(categories[0].id, categoryID)
        }
        
        try await app.test(.DELETE, "\(acronymsURI)/\(acronymID)/categories/\(categoryTwoID)")
        
        try app.test(.GET, "\(acronymsURI)/\(acronymID)/categories") { response in
            XCTAssertEqual(response.status, .ok)
            
            let categories = try response.content.decode([App.Category].self)
            XCTAssertEqual(categories.count, 1)
            XCTAssertEqual(categories[0].name, expectedCategoryName)
            XCTAssertEqual(categories[0].id, categoryID)
        }
    }
    
    func testAcronymsCanBeRetrievedFromAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(on: app.db)
        
        let acronym = try await Acronym.create(short: expectedShort, long: expectedLong, user: user, on: app.db)
        let _ = try await Acronym.create(on: app.db)
        
        try app.test(.GET, acronymsURI) { response in
            XCTAssertEqual(response.status, .ok)
            
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 2)
            XCTAssertEqual(acronyms[0].short, expectedShort)
            XCTAssertEqual(acronyms[0].long, expectedLong)
            XCTAssertEqual(acronyms[0].id, acronym.id)
        }
    }
    
    func testGetSingleAcronymFromAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(on: app.db)
        
        let acronym = try await Acronym.create(short: expectedShort, long: expectedLong, user: user, on: app.db)
        guard let acronymID = acronym.id else { throw CreationError.badAcronymID }
        
        try app.test(.GET, "\(acronymsURI)/\(acronymID)") { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedAcronym = try response.content.decode(Acronym.self)
            
            XCTAssertEqual(receivedAcronym.short, expectedShort)
            XCTAssertEqual(receivedAcronym.long, expectedLong)
            XCTAssertEqual(receivedAcronym.id, acronym.id)
        }
    }
    
    func testGetAcronymsUserFromAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(name: expectedName, username: expectedUsername, on: app.db)
        guard let userID = user.id else { throw CreationError.badUserID }
        
        let acronym = try await Acronym.create(user: user, on: app.db)
        guard let acronymID = acronym.id else { throw CreationError.badAcronymID }
        
        try app.test(.GET, "\(acronymsURI)/\(acronymID)/user") { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedUser = try response.content.decode(User.self)
            
            XCTAssertEqual(receivedUser.name, expectedName)
            XCTAssertEqual(receivedUser.username, expectedUsername)
            XCTAssertEqual(receivedUser.id, userID)
        }
    }
    
    func testUpdateAcronymOnAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(name: expectedName, username: expectedUsername, on: app.db)
        guard let userID = user.id else { throw CreationError.badUserID }
        
        let acronym = try await Acronym.create(user: user, on: app.db)
        guard let acronymID = acronym.id else { throw CreationError.badAcronymID }
        
        let updatedAcronymData = CreateAcronymData(short: expectedShort, long: expectedLong, userID: userID)
        
        try app.test(.PUT, "\(acronymsURI)/\(acronymID)") { req in
            try req.content.encode(updatedAcronymData)
        } afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedAcronym = try response.content.decode(Acronym.self)
            XCTAssertEqual(receivedAcronym.short, expectedShort)
            XCTAssertEqual(receivedAcronym.long, expectedLong)
            XCTAssertEqual(receivedAcronym.id, acronymID)
        }
    }
    
    func testDeleteAcronymFromAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(name: expectedName, username: expectedUsername, on: app.db)
        
        let acronym = try await Acronym.create(user: user, on: app.db)
        guard let acronymID = acronym.id else { throw CreationError.badAcronymID }
        
        try await app.test(.DELETE, "\(acronymsURI)/\(acronymID)")
        
        try app.test(.GET, acronymsURI) { response in
            XCTAssertEqual(response.status, .ok)
            
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 0)
        }
    }
    
    func testSearchAcronymWithShortOnAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(name: expectedName, username: expectedUsername, on: app.db)
        
        let acronym = try await Acronym.create(short: expectedShort, user: user, on: app.db)
        guard let acronymID = acronym.id else { throw CreationError.badAcronymID }
        
        try app.test(.GET, "\(acronymsURI)/search?term=\(expectedShort)") { response in
            XCTAssertEqual(response.status, .ok)
            
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 1)
            XCTAssertEqual(acronyms[0].short, expectedShort)
            XCTAssertEqual(acronyms[0].id, acronymID)
        }
    }
    
    func testSearchAcronymWithLongOnAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(name: expectedName, username: expectedUsername, on: app.db)
        
        let acronym = try await Acronym.create(long: expectedLong, user: user, on: app.db)
        guard let acronymID = acronym.id else { throw CreationError.badAcronymID }
        
        try app.test(.GET, "\(acronymsURI)/search?term=\(expectedLong)") { response in
            XCTAssertEqual(response.status, .ok)
            
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 1)
            XCTAssertEqual(acronyms[0].long, expectedLong)
            XCTAssertEqual(acronyms[0].id, acronymID)
        }
    }
    
    func testGetFirstAcronymFromAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(on: app.db)
        
        let acronym = try await Acronym.create(short: expectedShort, long: expectedLong, user: user, on: app.db)
        let _ = try await Acronym.create(on: app.db)
        
        try app.test(.GET, "\(acronymsURI)/first") { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedAcronym = try response.content.decode(Acronym.self)
            
            XCTAssertEqual(receivedAcronym.short, expectedShort)
            XCTAssertEqual(receivedAcronym.long, expectedLong)
            XCTAssertEqual(receivedAcronym.id, acronym.id)
        }
    }
    
    func testGetSortedAcronymsFromAPI() async throws {
        app = try await Application.testable()
        
        let user = try await User.create(name: expectedName, username: expectedUsername, on: app.db)
        
        let acronym = try await Acronym.create(short: expectedShort, long: expectedLong, user: user, on: app.db)
        let expectedFirstShort = "LOL"
        let expectedFirstLong = "Laugh Out Loud"
        let acronymTwo = try await Acronym.create(short: expectedFirstShort, long: expectedFirstLong, on: app.db)
        guard let acronymID = acronym.id,
              let acronymTwoID = acronymTwo.id else { throw CreationError.badAcronymID }
        
        try app.test(.GET, "\(acronymsURI)/sorted") { response in
            XCTAssertEqual(response.status, .ok)
            
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 2)
            XCTAssertEqual(acronyms[0].short, expectedFirstShort)
            XCTAssertEqual(acronyms[0].long, expectedFirstLong)
            XCTAssertEqual(acronyms[0].id, acronymTwoID)
        }
    }
}
