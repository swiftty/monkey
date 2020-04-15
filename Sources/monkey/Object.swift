public protocol Object: AnyObject {
    var type: ObjectType { get }
    func inspect() -> String
}

public struct ObjectType: RawRepresentable, Equatable, Hashable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension ObjectType {
    public static let INTEGER = ObjectType(rawValue: "INTEGER")
    public static let BOOLEAN = ObjectType(rawValue: "BOOLEAN")
    public static let NULL = ObjectType(rawValue: "NULL")
    public static let RETURN_VALUE = ObjectType(rawValue: "RETURN_VALUE")
}

func ~= (_ lhs: Object, _ rhs: Object?) -> Bool {
    lhs === rhs
}
