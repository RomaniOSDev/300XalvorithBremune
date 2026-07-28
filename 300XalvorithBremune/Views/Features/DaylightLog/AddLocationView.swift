import SwiftUI

struct AddLocationView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var latitudeText = ""
    @State private var selectedPreset: PresetCity?
    @State private var nameError = ""
    @State private var latError = ""
    @State private var shakeName = 0
    @State private var shakeLat = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Location name", text: $name)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .modifier(ShakeEffect(animatableData: CGFloat(shakeName)))
                    if !nameError.isEmpty {
                        Text(nameError)
                            .font(.caption)
                            .foregroundStyle(Color.red)
                    }
                }

                Section("Preset") {
                    ForEach(PresetCity.all) { city in
                        Button {
                            selectedPreset = city
                            name = city.name
                            latitudeText = String(format: "%.2f", city.latitude)
                            HapticFeedback.light()
                        } label: {
                            HStack {
                                Text(city.name)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                                if selectedPreset?.id == city.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color("AppAccent"))
                                }
                            }
                        }
                    }
                }

                Section("Latitude") {
                    TextField("Latitude", text: $latitudeText)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .modifier(ShakeEffect(animatableData: CGFloat(shakeLat)))
                    if !latError.isEmpty {
                        Text(latError)
                            .font(.caption)
                            .foregroundStyle(Color.red)
                    }
                }

                Section {
                    Button("Add Location") { add() }
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color("AppPrimary"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .dismissKeyboardOnTap()
            .keyboardDoneToolbar()
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func add() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        var ok = true
        if trimmed.isEmpty {
            nameError = "Enter a location name."
            withAnimation { shakeName += 1 }
            ok = false
        } else {
            nameError = ""
        }
        let lat: Double
        if let preset = selectedPreset, latitudeText.isEmpty {
            lat = preset.latitude
        } else if let value = Double(latitudeText.trimmingCharacters(in: .whitespaces)),
                  value >= -90, value <= 90 {
            lat = value
            latError = ""
        } else {
            latError = "Enter latitude between -90 and 90."
            withAnimation { shakeLat += 1 }
            ok = false
            lat = 0
        }
        guard ok else {
            HapticFeedback.warning()
            return
        }
        let lon = selectedPreset?.longitude ?? 0
        let entry = LocationEntry(name: trimmed, latitude: lat, longitude: lon)
        store.addLocation(entry)
        dismiss()
    }
}
