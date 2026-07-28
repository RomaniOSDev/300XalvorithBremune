import Foundation

struct AchievementDef: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String

    static let all: [AchievementDef] = [
        AchievementDef(
            id: "first_check",
            title: "First Check",
            detail: "Checked sunrise or sunset time once.",
            symbol: "sun.max.fill"
        ),
        AchievementDef(
            id: "consistent_planner",
            title: "Consistent Planner",
            detail: "Checked sun times every day for a week.",
            symbol: "calendar"
        ),
        AchievementDef(
            id: "early_bird",
            title: "Early Bird",
            detail: "Set an alert for sunrise three days in a row.",
            symbol: "alarm.fill"
        ),
        AchievementDef(
            id: "first_step",
            title: "First Step",
            detail: "Created your first item.",
            symbol: "flag.fill"
        ),
        AchievementDef(
            id: "getting_going",
            title: "Getting Going",
            detail: "Reached 10 items.",
            symbol: "flame.fill"
        ),
        AchievementDef(
            id: "power_user",
            title: "Power User",
            detail: "Reached 50 items.",
            symbol: "bolt.fill"
        ),
        AchievementDef(
            id: "active_user",
            title: "Active User",
            detail: "Completed 10 sessions.",
            symbol: "figure.walk"
        ),
        AchievementDef(
            id: "dedicated_user",
            title: "Dedicated User",
            detail: "Completed 50 sessions.",
            symbol: "star.fill"
        )
    ]
}
