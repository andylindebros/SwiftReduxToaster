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
                    case let NavigationAction.deeplink(deeplink):
                        if let reaction = deeplink.action(for: state.navigation),
                           let navigationAction = reaction as? Action {
                            dispatch(navigationAction)
                        }
                    default:
                        break
                    }

                    return nextAction
                }
            }
        }
    }
}
