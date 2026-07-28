import SwiftUI

struct DaylightLogView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showAdd = false
    @State private var selectedLocation: LocationEntry?
    @State private var appearIds: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            if store.locations.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(store.locations) { location in
                        Button {
                            HapticFeedback.light()
                            selectedLocation = location
                        } label: {
                            locationRow(location)
                        }
                        .listRowBackground(Color("AppSurface"))
                        .listRowSeparatorTint(Color("AppTextSecondary").opacity(0.3))
                        .opacity(appearIds.contains(location.id) ? 1 : 0)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.35)) {
                                _ = appearIds.insert(location.id)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.deleteLocation(id: location.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }

            Button {
                HapticFeedback.light()
                showAdd = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Location")
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
                        .fill(Color("AppPrimary"))
                        .shadow(color: Color("AppPrimary").opacity(0.4), radius: 10, y: 4)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 100)
        }
        .dismissKeyboardOnTap()
        .sheet(isPresented: $showAdd) {
            AddLocationView()
                .environmentObject(store)
        }
        .sheet(item: $selectedLocation) { location in
            LocationDetailView(location: location)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sunrise.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color("AppAccent"))
            Text("No data yet. Add locations to track daylight changes.")
                .font(.body)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Text("No data yet! Use Add Location to start tracking.")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func locationRow(_ location: LocationEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(location.name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Text(String(format: "%.2f°", location.latitude))
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            MiniDaylightChart(points: location.daylightData)
                .frame(height: 48)
            if let last = location.daylightData.last {
                Text(String(format: "Latest daylight: %.1fh", last.durationHours))
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
            }
        }
        .padding(.vertical, 6)
    }
}

struct LocationDetailView: View {
    let location: LocationEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(location.name)
                        .font(.title.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(String(format: "Latitude %.4f · Longitude %.4f", location.latitude, location.longitude))
                        .foregroundStyle(Color("AppTextSecondary"))

                    MiniDaylightChart(points: location.daylightData)
                        .frame(height: 160)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("AppSurface"))
                        )

                    if let first = location.daylightData.first,
                       let last = location.daylightData.last {
                        let delta = last.durationHours - first.durationHours
                        statRow("30-day change", String(format: "%+.2f hours", delta))
                        statRow("Current length", String(format: "%.2f hours", last.durationHours))
                        let avg = location.daylightData.map(\.durationHours).reduce(0, +) / Double(max(location.daylightData.count, 1))
                        statRow("Average", String(format: "%.2f hours", avg))
                    }
                }
                .padding(16)
            }
            .appScreenBackground()
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func statRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Text(value)
                .foregroundStyle(Color("AppTextPrimary"))
                .fontWeight(.semibold)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color("AppSurface")))
    }
}
