import SwiftUI
import SwiftData

@main
struct EisenhowersApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // SwiftData sets up the persistent store automatically for TodoItem.
        .modelContainer(for: TodoItem.self)
    }
}
