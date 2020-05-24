public final class Environment {
    private let _outer: [Environment]
    private var dict: [String: Object] = [:]

    public subscript (key: String) -> Object? {
        get { dict[key] ?? _outer.first?[key] }
        set { dict[key] = newValue }
    }

    public init() {
        _outer = []
    }

    public init(_ outer: Environment) {
        _outer = [outer]
    }
}
