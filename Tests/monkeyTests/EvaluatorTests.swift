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
            .init("[1, 2, 3][0]", 1 as Int64),
            .init("[1, 2, 3][1]", 2 as Int64),
            .init("[1, 2, 3][2]", 3 as Int64),
            .init("let i = 0; [1][i];", 1 as Int64),
            .init("[1, 2, 3][1 + 1]", 3 as Int64),
            .init("let myArray = [1, 2, 3]; myArray[2];", 3 as Int64),
            .init("let myArray = [1, 2, 3]; myArray[0] + myArray[1] + myArray[2];", 6 as Int64),
            .init("[1, 2, 3][3]", nil),
            .init("[1, 2, 3][-1]", nil),
            .init("""
            let reduce = fn(arr, initial, f) {
                let iter = fn(arr, result) {
                    if (len(arr) == 0) {
                        result;
                    } else {
                        iter(rest(arr), f(result, first(arr)));
                    }
                };
                iter(arr, initial);
            };
            let sum = fn(arr) {
                reduce(arr, 0, fn(initial, el) {
                    initial + el;
                });
            };
            sum([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
            """, 55 as Int64)
        ]

        for t in tests {
            let evaluated = _eval(t.input)
            if let error = evaluated as? ERROR {
                XCTFail(error.message, file: t.file, line: t.line)
                continue
            }
            switch t.expected {
            case let expected as Int64:
                checkIntegerObject(evaluated, expected: expected, file: t.file, line: t.line)

            case let expected as Bool:
                checkBooleanObject(evaluated, expected: expected, file: t.file, line: t.line)

            case nil:
                XCTAssert(evaluated is Null)

            default:
                XCTFail()
            }
        }
    }

    func testIfElseExpression() {
        let tests: [ExpressionInput<Any?>] = [
            .init("if (true) { 10 }", 10 as Int64),
            .init("if (false) { 10 }", nil),
            .init("if (1) { 10 }", 10 as Int64),
            .init("if (1 < 2) { 10 }", 10 as Int64),
            .init("if (1 > 2) { 10 }", nil),
            .init("if (1 > 2) { 10 } else { 20 }", 20 as Int64),
            .init("if (1 < 2) { 10 } else { 20 }", 10 as Int64)
        ]

        for t in tests {
            let evaluated = _eval(t.input)
            switch t.expected {
            case let expected as Int64:
                checkIntegerObject(evaluated, expected: expected, file: t.file, line: t.line)

            case nil:
                XCTAssert(evaluated is Null, file: t.file, line: t.line)

            default:
                XCTFail(file: t.file, line: t.line)
            }
        }
    }

    func testReturnStatements() {
        let tests: [ExpressionInput<Any?>] = [
            .init("return 10;", 10 as Int64),
            .init("return 10; 9;", 10 as Int64),
            .init("return 2 * 5; 8;", 10 as Int64),
            .init("9; return 2 * 10; 9;", 20 as Int64),
            .init("if (10 > 1) { if (10 > 1) { return 10; } return 1; }", 10 as Int64)
        ]

        for t in tests {
            let evaluated = _eval(t.input)
            switch t.expected {
            case let expected as Int64:
                checkIntegerObject(evaluated, expected: expected, file: t.file, line: t.line)

            default:
                XCTFail(file: t.file, line: t.line)
            }

        }
    }

    func testErrorHandling() {
        let tests: [ExpressionInput<String>] = [
            .init("5 + true;", "type mismatch: INTEGER + BOOLEAN"),
            .init("5 + true; 5", "type mismatch: INTEGER + BOOLEAN"),
            .init("-true", "unknown operator: -BOOLEAN"),
            .init("true + false;", "unknown operator: BOOLEAN + BOOLEAN"),
            .init("5; true + false; 5", "unknown operator: BOOLEAN + BOOLEAN"),
            .init("if (10 > 1) { true + false; }", "unknown operator: BOOLEAN + BOOLEAN"),
            .init(
                """
                if ( 10 > 1 ) {
                    if (10 > 1) {
                        return true + false;
                    }
                    return 1;
                }
                """, "unknown operator: BOOLEAN + BOOLEAN"),
            .init("foobar", "identifier not found: foobar"),
            .init(#"{fn(x) { x }: "Monkey"}"#, "unusable as hash key: FUNCTION"),
            .init(#"{"name": "Monkey"}[fn(x) { x }]"#, "unusable as hash key: FUNCTION")
        ]

        for t in tests {
            let raw = _eval(t.input)
            guard let evaluated = raw as? ERROR else {
                XCTFail("no error object returned. got=\(raw.type.rawValue)", file: t.file, line: t.line)
                continue
            }
            XCTAssertEqual(evaluated.message, t.expected)
        }
    }

    func testLetStatements() {
        let tests: [ExpressionInput<Int64>] = [
            .init("let a = 5; a;", 5),
            .init("let a = 5 * 5; a;", 25),
            .init("let a = 5; let b = a; b;", 5),
            .init("let a = 5; let b = a; let c = a + b + 5; c;", 15)
        ]

        for t in tests {
            checkIntegerObject(_eval(t.input), expected: t.expected, file: t.file, line: t.line)
        }
    }

    func testFunctionApplication() {
        let tests: [ExpressionInput<Int64>] = [
            .init("let identity = fn(x) { x; }; identity(5);", 5),
            .init("let identity = fn(x) { return x; }; identity(5);", 5),
            .init("let double = fn(x) { x * 2; }; double(5);", 10),
            .init("let add = fn(x, y) { x + y; }; add(5, 5);", 10),
            .init("let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));", 20),
            .init("fn(x) { x; }(5);", 5)
        ]

        for t in tests {
            checkIntegerObject(_eval(t.input), expected: t.expected, file: t.file, line: t.line)
        }
    }

    func testHashLiterals() throws {
        let input = """
        let two = "two";
        {
            "one": 10 - 9,
            two: 1 + 1,
            "thr" + "ee": 6 / 2,
            4: 4,
            true: 5,
            false: 6
        }
        """

        let evaluated = _eval(input)
        let hash = try XCTUnwrap(evaluated as? Hash)
        let expected = [
            String_(value: "one").hashKey(): 1 as Int64,
            String_(value: "two").hashKey(): 2,
            String_(value: "three").hashKey(): 3,
            Integer(value: 4).hashKey(): 4,
            Boolean(value: true).hashKey(): 5,
            Boolean(value: false).hashKey(): 6
        ]

        XCTAssertEqual(hash.pairs.count, expected.count)
        for expected in expected {
            let pair = try XCTUnwrap(hash.pairs[expected.key])
            checkIntegerObject(pair.value, expected: expected.value)
        }
    }

    func testHashIndexExpressions() throws {
        let tests: [ExpressionInput<Int64?>] = [
            .init(#"{"foo": 5}["foo"]"#, 5),
            .init(#"{"foo": 5}["bar"]"#, nil),
            .init(#"let key = "foo"; {"foo": 5}[key]"#, 5),
            .init(#"{}["bar"]"#, nil),
            .init(#"{5: 5}[5]"#, 5),
            .init(#"{5: 5}[15 / 3]"#, 5),
            .init(#"{true: 5}[true]"#, 5)
        ]

        for t in tests {
            let result = _eval(t.input)
            if let expected = t.expected {
                checkIntegerObject(result, expected: expected, file: t.file, line: t.line)
            } else {
                XCTAssertTrue(result is Null, file: t.file, line: t.line)
            }
        }
    }

    func testBuiltinFunctions() {
        let tests: [ExpressionInput<Any>] = [
            .init(#"len("")"#, 0),
            .init(#"len("four")"#, 4),
            .init(#"len("hello world")"#, 11),
            .init(#"len(1)"#, "argument to `len` not supported, got INTEGER"),
            .init(#"len("one", "two")"#, "wrong number of arguments. got=2, want=1")
        ]

        for t in tests {
            switch t.expected {
            case let expected as Int:
                checkIntegerObject(_eval(t.input), expected: Int64(expected), file: t.file, line: t.line)

            case let expected as String:
                let evaluated = _eval(t.input) as? ERROR
                XCTAssertEqual(evaluated?.message, expected, file: t.file, line: t.line)

            default:
                XCTFail()
            }
        }
    }
}

extension EvaluatorTests {
    private func _eval(_ input: String) -> Object {
        var parser = Parser(lexer: .init(input))
        let program = parser.parseProgram()
        var env = Environment()

        return eval(program, env: &env)
    }

    private func checkIntegerObject(_ obj: Object?, expected: Int64,
                                    file: StaticString = #file, line: UInt = #line) {
        let result = obj as? Integer
        XCTAssertEqual(result?.value, expected, file: file, line: line)
    }

    private func checkBooleanObject(_ obj: Object?, expected: Bool,
                                    file: StaticString = #file, line: UInt = #line) {
        let result = obj as? Boolean
        XCTAssertEqual(result?.value, expected, file: file, line: line)
    }
}
