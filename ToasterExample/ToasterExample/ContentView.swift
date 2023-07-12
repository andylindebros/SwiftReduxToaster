import SwiftReduxRouter
import SwiftReduxToaster
import SwiftUI
import SwiftUIRedux

struct ContentView: View {
    let store: Store<AppState>

    var body: some View {
        RouterView(
            navigationState: store.state.navigation,
            routes: [
                .init(
                    paths: [
                        .init("/first"),
                    ],
                    render: { _, model, _ in
                        CustomViewController(
                            rootView:
                            Toaster(state: store.state.toaster, dispatch: store.dispatchFunction, navigationId: model.id) {
                                VStack(spacing: 16) {
                                    Button(action: {
                                        store.dispatch(NavigationAction.add(path: NavigationPath.create("/first")!, to: .new()))
                                    }) {
                                        Text("first")
                                    }

                                    Button(action: {
                                        store.dispatch(ToasterAction.add(.init(type: .success, target: .targeted(to: model.id), title: "Success toast for this view", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")))
                                    }) {
                                        Text("Success toast for this view")
                                    }

                                    Button(action: {
                                        store.dispatch(ToasterAction.add(.init(type: .info, target: .targeted(to: model.id), title: "Info toast for this view", message: "Lorem ipsum dolor sit amet.", timeoutInterval: 0)))
                                    }) {
                                        Text("Info toast for this view")
                                    }

                                    Button(action: {
                                        store.dispatch(ToasterAction.add(.init(type: .warning, target: .all, title: "Warning Toast for all", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", timeoutInterval: 2)))
                                    }) {
                                        Text("Warning Toast for all")
                                    }

                                    Button(action: {
                                        store.dispatch(ToasterAction.add(.init(type: .error, target: .targeted(to: model.id), isDismissable: false, title: "Error non dismissable", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.", timeoutInterval: 2)))
                                    }) {
                                        Text("Error non dismissable")
                                    }
                                }

                            },
                            hideNavigationBar: !model.isPresented
                        )
                    }
                ),
                .init(
                    paths: [
                        .init("/second"),
                    ],
                    render: { _, model, _ in
                        RouteViewController(rootView:
                            Toaster(state: store.state.toaster, dispatch: store.dispatchFunction, navigationId: model.id) {
                                VStack {
                                    Text("Second")
                                }
                            }
                        )
                    }
                ),
            ],
            setSelectedPath: { model, path in
                store.dispatch(NavigationAction.setSelectedPath(to: path, in: model))
            },
            onDismiss: { model in
                store.dispatch(NavigationAction.setNavigationDismsissed(model))
            }
        ).edgesIgnoringSafeArea(.all)
    }
}

struct Toaster<Content: View>: View {
    @ObservedObject var state: ToasterState
    let dispatch: DispatchFunction
    let navigationId: UUID
    @ViewBuilder let content: () -> Content
    var body: some View {
        ZStack {
            content()
            SwiftReduxToaster.ToasterView(
                state: state,
                dispatch: { action in
                    guard let action = action as? Action else { return }
                    dispatch(action)
                },
                navigationId: navigationId
            ) { model, task in
                DefaultToast(
                    model: model,
                    task: task,
                    onClose: {
                        dispatch(ToasterAction.dismiss(model))
                    }
                )
            }
        }
    }
}

public final class CustomViewController<Content: View>: UIHostingController<Content>, UIRouteViewController {
    public init(
        rootView: Content,
        navigationModel: NavigationModel? = nil,
        navigationPath: SwiftReduxRouter.NavigationPath? = nil,
        hideNavigationBar: Bool = false
    ) {
        self.navigationModel = navigationModel
        self.navigationPath = navigationPath
        self.hideNavigationBar = hideNavigationBar
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var navigationModel: NavigationModel?
    public var navigationPath: SwiftReduxRouter.NavigationPath?
    public let hideNavigationBar: Bool

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hideNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if hideNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
}
