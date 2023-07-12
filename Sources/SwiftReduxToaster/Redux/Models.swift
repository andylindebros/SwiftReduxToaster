import Foundation

public struct ToasterModel: Identifiable, Codable, Sendable {
    public init(id: UUID = UUID(), type: ToasterType, target: Target, isDismissable: Bool = true, title: String, message: String? = nil, timeoutInterval: Int = 7, url: URL? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.target = target
        self.isDismissable = isDismissable
        self.timeoutInterval = timeoutInterval
        self.url = url
    }

    public var id: UUID
    public let type: ToasterType
    public let title: String
    public let message: String?
    public let target: Target
    public let timeoutInterval: Int
    public let isDismissable: Bool
    public let url: URL?
}

public extension ToasterModel {
    enum ToasterType: String, Codable, Sendable {
        case success, info, warning, error
    }

    enum Target: Codable, Sendable {
        case all
        case targeted(to: UUID)

        func isValid(for id: UUID) -> Bool {
            switch self {
            case .all:
                return true
            case let .targeted(to: targetID):
                return id == targetID
            }
        }

        func isTargeted(for id: UUID?) -> Bool {
            if case let Self.targeted(to: targetID) = self, targetID == id {
                return true
            }
            return false
        }
    }
}
