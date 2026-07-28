import Foundation

extension SolarCalculator {
    static func goldenHourWindows(for date: Date, latitude: Double, longitude: Double) -> [LightWindow] {
        guard let times = sunTimes(for: date, latitude: latitude, longitude: longitude),
              times.daylightHours > 0, times.daylightHours < 24 else { return [] }
        let morningEnd = times.sunrise.addingTimeInterval(60 * 60)
        let eveningStart = times.sunset.addingTimeInterval(-60 * 60)
        return [
            LightWindow(
                id: "golden-am",
                title: "Golden Hour · Morning",
                start: times.sunrise,
                end: morningEnd,
                detail: "Warm soft light after sunrise"
            ),
            LightWindow(
                id: "golden-pm",
                title: "Golden Hour · Evening",
                start: eveningStart,
                end: times.sunset,
                detail: "Warm soft light before sunset"
            )
        ]
    }

    static func blueHourWindows(for date: Date, latitude: Double, longitude: Double) -> [LightWindow] {
        guard let times = sunTimes(for: date, latitude: latitude, longitude: longitude),
              times.daylightHours > 0, times.daylightHours < 24 else { return [] }
        return [
            LightWindow(
                id: "blue-am",
                title: "Blue Hour · Dawn",
                start: times.sunrise.addingTimeInterval(-30 * 60),
                end: times.sunrise,
                detail: "Cool deep sky before sunrise"
            ),
            LightWindow(
                id: "blue-pm",
                title: "Blue Hour · Dusk",
                start: times.sunset,
                end: times.sunset.addingTimeInterval(30 * 60),
                detail: "Cool deep sky after sunset"
            )
        ]
    }

    static func outdoorPlannerSlots(for date: Date, latitude: Double, longitude: Double) -> [LightWindow] {
        guard let times = sunTimes(for: date, latitude: latitude, longitude: longitude),
              times.daylightHours > 0 else { return [] }
        let span = times.sunset.timeIntervalSince(times.sunrise)
        guard span > 0 else { return [] }
        let morningEnd = times.sunrise.addingTimeInterval(span * 0.33)
        let dayEnd = times.sunrise.addingTimeInterval(span * 0.66)
        return [
            LightWindow(id: "slot-morning", title: "Morning", start: times.sunrise, end: morningEnd, detail: "Fresh light · start outdoor tasks"),
            LightWindow(id: "slot-day", title: "Day", start: morningEnd, end: dayEnd, detail: "Peak daylight · longer activities"),
            LightWindow(id: "slot-evening", title: "Evening", start: dayEnd, end: times.sunset, detail: "Softer light · wind-down outdoors")
        ]
    }

    static func recommendedWindow(
        for preset: ActivityPreset,
        date: Date,
        latitude: Double,
        longitude: Double
    ) -> LightWindow? {
        guard let times = sunTimes(for: date, latitude: latitude, longitude: longitude),
              times.daylightHours > 0, times.daylightHours < 24 else { return nil }
        let span = times.sunset.timeIntervalSince(times.sunrise)
        switch preset {
        case .hiking:
            let start = times.sunrise.addingTimeInterval(span * 0.25)
            let end = times.sunrise.addingTimeInterval(span * 0.75)
            return LightWindow(id: "hike", title: "Hiking Window", start: start, end: end, detail: "Stable mid-day daylight")
        case .photography:
            return goldenHourWindows(for: date, latitude: latitude, longitude: longitude).last
        case .kidsOutdoor:
            let morning = LightWindow(
                id: "kids-am",
                title: "Kids · Morning",
                start: times.sunrise.addingTimeInterval(45 * 60),
                end: times.sunrise.addingTimeInterval(span * 0.4),
                detail: "Mild morning light"
            )
            return morning
        }
    }

    static func daylightDelta(for date: Date, latitude: Double, longitude: Double) -> DaylightDelta {
        let calendar = Calendar.current
        let today = daylightHours(for: date, latitude: latitude, longitude: longitude)
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        let yearAgoDate = calendar.date(byAdding: .year, value: -1, to: date) ?? date
        let yesterday = daylightHours(for: yesterdayDate, latitude: latitude, longitude: longitude)
        let yearAgo = daylightHours(for: yearAgoDate, latitude: latitude, longitude: longitude)
        return DaylightDelta(
            todayHours: today,
            yesterdayDelta: today - yesterday,
            yearAgoDelta: today - yearAgo
        )
    }

    static func polarStatus(for date: Date, latitude: Double, longitude: Double) -> String? {
        guard let times = sunTimes(for: date, latitude: latitude, longitude: longitude) else { return nil }
        if times.daylightHours >= 24 { return "Polar day — sun stays above the horizon" }
        if times.daylightHours <= 0 { return "Polar night — sun stays below the horizon" }
        return nil
    }

    static func upcomingSolarEvents(from date: Date = Date(), latitude: Double) -> [SolarEventItem] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let candidates: [(String, DateComponents, String)] = [
            ("spring-equinox", DateComponents(year: year, month: 3, day: 20), "Near-equal day and night"),
            ("summer-solstice", DateComponents(year: year, month: 6, day: 21), "Longest daylight of the year"),
            ("autumn-equinox", DateComponents(year: year, month: 9, day: 22), "Near-equal day and night"),
            ("winter-solstice", DateComponents(year: year, month: 12, day: 21), "Shortest daylight of the year"),
            ("spring-equinox-next", DateComponents(year: year + 1, month: 3, day: 20), "Near-equal day and night")
        ]

        let startOfToday = calendar.startOfDay(for: date)
        var events: [SolarEventItem] = []
        for (id, comps, detail) in candidates {
            guard let eventDate = calendar.date(from: comps) else { continue }
            if eventDate >= startOfToday {
                events.append(SolarEventItem(id: id, title: titleForSolarEvent(id), date: eventDate, detail: detail))
            }
        }

        if abs(latitude) >= 66.0 {
            events.insert(
                SolarEventItem(
                    id: "polar-zone",
                    title: "Polar Zone",
                    date: date,
                    detail: latitude >= 0
                        ? "Arctic latitudes can see polar day/night seasons"
                        : "Antarctic latitudes can see polar day/night seasons"
                ),
                at: 0
            )
        }
        return Array(events.prefix(4))
    }

    private static func titleForSolarEvent(_ id: String) -> String {
        switch id {
        case "spring-equinox", "spring-equinox-next": return "Spring Equinox"
        case "summer-solstice": return "Summer Solstice"
        case "autumn-equinox": return "Autumn Equinox"
        case "winter-solstice": return "Winter Solstice"
        default: return "Solar Event"
        }
    }

    static func countdownText(to target: Date, from now: Date = Date()) -> String {
        let remaining = target.timeIntervalSince(now)
        if remaining <= 0 { return "Now" }
        let total = Int(remaining)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        }
        return String(format: "%dm", max(minutes, 1))
    }

    static func formatWindow(_ window: LightWindow) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: window.start)) – \(formatter.string(from: window.end))"
    }
}
