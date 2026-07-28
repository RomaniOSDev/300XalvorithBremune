import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    private let monthLabels = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    metricsGrid

                    chartCard(
                        title: "Daylight by Month",
                        subtitle: monthlyAverages.isEmpty
                            ? "Sync Insight data to populate this chart"
                            : "Average hours of daylight"
                    ) {
                        if monthlyAverages.isEmpty {
                            emptyChartHint("No yearly daylight data yet")
                        } else {
                            BarChartView(values: monthlyAverages, labels: monthLabels)
                                .frame(height: 160)
                        }
                    }

                    chartCard(
                        title: "30-Day Daylight Trend",
                        subtitle: trendTitle
                    ) {
                        if trendPoints.count > 1 {
                            MiniDaylightChart(points: trendPoints)
                                .frame(height: 140)
                        } else {
                            emptyChartHint("Add a location to see a 30-day trend")
                        }
                    }

                    chartCard(
                        title: "Locations Snapshot",
                        subtitle: store.locations.isEmpty
                            ? "No tracked locations"
                            : "Current daylight hours"
                    ) {
                        if locationBars.isEmpty {
                            emptyChartHint("Track locations in Daylight Log")
                        } else {
                            BarChartView(
                                values: locationBars.map(\.1),
                                labels: locationBars.map(\.0)
                            )
                            .frame(height: 150)
                        }
                    }

                    chartCard(title: "Achievements", subtitle: "Unlock progress") {
                        HStack(spacing: 20) {
                            NeonProgressRing(progress: achievementProgress, lineWidth: 10)
                                .frame(width: 88, height: 88)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(store.achievementsUnlocked.count) / \(AchievementDef.all.count)")
                                    .font(.title2.bold())
                                    .foregroundStyle(Color("AppAccent"))
                                Text("badges unlocked")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Text("Streak \(store.streakDays) days")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .appScreenBackground()
            .dismissKeyboardOnTap()
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricTile("Sessions", "\(store.sessionsCompleted)", "play.circle.fill")
            metricTile("Minutes", "\(store.totalMinutesUsed)", "clock.fill")
            metricTile("Streak", "\(store.streakDays)", "flame.fill")
            metricTile("Items", "\(store.itemsCreated)", "square.stack.3d.up.fill")
            metricTile("Locations", "\(store.locations.count)", "mappin.and.ellipse")
            metricTile("Notes", "\(store.userNotes.count)", "note.text")
        }
    }

    private func metricTile(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color("AppAccent"))
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("AppSurface"))
        )
    }

    private func chartCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("AppSurface"))
                .shadow(color: Color("AppPrimary").opacity(0.18), radius: 10, y: 4)
        )
    }

    private func emptyChartHint(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity, minHeight: 100)
            .multilineTextAlignment(.center)
    }

    private var monthlyAverages: [Double] {
        guard !store.daylightData.isEmpty else { return [] }
        return (1...12).map { month in
            let entries = store.daylightData.filter { $0.month == month }
            guard !entries.isEmpty else { return 0 }
            return entries.map(\.durationHours).reduce(0, +) / Double(entries.count)
        }
    }

    private var trendPoints: [DaylightPoint] {
        if let first = store.locations.first, first.daylightData.count > 1 {
            return first.daylightData
        }
        let lat = store.selectedLatitude
        let lon = store.selectedLongitude
        let calendar = Calendar.current
        return (0..<30).reversed().compactMap { offset -> DaylightPoint? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let hours = SolarCalculator.daylightHours(for: date, latitude: lat, longitude: lon)
            return DaylightPoint(date: date, durationHours: hours)
        }
    }

    private var trendTitle: String {
        if let name = store.locations.first?.name {
            return name
        }
        return store.selectedLocationName
    }

    private var locationBars: [(String, Double)] {
        store.locations.prefix(6).map { location in
            let hours = location.daylightData.last?.durationHours
                ?? SolarCalculator.daylightHours(
                    for: Date(),
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            let short = String(location.name.prefix(6))
            return (short, hours)
        }
    }

    private var achievementProgress: Double {
        guard !AchievementDef.all.isEmpty else { return 0 }
        return Double(store.achievementsUnlocked.count) / Double(AchievementDef.all.count)
    }
}
