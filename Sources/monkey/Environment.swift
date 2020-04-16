public struct Environment {
    private var dict: [String: Object] = [:]

    public subscript (key: String) -> Object? {
        get { dict[key] }
        set { dict[key] = newValue }
    }

    public init() {}
}
