import Foundation
import Logger
@preconcurrency import SwiftReduxRouter
import SwiftReduxToaster
import SwiftUIRedux

extension NavigationAction: Action {}
extension ToasterAction: Action {}

/// The state of the app
struct AppState: Codable {
    private(set) var navigation: NavigationState
    private(set) var toaster: ToasterState

    @MainActor static func createStore(
        initState: AppState
    ) -> Store<AppState> {
        var middlewares = [Middleware<AppState>]()
        middlewares.append(ReactiveMiddleware.createMiddleware())
        #if DEBUG
            middlewares.append { _, _ in
                { next in
                    { action in
                        Task.detached {
                            Logger().publish(
                                message: "⚡️Action:",
                                obj: action,
                                level: .debug
                            )
                        }

                        return next(action)
                    }
                }
            }
        #endif
        let store = Store<AppState>(reducer: AppState.reducer, state: initState, middleware: middlewares)

        return store
    }

    @MainActor static func reducer(action: Action, state: AppState) -> AppState {
        return AppState(
            navigation: NavigationState.reducer(action: action, state: state.navigation),
            toaster: ToasterState.reducer(action: action, state: state.toaster)
        )
    }
}

extension AppState {
    @MainActor static var initState: AppState {
        AppState(
            navigation: NavigationState(
                navigationModels: [
                    NavigationModel.createInitModel(
                        path: NavigationPath(URL(string: "/tab1")),
                        selectedPath: NavigationPath.create("/first")!,
                        tab: NavigationTab(
                            name: "First Tab",
                            icon: NavigationTab.Icon.system(name: "star.fill")
                        )
                    ),
                    NavigationModel.createInitModel(
                        path: NavigationPath(URL(string: "/tab2")),
                        selectedPath: NavigationPath.create("/first")!,
                        tab: NavigationTab(
                            name: "Second Tab",
                            icon: NavigationTab.Icon.system(name: "heart.fill"),
                            badgeColor: .red
                        )
                    ),
                ],
                availableNavigationModelRoutes: [
                    NavigationRoute("/tab3"),
                ]
            ),
            toaster: ToasterState()
        )
    }
}
