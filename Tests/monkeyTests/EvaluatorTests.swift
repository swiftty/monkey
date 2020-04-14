import XCTest
@testable import monkey

final class EvaluatorTests: XCTestCase {
    func testEvalExpression() throws {
        let tests: [(input: String, expected: Any?)] = [
            ("5", 5 as Int64),
            ("10", 10 as Int64),
            ("true", true),
            ("false", false),
            ("!true", false),
            ("!false", true),
            ("!5", false),
            ("!!true", true),
            ("!!false", false),
            ("!!5", true),
            ("1 < 2", true),
            ("1 > 2", false),
            ("1 < 1", false),
            ("1 > 1", false),
            ("1 == 1", true),
            ("1 != 1", false),
            ("1 == 2", false),
            ("1 != 2", true),
            ("true == true", true),
            ("false == false", true),
            ("true == false", false),
            ("true != false", true),
            ("false != true", true),
            ("(1 < 2) == true", true),
            ("(1 < 2) == false", false),
            ("(1 > 2) == true", false),
            ("(1 > 2) == false", true),
            ("-5", -5 as Int64),
            ("-10", -10 as Int64),
            ("5 + 5 + 5 + 5 - 10", 10 as Int64),
            ("5 + 5 + 5 + 5 - 30", -10 as Int64),
            ("2 * 2 * 2 * 2 * 2", 32 as Int64),
            ("-50 + 100 + -50", 0 as Int64),
            ("5 * 2 + 10", 20 as Int64),
            ("5 + 2 * 10", 25 as Int64),
            ("20 + 2 * -10", 0 as Int64),
            ("50 / 2 * 2 + 10", 60 as Int64),
            ("2 * (5 + 10)", 30 as Int64),
            ("3 * 3 * 3 + 10", 37 as Int64),
            ("3 * (3 * 3) + 10", 37 as Int64),
            ("(5 + 10 * 2 + 15 / 3) * 2 + -10", 50 as Int64),
        ]

        for t in tests {
            let evaluated = _eval(t.input)
            switch t.expected {
            case let expected as Int64:
                try checkIntegerObject(evaluated, expected: expected)

            case let expected as Bool:
                try checkBooleanObject(evaluated, expected: expected)

            case nil:
                XCTAssert(evaluated is Null)

            default:
                XCTFail()
            }
        }
    }
}

extension EvaluatorTests {
    private func _eval(_ input: String) -> Object? {
        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()

        return eval(program)
    }

    private func checkIntegerObject(_ obj: Object?, expected: Int64,
                                    file: StaticString = #file, line: UInt = #line) throws {
        let result = try XCTUnwrap(obj as? Integer, file: file, line: line)
        XCTAssertEqual(result.value, expected, file: file, line: line)
    }

    private func checkBooleanObject(_ obj: Object?, expected: Bool,
                                    file: StaticString = #file, line: UInt = #line) throws {
        let result = try XCTUnwrap(obj as? Boolean, file: file, line: line)
        XCTAssertEqual(result.value, expected, file: file, line: line)
    }
}
