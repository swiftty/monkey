private enum Const {
    static let NULL = Null()
    static let TRUE = Boolean(value: true)
    static let FALSE = Boolean(value: false)
}

private extension Boolean {
    static func from(native flag: Bool) -> Boolean {
        flag ? Const.TRUE : Const.FALSE
    }

    func toggled() -> Boolean {
        value ? Const.FALSE : Const.TRUE
    }
}

public func eval(_ node: Node?, env: inout Environment) -> Object? {
    switch node {
    case let node as Program:
        return evalProgram(node, env: &env)

    case let node as ExpressionStatement:
        return eval(node.expression, env: &env)

    case let node as IntegerLiteral:
        return Integer(value: node.value)

    case let node as BooleanLiteral:
        return Boolean.from(native: node.value)

    case let node as StringLiteral:
        return String_(value: node.value)

    case let node as PrefixExpression:
        let right = eval(node.right, env: &env)
        if isError(right) {
            return right
        }
        return evalPrefixExpression(node.operator, right)

    case let node as InfixExpression:
        let left = eval(node.left, env: &env)
        if isError(left) {
            return left
        }
        let right = eval(node.right, env: &env)
        if isError(right) {
            return right
        }
        return evalInfixExpression(node.operator, left, right)

    case let node as BlockStatement:
        return evalBlockStatement(node, env: &env)

    case let node as IfExpression:
        return evalIfExpression(node, env: &env)

    case let node as ReturnStatement:
        let val = eval(node.returnValue, env: &env) ?? Const.NULL
        if isError(val) {
            return val
        }
        return ReturnValue(value: val)

    case let node as LetStatement:
        let val = eval(node.value, env: &env)
        if isError(val) {
            return val
        }
        env[node.name.value] = val
        return nil

    case let node as Identifier:
        return evalIdentifier(node, env: &env)

    case let node as FunctionLiteral:
        return Function(parameters: node.parameters, body: node.body, env: env)

    case let node as CallExpression:
        let function = eval(node.function, env: &env)
        if isError(function) {
            return function
        }
        let args = evalExpressions(node.arguments, env: &env)
        if isError(args.first ?? nil) {
            return args.first ?? nil
        }
        return applyFunction(function, arguments: args)

    default:
        return nil
    }
}

// MARK: - private -
private func evalProgram(_ program: Program, env: inout Environment) -> Object? {
    var result: Object?
    for stmt in program.statements {
        result = eval(stmt, env: &env)

        switch result {
        case let result as ReturnValue:
            return result.value

        case is ERROR:
            return result

        default:
            break
        }
    }
    return result
}

private func evalStatements(_ statements: [Statement], env: inout Environment) -> Object? {
    var result: Object?
    for stmt in statements {
        result = eval(stmt, env: &env)

        if let r = result as? ReturnValue {
            return r.value
        }
    }
    return result
}

private func evalBlockStatement(_ block: BlockStatement, env: inout Environment) -> Object? {
    var result: Object?
    for stmt in block.statements {
        result = eval(stmt, env: &env)

        switch result {
        case is ReturnValue, is ERROR:
            return result

        default:
            break
        }
    }
    return result
}

private func evalPrefixExpression(_ operator: String, _ right: Object?) -> Object? {
    switch `operator` {
    case "!":
        return evalBangOperatorExpression(right)

    case "-":
        return evalMinusPrefixOperatorExpression(right)

    default:
        return ERROR(message: "unknown operator: \(`operator`)\((right ?? Const.NULL).type.rawValue)")
    }
}

private func evalBangOperatorExpression(_ right: Object?) -> Object {
    switch right {
    case let bool as Boolean:
        return bool.toggled()

    case is Null:
        return Const.TRUE

    default:
        return Const.FALSE
    }
}

private func evalMinusPrefixOperatorExpression(_ right: Object?) -> Object {
    guard let r = right as? Integer else {
        return ERROR(message: "unknown operator: -\((right ?? Const.NULL).type)")
    }
    return Integer(value: -r.value)
}

private func evalInfixExpression(_ operator: String, _ left: Object?, _ right: Object?) -> Object {
    switch (left, right) {
    case (let left as Integer, let right as Integer):
        return evalIntegerInfixExpression(`operator`, left, right)

    case (let left as String_, let right as String_):
        return evalStringInfixExpression(`operator`, left, right)

    case (let left?, let right?) where `operator` == "==":
        return Boolean.from(native: left === right)

    case (let left?, let right?) where `operator` == "!=":
        return Boolean.from(native: left !== right)

    case (let left?, let right?) where left.type != right.type:
        return ERROR(message: "type mismatch: \(left.type) \(`operator`) \(right.type)")

    default:
        let left = left ?? Const.NULL
        let right = right ?? Const.NULL
        return ERROR(message: "unknown operator: \(left.type) \(`operator`) \(right.type)")
    }
}

private func evalIntegerInfixExpression(_ operator: String, _ left: Integer, _ right: Integer) -> Object {
    switch  `operator` {
    case "+":
        return Integer(value: left.value + right.value)

    case "-":
        return Integer(value: left.value - right.value)

    case "*":
        return Integer(value: left.value * right.value)

    case "/":
        return Integer(value: left.value / right.value)

    case "<":
        return Boolean.from(native: left.value < right.value)

    case ">":
        return Boolean.from(native: left.value > right.value)

    case "==":
        return Boolean.from(native: left.value == right.value)

    case "!=":
        return Boolean.from(native: left.value != right.value)

    default:
        return Const.NULL
    }
}

private func evalStringInfixExpression(_ operator: String, _ left: String_, _ right: String_) -> Object {
    switch  `operator` {
    case "+":
        return String_(value: left.value + right.value)

    case "==":
        return Boolean.from(native: left.value == right.value)

    case "!=":
        return Boolean.from(native: left.value != right.value)

    default:
        return ERROR(message: "unknown operator: \(left.type) \(`operator`) \(right.type)")
    }
}

private func evalIfExpression(_ ie: IfExpression, env: inout Environment) -> Object? {
    let condition = eval(ie.condition, env: &env)
    if isError(condition) {
        return condition
    }
    if isTruthy(condition) {
        return eval(ie.consequence, env: &env)
    } else if let alt = ie.alternative {
        return eval(alt, env: &env)
    } else {
        return Const.NULL
    }
}

private func evalIdentifier(_ node: Identifier, env: inout Environment) -> Object? {
    guard let val = env[node.value] else {
        return ERROR(message: "identifier not found: \(node.value)")
    }
    return val
}

private func evalExpressions(_ expressions: [Expression], env: inout Environment) -> [Object?] {
    var result: [Object?] = []
    for e in expressions {
        let evaluated = eval(e, env: &env)
        if isError(evaluated) {
            return [evaluated]
        }
        result.append(evaluated)
    }
    return result
}

private func applyFunction(_ fn: Object?, arguments args: [Object?]) -> Object? {
    guard let function = fn as? Function else {
        return ERROR(message: "not a function: \((fn ?? Const.NULL).type)")
    }
    var env = extendFunctionEnvironment(function, arguments: args)
    let evaluated = eval(function.body, env: &env)
    return unwrapReturnValue(evaluated)
}

private func extendFunctionEnvironment(_ fn: Function, arguments args: [Object?]) -> Environment {
    var env = Environment(fn.env)

    for (i, param) in fn.parameters.enumerated() {
        env[param.value] = args[i]
    }

    return env
}

private func unwrapReturnValue(_ obj: Object?) -> Object? {
    if let returnValue = obj as? ReturnValue {
        return returnValue.value
    }
    return obj
}

private func isTruthy(_ obj: Object?) -> Bool {
    switch obj {
    case nil: return false
    case Const.NULL: return false
    case Const.FALSE: return false
    case Const.TRUE: return true
    default: return true
    }
}

private func isError(_ obj: Object?) -> Bool {
    obj is ERROR
}
