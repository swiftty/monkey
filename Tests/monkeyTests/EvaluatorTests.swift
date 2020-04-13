import XCTest
@testable import monkey

final class EvaluatorTests: XCTestCase {
    func testEvalIntegerExpression() throws {
        let tests: [(input: String, expected: Int64)] = [
            ("5", 5),
            ("10", 10)
        ]

        for t in tests {
            let evaluated = _eval(t.input)
            try checkIntegerObject(evaluated, expected: t.expected)
        }
    }

    func testEvalBooleanExpression() throws {
        let tests: [(input: String, expected: Bool)] = [
            ("true", true),
            ("false", false)
        ]

        for t in tests {
            let evaluated = _eval(t.input)
            try checkBooleanObject(evaluated, expected: t.expected)
        }
    }
}

extension EvaluatorTests {
    private func _eval(_ input: String) -> Object? {
        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()

        return eval(program)
    }

    private func checkIntegerObject(_ obj: Object?, expected: Int64) throws {
        let result = try XCTUnwrap(obj as? Integer)
        XCTAssertEqual(result.value, expected)
    }

    private func checkBooleanObject(_ obj: Object?, expected: Bool) throws {
        let result = try XCTUnwrap(obj as? Boolean)
        XCTAssertEqual(result.value, expected)
    }
}
