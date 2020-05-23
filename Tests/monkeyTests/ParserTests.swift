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
        try checkLiteralExpresseion(stmt.expression, expected: "foobar")
    }

    func testBooleanLiteralExpression() throws {
        let tests: [(input: String, value: Bool)] = [
            ("false", false),
            ("true", true)
        ]

        for t in tests {
            var parser = Parser(lexer: .init(t.input))
            let program = parser.parseProgram()
            try checkParserErrors(parser: parser)

            if case let count = program.statements.count, count != 1 {
                XCTFail("program.statements does not contain 1 statements. got=\(count)")
                continue
            }

            let stmt = try XCTUnwrap(program.statements[0] as? ExpressionStatement)
            try checkLiteralExpresseion(stmt.expression, expected: t.value)
        }
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
        try checkLiteralExpresseion(stmt.expression, expected: 5)
    }

    func testStringLiteralExpression() throws {
        let input = """
        "hello world";
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
        try checkLiteralExpresseion(stmt.expression, expected: "hello world")
    }

    func testFunctionLiteralExpression() throws {
        let input = """
        fn(x, y) { x + y; }
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

        let function = try XCTUnwrap(stmt.expression as? FunctionLiteral)
        XCTAssertEqual(function.parameters.count, 2)
        try checkLiteralExpresseion(function.parameters[0], expected: "x")
        try checkLiteralExpresseion(function.parameters[1], expected: "y")

        XCTAssertEqual(function.body.statements.count, 1)
        let bodyStmt = try XCTUnwrap(function.body.statements.first as? ExpressionStatement)
        try checkInfixExpression(bodyStmt.expression, "x", "+", "y")
    }

    func testIndexExpression() throws {
        let input = "myArray[1 + 1]"

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

        let indexExp = try XCTUnwrap(stmt.expression as? IndexExpression)
        try checkLiteralExpresseion(indexExp.left, expected: "myArray")
        try checkInfixExpression(indexExp.index, 1, "+", 1)
    }

    func testFunctionParameter() throws {
        let tests: [(input: String, expectedParams: [String])] = [
            ("fn() {};", []),
            ("fn(x) {};", ["x"]),
            ("fn(x, y, z) {};", ["x", "y", "z"])
        ]

        for t in tests {
            var parser = Parser(lexer: .init(t.input))
            let program = parser.parseProgram()
            try checkParserErrors(parser: parser)

            let stmt = try XCTUnwrap(program.statements[0] as? ExpressionStatement)
            let function = try XCTUnwrap(stmt.expression as? FunctionLiteral)

            XCTAssertEqual(function.parameters.count, t.expectedParams.count)
            for (p, ident) in zip(function.parameters, t.expectedParams) {
                try checkLiteralExpresseion(p, expected: ident)
            }
        }
    }

    func testCallExpression() throws {
        let input = "add(1, 2 * 3, 4 + 5);"

        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()
        try checkParserErrors(parser: parser)

        let stmt = try XCTUnwrap(program.statements[0] as? ExpressionStatement)
        let exp = try XCTUnwrap(stmt.expression as? CallExpression)

        try checkLiteralExpresseion(exp.function, expected: "add")
        XCTAssertEqual(exp.arguments.count, 3)
        try checkLiteralExpresseion(exp.arguments[0], expected: 1)
        try checkInfixExpression(exp.arguments[1], 2, "*", 3)
        try checkInfixExpression(exp.arguments[2], 4, "+", 5)
    }

    func testPrefixExpression() throws {
        let tests: [(input: String, operator: String, value: Any)] = [
            ("!5", "!", 5),
            ("-15", "-", 15),
            ("!true;", "!", true),
            ("!false;", "!", false)
        ]

        for t in tests {
            var parser = Parser(lexer: .init(t.input))
            let program = parser.parseProgram()
            try checkParserErrors(parser: parser)

            if case let count = program.statements.count, count != 1 {
                XCTFail("program.statements does not contain 1 statements. got=\(count)")
                continue
            }

            let stmt = try XCTUnwrap(program.statements[0] as? ExpressionStatement)
            let exp = try XCTUnwrap(stmt.expression as? PrefixExpression)

            XCTAssertEqual(exp.operator, t.operator)
            try checkLiteralExpresseion(exp.right, expected: t.value)
        }
    }

    func testInfixExpression() throws {
        let tests: [(input: String, left: Any, operator: String, right: Any)] = [
            ("5 + 5", 5, "+", 5),
            ("5 - 5", 5, "-", 5),
            ("5 * 5", 5, "*", 5),
            ("5 / 5", 5, "/", 5),
            ("5 > 5", 5, ">", 5),
            ("5 < 5", 5, "<", 5),
            ("5 == 5", 5, "==", 5),
            ("5 != 5", 5, "!=", 5),
            ("true == true", true, "==", true),
            ("true != false", true, "!=", false),
            ("false == false", false, "==", false)
        ]

        for t in tests {
            var parser = Parser(lexer: .init(t.input))
            let program = parser.parseProgram()
            try checkParserErrors(parser: parser)

            if case let count = program.statements.count, count != 1 {
                XCTFail("program.statements does not contain 1 statements. got=\(count)")
                continue
            }

            let stmt = try XCTUnwrap(program.statements[0] as? ExpressionStatement)
            try checkInfixExpression(stmt.expression, t.left, t.operator, t.right)
        }
    }

    func testOperatorPrecedence() throws {
        let tests: [(input: String, expected: String)] = [
            ("-a * b", "((-a) * b)"),
            ("!-a", "(!(-a))"),
            ("a + b + c", "((a + b) + c)"),
            ("a + b - c", "((a + b) - c)"),
            ("a * b * c", "((a * b) * c)"),
            ("a * b / c", "((a * b) / c)"),
            ("a + b / c", "(a + (b / c))"),
            ("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"),
            ("3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"),
            ("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"),
            ("5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"),
            ("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
            ("true", "true"),
            ("false", "false"),
            ("3 > 5 == false", "((3 > 5) == false)"),
            ("3 < a == true", "((3 < a) == true)"),
            ("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"),
            ("(5 + 5) * 2", "((5 + 5) * 2)"),
            ("2 / (5 + 5)", "(2 / (5 + 5))"),
            ("-(5 + 5)", "(-(5 + 5))"),
            ("!(true == true)", "(!(true == true))"),
            ("a + add(b * c) + d", "((a + add((b * c))) + d)"),
            ("add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"),
            ("add(a + b + c * d / f)", "add(((a + b) + ((c * d) / f)))"),
            ("a * [1, 2, 3, 4][b * c] * d", "((a * ([1, 2, 3, 4][(b * c)])) * d)"),
            ("add(a * b[2], b[1], 2 * [1, 2][1])", "add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))")
        ]

        for t in tests {
            var parser = Parser(lexer: .init(t.input))
            let program = parser.parseProgram()
            try checkParserErrors(parser: parser)

            XCTAssertEqual(program.description, t.expected)
        }
    }

    func testLetStatements() throws {
        let tests: [(input: String, expectedIdentifier: String, expectedValue: Any)] = [
            ("let x = 5;", "x", 5),
            ("let y = true;", "y", true),
            ("let foobar = y;", "foobar", "y")
        ]

        for t in tests {
            var parser = Parser(lexer: .init(t.input))
            let program = parser.parseProgram()
            try checkParserErrors(parser: parser)
            if case let count = program.statements.count, count != 1 {
                XCTFail("program.statements does not contain 1 statements. got=\(count)")
                continue
            }

            let stmt = program.statements[0]
            try checkLetStatement(stmt, expected: t.expectedIdentifier)

            let val = try XCTUnwrap(stmt as? LetStatement).value
            try checkLiteralExpresseion(val, expected: t.expectedValue)
        }
    }

    func testReturnStatements() throws {
        let tests: [(input: String, expectedValue: Any?)] = [
            ("return;", nil),
            ("return 5;", 5),
            ("return true;", true),
            ("return foobar;", "foobar")
        ]

        for t in tests {
            var parser = Parser(lexer: .init(t.input))
            let program = parser.parseProgram()
            try checkParserErrors(parser: parser)
            if case let count = program.statements.count, count != 1 {
                XCTFail("program.statements does not contain 1 statements. got=\(count)")
                continue
            }

            let retStmt = try XCTUnwrap(program.statements[0] as? ReturnStatement)
            XCTAssertEqual(retStmt.tokenLiteral(), "return")
            if let expected = t.expectedValue {
                try checkLiteralExpresseion(retStmt.returnValue, expected: expected)
            } else {
                XCTAssertNil(retStmt.returnValue)
            }
        }
    }

    func testIfExpression() throws {
        let input = "if (x < y) { x }"

        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()
        try checkParserErrors(parser: parser)
        if case let count = program.statements.count, count != 1 {
            XCTFail("program.statements does not contain 1 statements. got=\(count)")
            return
        }

        let stmt = try XCTUnwrap(program.statements[0] as? ExpressionStatement)
        let exp = try XCTUnwrap(stmt.expression as? IfExpression)
        try checkInfixExpression(exp.condition, "x", "<", "y")

        let consequence = try XCTUnwrap(exp.consequence.statements.first as? ExpressionStatement)
        try checkLiteralExpresseion(consequence.expression, expected: "x")
        XCTAssertNil(exp.alternative)
    }

    func testIfElseExpression() throws {
        let input = "if (x < y) { x } else { y }"

        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()
        try checkParserErrors(parser: parser)
        if case let count = program.statements.count, count != 1 {
            XCTFail("program.statements does not contain 1 statements. got=\(count)")
            return
        }

        let stmt = try XCTUnwrap(program.statements[0] as? ExpressionStatement)
        let exp = try XCTUnwrap(stmt.expression as? IfExpression)
        try checkInfixExpression(exp.condition, "x", "<", "y")

        let consequence = try XCTUnwrap(exp.consequence.statements.first as? ExpressionStatement)
        try checkLiteralExpresseion(consequence.expression, expected: "x")

        let alternative = try XCTUnwrap(exp.alternative?.statements.first as? ExpressionStatement)
        try checkLiteralExpresseion(alternative.expression, expected: "y")
    }
}

extension ParserTests {
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

    private func checkLiteralExpresseion<T>(_ exp: Expression?, expected: T,
                                            file: StaticString = #file, line: UInt = #line) throws {
        func checkIdentifier(to value: String) throws {
            let identifier = try XCTUnwrap(exp as? Identifier, file: file, line: line)

            XCTAssertEqual(identifier.value, value, file: file, line: line)
            XCTAssertEqual(identifier.tokenLiteral(), value, file: file, line: line)
        }
        func checkBooleanLiteral(to value: Bool) throws {
            let bool = try XCTUnwrap(exp as? BooleanLiteral, file: file, line: line)

            XCTAssertEqual(bool.value, value, file: file, line: line)
            XCTAssertEqual(bool.tokenLiteral(), "\(value)", file: file, line: line)
        }
        func checkIntegerLiteral(to value: Int64) throws {
            let integ = try XCTUnwrap(exp as? IntegerLiteral, file: file, line: line)

            XCTAssertEqual(integ.value, value, file: file, line: line)
            XCTAssertEqual(integ.tokenLiteral(), "\(value)", file: file, line: line)
        }
        func checkStringLiteral(to value: String) throws {
            let string = try XCTUnwrap(exp as? StringLiteral, file: file, line: line)

            XCTAssertEqual(string.value, value, file: file, line: line)
            XCTAssertEqual(string.tokenLiteral(), value, file: file, line: line)
        }
        switch (expected, exp) {
        case (let v as Bool, _):
            try checkBooleanLiteral(to: v)

        case (let v as Int, _):
            try checkIntegerLiteral(to: Int64(v))

        case (let v as Int64, _):
            try checkIntegerLiteral(to: v)

        case (let v as String, is StringLiteral):
            try checkStringLiteral(to: v)

        case (let v as String, is Identifier):
            try checkIdentifier(to: v)

        default:
            XCTFail("type of exp not handled. got=\(T.self)", file: file, line: line)
        }
    }

    private func checkInfixExpression<Left, Right>(_ exp: Expression?,
                                                   _ left: Left,
                                                   _ operator: String,
                                                   _ right: Right,
                                                   file: StaticString = #file, line: UInt = #line) throws {
        let exp = try XCTUnwrap(exp as? InfixExpression, file: file, line: line)

        XCTAssertEqual(exp.operator, `operator`, file: file, line: line)
        try checkLiteralExpresseion(exp.left, expected: left, file: file, line: line)
        try checkLiteralExpresseion(exp.right, expected: right, file: file, line: line)
    }

    private func checkLetStatement(_ stmt: Statement, expected name: String,
                                   file: StaticString = #file, line: UInt = #line) throws {
        XCTAssertEqual(stmt.tokenLiteral(), "let", file: file, line: line)

        let letStmt = try XCTUnwrap(stmt as? LetStatement, file: file, line: line)
        XCTAssertEqual(letStmt.name.value, name, file: file, line: line)
        XCTAssertEqual(letStmt.name.tokenLiteral(), name, file: file, line: line)
    }
}
