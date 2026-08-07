import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenHeader(title: "Achievements")

                    metricsCard

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AchievementDef.all) { def in
                            achievementCard(def)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, AppLayout.tabContentBottomPadding)
                }
            }
            .appScreenBackground()
            .dismissKeyboardOnTap()
            .navigationBarHidden(true)
        }
    }

    private var metricsCard: some View {
        HStack(spacing: 0) {
            metric("Sessions", "\(store.sessionsCompleted)")
            Divider().frame(height: 40).overlay(Color("AppTextSecondary").opacity(0.4))
            metric("Streak", "\(store.streakDays)d")
            Divider().frame(height: 40).overlay(Color("AppTextSecondary").opacity(0.4))
            metric("Items", "\(store.itemsCreated)")
            Divider().frame(height: 40).overlay(Color("AppTextSecondary").opacity(0.4))
            metric("Unlocked", "\(store.achievementsUnlocked.count)/8")
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("AppSurface"))
                .shadow(color: Color("AppPrimary").opacity(0.25), radius: 10, y: 4)
        )
        .padding(.horizontal, 16)
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }

    private func achievementCard(_ def: AchievementDef) -> some View {
        let unlocked = store.achievementsUnlocked[def.id] != nil
        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(unlocked ? Color("AppPrimary").opacity(0.25) : Color("AppBackground"))
                    .frame(width: 56, height: 56)
                Image(systemName: def.symbol)
                    .font(.title2)
                    .foregroundStyle(unlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.45))
            }
            Text(def.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(unlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(def.detail)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("AppSurface"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(unlocked ? Color("AppAccent").opacity(0.45) : Color.clear, lineWidth: 1)
                )
                .shadow(color: unlocked ? Color("AppAccent").opacity(0.2) : .clear, radius: 8, y: 2)
        )
        .opacity(unlocked ? 1 : 0.72)
    }
}
