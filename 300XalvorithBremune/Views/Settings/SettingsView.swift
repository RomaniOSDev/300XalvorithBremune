import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetConfirm = false
    @State private var showStatistics = false
    @State private var showGoals = false
    @State private var showAlertHistory = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenHeader(title: "Settings")

                    feedbackCard

                    themeCard

                    Button {
                        HapticFeedback.light()
                        showStatistics = true
                    } label: {
                        statsCard
                    }
                    .buttonStyle(.plain)

                    settingsRow(
                        title: "Outdoor Goals",
                        icon: "figure.walk",
                        tint: Color("AppAccent")
                    ) {
                        showGoals = true
                    }

                    settingsRow(
                        title: "Alert History",
                        icon: "bell.badge",
                        tint: Color("AppPrimary")
                    ) {
                        showAlertHistory = true
                    }

                    settingsRow(
                        title: "Rate Us",
                        icon: "star.fill",
                        tint: Color("AppAccent")
                    ) {
                        requestReview()
                    }

                    settingsRow(
                        title: "Privacy Policy",
                        icon: "hand.raised.fill",
                        tint: Color("AppPrimary")
                    ) {
                        openURL(AppLinks.privacy)
                    }

                    settingsRow(
                        title: "Terms of Use",
                        icon: "doc.text.fill",
                        tint: Color("AppPrimary")
                    ) {
                        openURL(AppLinks.terms)
                    }

                    Button {
                        HapticFeedback.light()
                        showResetConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Reset All Data")
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                        }
                        .foregroundStyle(Color.red)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color("AppSurface"))
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
            .appScreenBackground()
            .dismissKeyboardOnTap()
            .navigationBarHidden(true)
            .sheet(isPresented: $showStatistics) {
                StatisticsView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showGoals) {
                NavigationStack {
                    OutdoorGoalsView()
                        .environmentObject(store)
                        .navigationTitle("Outdoor Goals")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") { showGoals = false }
                                    .foregroundStyle(Color("AppPrimary"))
                            }
                        }
                        .appScreenBackground()
                }
                .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showAlertHistory) {
                AlertHistoryView()
                    .environmentObject(store)
            }
            .alert("Reset All Data?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This clears all preferences, locations, insights, and achievements.")
            }
        }
    }

    private var feedbackCard: some View {
        VStack(spacing: 0) {
            if AppFeedback.hasSoundEffects {
                Toggle(isOn: $store.soundEnabled) {
                    Label {
                        Text("Sound")
                            .foregroundStyle(Color("AppTextPrimary"))
                    } icon: {
                        Image(systemName: store.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                .tint(Color("AppPrimary"))
                .padding(16)
                .onChange(of: store.soundEnabled) { enabled in
                    if enabled { SoundPlayer.tick() }
                }

                Divider()
                    .background(Color("AppTextSecondary").opacity(0.3))
                    .padding(.leading, 16)
            }

            Toggle(isOn: $store.hapticEnabled) {
                Label {
                    Text("Haptic Feedback")
                        .foregroundStyle(Color("AppTextPrimary"))
                } icon: {
                    Image(systemName: "waveform")
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .tint(Color("AppPrimary"))
            .padding(16)
            .onChange(of: store.hapticEnabled) { enabled in
                if enabled { HapticFeedback.medium() }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("AppSurface"))
        )
        .padding(.horizontal, 16)
    }

    private var themeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appearance")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            Text("Dawn / Noon / Dusk palettes")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Picker("Theme", selection: $store.themeMode) {
                ForEach(AppThemeMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: store.themeMode) { _ in
                HapticFeedback.light()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("AppSurface"))
        )
        .padding(.horizontal, 16)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Statistics")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Text("Open")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
            }
            HStack {
                statCell("Sessions", "\(store.sessionsCompleted)")
                statCell("Minutes", "\(store.totalMinutesUsed)")
                statCell("Streak", "\(store.streakDays)")
            }
            HStack {
                statCell("Items", "\(store.itemsCreated)")
                statCell("Locations", "\(store.locations.count)")
                statCell("Badges", "\(store.achievementsUnlocked.count)")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("AppSurface"))
                .shadow(color: Color("AppPrimary").opacity(0.2), radius: 10, y: 4)
        )
        .padding(.horizontal, 16)
    }

    private func statCell(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color("AppAccent"))
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }

    private func settingsRow(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                    .frame(width: 28)
                Text(title)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color("AppSurface"))
            )
        }
        .padding(.horizontal, 16)
    }

    private func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
                ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        else { return }
        SKStoreReviewController.requestReview(in: scene)
        HapticFeedback.success()
    }
}
