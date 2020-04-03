import XCTest
@testable import monkey

final class ParserTests: XCTestCase {
    func testIdentifierExpression() throws {
        let input = """
        foobar;
        """

        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()
        try checkParserErrors(parser: parser)

        if case let count = program.statements.count, count != 1 {
            XCTFail("program.statements does not contain 1 statements. got=\(count)")
            return
        }
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("stmt not ExpressionStatement. got=\(type(of: program.statements[0]))")
            return
        }
        guard let ident = stmt.expression as? Identifier else {
            XCTFail("stmt not Identifier. got=\(type(of: stmt))")
            return
        }
        XCTAssertEqual(ident.value, "foobar")
        XCTAssertEqual(ident.tokenLiteral(), "foobar")
    }

    func testIntegerLiteralExpression() throws {
        let input = """
        5;
        """

        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()
        try checkParserErrors(parser: parser)

        if case let count = program.statements.count, count != 1 {
            XCTFail("program.statements does not contain 1 statements. got=\(count)")
            return
        }
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("stmt not ExpressionStatement. got=\(type(of: program.statements[0]))")
            return
        }
        guard let literal = stmt.expression as? IntegerLiteral else {
            XCTFail("stmt not Identifier. got=\(type(of: stmt))")
            return
        }
        XCTAssertEqual(literal.value, 5)
        XCTAssertEqual(literal.tokenLiteral(), "5")
    }

    func testLetStatements() throws {
        let input = """
        let x = 5;
        let y = 10;
        let foobar = 838383;
        """

        let expected = [
            "x", "y", "foobar"
        ]

        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()
        try checkParserErrors(parser: parser)
        if case let count = program.statements.count, count != expected.count {
            XCTFail("program.statements does not contain 3 statements. got=\(count)")
            return
        }

        for (i, name) in expected.enumerated() {
            let stmt = program.statements[i]
            checkLetStatement(stmt: stmt, name: name)
        }
    }

    func testReturnStatements() throws {
        let input = """
        return 5;
        return 10;
        return 993322;
        """

        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()
        try checkParserErrors(parser: parser)
        if case let count = program.statements.count, count != 3 {
            XCTFail("program.statements does not contain 3 statements. got=\(count)")
            return
        }

        for stmt in program.statements {
            guard let returnStmt = stmt as? ReturnStatement else {
                XCTFail("stmt not ReturnStatement. got=\(type(of: stmt))")
                continue
            }
            XCTAssertEqual(returnStmt.tokenLiteral(), "return")
        }
    }

    private func checkParserErrors(parser: Parser,
                                   file: StaticString = #file, line: UInt = #line) throws {
        if parser.errors.isEmpty {
            return
        }

        XCTFail("parser has \(parser.errors.count) errors.", file: file, line: line)
        for msg in parser.errors {
            XCTFail("parser error: \(msg)", file: file, line: line)
        }

        struct ParseError: Error {}
        throw ParseError()
    }

    private func checkLetStatement(stmt: Statement, name: String,
                                   file: StaticString = #file, line: UInt = #line) {
        if case let literal = stmt.tokenLiteral(), literal != "let" {
            XCTFail("stmt.tokenLiteral() not 'let'. got=\(literal)",
                file: file, line: line)
            return
        }

        guard let letStmt = stmt as? LetStatement else {
            XCTFail("stmt not LetStatement. got=\(type(of: stmt))",
                file: file, line: line)
            return
        }

        if letStmt.name.value != name {
            XCTFail("letStmt.name.value not '\(name)'. got=\(letStmt.name.value)",
                file: file, line: line)
            return
        }

        if letStmt.name.tokenLiteral() != name {
            XCTFail("letStmt.name.tokenLiteral() not '\(name)'. got=\(letStmt.name.tokenLiteral())",
                file: file, line: line)
            return
        }
    }

    static var allTests = [
        ("testLetStatements", testLetStatements),
        ("testReturnStatements", testReturnStatements)
    ]
}
