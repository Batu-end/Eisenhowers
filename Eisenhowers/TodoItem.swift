import Foundation
import SwiftData

// SwiftData requires @Model classes to use simple types.
// We store the quadrant as its String rawValue and expose a
// computed property so the rest of the app can use the enum.
@Model
class TodoItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var quadrantRaw: String   // "doNow" | "schedule" | "delegate" | "eliminate"

    var quadrant: Quadrant {
        get { Quadrant(rawValue: quadrantRaw) ?? .doNow }
        set { quadrantRaw = newValue.rawValue }
    }

    init(title: String, quadrant: Quadrant) {
        self.id          = UUID()
        self.title       = title
        self.isCompleted = false
        self.quadrantRaw = quadrant.rawValue
    }
}
