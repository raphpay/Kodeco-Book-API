//
//  CategoriesTests.swift
//
//
//  Created by Raphaël Payet on 23/01/2024.
//

import Foundation

@testable import App
import XCTVapor

final class CategoriesTests: XCTestCase {
    let expectedName = "Teenager"
    let expectedShort = "WTF"
    let expectedLong = "What The Flip"
    let categoriesURI = "/api/categories/"
    let acronymsURI = "/api/acronyms/"
    var app: Application!
    
    override func tearDown() {
        // Tear down code here
        app.shutdown()
        super.tearDown()
    }
}

// MARK: - Create
extension CategoriesTests {
    func testCategoryCanBeCreatedOnAPI() async throws {
        app = try await Application.testable()
        
        let category = App.Category(name: expectedName)
        guard let categoryID = category.id else { throw CreationError.badCategoryID }
        
        try app.test(.POST, categoriesURI) { req in
            try req.content.encode(category)
        } afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedCategory = try response.content.decode(App.Category.self)
            XCTAssertEqual(receivedCategory.name, category.name)
            XCTAssertEqual(receivedCategory.id, categoryID)
        }
    }
}

// MARK: - Read
extension CategoriesTests {
    func testCategoriesCanBeRetrievedFromAPI() async throws {
        app = try await Application.testable()
        
        let category = try await Category.create(name: expectedName, on: app.db)
        let _ = try await Category.create(on: app.db)
        guard let categoryID = category.id else { throw CreationError.badCategoryID }
        
        try app.test(.GET, categoriesURI) { response in
            XCTAssertEqual(response.status, .ok)
            
            let categories = try response.content.decode([App.Category].self)
            XCTAssertEqual(categories.count, 2)
            XCTAssertEqual(categories[0].name, category.name)
            XCTAssertEqual(categories[0].id, categoryID)
        }
    }
    
    func testGetSingleCategoryFromAPI() async throws {
        app = try await Application.testable()
        
        let category = try await Category.create(name: expectedName, on: app.db)
        let _ = try await Category.create(on: app.db)
        guard let categoryID = category.id else { throw CreationError.badCategoryID }
        
        try app.test(.GET, "\(categoriesURI)/\(categoryID)") { response in
            XCTAssertEqual(response.status, .ok)
            
            XCTAssertEqual(response.status, .ok)
            
            let receivedCategory = try response.content.decode(App.Category.self)
            XCTAssertEqual(receivedCategory.name, category.name)
            XCTAssertEqual(receivedCategory.id, categoryID)
        }
    }
    
    func testGetAcronymsCategoryFromAPI() async throws {
        app = try await Application.testable()
        
        let acronym = try await Acronym.create(short: expectedShort, long: expectedLong, on: app.db)
        guard let acronymID = acronym.id else { throw CreationError.badAcronymID }
        
        let category = try await Category.create(name: expectedName, on: app.db)
        guard let categoryID = category.id else { throw CreationError.badCategoryID }
        
        try await app.test(.POST, "\(acronymsURI)/\(acronymID)/categories/\(categoryID)")
        
        try app.test(.GET, "\(categoriesURI)/\(categoryID)/acronyms") { response in
            XCTAssertEqual(response.status, .ok)
            
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 1)
            XCTAssertEqual(acronyms[0].short, expectedShort)
            XCTAssertEqual(acronyms[0].long, expectedLong)
        }
    }
}

// MARK: - Update
// MARK: - Delete
