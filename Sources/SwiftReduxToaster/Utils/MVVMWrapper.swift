import Foundation

@MainActor
public class MVVMWrapper {
    public init(state: ToasterState) {
        self.state = state
    }

    public var state: ToasterState

    public func dispatch(_ action: ToasterAction) {
        state = ToasterState.reducer(action: action, state: state)
    }
}
