import Foundation

enum SolarCalculator {
    /// Approximate sunrise/sunset using solar declination + solar noon offset from longitude.
    static func sunTimes(for date: Date, latitude: Double, longitude: Double) -> (sunrise: Date, sunset: Date, daylightHours: Double)? {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let latRad = latitude * .pi / 180.0

        let declination = 23.45 * sin((2.0 * .pi / 365.0) * (284.0 + Double(dayOfYear)))
        let decRad = declination * .pi / 180.0

        let cosHourAngle = -tan(latRad) * tan(decRad)
        guard cosHourAngle >= -1.0, cosHourAngle <= 1.0 else {
            let hours = cosHourAngle < -1.0 ? 24.0 : 0.0
            let start = calendar.startOfDay(for: date)
            if hours >= 24.0 {
                return (start, start.addingTimeInterval(24 * 3600 - 1), 24.0)
            }
            return (start, start, 0.0)
        }

        let hourAngle = acos(cosHourAngle)
        let daylightHours = 2.0 * hourAngle * 12.0 / .pi

        let equationOfTime = 9.87 * sin(2.0 * B(dayOfYear))
            - 7.53 * cos(B(dayOfYear))
            - 1.5 * sin(B(dayOfYear))
        let timeOffsetMinutes = equationOfTime + 4.0 * longitude
        let solarNoonMinutes = 12.0 * 60.0 - timeOffsetMinutes

        let halfDayMinutes = (daylightHours / 2.0) * 60.0
        let sunriseMinutes = solarNoonMinutes - halfDayMinutes
        let sunsetMinutes = solarNoonMinutes + halfDayMinutes

        let start = calendar.startOfDay(for: date)
        let sunrise = start.addingTimeInterval(sunriseMinutes * 60.0)
        let sunset = start.addingTimeInterval(sunsetMinutes * 60.0)
        return (sunrise, sunset, daylightHours)
    }

    static func daylightHours(for date: Date, latitude: Double, longitude: Double = 0) -> Double {
        sunTimes(for: date, latitude: latitude, longitude: longitude)?.daylightHours ?? 12.0
    }

    static func daylightProgress(now: Date, sunrise: Date, sunset: Date) -> Double {
        if now <= sunrise { return 0 }
        if now >= sunset { return 1 }
        let total = sunset.timeIntervalSince(sunrise)
        guard total > 0 else { return 0 }
        return min(1, max(0, now.timeIntervalSince(sunrise) / total))
    }

    private static func B(_ dayOfYear: Int) -> Double {
        2.0 * .pi * (Double(dayOfYear) - 81.0) / 364.0
    }
}
