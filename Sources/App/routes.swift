import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    // 1
    app.post("api", "acronyms") { req -> EventLoopFuture<Acronym> in
      // 2
      let acronym = try req.content.decode(Acronym.self)
      // 3
      return acronym.save(on: req.db).map {
        // 4
        acronym
      }
    }
    
    // 1
    app.get("api", "acronyms") {
      req -> EventLoopFuture<[Acronym]> in
      // 2
      Acronym.query(on: req.db).all()
    }

    // 1
    app.get("api", "acronyms", ":acronymID") {
      req -> EventLoopFuture<Acronym> in
      // 2
      Acronym.find(req.parameters.get("acronymID"), on: req.db)
        // 3
        .unwrap(or: Abort(.notFound))
    }
    
    // 1
    app.put("api", "acronyms", ":acronymID") {
      req -> EventLoopFuture<Acronym> in
      // 2
      let updatedAcronym = try req.content.decode(Acronym.self)
      return Acronym.find(
          req.parameters.get("acronymID"),
          on: req.db)
        .unwrap(or: Abort(.notFound)).flatMap { acronym in
          acronym.short = updatedAcronym.short
          acronym.long = updatedAcronym.long
          return acronym.save(on: req.db).map {
            acronym
          }
      }
    }

    // 1
    app.delete("api", "acronyms", ":acronymID") {
      req -> EventLoopFuture<HTTPStatus> in
      // 2
      Acronym.find(req.parameters.get("acronymID"), on: req.db)
        .unwrap(or: Abort(.notFound))
        // 3
        .flatMap { acronym in
          // 4
          acronym.delete(on: req.db)
            // 5
            .transform(to: .noContent)
      }
    }
    
    // 1
//    app.get("api", "acronyms", "search") {
//      req -> EventLoopFuture<[Acronym]> in
//      // 2
//      guard let searchTerm =
//        req.query[String.self, at: "term"] else {
//        throw Abort(.badRequest)
//      }
//      // 3
//      return Acronym.query(on: req.db)
//        .filter(\.$short == searchTerm)
//        .all()
//    }
    
    app.get("api", "acronyms", "search") {
      req -> EventLoopFuture<[Acronym]> in
      // 2
      guard let searchTerm =
        req.query[String.self, at: "term"] else {
        throw Abort(.badRequest)
      }
      // 3
        return Acronym.query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }
            .all()
    }
    
    // 1
    app.get("api", "acronyms", "first") {
      req -> EventLoopFuture<Acronym> in
      // 2
      Acronym.query(on: req.db)
        .first()
        .unwrap(or: Abort(.notFound))
    }



//    try app.register(collection: TodoController())
}
