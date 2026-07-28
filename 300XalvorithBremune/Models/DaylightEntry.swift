import Foundation

struct DaylightEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var durationHours: Double
    var month: Int
    var year: Int

    init(id: UUID = UUID(), date: Date, durationHours: Double) {
        self.id = id
        self.date = date
        self.durationHours = durationHours
        let comps = Calendar.current.dateComponents([.month, .year], from: date)
        self.month = comps.month ?? 1
        self.year = comps.year ?? 2026
    }
}

struct UserNote: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var content: String

    init(id: UUID = UUID(), date: Date = Date(), content: String) {
        self.id = id
        self.date = date
        self.content = content
    }
}
