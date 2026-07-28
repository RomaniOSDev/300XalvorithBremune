import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject private var store = AppDataStore.shared

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
        .modifier(ThemeEnvironmentBinder(store: store))
    }
}

private struct ThemeEnvironmentBinder: ViewModifier {
    @ObservedObject var store: AppDataStore
    @State private var palette = ThemePalette.noon

    func body(content: Content) -> some View {
        content
            .environment(\.themePalette, palette)
            .onAppear(perform: refresh)
            .onChange(of: store.themeMode) { _ in refresh() }
            .onChange(of: store.selectedLatitude) { _ in refresh() }
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
                refresh()
            }
    }

    private func refresh() {
        let now = Date()
        let times = SolarCalculator.sunTimes(
            for: now,
            latitude: store.selectedLatitude,
            longitude: store.selectedLongitude
        )
        palette = ThemePalette.resolved(
            mode: store.themeMode,
            now: now,
            sunrise: times?.sunrise,
            sunset: times?.sunset
        )
    }
}
