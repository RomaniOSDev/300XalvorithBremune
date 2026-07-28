import Foundation

struct LocationEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var daylightData: [DaylightPoint]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double = 0,
        daylightData: [DaylightPoint] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.daylightData = daylightData
        self.createdAt = createdAt
    }
}

struct DaylightPoint: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var durationHours: Double

    init(id: UUID = UUID(), date: Date, durationHours: Double) {
        self.id = id
        self.date = date
        self.durationHours = durationHours
    }
}

struct PresetCity: Identifiable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double

    static let all: [PresetCity] = [
        PresetCity(id: "nyc", name: "New York", latitude: 40.71, longitude: -74.01),
        PresetCity(id: "lon", name: "London", latitude: 51.51, longitude: -0.13),
        PresetCity(id: "tok", name: "Tokyo", latitude: 35.68, longitude: 139.69),
        PresetCity(id: "syd", name: "Sydney", latitude: -33.87, longitude: 151.21),
        PresetCity(id: "cai", name: "Cairo", latitude: 30.04, longitude: 31.24),
        PresetCity(id: "rio", name: "Rio de Janeiro", latitude: -22.91, longitude: -43.17),
        PresetCity(id: "ber", name: "Berlin", latitude: 52.52, longitude: 13.41),
        PresetCity(id: "lax", name: "Los Angeles", latitude: 34.05, longitude: -118.24)
    ]
}
