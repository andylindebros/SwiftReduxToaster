import Foundation

public protocol ToasterActionProvider: Codable, CustomLogging, Sendable {}

public enum ToasterAction: ToasterActionProvider {
    case add(ToasterModel)
    case dismiss(ToasterModel)
    case activeNavigation(UUID)

    public var description: String {
        let value = "\(type(of: self)):"
        switch self {
        case let .add(model):
            return "\(value).add(\(model)"
        case let .dismiss(model):
            return "\(value).dismiss(\(model)"
        case let .activeNavigation(id):
            return "\(value).activeNavigation(\(id)"
        }
    }
}
