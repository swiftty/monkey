import XCTest
@testable import monkey

final class ASTTests: XCTestCase {
    func testString() throws {
        let program = Program(statements: [
            LetStatement(token: Token(type: .LET, literal: "let"),
                         name: Identifier(token: .init(type: .IDENT, literal: "myVar"), value: "myVar"),
                         value: Identifier(token: .init(type: .IDENT, literal: "anotherVar"), value: "anotherVar"))

        ])

        XCTAssertEqual(program.description, "let myVar = anotherVar;")
    }
}
