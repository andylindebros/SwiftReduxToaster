import SwiftUI
import SwiftUIRedux

@main
@MainActor
struct ToasterExampleApp: App {
    let store = AppState.createStore(initState: AppState.initState)
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
