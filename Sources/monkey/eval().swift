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
        return evalPrefixExpression(node.operator, eval(node.right))

    case let node as InfixExpression:
        return evalInfixExpression(node.operator, eval(node.left), eval(node.right))

    case let node as BlockStatement:
        return evalBlockStatement(node)

    case let node as IfExpression:
        return evalIfExpression(node)

    case let node as ReturnStatement:
        return ReturnValue(value: eval(node.returnValue) ?? Const.NULL)

    default:
        return nil
    }
}

// MARK: - private -
private func evalProgram(_ program: Program) -> Object? {
    var result: Object?
    for stmt in program.statements {
        result = eval(stmt)

        if let r = result as? ReturnValue {
            return r.value
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

        if result is ReturnValue {
            return result
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
        return Const.NULL
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
    guard let right = right as? Integer else { return Const.NULL }
    return Integer(value: -right.value)
}

private func evalInfixExpression(_ operator: String, _ left: Object?, _ right: Object?) -> Object {
    switch (left, right) {
    case (let left as Integer, let right as Integer):
        return evalIntegerInfixExpression(`operator`, left, right)

    case (let left?, let right?) where `operator` == "==":
        return Boolean.from(native: left === right)

    case (let left?, let right?) where `operator` == "!=":
        return Boolean.from(native: left !== right)

    default:
        return Const.NULL
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
    if isTruthy(eval(ie.condition)) {
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
