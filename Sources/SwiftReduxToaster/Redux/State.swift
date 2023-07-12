import Foundation

// MARK: State

public final class ToasterState: ObservableObject, Codable {
    public init(models: [ToasterModel] = []) {
        self.models = models
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        models = try values.decode([ToasterModel].self, forKey: .models)
    }

    @Published public private(set) var models: [ToasterModel]

    @Published public private(set) var activeNavigationId: UUID?

    enum CodingKeys: CodingKey {
        case models
    }

    public var isActive: Bool {
        models.count > 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(models, forKey: .models)
    }
}

public extension ToasterState {
    static func reducer<Action>(action: Action, state: ToasterState?) -> ToasterState {
        let state = state ?? ToasterState()

        switch action as? ToasterAction {
        case let .add(model):
            state.models.append(model)

        case let .dismiss(model):
            guard let index = state.models.firstIndex(where: { $0.id == model.id }) else {
                return state
            }
            state.models.remove(at: index)

        case let .activeNavigation(id):
            // remove all redundant models
            state.models = state.models.filter { !$0.target.isTargeted(for: state.activeNavigationId) }

            state.activeNavigationId = id

        case .none:
            break
        }

        return state
    }
}
