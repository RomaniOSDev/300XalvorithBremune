import SwiftUI

struct AlertsPrefsView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @Binding var showSuccess: Bool

    @State private var name: String = ""
    @State private var sunriseEnabled = false
    @State private var sunsetEnabled = false
    @State private var sunriseOffset = Date()
    @State private var sunsetOffset = Date()
    @State private var nameError = ""
    @State private var shakeName = 0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("In-app alert preferences only. No push notifications are sent.")
                        .font(.footnote)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                Section("Alert Name") {
                    TextField("Name", text: $name)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .modifier(ShakeEffect(animatableData: CGFloat(shakeName)))
                    if !nameError.isEmpty {
                        Text(nameError)
                            .font(.caption)
                            .foregroundStyle(Color.red)
                    }
                }

                Section("Preferences") {
                    Toggle("Sunrise Alert", isOn: $sunriseEnabled)
                        .tint(Color("AppPrimary"))
                    if sunriseEnabled {
                        DatePicker("Preferred time", selection: $sunriseOffset, displayedComponents: .hourAndMinute)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    Toggle("Sunset Alert", isOn: $sunsetEnabled)
                        .tint(Color("AppPrimary"))
                    if sunsetEnabled {
                        DatePicker("Preferred time", selection: $sunsetOffset, displayedComponents: .hourAndMinute)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }

                Section {
                    Button {
                        save()
                    } label: {
                        Text("Save Alerts")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppPrimary"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .dismissKeyboardOnTap()
            .keyboardDoneToolbar()
            .navigationTitle("Alerts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                name = store.alertName
                sunriseEnabled = store.sunriseAlertEnabled
                sunsetEnabled = store.sunsetAlertEnabled
                if let first = store.alertTimes.first {
                    sunriseOffset = first
                }
                if store.alertTimes.count > 1 {
                    sunsetOffset = store.alertTimes[1]
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty && (sunriseEnabled || sunsetEnabled) {
            nameError = "Give this alert preference a name."
            HapticFeedback.warning()
            withAnimation { shakeName += 1 }
            return
        }
        nameError = ""
        var times: [Date] = []
        if sunriseEnabled { times.append(sunriseOffset) }
        if sunsetEnabled { times.append(sunsetOffset) }
        store.saveAlertPreferences(
            name: trimmed,
            sunrise: sunriseEnabled,
            sunset: sunsetEnabled,
            times: times
        )
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccess = true
        }
        dismiss()
    }
}
