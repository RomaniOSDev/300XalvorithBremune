import SwiftUI

// MARK: - Cards used on Sun tab

struct DaylightDeltaCard: View {
    let delta: DaylightDelta

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daylight Change")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            HStack(spacing: 12) {
                deltaCell("Today", String(format: "%.2fh", delta.todayHours))
                deltaCell("vs Yesterday", signed(delta.yesterdayDelta))
                deltaCell("vs Last Year", signed(delta.yearAgoDelta))
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private func deltaCell(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private func signed(_ value: Double) -> String {
        String(format: "%+.2fh", value)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color("AppSurface"))
            .shadow(color: Color("AppPrimary").opacity(0.2), radius: 8, y: 4)
    }
}

struct GoldenBlueHourCard: View {
    let latitude: Double
    let longitude: Double
    let date: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            let now = timeline.date
            let golden = SolarCalculator.goldenHourWindows(for: date, latitude: latitude, longitude: longitude)
            let blue = SolarCalculator.blueHourWindows(for: date, latitude: latitude, longitude: longitude)
            let next = nextWindow(from: golden + blue, now: now)

            VStack(alignment: .leading, spacing: 12) {
                Text("Golden & Blue Hour")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                if let next {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(next.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color("AppAccent"))
                            Text(SolarCalculator.formatWindow(next))
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Starts in")
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                            Text(SolarCalculator.countdownText(to: next.start, from: now))
                                .font(.title3.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                } else {
                    Text("No golden/blue windows for this date.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                ForEach((golden + blue).prefix(4)) { window in
                    HStack {
                        Text(window.title)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                        Text(SolarCalculator.formatWindow(window))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("AppSurface"))
            )
        }
    }

    private func nextWindow(from windows: [LightWindow], now: Date) -> LightWindow? {
        windows
            .filter { $0.end > now }
            .sorted { $0.start < $1.start }
            .first
    }
}

struct OutdoorPlannerCard: View {
    let slots: [LightWindow]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Outdoor Planner")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            if slots.isEmpty {
                Text("No daylight slots available for this date.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            } else {
                ForEach(slots) { slot in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: icon(for: slot.id))
                            .foregroundStyle(Color("AppAccent"))
                            .frame(width: 22)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(slot.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(SolarCalculator.formatWindow(slot))
                                .font(.caption)
                                .foregroundStyle(Color("AppAccent"))
                            Text(slot.detail)
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("AppSurface"))
        )
    }

    private func icon(for id: String) -> String {
        switch id {
        case "slot-morning": return "sunrise.fill"
        case "slot-day": return "sun.max.fill"
        default: return "sunset.fill"
        }
    }
}

struct ActivityPresetsCard: View {
    let date: Date
    let latitude: Double
    let longitude: Double
    @State private var selected: ActivityPreset = .hiking

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Presets")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))

            HStack(spacing: 8) {
                ForEach(ActivityPreset.allCases) { preset in
                    Button {
                        HapticFeedback.light()
                        selected = preset
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: preset.symbol)
                            Text(preset.title)
                                .font(.caption2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .foregroundStyle(selected == preset ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected == preset ? Color("AppPrimary") : Color("AppBackground").opacity(0.6))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if let window = SolarCalculator.recommendedWindow(
                for: selected,
                date: date,
                latitude: latitude,
                longitude: longitude
            ) {
                Text(selected.blurb)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(window.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                Text(SolarCalculator.formatWindow(window))
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            } else {
                Text("No recommended window for this date.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("AppSurface"))
        )
    }
}

struct SolarEventsCard: View {
    let events: [SolarEventItem]
    let polarNote: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Solar Events")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))

            if let polarNote {
                Text(polarNote)
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("AppPrimary").opacity(0.25))
                    )
            }

            ForEach(events) { event in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(event.detail)
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    Text(event.date, style: .date)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("AppSurface"))
        )
    }
}

// MARK: - Location Compare

struct LocationCompareView: View {
    @State private var leftID: String = PresetCity.all[0].id
    @State private var rightID: String = PresetCity.all[1].id

    private var cities: [PresetCity] { PresetCity.all }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                pickerRow(title: "Location A", selection: $leftID)
                pickerRow(title: "Location B", selection: $rightID)

                if let left = city(leftID), let right = city(rightID) {
                    comparison(left: left, right: right)
                }
            }
            .padding(16)
            .padding(.bottom, 110)
        }
        .dismissKeyboardOnTap()
    }

    private func pickerRow(title: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Picker(title, selection: selection) {
                ForEach(cities) { city in
                    Text(city.name).tag(city.id)
                }
            }
            .pickerStyle(.menu)
            .tint(Color("AppAccent"))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color("AppSurface")))
        }
    }

    private func city(_ id: String) -> PresetCity? {
        cities.first { $0.id == id }
    }

    private func comparison(left: PresetCity, right: PresetCity) -> some View {
        let date = Date()
        let leftTimes = SolarCalculator.sunTimes(for: date, latitude: left.latitude, longitude: left.longitude)
        let rightTimes = SolarCalculator.sunTimes(for: date, latitude: right.latitude, longitude: right.longitude)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return VStack(spacing: 12) {
            HStack {
                Text(left.name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(maxWidth: .infinity)
                Text("vs")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(right.name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(maxWidth: .infinity)
            }

            metricRow(
                "Sunrise",
                leftTimes.map { formatter.string(from: $0.sunrise) } ?? "--",
                rightTimes.map { formatter.string(from: $0.sunrise) } ?? "--"
            )
            metricRow(
                "Sunset",
                leftTimes.map { formatter.string(from: $0.sunset) } ?? "--",
                rightTimes.map { formatter.string(from: $0.sunset) } ?? "--"
            )
            metricRow(
                "Daylight",
                leftTimes.map { String(format: "%.2fh", $0.daylightHours) } ?? "--",
                rightTimes.map { String(format: "%.2fh", $0.daylightHours) } ?? "--"
            )

            if let l = leftTimes, let r = rightTimes {
                let diff = l.daylightHours - r.daylightHours
                Text(String(format: "%@ has %+.2fh daylight vs %@", left.name, diff, right.name))
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color("AppSurface")))
    }

    private func metricRow(_ title: String, _ left: String, _ right: String) -> some View {
        HStack {
            Text(left)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppAccent"))
                .frame(maxWidth: .infinity)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Text(right)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppAccent"))
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Light Diary

struct LightDiaryView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var draft = ""
    @State private var mood: MoodLevel = .okay
    @State private var energy = 3

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How did the light feel?")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))

                    TextField("Short note", text: $draft, axis: .vertical)
                        .lineLimit(3...5)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color("AppBackground").opacity(0.55)))
                        .foregroundStyle(Color("AppTextPrimary"))

                    Text("Mood")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    HStack {
                        ForEach(MoodLevel.allCases) { level in
                            Button {
                                mood = level
                                HapticFeedback.light()
                            } label: {
                                Image(systemName: level.symbol)
                                    .foregroundStyle(mood == level ? Color("AppAccent") : Color("AppTextSecondary"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(mood == level ? Color("AppPrimary").opacity(0.35) : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Stepper(value: $energy, in: 1...5) {
                        Text("Energy \(energy)/5")
                            .foregroundStyle(Color("AppTextPrimary"))
                    }

                    Button {
                        save()
                    } label: {
                        Text("Save Diary Entry")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color("AppPrimary")))
                    }
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("AppSurface")))

                if store.lightDiary.isEmpty {
                    Text("No diary entries yet.")
                        .foregroundStyle(Color("AppTextSecondary"))
                        .padding(.top, 12)
                } else {
                    ForEach(store.lightDiary) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: entry.mood.symbol)
                                    .foregroundStyle(Color("AppAccent"))
                                Text(entry.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Spacer()
                                Text(String(format: "%.1fh light", entry.daylightHours))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color("AppAccent"))
                            }
                            Text(entry.content)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Mood \(entry.mood.title) · Energy \(entry.energy)/5")
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color("AppSurface")))
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 110)
        }
        .dismissKeyboardOnTap()
    }

    private func save() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            HapticFeedback.warning()
            return
        }
        let hours = SolarCalculator.daylightHours(
            for: Date(),
            latitude: store.selectedLatitude,
            longitude: store.selectedLongitude
        )
        store.addLightDiaryEntry(
            LightDiaryEntry(content: text, mood: mood, energy: energy, daylightHours: hours)
        )
        draft = ""
        HapticFeedback.success()
        SoundPlayer.success()
    }
}

// MARK: - Outdoor Goals

struct OutdoorGoalsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var addMinutes = 15

    var body: some View {
        let goal = store.outdoorGoal
        let progress = min(1, Double(goal.minutesToday) / Double(max(goal.dailyMinutesTarget, 1)))

        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 16) {
                    NeonProgressRing(progress: progress, lineWidth: 12)
                        .frame(width: 120, height: 120)
                        .overlay {
                            VStack(spacing: 2) {
                                Text("\(goal.minutesToday)")
                                    .font(.title.bold())
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text("/ \(goal.dailyMinutesTarget)m")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }

                    Text("Outdoor light goal")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Streak \(goal.goalStreak) days")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("AppSurface")))

                Stepper("Goal \(store.outdoorGoal.dailyMinutesTarget) min/day", value: Binding(
                    get: { store.outdoorGoal.dailyMinutesTarget },
                    set: { store.updateOutdoorGoalTarget($0) }
                ), in: 10...180, step: 5)
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color("AppSurface")))
                .foregroundStyle(Color("AppTextPrimary"))

                Stepper("Log \(addMinutes) minutes", value: $addMinutes, in: 5...120, step: 5)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color("AppSurface")))
                    .foregroundStyle(Color("AppTextPrimary"))

                Button {
                    store.logOutdoorMinutes(addMinutes)
                    HapticFeedback.medium()
                    SoundPlayer.tick()
                } label: {
                    Text("Add Outdoor Time")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                }
            }
            .padding(16)
            .padding(.bottom, 40)
        }
        .dismissKeyboardOnTap()
    }
}

// MARK: - Alert History

struct AlertHistoryView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.alertHistory.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 40))
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text("No alert history yet.")
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text("Saved alert preferences will appear here.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.alertHistory) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.title)
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text(entry.detail)
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(Color("AppAccent"))
                            }
                            .listRowBackground(Color("AppSurface"))
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .appScreenBackground()
            .navigationTitle("Alert History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
