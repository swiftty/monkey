import XCTest
@testable import monkey

final class EvaluatorTests: XCTestCase {
    func testEvalExpression() {
        let tests: [ExpressionInput<Any?>] = [
            .init("5", 5 as Int64),
            .init("10", 10 as Int64),
            .init("true", true),
            .init("false", false),
            .init("!true", false),
            .init("!false", true),
            .init("!5", false),
            .init("!!true", true),
            .init("!!false", false),
            .init("!!5", true),
            .init("1 < 2", true),
            .init("1 > 2", false),
            .init("1 < 1", false),
            .init("1 > 1", false),
            .init("1 == 1", true),
            .init("1 != 1", false),
            .init("1 == 2", false),
            .init("1 != 2", true),
            .init("true == true", true),
            .init("false == false", true),
            .init("true == false", false),
            .init("true != false", true),
            .init("false != true", true),
            .init("(1 < 2) == true", true),
            .init("(1 < 2) == false", false),
            .init("(1 > 2) == true", false),
            .init("(1 > 2) == false", true),
            .init("-5", -5 as Int64),
            .init("-10", -10 as Int64),
            .init("5 + 5 + 5 + 5 - 10", 10 as Int64),
            .init("5 + 5 + 5 + 5 - 30", -10 as Int64),
            .init("2 * 2 * 2 * 2 * 2", 32 as Int64),
            .init("-50 + 100 + -50", 0 as Int64),
            .init("5 * 2 + 10", 20 as Int64),
            .init("5 + 2 * 10", 25 as Int64),
            .init("20 + 2 * -10", 0 as Int64),
            .init("50 / 2 * 2 + 10", 60 as Int64),
            .init("2 * (5 + 10)", 30 as Int64),
            .init("3 * 3 * 3 + 10", 37 as Int64),
            .init("3 * (3 * 3) + 10", 37 as Int64),
            .init("(5 + 10 * 2 + 15 / 3) * 2 + -10", 50 as Int64),
        ]

        for t in tests {
            let evaluated = _eval(t.input)
            switch t.expected {
            case let expected as Int64:
                XCTAssertNoThrow(try checkIntegerObject(evaluated, expected: expected, file: t.file, line: t.line))

            case let expected as Bool:
                XCTAssertNoThrow(try checkBooleanObject(evaluated, expected: expected, file: t.file, line: t.line))

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
