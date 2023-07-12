import Foundation
import SwiftReduxRouter
import SwiftReduxToaster
import SwiftUIRedux

public enum ReactiveMiddleware {
    static func createMiddleware() -> Middleware<AppState> {
        return { dispatch, state in
            { next in
                { action in
                    let nextAction: Void = next(action)

                    guard let state = state() else {
                        return nextAction
                    }

                    switch action {
                    case let NavigationAction.setSelectedPath(to: _, in: model):
                        dispatch(ToasterAction.activeNavigation(model.id))
                    case NavigationAction.setNavigationDismsissed:
                        let selectedNavigationID = state.navigation.selectedModelId
                        dispatch(ToasterAction.activeNavigation(selectedNavigationID))
                    default:
                        break
                    }

                    return nextAction
                }
            }
        }
    }
}
