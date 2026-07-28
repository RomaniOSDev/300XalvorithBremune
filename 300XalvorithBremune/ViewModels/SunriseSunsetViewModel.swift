import Foundation
import Combine

final class SunriseSunsetViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var sunriseText: String = "--:--"
    @Published var sunsetText: String = "--:--"
    @Published var daylightText: String = "--"
    @Published var progress: Double = 0
    @Published var hasChecked: Bool = false

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .none
        return f
    }()

    func dateLabel() -> String {
        dayFormatter.string(from: selectedDate)
    }

    func refresh(latitude: Double, longitude: Double, now: Date = Date()) {
        guard let times = SolarCalculator.sunTimes(for: selectedDate, latitude: latitude, longitude: longitude) else {
            sunriseText = "--:--"
            sunsetText = "--:--"
            daylightText = "N/A"
            progress = 0
            return
        }
        sunriseText = formatter.string(from: times.sunrise)
        sunsetText = formatter.string(from: times.sunset)
        let hours = Int(times.daylightHours)
        let minutes = Int((times.daylightHours - Double(hours)) * 60)
        daylightText = String(format: "%dh %02dm", hours, minutes)

        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            progress = SolarCalculator.daylightProgress(now: now, sunrise: times.sunrise, sunset: times.sunset)
        } else if selectedDate < calendar.startOfDay(for: now) {
            progress = 1
        } else {
            progress = 0
        }
    }

    func shiftDay(_ delta: Int) {
        if let next = Calendar.current.date(byAdding: .day, value: delta, to: selectedDate) {
            selectedDate = next
        }
    }
}
