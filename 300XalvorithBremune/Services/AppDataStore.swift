import Foundation
import Combine

final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var sessionsCompleted: Int {
        didSet { defaults.set(sessionsCompleted, forKey: Keys.sessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet { defaults.set(lastActivityDate, forKey: Keys.lastActivityDate) }
    }

    @Published var itemsCreated: Int {
        didSet { defaults.set(itemsCreated, forKey: Keys.itemsCreated) }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveCodable(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }

    @Published var sunriseAlertEnabled: Bool {
        didSet { defaults.set(sunriseAlertEnabled, forKey: Keys.sunriseAlertEnabled) }
    }

    @Published var sunsetAlertEnabled: Bool {
        didSet { defaults.set(sunsetAlertEnabled, forKey: Keys.sunsetAlertEnabled) }
    }

    @Published var alertTimes: [Date] {
        didSet { saveCodable(alertTimes, key: Keys.alertTimes) }
    }

    @Published var alertName: String {
        didSet { defaults.set(alertName, forKey: Keys.alertName) }
    }

    @Published var selectedLatitude: Double {
        didSet { defaults.set(selectedLatitude, forKey: Keys.selectedLatitude) }
    }

    @Published var selectedLongitude: Double {
        didSet { defaults.set(selectedLongitude, forKey: Keys.selectedLongitude) }
    }

    @Published var selectedLocationName: String {
        didSet { defaults.set(selectedLocationName, forKey: Keys.selectedLocationName) }
    }

    @Published var locations: [LocationEntry] {
        didSet { saveCodable(locations, key: Keys.locations) }
    }

    @Published var alertTime: Date {
        didSet { defaults.set(alertTime, forKey: Keys.alertTime) }
    }

    @Published var isTrackingEnabled: Bool {
        didSet { defaults.set(isTrackingEnabled, forKey: Keys.isTrackingEnabled) }
    }

    @Published var daylightData: [DaylightEntry] {
        didSet { saveCodable(daylightData, key: Keys.daylightData) }
    }

    @Published var lastSyncDate: Date? {
        didSet { defaults.set(lastSyncDate, forKey: Keys.lastSyncDate) }
    }

    @Published var userNotes: [UserNote] {
        didSet { saveCodable(userNotes, key: Keys.userNotes) }
    }

    @Published var pendingAchievementBanner: String?

    @Published var soundEnabled: Bool {
        didSet {
            defaults.set(soundEnabled, forKey: Keys.soundEnabled)
            AppFeedback.soundEnabled = soundEnabled
        }
    }

    @Published var hapticEnabled: Bool {
        didSet {
            defaults.set(hapticEnabled, forKey: Keys.hapticEnabled)
            AppFeedback.hapticEnabled = hapticEnabled
        }
    }

    @Published var themeMode: AppThemeMode {
        didSet { defaults.set(themeMode.rawValue, forKey: Keys.themeMode) }
    }

    @Published var lightDiary: [LightDiaryEntry] {
        didSet { saveCodable(lightDiary, key: Keys.lightDiary) }
    }

    @Published var outdoorGoal: OutdoorGoalState {
        didSet { saveCodable(outdoorGoal, key: Keys.outdoorGoal) }
    }

    @Published var alertHistory: [AlertHistoryEntry] {
        didSet { saveCodable(alertHistory, key: Keys.alertHistory) }
    }

    private var sessionStartedAt: Date?

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let sessionsCompleted = "sessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let itemsCreated = "itemsCreated"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let sunriseAlertEnabled = "sunriseAlertEnabled"
        static let sunsetAlertEnabled = "sunsetAlertEnabled"
        static let alertTimes = "alertTimes"
        static let alertName = "alertName"
        static let selectedLatitude = "selectedLatitude"
        static let selectedLongitude = "selectedLongitude"
        static let selectedLocationName = "selectedLocationName"
        static let locations = "locations"
        static let alertTime = "alertTime"
        static let isTrackingEnabled = "isTrackingEnabled"
        static let daylightData = "daylightData"
        static let lastSyncDate = "lastSyncDate"
        static let userNotes = "userNotes"
        static let soundEnabled = "soundEnabled"
        static let hapticEnabled = "hapticEnabled"
        static let themeMode = "themeMode"
        static let lightDiary = "lightDiary"
        static let outdoorGoal = "outdoorGoal"
        static let alertHistory = "alertHistory"
    }

    private init() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
            guard let data = defaults.data(forKey: key) else { return nil }
            return try? decoder.decode(type, from: data)
        }

        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        sessionsCompleted = defaults.integer(forKey: Keys.sessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        achievementsUnlocked = decode([String: Date].self, key: Keys.achievementsUnlocked) ?? [:]
        sunriseAlertEnabled = defaults.bool(forKey: Keys.sunriseAlertEnabled)
        sunsetAlertEnabled = defaults.bool(forKey: Keys.sunsetAlertEnabled)
        alertTimes = decode([Date].self, key: Keys.alertTimes) ?? []
        alertName = defaults.string(forKey: Keys.alertName) ?? ""
        selectedLatitude = defaults.object(forKey: Keys.selectedLatitude) as? Double ?? 40.71
        selectedLongitude = defaults.object(forKey: Keys.selectedLongitude) as? Double ?? -74.01
        selectedLocationName = defaults.string(forKey: Keys.selectedLocationName) ?? "New York"
        locations = decode([LocationEntry].self, key: Keys.locations) ?? []
        alertTime = (defaults.object(forKey: Keys.alertTime) as? Date) ?? Date()
        isTrackingEnabled = defaults.bool(forKey: Keys.isTrackingEnabled)
        daylightData = decode([DaylightEntry].self, key: Keys.daylightData) ?? []
        lastSyncDate = defaults.object(forKey: Keys.lastSyncDate) as? Date
        userNotes = decode([UserNote].self, key: Keys.userNotes) ?? []
        if defaults.object(forKey: Keys.soundEnabled) == nil {
            soundEnabled = true
        } else {
            soundEnabled = defaults.bool(forKey: Keys.soundEnabled)
        }
        if defaults.object(forKey: Keys.hapticEnabled) == nil {
            hapticEnabled = true
        } else {
            hapticEnabled = defaults.bool(forKey: Keys.hapticEnabled)
        }
        if let raw = defaults.string(forKey: Keys.themeMode),
           let mode = AppThemeMode(rawValue: raw) {
            themeMode = mode
        } else {
            themeMode = .auto
        }
        lightDiary = decode([LightDiaryEntry].self, key: Keys.lightDiary) ?? []
        outdoorGoal = decode(OutdoorGoalState.self, key: Keys.outdoorGoal) ?? .default
        alertHistory = decode([AlertHistoryEntry].self, key: Keys.alertHistory) ?? []
        AppFeedback.soundEnabled = soundEnabled
        AppFeedback.hapticEnabled = hapticEnabled
        refreshOutdoorGoalDayIfNeeded()

        NotificationCenter.default.addObserver(
            forName: .dataReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reloadAfterReset()
        }
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        HapticFeedback.medium()
        SoundPlayer.success()
    }

    func recordSessionCheck() {
        sessionsCompleted += 1
        recordActivity()
        evaluateAchievements()
    }

    func recordItemCreated() {
        itemsCreated += 1
        recordActivity()
        evaluateAchievements()
    }

    func recordActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                streakDays += 1
            } else if diff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = Date()
        evaluateAchievements()
    }

    func markSessionStart() {
        sessionStartedAt = Date()
    }

    func markSessionEnd() {
        guard let start = sessionStartedAt else { return }
        let minutes = max(1, Int(Date().timeIntervalSince(start) / 60.0))
        totalMinutesUsed += minutes
        sessionStartedAt = nil
    }

    func saveAlertPreferences(name: String, sunrise: Bool, sunset: Bool, times: [Date]) {
        alertName = name
        sunriseAlertEnabled = sunrise
        sunsetAlertEnabled = sunset
        alertTimes = times
        let parts = [
            sunrise ? "Sunrise" : nil,
            sunset ? "Sunset" : nil
        ].compactMap { $0 }
        let detail = parts.isEmpty
            ? "Alerts disabled"
            : "\(parts.joined(separator: " · ")) · \(times.count) time(s)"
        alertHistory.insert(
            AlertHistoryEntry(title: name.isEmpty ? "Alert Preferences" : name, detail: detail),
            at: 0
        )
        if alertHistory.count > 50 {
            alertHistory = Array(alertHistory.prefix(50))
        }
        recordItemCreated()
        HapticFeedback.medium()
        SoundPlayer.alertSet()
        evaluateAchievements()
    }

    func addLightDiaryEntry(_ entry: LightDiaryEntry) {
        lightDiary.insert(entry, at: 0)
        recordItemCreated()
    }

    func updateOutdoorGoalTarget(_ minutes: Int) {
        var goal = outdoorGoal
        goal.dailyMinutesTarget = min(180, max(10, minutes))
        outdoorGoal = goal
    }

    func logOutdoorMinutes(_ minutes: Int) {
        refreshOutdoorGoalDayIfNeeded()
        var goal = outdoorGoal
        let before = goal.minutesToday
        goal.minutesToday = before + max(0, minutes)
        goal.lastLogDay = Calendar.current.startOfDay(for: Date())
        if before < goal.dailyMinutesTarget && goal.minutesToday >= goal.dailyMinutesTarget {
            goal.goalStreak += 1
        }
        outdoorGoal = goal
        recordActivity()
        evaluateAchievements()
    }

    func refreshOutdoorGoalDayIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var goal = outdoorGoal
        guard let last = goal.lastLogDay else {
            goal.lastLogDay = today
            outdoorGoal = goal
            return
        }
        let lastDay = calendar.startOfDay(for: last)
        guard lastDay < today else { return }

        let hitTarget = goal.minutesToday >= goal.dailyMinutesTarget
        let dayGap = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        if !hitTarget || dayGap > 1 {
            goal.goalStreak = 0
        }
        goal.minutesToday = 0
        goal.lastLogDay = today
        outdoorGoal = goal
    }

    func addLocation(_ entry: LocationEntry) {
        var enriched = entry
        if enriched.daylightData.isEmpty {
            enriched.daylightData = generateTrend(for: enriched.latitude, longitude: enriched.longitude)
        }
        locations.insert(enriched, at: 0)
        isTrackingEnabled = true
        recordItemCreated()
        HapticFeedback.medium()
        SoundPlayer.alertSet()
    }

    func deleteLocation(id: UUID) {
        locations.removeAll { $0.id == id }
        HapticFeedback.light()
    }

    func syncDaylightInsights() {
        let lat = selectedLatitude
        let lon = selectedLongitude
        var entries: [DaylightEntry] = []
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        for month in 1...12 {
            guard let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else { continue }
            let days = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
            for day in 1...days {
                guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else { continue }
                let hours = SolarCalculator.daylightHours(for: date, latitude: lat, longitude: lon)
                entries.append(DaylightEntry(date: date, durationHours: hours))
            }
        }
        daylightData = entries
        lastSyncDate = Date()
        recordActivity()
        HapticFeedback.medium()
        SoundPlayer.syncDone()
        evaluateAchievements()
    }

    func addNote(_ note: UserNote) {
        userNotes.insert(note, at: 0)
        recordItemCreated()
    }

    func applyPreset(_ city: PresetCity) {
        selectedLatitude = city.latitude
        selectedLongitude = city.longitude
        selectedLocationName = city.name
        HapticFeedback.light()
        SoundPlayer.tick()
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadAfterReset()
        NotificationCenter.default.post(name: .dataReset, object: nil)
        HapticFeedback.warning()
    }

    private func reloadAfterReset() {
        hasSeenOnboarding = false
        sessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        itemsCreated = 0
        achievementsUnlocked = [:]
        sunriseAlertEnabled = false
        sunsetAlertEnabled = false
        alertTimes = []
        alertName = ""
        selectedLatitude = 40.71
        selectedLongitude = -74.01
        selectedLocationName = "New York"
        locations = []
        alertTime = Date()
        isTrackingEnabled = false
        daylightData = []
        lastSyncDate = nil
        userNotes = []
        pendingAchievementBanner = nil
        soundEnabled = true
        hapticEnabled = true
        themeMode = .auto
        lightDiary = []
        outdoorGoal = .default
        alertHistory = []
    }

    func evaluateAchievements() {
        var newly: [String] = []
        func unlock(_ id: String) {
            guard achievementsUnlocked[id] == nil else { return }
            achievementsUnlocked[id] = Date()
            newly.append(id)
        }

        if sessionsCompleted >= 1 { unlock("first_check") }
        if streakDays >= 7 { unlock("consistent_planner") }
        if itemsCreated >= 3 { unlock("early_bird") }
        if itemsCreated >= 1 { unlock("first_step") }
        if itemsCreated >= 10 { unlock("getting_going") }
        if itemsCreated >= 50 { unlock("power_user") }
        if sessionsCompleted >= 10 { unlock("active_user") }
        if sessionsCompleted >= 50 { unlock("dedicated_user") }

        if let first = newly.first, pendingAchievementBanner == nil {
            pendingAchievementBanner = first
            HapticFeedback.success()
            SoundPlayer.success()
            NotificationCenter.default.post(name: .achievementUnlocked, object: first)
        }
    }

    private func generateTrend(for latitude: Double, longitude: Double) -> [DaylightPoint] {
        var points: [DaylightPoint] = []
        let calendar = Calendar.current
        for offset in stride(from: 29, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let hours = SolarCalculator.daylightHours(for: date, latitude: latitude, longitude: longitude)
            points.append(DaylightPoint(date: date, durationHours: hours))
        }
        return points
    }

    private func saveCodable<T: Encodable>(_ value: T, key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private func loadCodable<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}
