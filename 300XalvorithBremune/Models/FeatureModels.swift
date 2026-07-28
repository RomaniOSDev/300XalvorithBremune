import Foundation

enum AppThemeMode: String, CaseIterable, Identifiable, Codable {
    case auto
    case dawn
    case noon
    case dusk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .auto: return "Auto"
        case .dawn: return "Dawn"
        case .noon: return "Noon"
        case .dusk: return "Dusk"
        }
    }
}

enum MoodLevel: Int, CaseIterable, Codable, Identifiable {
    case low = 1
    case calm = 2
    case okay = 3
    case good = 4
    case great = 5

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .low: return "Low"
        case .calm: return "Calm"
        case .okay: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        }
    }

    var symbol: String {
        switch self {
        case .low: return "cloud.rain.fill"
        case .calm: return "cloud.fill"
        case .okay: return "cloud.sun.fill"
        case .good: return "sun.max.fill"
        case .great: return "sun.horizon.fill"
        }
    }
}

struct LightDiaryEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var content: String
    var mood: MoodLevel
    var energy: Int
    var daylightHours: Double

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        content: String,
        mood: MoodLevel,
        energy: Int,
        daylightHours: Double
    ) {
        self.id = id
        self.date = date
        self.content = content
        self.mood = mood
        self.energy = min(5, max(1, energy))
        self.daylightHours = daylightHours
    }
}

struct OutdoorGoalState: Codable, Equatable {
    var dailyMinutesTarget: Int
    var minutesToday: Int
    var goalStreak: Int
    var lastLogDay: Date?

    static let `default` = OutdoorGoalState(
        dailyMinutesTarget: 30,
        minutesToday: 0,
        goalStreak: 0,
        lastLogDay: nil
    )
}

struct AlertHistoryEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var title: String
    var detail: String

    init(id: UUID = UUID(), date: Date = Date(), title: String, detail: String) {
        self.id = id
        self.date = date
        self.title = title
        self.detail = detail
    }
}

enum ActivityPreset: String, CaseIterable, Identifiable {
    case hiking
    case photography
    case kidsOutdoor

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hiking: return "Hiking"
        case .photography: return "Photography"
        case .kidsOutdoor: return "Kids Outdoor"
        }
    }

    var symbol: String {
        switch self {
        case .hiking: return "figure.walk"
        case .photography: return "camera.fill"
        case .kidsOutdoor: return "person.2.fill"
        }
    }

    var blurb: String {
        switch self {
        case .hiking: return "Longest mid-day light window"
        case .photography: return "Golden hour windows"
        case .kidsOutdoor: return "Mild morning & afternoon light"
        }
    }
}

struct SolarEventItem: Identifiable {
    let id: String
    let title: String
    let date: Date
    let detail: String
}

struct DaylightDelta: Equatable {
    let todayHours: Double
    let yesterdayDelta: Double
    let yearAgoDelta: Double
}

struct LightWindow: Identifiable, Equatable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let detail: String
}
