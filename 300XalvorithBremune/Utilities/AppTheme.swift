import SwiftUI

struct ThemePalette {
    let topOverlay: Color
    let bottomOverlay: Color
    let glow: Color

    static let dawn = ThemePalette(
        topOverlay: Color(red: 0.95, green: 0.55, blue: 0.35).opacity(0.22),
        bottomOverlay: Color(red: 0.35, green: 0.25, blue: 0.45).opacity(0.35),
        glow: Color(red: 1.0, green: 0.65, blue: 0.35)
    )

    static let noon = ThemePalette(
        topOverlay: Color(red: 0.25, green: 0.55, blue: 0.85).opacity(0.18),
        bottomOverlay: Color(red: 0.10, green: 0.20, blue: 0.35).opacity(0.40),
        glow: Color(red: 0.35, green: 0.75, blue: 0.95)
    )

    static let dusk = ThemePalette(
        topOverlay: Color(red: 0.75, green: 0.30, blue: 0.45).opacity(0.25),
        bottomOverlay: Color(red: 0.15, green: 0.10, blue: 0.28).opacity(0.45),
        glow: Color(red: 0.95, green: 0.45, blue: 0.55)
    )

    static func resolved(mode: AppThemeMode, now: Date, sunrise: Date?, sunset: Date?) -> ThemePalette {
        switch mode {
        case .dawn: return .dawn
        case .noon: return .noon
        case .dusk: return .dusk
        case .auto:
            guard let sunrise, let sunset else { return .noon }
            if now < sunrise.addingTimeInterval(90 * 60) { return .dawn }
            if now > sunset.addingTimeInterval(-90 * 60) { return .dusk }
            return .noon
        }
    }
}

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = ThemePalette.noon
}

extension EnvironmentValues {
    var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}

struct AppScreenBackground: ViewModifier {
    @Environment(\.themePalette) private var palette

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    Color("AppBackground")
                    Image("bgSunrise")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.28)
                    LinearGradient(
                        colors: [palette.topOverlay, palette.bottomOverlay],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .clipped()
                .ignoresSafeArea()
            }
    }
}

enum AppLayout {
    /// Extra space above the tab bar after `safeAreaInset` reserves its height.
    static let tabContentBottomPadding: CGFloat = 24
}

extension View {
    func appScreenBackground() -> some View {
        modifier(AppScreenBackground())
    }
}
