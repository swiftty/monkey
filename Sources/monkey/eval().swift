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

public func eval(_ node: Node?) -> Object? {
    switch node {
    case let node as Program:
        return evalProgram(node)

    case let node as ExpressionStatement:
        return eval(node.expression)

    case let node as IntegerLiteral:
        return Integer(value: node.value)

    case let node as BooleanLiteral:
        return Boolean.from(native: node.value)

    case let node as PrefixExpression:
        let right = eval(node.right)
        if isError(right) {
            return right
        }
        return evalPrefixExpression(node.operator, right)

    case let node as InfixExpression:
        let left = eval(node.left)
        if isError(left) {
            return left
        }
        let right = eval(node.right)
        if isError(right) {
            return right
        }
        return evalInfixExpression(node.operator, left, right)

    case let node as BlockStatement:
        return evalBlockStatement(node)

    case let node as IfExpression:
        return evalIfExpression(node)

    case let node as ReturnStatement:
        let val = eval(node.returnValue) ?? Const.NULL
        if isError(val) {
            return val
        }
        return ReturnValue(value: val)

    default:
        return nil
    }
}

// MARK: - private -
private func evalProgram(_ program: Program) -> Object? {
    var result: Object?
    for stmt in program.statements {
        result = eval(stmt)

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

private func evalStatements(_ statements: [Statement]) -> Object? {
    var result: Object?
    for stmt in statements {
        result = eval(stmt)

        if let r = result as? ReturnValue {
            return r.value
        }
    }
    return result
}

private func evalBlockStatement(_ block: BlockStatement) -> Object? {
    var result: Object?
    for stmt in block.statements {
        result = eval(stmt)

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

private func evalIfExpression(_ ie: IfExpression) -> Object? {
    let condition = eval(ie.condition)
    if isError(condition) {
        return condition
    }
    if isTruthy(condition) {
        return eval(ie.consequence)
    } else if let alt = ie.alternative {
        return eval(alt)
    } else {
        return Const.NULL
    }
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
