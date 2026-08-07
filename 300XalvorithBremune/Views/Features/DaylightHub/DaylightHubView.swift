import SwiftUI

struct DaylightHubView: View {
    @State private var segment = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScreenHeader(title: "Daylight")

                Picker("Section", selection: $segment) {
                    Text("Log").tag(0)
                    Text("Insight").tag(1)
                    Text("Compare").tag(2)
                    Text("Diary").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                Group {
                    switch segment {
                    case 0:
                        DaylightLogView()
                    case 1:
                        DaylightInsightView()
                    case 2:
                        LocationCompareView()
                    default:
                        LightDiaryView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .appScreenBackground()
            .dismissKeyboardOnTap()
            .navigationBarHidden(true)
        }
    }
}
