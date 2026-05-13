import SwiftUI

// The four quadrants of the Eisenhower Matrix.
// Raw String value is used as the SwiftData storage key.
enum Quadrant: String, CaseIterable, Identifiable, Codable {
    case doNow      = "doNow"
    case schedule   = "schedule"
    case delegate   = "delegate"
    case eliminate  = "eliminate"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .doNow:     return "Do"
        case .schedule:  return "Schedule"
        case .delegate:  return "Delegate"
        case .eliminate: return "Eliminate"
        }
    }

    var subtitle: String {
        switch self {
        case .doNow:     return "Urgent & Important"
        case .schedule:  return "Not Urgent · Important"
        case .delegate:  return "Urgent · Not Important"
        case .eliminate: return "Not Urgent · Not Important"
        }
    }

    var color: Color {
        switch self {
        case .doNow:     return Color(red: 0.84, green: 0.24, blue: 0.20) // red
        case .schedule:  return Color(red: 0.17, green: 0.51, blue: 0.82) // blue
        case .delegate:  return Color(red: 0.88, green: 0.55, blue: 0.07) // amber
        case .eliminate: return Color(red: 0.35, green: 0.40, blue: 0.46) // slate
        }
    }

    var icon: String {
        switch self {
        case .doNow:     return "flame.fill"
        case .schedule:  return "calendar"
        case .delegate:  return "person.wave.2.fill"
        case .eliminate: return "trash.fill"
        }
    }
}
