# SwiftTReduxToaster
SwiftTReduxToaster provides a notification view for a Swift redux app

![Demo](https://github.com/andylindebros/SwiftReduxToaster/blob/main/Assets/banner.gif)


## Implementation
1. Add the state of the SwiftReduxToaster to the AppState
```Swift

struct AppState: Codable {
    private(set) var toaster: ToasterState

    @MainActor static func createStore(
        initState: AppState
    ) -> Store<AppState> {
        Store<AppState>(reducer: AppState.reducer, state: initState, middleware: [Middleware<AppState>]())
    }

    @MainActor static func reducer(action: Action, state: AppState) -> AppState {
        AppState(toaster: ToasterState.reducer(action: action, state: state.toaster))
    }
}
```
1. Implement the toaster in your UI
``` Swift
@MainActor struct ToasterExampleApp: App {
    let store = AppState.createStore(initState: AppState.initState)
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Button(action: {
                    store.dispatch(ToasterAction.add(.init(
                        type: .success, 
                        target: .all, 
                        title: "Success toast", 
                        message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
                    )))
                }) {
                    Text("Tigger notificaiton")
                }

                SwiftReduxToaster.ToasterView(
                    state: store.state.toaster,
                    dispatch: { action in
                        guard let action = action as? Action else { return }
                            store.dispatch(action)
                    },
                    navigationId: navigationId
                ) { model, task in
                    DefaultToast(
                        model: model,
                        task: task
                    ) {
                           store.dispatch(ToasterAction.dismiss(model))
                    }
                }
            }
        }
    }
}
```

## Options
You can customize the notification by changing the properties of the ToasterModel
```Swift
struct ToasterModel{
    var id: UUID // The id of the notification
    let type: ToasterType // success, info, warning, error
    let title: String // The title of the notification
    let message: String? // the message of the notification
    let target: Target // Limitation of views that should show the notification (Useful if you have multiple view implementations)
    let timeoutInterval: Int // Dismiss after number of seconds. Default is 7. Disable it by setting it to zero
    let isDismissable: Bool // Defines if the user can dismiss it or not
    let url: URL? // Pass a url that can be use in future actions. Useful when working with deep links
}
```

## Custom view
You can create and implement your own view for the toaster. Just replace `DefaultToast` with your custom view.
```Swift
ToasterView(
    state: store.state.toaster,
    dispatch: { action in
        guard let action = action as? Action else { return }
            store.dispatch(action)
    },
    navigationId: navigationId
) { model, _ in
    HStack {
        Text(model.title)
        Button(action: {
            store.disaptch(ToasterAction.dismiss(model))
        }) {
            Text("Dismiss")
        }
    }
}
```
