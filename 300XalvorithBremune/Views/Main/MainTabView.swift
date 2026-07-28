import SwiftUI

enum AppTab: Int, CaseIterable {
    case sun
    case daylight
    case achievements
    case settings

    var title: String {
        switch self {
        case .sun: return "Sun"
        case .daylight: return "Daylight"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .sun: return "sun.max.fill"
        case .daylight: return "chart.xyaxis.line"
        case .achievements: return "trophy.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct GlassTabBar: View {
    @Binding var selected: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Button {
                    HapticFeedback.light()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selected = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(selected == tab ? Color("AppPrimary") : Color("AppTextSecondary"))
                            .scaleEffect(selected == tab ? 1.0 : 0.95)
                        Text(tab.title)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(selected == tab ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Circle()
                            .fill(selected == tab ? Color("AppAccent") : Color.clear)
                            .frame(width: 6, height: 6)
                            .shadow(color: selected == tab ? Color("AppAccent").opacity(0.8) : .clear, radius: 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("AppSurface").opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [Color("AppPrimary").opacity(0.35), Color("AppAccent").opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.35), radius: 16, y: -2)
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selected: AppTab = .sun
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selected {
                case .sun:
                    SunriseSunsetView()
                case .daylight:
                    DaylightHubView()
                case .achievements:
                    AchievementsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            GlassTabBar(selected: $selected)

            AchievementBannerOverlay(
                achievementId: $store.pendingAchievementBanner,
                definitions: AchievementDef.all
            )
            .padding(.top, 48)
        }
        .ignoresSafeArea(.keyboard)
        .dismissKeyboardOnTap()
        .onAppear {
            store.markSessionStart()
            store.refreshOutdoorGoalDayIfNeeded()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                store.markSessionStart()
            } else if phase == .background {
                store.markSessionEnd()
            }
        }
    }
}
