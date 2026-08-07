import SwiftUI

struct SunriseSunsetView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = SunriseSunsetViewModel()
    @State private var showAlerts = false
    @State private var showLocationPicker = false
    @State private var latitudeText = ""
    @State private var shakeLatitude = 0
    @State private var latitudeError = ""
    @State private var showSuccess = false
    @State private var didRecordSession = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let dialSize = min(240, max(180, min(geo.size.width - 48, geo.size.height * 0.32)))

                ScrollView {
                    VStack(spacing: 0) {
                        heroHeader

                        VStack(spacing: 18) {
                            locationChip
                            dateNavigator
                            sunDialSection(size: dialSize)
                            timesRow
                            DaylightDeltaCard(
                                delta: SolarCalculator.daylightDelta(
                                    for: viewModel.selectedDate,
                                    latitude: store.selectedLatitude,
                                    longitude: store.selectedLongitude
                                )
                            )
                            GoldenBlueHourCard(
                                latitude: store.selectedLatitude,
                                longitude: store.selectedLongitude,
                                date: viewModel.selectedDate
                            )
                            OutdoorPlannerCard(
                                slots: SolarCalculator.outdoorPlannerSlots(
                                    for: viewModel.selectedDate,
                                    latitude: store.selectedLatitude,
                                    longitude: store.selectedLongitude
                                )
                            )
                            ActivityPresetsCard(
                                date: viewModel.selectedDate,
                                latitude: store.selectedLatitude,
                                longitude: store.selectedLongitude
                            )
                            SolarEventsCard(
                                events: SolarCalculator.upcomingSolarEvents(
                                    from: Date(),
                                    latitude: store.selectedLatitude
                                ),
                                polarNote: SolarCalculator.polarStatus(
                                    for: viewModel.selectedDate,
                                    latitude: store.selectedLatitude,
                                    longitude: store.selectedLongitude
                                )
                            )
                            alertsButton
                            emptyGuidance
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, AppLayout.tabContentBottomPadding)
                    }
                }
            }
            .appScreenBackground()
            .dismissKeyboardOnTap()
            .navigationBarHidden(true)
            .sheet(isPresented: $showAlerts) {
                AlertsPrefsView(showSuccess: $showSuccess)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showLocationPicker) {
                locationPickerSheet
            }
            .overlay {
                SuccessPulse(visible: $showSuccess)
            }
            .onAppear {
                viewModel.refresh(latitude: store.selectedLatitude, longitude: store.selectedLongitude)
                if !didRecordSession {
                    store.recordSessionCheck()
                    didRecordSession = true
                }
            }
            .onChange(of: viewModel.selectedDate) { _ in
                viewModel.refresh(latitude: store.selectedLatitude, longitude: store.selectedLongitude)
            }
            .onChange(of: store.selectedLatitude) { _ in
                viewModel.refresh(latitude: store.selectedLatitude, longitude: store.selectedLongitude)
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    viewModel.refresh(latitude: store.selectedLatitude, longitude: store.selectedLongitude)
                }
            }
        }
    }

    private var heroHeader: some View {
        ScreenHeader(
            title: "Sunrise · Sunset",
            subtitle: "Plan outdoor time around daylight"
        )
    }

    private var locationChip: some View {
        Button {
            HapticFeedback.light()
            latitudeText = String(format: "%.2f", store.selectedLatitude)
            showLocationPicker = true
        } label: {
            HStack {
                Image(systemName: "globe.americas.fill")
                    .foregroundStyle(Color("AppAccent"))
                Text(store.selectedLocationName)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Text(String(format: "%.2f°", store.selectedLatitude))
                    .foregroundStyle(Color("AppTextSecondary"))
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color("AppSurface"))
                    .shadow(color: Color.black.opacity(0.25), radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
    }

    private var dateNavigator: some View {
        HStack {
            Button {
                HapticFeedback.light()
                SoundPlayer.tick()
                viewModel.shiftDay(-1)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(viewModel.dateLabel())
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Spacer()

            Button {
                HapticFeedback.light()
                SoundPlayer.tick()
                viewModel.shiftDay(1)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(width: 44, height: 44)
            }
        }
    }

    private func sunDialSection(size: CGFloat) -> some View {
        TimelineView(.periodic(from: .now, by: scenePhase == .active ? 60 : 3600)) { timeline in
            let snapshot = dialSnapshot(at: timeline.date)
            SunDialView(
                progress: snapshot.progress,
                sunriseLabel: snapshot.sunrise,
                sunsetLabel: snapshot.sunset,
                size: size
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }

    private func dialSnapshot(at now: Date) -> (progress: Double, sunrise: String, sunset: String) {
        guard let times = SolarCalculator.sunTimes(
            for: viewModel.selectedDate,
            latitude: store.selectedLatitude,
            longitude: store.selectedLongitude
        ) else {
            return (0, "--:--", "--:--")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let calendar = Calendar.current
        let progress: Double
        if calendar.isDateInToday(viewModel.selectedDate) {
            progress = SolarCalculator.daylightProgress(now: now, sunrise: times.sunrise, sunset: times.sunset)
        } else if viewModel.selectedDate < calendar.startOfDay(for: now) {
            progress = 1
        } else {
            progress = 0
        }
        return (progress, formatter.string(from: times.sunrise), formatter.string(from: times.sunset))
    }

    private var timesRow: some View {
        HStack(spacing: 10) {
            timeCard(title: "Sunrise", value: viewModel.sunriseText, icon: "sunrise.fill")
            timeCard(title: "Sunset", value: viewModel.sunsetText, icon: "sunset.fill")
            timeCard(title: "Daylight", value: viewModel.daylightText, icon: "sun.max.fill")
        }
    }

    private func timeCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color("AppAccent"))
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .padding(.horizontal, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("AppSurface"))
                .shadow(color: Color("AppPrimary").opacity(0.2), radius: 8, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }

    private var alertsButton: some View {
        Button {
            HapticFeedback.light()
            showAlerts = true
        } label: {
            HStack {
                Image(systemName: "bell.badge.fill")
                Text("Alerts")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.headline)
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color("AppPrimary").opacity(0.45), radius: 10, y: 4)
            )
        }
    }

    @ViewBuilder
    private var emptyGuidance: some View {
        if !store.sunriseAlertEnabled && !store.sunsetAlertEnabled {
            VStack(spacing: 12) {
                Image(systemName: "sun.max")
                    .font(.system(size: 40))
                    .foregroundStyle(Color("AppAccent"))
                Text("Start tracking your days by setting alerts for the first time.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                Text("Set your first alert to start tracking.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("AppSurface").opacity(0.7))
            )
        }
    }

    private var locationPickerSheet: some View {
        NavigationStack {
            Form {
                Section("Preset Cities") {
                    ForEach(PresetCity.all) { city in
                        Button {
                            store.applyPreset(city)
                            showLocationPicker = false
                        } label: {
                            HStack {
                                Text(city.name)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                                Text(String(format: "%.1f°", city.latitude))
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                    }
                }

                Section("Custom Latitude") {
                    TextField("Latitude (-90 to 90)", text: $latitudeText)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .modifier(ShakeEffect(animatableData: CGFloat(shakeLatitude)))
                    if !latitudeError.isEmpty {
                        Text(latitudeError)
                            .font(.caption)
                            .foregroundStyle(Color.red)
                    }
                    Button("Apply Latitude") {
                        applyCustomLatitude()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .dismissKeyboardOnTap()
            .keyboardDoneToolbar()
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        showLocationPicker = false
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func applyCustomLatitude() {
        guard let lat = Double(latitudeText.trimmingCharacters(in: .whitespaces)),
              lat >= -90, lat <= 90 else {
            latitudeError = "Enter a valid latitude between -90 and 90."
            HapticFeedback.warning()
            withAnimation { shakeLatitude += 1 }
            return
        }
        latitudeError = ""
        store.selectedLatitude = lat
        store.selectedLongitude = 0
        store.selectedLocationName = String(format: "Lat %.2f°", lat)
        HapticFeedback.medium()
        SoundPlayer.tick()
        showLocationPicker = false
    }
}
